#!/usr/bin/env python3
"""Normalize heterogeneous source registries for design-system reverse engineering.

Input CSV minimum columns:
- source_type
- source_locator

Optional columns:
- source_section
- evidence_level
- priority
- notes

Output files:
- normalized.csv (all rows with status)
- duplicates.csv (duplicate rows)
- invalid.csv (invalid rows)
- summary.json (counts)
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
from pathlib import Path, PurePosixPath
from typing import Dict, Optional, Tuple
from urllib.parse import parse_qs, quote, unquote, urlencode, urlparse, urlunparse

SUPPORTED_SOURCE_TYPES = {"code", "figma", "notion", "doc", "api", "other"}

OUTPUT_COLUMNS = [
    "source_row",
    "source_type",
    "source_locator_raw",
    "source_locator_normalized",
    "source_section",
    "evidence_level",
    "priority",
    "notes",
    "canonical_key",
    "file_key",
    "node_id",
    "page_id",
    "path",
    "line",
    "status",
    "invalid_reason",
    "duplicate_of",
]

FIGMA_NODE_RE = re.compile(r"^[0-9]+:[0-9]+$")
NOTION_UUID_RE = re.compile(
    r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
)
NOTION_HEX32_RE = re.compile(r"(?<![0-9a-fA-F])[0-9a-fA-F]{32}(?![0-9a-fA-F])")
CODE_PATH_RE = re.compile(r"^(?P<path>.+?)(?::(?P<line>[0-9]+))?$")


def normalize_url(locator: str) -> Optional[str]:
    parsed = urlparse(locator.strip())
    if not parsed.scheme or not parsed.netloc:
        return None

    scheme = parsed.scheme.lower()
    netloc = parsed.netloc.lower()
    path = parsed.path or "/"
    query_items = parse_qs(parsed.query, keep_blank_values=True)
    sorted_items = sorted((k, v) for k, vals in query_items.items() for v in vals)
    query = urlencode(sorted_items)

    return urlunparse((scheme, netloc, path, "", query, ""))


def normalize_figma(locator: str) -> Tuple[bool, Dict[str, str], str]:
    parsed = urlparse(locator.strip())
    if not parsed.scheme or not parsed.netloc:
        return False, {}, "figma locator must be a URL"

    segments = [seg for seg in parsed.path.split("/") if seg]
    file_key = ""
    for i, seg in enumerate(segments):
        if seg in {"design", "file"} and i + 1 < len(segments):
            file_key = segments[i + 1]
            break

    if not file_key:
        return False, {}, "figma file key not found"

    query = parse_qs(parsed.query, keep_blank_values=True)
    node_raw = ""
    if "node-id" in query and query["node-id"]:
        node_raw = query["node-id"][0]
    elif "node_id" in query and query["node_id"]:
        node_raw = query["node_id"][0]

    if not node_raw:
        return False, {}, "figma node id not found"

    node_id = unquote(node_raw).strip()
    if re.match(r"^[0-9]+-[0-9]+$", node_id):
        node_id = node_id.replace("-", ":")

    if not FIGMA_NODE_RE.match(node_id):
        return False, {}, "figma node id must match <number>:<number>"

    normalized_query = urlencode({"node-id": node_id}, quote_via=quote)
    normalized_url = urlunparse((parsed.scheme.lower(), parsed.netloc.lower(), parsed.path, "", normalized_query, ""))

    result = {
        "source_locator_normalized": normalized_url,
        "canonical_key": f"figma:{file_key}:{node_id}",
        "file_key": file_key,
        "node_id": node_id,
    }
    return True, result, ""


def normalize_code(locator: str) -> Tuple[bool, Dict[str, str], str]:
    value = locator.strip()
    if not value:
        return False, {}, "code locator is empty"
    if "://" in value:
        return False, {}, "code locator must be path or path:line"

    match = CODE_PATH_RE.match(value)
    if not match:
        return False, {}, "invalid code locator format"

    path_raw = match.group("path") or ""
    line_raw = match.group("line")

    if not path_raw:
        return False, {}, "code path is empty"

    normalized_path = str(PurePosixPath(path_raw.replace("\\", "/")))
    if normalized_path in {"", "."}:
        return False, {}, "code path is invalid"

    line = int(line_raw) if line_raw else 0
    locator_normalized = f"{normalized_path}:{line}" if line > 0 else normalized_path

    result = {
        "source_locator_normalized": locator_normalized,
        "canonical_key": f"code:{normalized_path}:{line}",
        "path": normalized_path,
        "line": str(line),
    }
    return True, result, ""


def normalize_notion(locator: str) -> Tuple[bool, Dict[str, str], str]:
    value = locator.strip()
    if not value:
        return False, {}, "notion locator is empty"

    parsed = urlparse(value)
    section = "root"

    if parsed.scheme and parsed.netloc:
        if parsed.fragment:
            section = parsed.fragment.strip() or "root"

    page_id_candidates = [
        match.group(0).replace("-", "").lower()
        for match in NOTION_UUID_RE.finditer(value)
    ]
    page_id_candidates.extend(
        match.group(0).lower() for match in NOTION_HEX32_RE.finditer(value)
    )

    if not page_id_candidates:
        return False, {}, "notion page id not found"

    page_id = page_id_candidates[-1]

    locator_normalized = value
    if parsed.scheme and parsed.netloc:
        normalized_url = normalize_url(value)
        if normalized_url:
            locator_normalized = normalized_url

    result = {
        "source_locator_normalized": locator_normalized,
        "canonical_key": f"notion:{page_id}:{section}",
        "page_id": page_id,
    }
    return True, result, ""


def normalize_generic_url(locator: str) -> Tuple[bool, Dict[str, str], str]:
    normalized_url = normalize_url(locator)
    if not normalized_url:
        return False, {}, "URL normalization failed"

    result = {
        "source_locator_normalized": normalized_url,
        "canonical_key": f"url:{normalized_url}",
    }
    return True, result, ""


def normalize_other(locator: str) -> Tuple[bool, Dict[str, str], str]:
    value = locator.strip()
    if not value:
        return False, {}, "other locator is empty"

    digest = hashlib.sha256(value.lower().encode("utf-8")).hexdigest()[:16]
    result = {
        "source_locator_normalized": value,
        "canonical_key": f"other:{digest}",
    }
    return True, result, ""


def normalize_row(source_type: str, locator: str) -> Tuple[bool, Dict[str, str], str]:
    stype = source_type.lower().strip()

    if stype == "figma":
        return normalize_figma(locator)
    if stype == "code":
        return normalize_code(locator)
    if stype == "notion":
        return normalize_notion(locator)
    if stype in {"doc", "api"}:
        return normalize_generic_url(locator)
    if stype == "other":
        return normalize_other(locator)

    return False, {}, f"unsupported source_type: {source_type}"


def load_rows(csv_path: Path) -> list[dict]:
    with csv_path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        if not reader.fieldnames:
            raise ValueError("input CSV has no header")

        required = {"source_type", "source_locator"}
        missing = required - set(reader.fieldnames)
        if missing:
            raise ValueError(f"missing required columns: {', '.join(sorted(missing))}")

        return list(reader)


def empty_output_row(row_number: int, row: dict) -> dict:
    out = {col: "" for col in OUTPUT_COLUMNS}
    out["source_row"] = str(row_number)
    out["source_type"] = (row.get("source_type") or "").strip().lower()
    out["source_locator_raw"] = (row.get("source_locator") or "").strip()
    out["source_section"] = (row.get("source_section") or "").strip()
    out["evidence_level"] = (row.get("evidence_level") or "").strip().lower()
    out["priority"] = (row.get("priority") or "").strip().lower()
    out["notes"] = (row.get("notes") or "").strip()
    return out


def write_csv(path: Path, rows: list[dict]) -> None:
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=OUTPUT_COLUMNS)
        writer.writeheader()
        writer.writerows(rows)


def run(input_path: Path, out_dir: Path) -> dict:
    rows = load_rows(input_path)
    out_dir.mkdir(parents=True, exist_ok=True)

    normalized_rows: list[dict] = []
    duplicate_rows: list[dict] = []
    invalid_rows: list[dict] = []

    seen_keys: Dict[str, str] = {}

    for idx, row in enumerate(rows, start=1):
        out = empty_output_row(idx, row)
        source_type = out["source_type"]

        if source_type not in SUPPORTED_SOURCE_TYPES:
            out["status"] = "invalid"
            out["invalid_reason"] = f"unsupported source_type: {source_type}"
            normalized_rows.append(out)
            invalid_rows.append(out)
            continue

        ok, normalized, reason = normalize_row(source_type, out["source_locator_raw"])
        if not ok:
            out["status"] = "invalid"
            out["invalid_reason"] = reason
            normalized_rows.append(out)
            invalid_rows.append(out)
            continue

        out.update(normalized)
        canonical_key = out["canonical_key"]

        if canonical_key in seen_keys:
            out["status"] = "duplicate"
            out["duplicate_of"] = seen_keys[canonical_key]
            normalized_rows.append(out)
            duplicate_rows.append(out)
            continue

        out["status"] = "valid"
        seen_keys[canonical_key] = out["source_row"]
        normalized_rows.append(out)

    write_csv(out_dir / "normalized.csv", normalized_rows)
    write_csv(out_dir / "duplicates.csv", duplicate_rows)
    write_csv(out_dir / "invalid.csv", invalid_rows)

    summary = {
        "input_rows": len(rows),
        "valid_rows": sum(1 for r in normalized_rows if r["status"] == "valid"),
        "duplicate_rows": len(duplicate_rows),
        "invalid_rows": len(invalid_rows),
        "supported_source_types": sorted(SUPPORTED_SOURCE_TYPES),
        "output_dir": str(out_dir),
    }

    with (out_dir / "summary.json").open("w", encoding="utf-8") as f:
        json.dump(summary, f, ensure_ascii=True, indent=2, sort_keys=True)

    return summary


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Normalize source registry CSV")
    parser.add_argument("--input", required=True, type=Path, help="Input CSV path")
    parser.add_argument("--out-dir", required=True, type=Path, help="Output directory path")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    summary = run(args.input, args.out_dir)
    print(json.dumps(summary, ensure_ascii=True))


if __name__ == "__main__":
    main()
