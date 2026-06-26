PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS memory_metadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
) STRICT;

INSERT OR IGNORE INTO memory_metadata(key, value)
VALUES ('schema_version', '1');

CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  worktree_key TEXT NOT NULL,
  branch TEXT,
  head_oid_at_start TEXT,
  status TEXT NOT NULL CHECK (status IN (
    'active',
    'completed',
    'failed',
    'abandoned'
  )),
  started_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  ended_at TEXT,
  meta_json TEXT NOT NULL DEFAULT '{}' CHECK (json_valid(meta_json))
) STRICT;

CREATE TABLE IF NOT EXISTS session_edges (
  from_session_id TEXT NOT NULL REFERENCES sessions(id),
  to_session_id TEXT NOT NULL REFERENCES sessions(id),
  edge_type TEXT NOT NULL CHECK (edge_type IN (
    'continues',
    'forks',
    'references',
    'blocks'
  )),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  PRIMARY KEY (from_session_id, to_session_id, edge_type)
) STRICT;

CREATE TABLE IF NOT EXISTS memory_events (
  id INTEGER PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES sessions(id),
  session_seq INTEGER NOT NULL,
  occurred_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  kind TEXT NOT NULL,
  topic_key TEXT,
  scope_uri TEXT,
  body TEXT NOT NULL,
  importance INTEGER NOT NULL DEFAULT 3 CHECK (importance BETWEEN 0 AND 5),
  meta_json TEXT NOT NULL DEFAULT '{}' CHECK (json_valid(meta_json)),
  idempotency_key TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (session_id, session_seq)
) STRICT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_memory_events_idempotency
ON memory_events(idempotency_key)
WHERE idempotency_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_memory_events_time
ON memory_events(occurred_at, id);

CREATE INDEX IF NOT EXISTS idx_memory_events_session
ON memory_events(session_id, session_seq);

CREATE INDEX IF NOT EXISTS idx_memory_events_topic
ON memory_events(topic_key, occurred_at, id)
WHERE topic_key IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_memory_events_scope
ON memory_events(scope_uri, occurred_at, id)
WHERE scope_uri IS NOT NULL;

CREATE VIRTUAL TABLE IF NOT EXISTS memory_events_fts USING fts5(
  body,
  kind UNINDEXED,
  topic_key UNINDEXED,
  scope_uri UNINDEXED,
  content='memory_events',
  content_rowid='id',
  tokenize='unicode61'
);

CREATE TRIGGER IF NOT EXISTS memory_events_ai
AFTER INSERT ON memory_events BEGIN
  INSERT INTO memory_events_fts(rowid, body, kind, topic_key, scope_uri)
  VALUES (new.id, new.body, new.kind, new.topic_key, new.scope_uri);
END;

CREATE TRIGGER IF NOT EXISTS memory_events_ad
AFTER DELETE ON memory_events BEGIN
  INSERT INTO memory_events_fts(memory_events_fts, rowid, body, kind, topic_key, scope_uri)
  VALUES ('delete', old.id, old.body, old.kind, old.topic_key, old.scope_uri);
END;

CREATE TRIGGER IF NOT EXISTS memory_events_au
AFTER UPDATE ON memory_events BEGIN
  INSERT INTO memory_events_fts(memory_events_fts, rowid, body, kind, topic_key, scope_uri)
  VALUES ('delete', old.id, old.body, old.kind, old.topic_key, old.scope_uri);
  INSERT INTO memory_events_fts(rowid, body, kind, topic_key, scope_uri)
  VALUES (new.id, new.body, new.kind, new.topic_key, new.scope_uri);
END;

CREATE TABLE IF NOT EXISTS artifacts (
  id INTEGER PRIMARY KEY,
  uri TEXT NOT NULL UNIQUE,
  artifact_kind TEXT NOT NULL,
  media_type TEXT NOT NULL,
  title TEXT,
  first_seen_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  last_seen_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
) STRICT;

CREATE TABLE IF NOT EXISTS artifact_snapshots (
  id INTEGER PRIMARY KEY,
  artifact_id INTEGER NOT NULL REFERENCES artifacts(id),
  git_blob_oid TEXT,
  content_hash TEXT NOT NULL,
  extractor_id TEXT NOT NULL,
  extractor_version TEXT NOT NULL,
  indexed_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (artifact_id, content_hash, extractor_id, extractor_version)
) STRICT;

CREATE TABLE IF NOT EXISTS event_artifact_refs (
  event_id INTEGER NOT NULL REFERENCES memory_events(id),
  artifact_id INTEGER NOT NULL REFERENCES artifacts(id),
  relation TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  PRIMARY KEY (event_id, artifact_id, relation)
) STRICT;

CREATE TABLE IF NOT EXISTS memory_rollups (
  id INTEGER PRIMARY KEY,
  rollup_type TEXT NOT NULL,
  rollup_key TEXT NOT NULL,
  start_event_id INTEGER NOT NULL REFERENCES memory_events(id),
  end_event_id INTEGER NOT NULL REFERENCES memory_events(id),
  summary TEXT NOT NULL,
  source_hash TEXT NOT NULL,
  token_estimate INTEGER NOT NULL DEFAULT 0 CHECK (token_estimate >= 0),
  status TEXT NOT NULL CHECK (status IN ('active', 'stale', 'superseded')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (rollup_type, rollup_key, source_hash)
) STRICT;

CREATE INDEX IF NOT EXISTS idx_memory_rollups_lookup
ON memory_rollups(rollup_type, rollup_key, status, created_at);
