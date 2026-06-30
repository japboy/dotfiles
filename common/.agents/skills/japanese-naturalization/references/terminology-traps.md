# Terminology Traps

Use this file when a literal English-to-Japanese mapping could produce unnatural
or misleading Japanese. These entries are defaults, not absolute rules. Let
project evidence, official terminology, and the target audience override this
registry.

## Update Rules

Keep this file appendable and reviewable:

1. Add or revise a row in the registry instead of creating a term-specific
   explanation section.
2. Keep each rule bounded to one trigger, one context, and one rewrite action.
3. Put source links in the Evidence Registry and refer to them by ID.
4. Add an evaluation fixture in
   [evaluation-prompts.csv](evaluation-prompts.csv) when the rule changes
   rewrite behavior.
5. Treat single observed phrases as candidates. Promote them to reusable rules
   only when the context, preferred wording, and validation check are explicit.

## Trap Registry

| Rule ID | Trigger | Context | Prefer | Avoid or treat carefully | Rewrite action | Evidence | Eval |
|---|---|---|---|---|---|---|---|
| consumer-retail | consumer | Retail, economics, consumer behavior | 消費者 | コンシューマー | Use when the actor is a market participant or buyer. | project-or-domain-evidence |  |
| consumer-product | consumer | Product analytics or UI usage | ユーザー, 利用者 | 消費者, コンシューマー | Prefer the term used by the product or service. | project-or-domain-evidence | consumer-001 |
| consumer-stream | consumer | Kafka, queues, streams | コンシューマー | 消費者 | Preserve established stream-processing terminology. | project-or-domain-evidence | consumer-002 |
| consumer-api | consumer | API caller or downstream integration | クライアント, 呼び出し元, 利用側 | 消費者 | Choose by architecture and sentence role. | project-or-domain-evidence | consumer-003 |
| consumer-pubsub | consumer | Pub/Sub or event subscription | サブスクライバー, 購読側, コンシューマー | 消費者 | Preserve project terminology if present. | project-or-domain-evidence |  |
| client-architecture | client | Client-server architecture | クライアント | 顧客 | Use for a technical actor, not a business customer. | project-or-domain-evidence |  |
| client-customer | client | Customer relationship | 顧客, クライアント | クライアントアプリ | Use 顧客 for customers unless the industry says クライアント. | project-or-domain-evidence |  |
| client-ui | client | UI application | クライアントアプリ, クライアント | 顧客 | Use when contrasting backend or server. | project-or-domain-evidence |  |
| user-product | user | Software product | ユーザー | 消費者 | Use 利用者 when public-sector or formal tone fits better. | project-or-domain-evidence |  |
| user-public-service | user | Public service or formal document | 利用者 | ユーザー | Prefer institutional wording for forms, policies, and services. | project-or-domain-evidence |  |
| prompt-llm | prompt | LLM instruction | プロンプト | 入力欄 | Use 指示文 only when explaining the content of the prompt. | project-or-domain-evidence |  |
| prompt-ui | prompt | UI field or label | 入力欄, 入力文, メッセージ | プロンプト | Choose based on what the UI element actually represents. | project-or-domain-evidence |  |
| context-technical | context | LLM, design, programming | コンテキスト, 文脈 | 状況 | コンテキスト is often natural in technical contexts. | project-or-domain-evidence |  |
| context-general | context | General explanation | 文脈, 背景, 状況 | コンテキスト | Prefer the word a non-specialist would use. | project-or-domain-evidence |  |
| subscribe-events | subscribe | Event streams or state updates | 購読する, subscribe する | 登録する | Preserve domain terms when the reader expects them. | project-or-domain-evidence | subscribe-001 |
| subscribe-newsletter | subscribe | Newsletter or paid plan | 登録する, 購読する | subscribe する | Choose based on product wording and payment model. | project-or-domain-evidence |  |
| frontend-architecture | frontend | Web/application architecture | フロントエンド | 前面部 | Keep established katakana. | project-or-domain-evidence | katakana-001 |
| backend-architecture | backend | Web/application architecture | バックエンド | 後方部 | Keep established katakana. | project-or-domain-evidence | katakana-001 |
| endpoint-api | endpoint | API | エンドポイント | 終端点 | Keep established katakana unless explaining to beginners. | mdn-endpoint |  |
| api-wiring-route | API wiring / API 配線 | Route or handler definition | API ルートを定義する, エンドポイントを実装する, Route Handler を実装する | API 配線 | Name the route, endpoint, or handler concept instead of using 配線. | express-routing, next-route-handler | api-wiring-001 |
| api-wiring-gateway | API wiring / API 配線 | API gateway or API management backend mapping | バックエンド統合を設定する, ルートをバックエンドに接続する, バックエンドへのルーティングを構成する | API 配線 | Name the backend integration or routing configuration. | aws-apigw-integration, gcp-apigw-route-config | api-wiring-002 |
| api-wiring-client-call | API wiring / API 配線 | Frontend or client-side request code | API 呼び出しを実装する, フロントエンドから API を呼び出す | API 配線 | Name the API call behavior, not routing or integration. | mdn-endpoint | api-wiring-003 |
| api-wiring-service-integration | API wiring / API 配線 | Service-to-service integration | API 連携を実装する, API 連携を設定する | API 配線 | Use 連携 when the point is system or service integration. | project-or-domain-evidence |  |
| wiring-event-tool | wiring / 配線 | Event handler or tool wiring | 配線, 接続, 紐づけ | API 配線 | Keep 配線 only when the actual concept is event or tool wiring. | project-or-domain-evidence | api-wiring-004 |

## Evidence Registry

| Evidence ID | Source | Supports |
|---|---|---|
| project-or-domain-evidence | Local project docs, product UI, code, glossary, or domain-specific official sources | Use when the preferred wording depends on a project, product, domain, or audience. Inspect local evidence before public sources. |
| express-routing | https://expressjs.com/en/guide/routing.html | Express uses routing, routes, paths, and handlers for request handling. |
| next-route-handler | https://nextjs.org/docs/app/api-reference/file-conventions/route | Next.js uses Route Handlers and API routes for API request handlers. |
| aws-apigw-integration | https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/http-api-develop-integrations.html | AWS API Gateway uses integrations and routes for connecting requests to backend resources. |
| gcp-apigw-route-config | https://docs.cloud.google.com/api-gateway/docs/get-started-cloud-run?hl=ja | Google Cloud API Gateway uses OpenAPI descriptions and route configuration for backend services. |
| mdn-endpoint | https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Forms/Sending_forms_through_JavaScript | MDN describes sending requests to an endpoint rather than "wiring" an API. |

## Decision Process

1. Define the concept before choosing the word.
2. Check whether the project already uses a term for the same concept.
3. Prefer the term that the target audience would expect in that context.
4. Keep established technical katakana instead of forcing kanji translations.
5. If two terms are both plausible but imply different concepts, surface the
   ambiguity instead of hiding it in a smooth rewrite.
