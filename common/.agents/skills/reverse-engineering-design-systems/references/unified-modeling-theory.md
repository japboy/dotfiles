# 統合モデリング理論
## ドメインモデリング・情報アーキテクチャ・デザインシステムの統一的理解

**Version 1.0**
**Date: 2026-01-25**

---

## 目次

1. [序論](#1-序論)
2. [各モデリング手法の詳細](#2-各モデリング手法の詳細)
   - 2.1 [ドメインモデリング (Domain-Driven Design)](#21-ドメインモデリング-domain-driven-design)
   - 2.2 [情報アーキテクチャ (Information Architecture)](#22-情報アーキテクチャ-information-architecture)
   - 2.3 [デザインシステム (Design System)](#23-デザインシステム-design-system)
   - 2.4 [The Elements of User Experience](#24-the-elements-of-user-experience)
3. [各手法の関連性分析](#3-各手法の関連性分析)
4. [世の中の評価・認知度](#4-世の中の評価認知度)
5. [モデル間の不整合分析](#5-モデル間の不整合分析)
6. [統合モデル実現の可否](#6-統合モデル実現の可否)
7. [結論](#7-結論)
8. [参考文献](#8-参考文献)

---

## 1. 序論

### 1.1 研究の背景

現代のデジタルプロダクト開発において、ドメインモデリング、情報アーキテクチャ（IA）、デザインシステムは、それぞれ独立した分野として発展してきた。しかし、これらの手法は本質的に「現実世界の構造をデジタル製品として表現する」という共通の目的を持っている。

本研究は、Jesse James Garrett の「The Elements of User Experience」を軸として、これら3つのモデリング手法を統合的に理解し、実践に適用可能な統一フレームワークの構築を目指す。

### 1.2 研究の目的

本ドキュメントは以下の項目について学術的に調査・分析を行う：

1. 各モデリング手法の具体的な関連性
2. 世の中の評価・認知度
3. 各モデリング手法の詳細
4. 統合する上でのモデル間の不整合
5. 統合モデル実現の可否
6. 統合モデルによる具体的な分析手法の確立

### 1.3 変換パイプラインの概念

本研究が提案する統合モデルは、「知恵 → 構造 → 知識 → 実装」という変換パイプラインに基づく：

```
┌─────────────────┐
│  知恵 (Wisdom)   │ ← 判断・意味構造・認知モデル
│                 │   （情報アーキテクチャの領域）
└────────┬────────┘
         ▼
┌─────────────────┐
│ 構造 (Structure) │ ← 概念・規則・関係性
│                 │   （ドメインモデリングの領域）
└────────┬────────┘
         ▼
┌─────────────────┐
│知識 (Knowledge) │ ← 形式化された表現
│                 │   （DSL / Schema / Ontology）
└────────┬────────┘
         ▼
┌─────────────────┐
│ 実装 (Action)   │ ← UI・エージェント・ワークフロー
│                 │   （デザインシステムの領域）
└─────────────────┘
```

---

## 2. 各モデリング手法の詳細

### 2.1 ドメインモデリング (Domain-Driven Design)

#### 2.1.1 歴史的経緯

ドメインモデリングの現代的形態は、Eric Evans の著書『Domain-Driven Design: Tackling Complexity in the Heart of Software』（2003年）によって体系化された。この著作は Martin Fowler の先行研究、特に『Analysis Patterns: Reusable Object Models』（1996年）および『Patterns of Enterprise Application Architecture』（2002年）の影響を強く受けている。

**起源と発展**

| 年 | 出来事 | 提唱者/組織 |
|---|---|---|
| 1960年代 | Simula言語によるオブジェクト指向の萌芽 | Dahl & Nygaard |
| 1972年 | Smalltalkの開発 | Alan Kay (Xerox PARC) |
| 1994年 | デザインパターンの体系化 | Gang of Four |
| 1996年 | Analysis Patterns出版 | Martin Fowler |
| 2001年 | アジャイルマニフェスト署名 | Fowler他 |
| 2002年 | PoEAA出版 | Martin Fowler |
| 2003年 | DDD書籍出版 | Eric Evans |
| 2013年 | Implementing DDD出版 | Vaughn Vernon |

#### 2.1.2 理論的基盤

DDDは、ソフトウェアの複雑さに対処するため、**戦略的設計**と**戦術的設計**の二層構造を採用する。

**戦略的設計パターン**

```mermaid
graph TB
    subgraph "戦略的設計"
        BC1[境界づけられたコンテキスト A]
        BC2[境界づけられたコンテキスト B]
        BC3[境界づけられたコンテキスト C]

        BC1 -->|"Shared Kernel"| BC2
        BC2 -->|"Customer-Supplier"| BC3
        BC1 -->|"Anticorruption Layer"| BC3
    end

    UL[ユビキタス言語] --> BC1
    UL --> BC2
    UL --> BC3
```

1. **境界づけられたコンテキスト (Bounded Context)**
   - 定義：特定のドメインモデルが一貫性を持ち有効である概念的境界
   - 目的：関心の分離を保証し、モデル・ルール・用語の一貫性を維持
   - 重要な洞察：コンテキスト境界の主要決定因は「人間の文化」である

2. **ユビキタス言語 (Ubiquitous Language)**
   - 定義：開発者・ドメインエキスパート・その他参加者間で共有される共通言語
   - 目的：曖昧さのないコミュニケーションを確立
   - 特徴：コード内のすべての概念をドメイン中心の観点から命名

3. **コンテキストマッピング (Context Mapping)**
   - 定義：異なる境界づけられたコンテキスト間の関係を定義する手法
   - パターン：Shared Kernel、Customer-Supplier、Conformist、Anticorruption Layer、Open Host Service、Published Language

**戦術的設計パターン**

| パターン | 定義 | 特徴 |
|---|---|---|
| Entity | アイデンティティによって定義されるオブジェクト | 固有のライフサイクルを持つ |
| Value Object | アイデンティティを持たない不変オブジェクト | 属性のみで定義 |
| Aggregate | 一貫性境界を定義する概念 | Root経由でのみ変更可能 |
| Repository | ドメインオブジェクト取得のためのインターフェース | 永続化の詳細を隠蔽 |
| Factory | オブジェクト生成をカプセル化 | 複雑な生成ロジックを分離 |
| Domain Service | 特定のエンティティに属さない振る舞い | 複数オブジェクト間の操作 |
| Domain Event | ドメイン内の重要な出来事 | 状態変化の記録と通知 |

#### 2.1.3 哲学的基盤

DDDは「世界を正しく表現するモデル」の構築を目指す。その根底には以下の哲学がある：

- **内部志向性**：システム内部の論理的整合性を重視
- **精度重視**：ビジネスルールの正確な表現
- **正確性・一貫性の優先**：曖昧さの排除

---

### 2.2 情報アーキテクチャ (Information Architecture)

#### 2.2.1 歴史的経緯

情報アーキテクチャの概念は、Richard Saul Wurman によって1976年のアメリカ建築家協会（AIA）年次大会で初めて提唱された。

**起源と発展**

| 年 | 出来事 | 提唱者/組織 |
|---|---|---|
| 1876年 | 十進分類法の発明 | Melvil Dewey |
| 1933年 | コロン分類法（ファセット分類）発表 | S.R. Ranganathan |
| 1976年 | 「情報アーキテクチャ」用語の提唱 | Richard Saul Wurman |
| 1989年 | 『Information Anxiety』出版、LATCH原則発表 | Richard Saul Wurman |
| 1998年 | 『Web情報アーキテクチャ』初版出版 | Rosenfeld & Morville |
| 2002年 | IA Institute設立 | 複数の実務家 |
| 2009年 | Journal of Information Architecture創刊 | 学術コミュニティ |
| 2015年 | 『Web情報アーキテクチャ』第4版出版 | Rosenfeld, Morville & Arango |

**LATCH原則**（情報を組織化する5つの方法）：
- **L**ocation（場所）
- **A**lphabet（アルファベット順）
- **T**ime（時間）
- **C**ategory（カテゴリ）
- **H**ierarchy（階層）

#### 2.2.2 理論的基盤

IAは「世界を人にとって理解可能にするモデル」の構築を目指す。

**4つのコアシステム**

```mermaid
graph TD
    subgraph "情報アーキテクチャの4システム"
        OS[組織化システム<br/>Organization Systems]
        LS[ラベリングシステム<br/>Labeling Systems]
        NS[ナビゲーションシステム<br/>Navigation Systems]
        SS[検索システム<br/>Search Systems]
    end

    OS --> |"情報の分類"| LS
    LS --> |"ナビゲーション要素"| NS
    NS --> |"検索結果の表示"| SS
    SS --> |"検索条件の組織化"| OS
```

1. **組織化システム (Organization Systems)**
   - 機能：コンテンツの分類・グループ化
   - 手法：タクソノミー、階層構造、ファセット分類
   - 目的：情報の論理的構造を確立

2. **ラベリングシステム (Labeling Systems)**
   - 機能：情報の表現方法の決定
   - 要素：命名規則、用語選択、メタデータ
   - 目的：ユーザーの理解を促進

3. **ナビゲーションシステム (Navigation Systems)**
   - 機能：ユーザーの情報空間内移動を支援
   - 種類：グローバルナビゲーション、ローカルナビゲーション、コンテキストナビゲーション
   - 目的：迷わない体験の提供

4. **検索システム (Search Systems)**
   - 機能：直接検索による情報発見
   - 要素：検索インターフェース、検索アルゴリズム、結果表示
   - 目的：目的情報への迅速なアクセス

#### 2.2.3 認知科学との関係

IAは認知科学のメンタルモデル理論に深く根ざしている：

- **メンタルモデル**：ユーザーがシステムについて持つ内的表象
- **スキーマ理論**：長期記憶に保存された知識構造の活性化
- **認知負荷**：デザイナーとユーザーのメンタルモデルのギャップがユーザビリティの主要課題

**ファセット分類の革新性**

S.R. Ranganathanが1933年に発表したコロン分類法は、IAの理論的基盤の一つである。PMESTの5ファセット（Personality, Matter, Energy, Space, Time）により、単一オブジェクトに複数の分類を割り当てることが可能になった。

---

### 2.3 デザインシステム (Design System)

#### 2.3.1 概念の定義と範囲

デザインシステムは、単なるコンポーネントライブラリではなく、以下の要素を包含する包括的なフレームワークである：

**構成要素の階層**

| レベル | 要素 | 定義 | 範囲 |
|---|---|---|---|
| 基盤 | スタイルガイド | 視覚的ルールの文書化 | 色、タイポグラフィ、ボイス＆トーン |
| 中間 | パターンライブラリ | 再利用可能なUIコンポーネント集 | ボタン、フォーム、ナビゲーション |
| 統合 | デザインシステム | 上記＋原則・ガイドライン・コード | アクセシビリティ、UX原則、実装コード |

> 「デザインシステムは、パターンライブラリとスタイルガイドを包含しつつ、それらを統合する原則とガイドラインを加えたものである」— Alla Kholmatova

#### 2.3.2 歴史的経緯

デザインシステムの起源は、1977年のApple Human Interface Guidelinesまで遡る。現代的形態は複数の系統から発展してきた。

**起源と発展**

| 年 | 出来事 | 提唱者/組織 | 意義 |
|---|---|---|---|
| 1977年 | Apple II Human Interface Guidelines | Apple | 最初期のUIガイドライン文書 |
| 1986年 | Human Interface Guidelines正式出版 | Apple | 「Human Interface」概念の確立 |
| 2013年 | Atomic Design提唱 | Brad Frost | コンポーネント階層の体系化 |
| 2014年 | Material Design発表 | Google | 物理的メタファーに基づくシステム |
| 2014年 | Design Tokens概念の発明 | Jina Anne & Jon Levine (Salesforce) | クロスプラットフォーム設計変数 |
| 2015年 | Lightning Design System公開 | Salesforce | 世界初のオープンソース・エンタープライズDS |
| 2016年 | Carbon Design System開始 | IBM | アクセシビリティ重視のオープンソースDS |
| 2017年 | Fluent Design System発表 | Microsoft | 5つの基本要素（Light, Depth, Motion, Material, Scale） |
| 2017年 | 『Design Systems』出版 | Alla Kholmatova (Smashing) | 効果的なDSの原則を体系化 |
| 2021年 | Material You (Material Design 3) | Google | ユーザーカスタマイズ可能なテーマ |
| 2025年 | W3C Design Tokens仕様 安定版 | W3C DTCG | 業界標準の確立 |

#### 2.3.3 主要な理論的モデル

##### A. Atomic Design（Brad Frost, 2013）

化学のメタファーに基づく5層階層モデル。「ページではなくシステムを構築する」という思想を体現。

```mermaid
graph BT
    subgraph "Atomic Design 階層"
        A[Atoms 原子<br/>HTML要素: ボタン、入力、ラベル]
        M[Molecules 分子<br/>機能単位: 検索バー、フォームフィールド]
        O[Organisms 有機体<br/>セクション: ヘッダー、カード群、ナビ]
        T[Templates テンプレート<br/>ページ構造: ワイヤーフレーム]
        P[Pages ページ<br/>具体的インスタンス: 実コンテンツ適用]
    end

    A --> M
    M --> O
    O --> T
    T --> P
```

**重要な洞察**: Atomic Designは線形プロセスではなく、全体と部分を同時に考えるメンタルモデルである。Pattern Labというツールと共に実装されている。

##### B. Nathan Curtis のフレームワーク（EightShapes）

デザインシステムのガバナンスと組織設計に関する先駆的研究。

**コア原則**：
1. 「システムは簡単な問題を解決し、プロダクトが難しい問題をより簡単に解決できるようにする」
2. 「プロダクトは自らの運命を所有し、システムはその実現を支援する」
3. 「複雑なものの柔軟性より、シンプルなものの優雅さを優先する」
4. 「ドキュメントはまずツールとして、次に見せるための図として、必要なら読むための文章として作る」

**チームモデル**（ガバナンス構造）：

| モデル | 説明 | 適合組織 |
|---|---|---|
| Centralized（集中型） | 専任チームがDS全体を管理 | 小規模〜中規模、新規組織 |
| Federated（連邦型） | 各プロダクトチームの代表者が共同管理 | 大規模、多様なプロダクト群 |
| Standalone（独立型） | 各チームが独自のDSを維持 | 独立性の高いプロダクト |

##### C. Alla Kholmatova の設計原則（Smashing Magazine, 2017）

効果的なデザインシステムの特性を体系化。AirBnB、Atlassian、Eurostar、TEDなどのケーススタディに基づく。

**効果的なDSの条件**：
- 一貫したユーザー体験を生成できる
- チームが貢献したくなる設計
- 時間とともに改善される（肥大化しない）

##### D. Design Tokens（Jina Anne & Jon Levine, Salesforce, 2014）

デザインの最小単位を「トークン」として抽象化し、プラットフォーム間で共有可能にする概念。

**起源**: Jina AnneがSalesforce在籍中、YAMLデータで色・余白・タイポグラフィを管理し、複数プラットフォーム（Web、iOS、Android、Java、React、Angular等）向けに変換する手法を開発。これが「Theo」（最初のデザイントークンジェネレータ）となった。

**トークンの種類**：
- グローバルトークン: `color-blue-500`
- セマンティックトークン: `color-primary`
- コンポーネントトークン: `button-background-color`

#### 2.3.4 主要なデザインシステム事例

##### Apple Human Interface Guidelines（1977年〜）

**歴史**: 最も歴史の長いUIガイドライン。「Human Interface」という用語自体がApple固有の概念。

**設計哲学**:
- Aesthetic Integrity（美的一貫性）: 外観と機能の統合
- Consistency（一貫性）: 予測可能な操作
- Direct Manipulation（直接操作）: オブジェクトの直接的な操作
- Feedback（フィードバック）: 操作結果の明示
- User Control（ユーザー制御）: ユーザーが主導権を持つ

**特徴**: プラットフォーム固有の最適化（iOS、macOS、watchOS、tvOS、visionOS）

##### Google Material Design（2014年〜）

**設計哲学**: 「Material is the Metaphor」— 紙とインクの物理的性質をデジタルに翻訳。

**進化**:
- Material Design 1（2014）: 基本原則の確立
- Material Design 2（2018）: カスタマイズ性の強化、丸み・余白の拡大
- Material Design 3 / Material You（2021）: ユーザー壁紙からの動的テーマ生成

**コア要素**: 光、深度、モーション、素材感、スケール

##### Salesforce Lightning Design System（2015年〜）

**起源**: 2013年のSalesforce1開発時に始まったグラスルーツな取り組み。当初は「Landmark Design System」と呼ばれた。

**革新性**: 「世界初のオープンソース・エンタープライズ・アクセシブル・プラットフォーム非依存のデザインシステム」

**4つの原則**: Clarity（明確性）、Efficiency（効率性）、Consistency（一貫性）、Beauty（美しさ）

**構成要素**: デザイントークン、ユーティリティ、ガイドライン、コンポーネントブループリント

##### IBM Carbon Design System（2016年〜）

**設計哲学**: IBM Design Languageを基盤とし、人間中心設計を重視。

**コア原則**:
- Human-Centered（人間中心）: ユーザーではなく「人間」として理解
- Purposeful（目的志向）: すべての要素に意味を持たせる
- Consistency（一貫性）: 予測可能で安定した体験
- Accessibility（アクセシビリティ）: すべての人のための設計

**特徴**: オープンソース、IBM Plexタイプフェイスの採用、ProductiveとExpressiveの2つのタイポグラフィモード

##### Microsoft Fluent Design System（2017年〜）

**起源**: Metro Design Language（MDL2）の進化形として開発。

**5つの基本要素**: Light（光）、Depth（深度）、Motion（動き）、Material（素材）、Scale（スケール）

**進化**:
- Fluent 1（2017）: Windows 10向け
- Fluent 2（2023）: クロスプラットフォーム対応強化

**原則**: Familiar & Intuitive（親しみやすく直感的）、Inclusive（包括的）、One Microsoft（統一されたMS体験）

#### 2.3.5 W3C Design Tokens 仕様

2025年10月、W3C Design Tokens Community Group (DTCG) が初の安定版仕様（2025.10）をリリース。Jina AnneがCo-chairを務める。

**仕様の主要機能**:
- テーマ・マルチブランド対応: `$extends`プロパティによる継承
- 現代的な色空間: Display P3、Oklch、CSS Color Module 4対応
- リッチなトークン関係: エイリアス、継承、コンポーネントレベル参照
- クロスプラットフォーム一貫性: iOS、Android、Web、Flutter向けコード生成

**採用ツール**: Style Dictionary、Tokens Studio、Terrazzo、Figma、Sketch、Penpot、Framer、Knapsack、Supernova、zeroheight

#### 2.3.6 成熟度モデル

デザインシステムの成熟度を評価するフレームワークが複数提案されている。

**Sparkbox Design System Maturity Model**:
- Stage 1: 問題特定〜初回リリース
- Stage 2: 成長・採用拡大
- Stage 3: 生存・維持
- Stage 4: 繁栄・進化

**USWDS Maturity Model**（米国政府）:
- Principles → Guidance → Code の同心円構造
- 外側から内側へ成熟度を高める

**重要な批判**: 線形的な成熟度モデルは、デザインシステムの反復的・非線形的な性質を正確に反映しない。各組織に合わせたカスタマイズが必要。

#### 2.3.7 デザインシステムの構成要素（総括）

| 要素 | 定義 | 例 | 出典 |
|---|---|---|---|
| デザイントークン | 不可分なデザイン決定の単位 | 色、余白、タイポグラフィ | Jina Anne (Salesforce) |
| コンポーネント | 再利用可能なUI要素 | ボタン、カード、モーダル | Atomic Design |
| パターン | 繰り返し使用されるソリューション | ナビゲーション、フォーム | Pattern Library |
| ガイドライン | デザイン・実装の規則 | アクセシビリティ、ブランド | HIG, Material |
| 原則 | 設計判断の指針となる価値観 | Clarity, Consistency | Nathan Curtis |
| ガバナンス | 管理・進化の仕組み | Federated Model | EightShapes |

---

### 2.4 The Elements of User Experience

#### 2.4.1 歴史的経緯

Jesse James Garrett は2000年3月に「The Elements of User Experience」のダイアグラムを公開し、2002年に書籍として体系化した。

**起源と発展**

| 年 | 出来事 |
|---|---|
| 1999-2000年 | Garrettがダイアグラムを開発 |
| 2000年3月 | ダイアグラムをPDFで公開（2万回以上ダウンロード） |
| 2001年 | Adaptive Path 設立 |
| 2002年 | 書籍初版出版 |
| 2005年 | AJAX用語の提唱 |
| 2011年 | 書籍第2版出版（モバイル対応） |
| 2014年 | Adaptive Path が Capital One に買収 |

#### 2.4.2 5層モデルの詳細

```mermaid
graph TB
    subgraph "The Elements of User Experience"
        subgraph "具体的"
            Surface["Surface 表層<br/>ビジュアルデザイン"]
        end
        subgraph "　"
            Skeleton["Skeleton 骨格<br/>インターフェース/ナビゲーション/情報デザイン"]
        end
        subgraph "　　"
            Structure["Structure 構造<br/>インタラクションデザイン / IA"]
        end
        subgraph "　　　"
            Scope["Scope 要件<br/>機能仕様 / コンテンツ要件"]
        end
        subgraph "抽象的"
            Strategy["Strategy 戦略<br/>ユーザーニーズ / ビジネス目標"]
        end
    end

    Strategy --> Scope
    Scope --> Structure
    Structure --> Skeleton
    Skeleton --> Surface
```

**二面性モデル（Dual Nature）**

| 層 | 機能系（Product as Functionality） | 情報系（Product as Information） |
|---|---|---|
| Strategy | ユーザーニーズ / ビジネス目標 | ← 共通 |
| Scope | 機能仕様 | コンテンツ要件 |
| Structure | インタラクションデザイン | 情報アーキテクチャ |
| Skeleton | インターフェースデザイン | ナビゲーションデザイン |
| Surface | ビジュアルデザイン | ← 共通 |

#### 2.4.3 制約関係の原則

Garrettモデルの重要な特徴は、**下位層から上位層への制約関係**である：

> 「下位レイヤの決定が上位レイヤの選択肢を制約する」

この原則により：
- 戦略が明確でなければ、要件は定義できない
- 要件が確定しなければ、構造は設計できない
- 構造が決まらなければ、骨格は構成できない
- 骨格がなければ、表層のデザインは成立しない

---

## 3. 各手法の関連性分析

### 3.1 レイヤー対応関係

```mermaid
graph LR
    subgraph "Elements of UX"
        E1[Strategy]
        E2[Scope]
        E3[Structure]
        E4[Skeleton]
        E5[Surface]
    end

    subgraph "Domain Modeling"
        D1[ビジネス戦略]
        D2[境界づけられたコンテキスト]
        D3[エンティティ/アグリゲート]
        D4[リポジトリ/サービス]
        D5[---]
    end

    subgraph "Information Architecture"
        I1[ユーザーリサーチ]
        I2[コンテンツ戦略]
        I3[組織化/ラベリング]
        I4[ナビゲーション]
        I5[---]
    end

    subgraph "Design System"
        DS1[ブランド戦略]
        DS2[デザイン原則]
        DS3[パターンライブラリ]
        DS4[コンポーネント]
        DS5[トークン/ビジュアル]
    end

    E1 --- D1
    E1 --- I1
    E1 --- DS1

    E2 --- D2
    E2 --- I2
    E2 --- DS2

    E3 --- D3
    E3 --- I3
    E3 --- DS3

    E4 --- D4
    E4 --- I4
    E4 --- DS4

    E5 --- DS5
```

### 3.2 変換関係の定義

各モデリング手法は、異なる「変換」を担当する：

| 手法 | 変換 | 入力 | 出力 |
|---|---|---|---|
| ドメインモデリング | 現実 → 概念モデル | 業務知識・ルール | 計算可能な構造 |
| 情報アーキテクチャ | 概念モデル → 認知モデル | 情報構造 | 人が理解可能な構造 |
| デザインシステム | 認知モデル → UIモデル | 認知構造 | 視覚的表現 |

### 3.3 学問的系統の相違

```mermaid
graph TD
    subgraph "学問的系統"
        SE[ソフトウェア工学] --> DDD[ドメインモデリング]
        LIS[図書館情報学] --> IA[情報アーキテクチャ]
        CS[認知科学] --> IA
        GD[グラフィックデザイン] --> DS[デザインシステム]
        HCI[HCI] --> DS
        FE[フロントエンド工学] --> DS
    end
```

この学問的系統の相違が、統合における主要な障壁となっている。

---

## 4. 世の中の評価・認知度

### 4.1 ドメインモデリング (DDD)

#### 学術界での評価

| 指標 | 数値 | 出典 |
|---|---|---|
| Eric Evans著書の引用数 | 249件 | ACM Digital Library |
| 系統的文献レビュー（SLR）で分析された研究数 | 36件 | arXiv (2023-2025) |
| マイクロサービス関連研究の割合 | 44% | SLR調査結果 |

#### 産業界での採用

- **銀行・金融セクター市場規模**: 24億ドル（2024年）→ 87億ドル（2033年予測）
- **CAGR**: 15.2%
- **報告されている効果**:
  - 統合欠陥の35%削減
  - 保守オーバーヘッドの25%削減
  - チーム生産性の29%向上（Cambridge University調査）

#### 主要批判

1. 実装オーバーヘッドが大きい
2. ドメインエキスパートの継続的関与が必要
3. 単純なドメインには不適切
4. モデリングミスのコストが高い

### 4.2 情報アーキテクチャ (IA)

#### 学術界での評価

- **主要学術誌**: Journal of Information Architecture（2009年創刊）
- **課題**: 独自の研究空間としての確立に困難
- **関連分野**: HCI分野の重要な研究領域として認知

#### 産業界での採用

- **専門組織**: IA Institute（2002-2019）、World IA Association（現在）
- **主要カンファレンス**: IA Conference（25年の歴史）
- **2023年State of IA調査**: 913名の回答者、多くが組織でのIA認知は高いと回答

#### 主要批判

1. UX/UIデザインへの統合により独立した専門分野としてのアイデンティティに課題
2. 学術界での体系的な研究基盤が弱い
3. 定義や理論モデルについて学術的コンセンサスが未確立

### 4.3 デザインシステム

#### 学術界での評価

- **HCI International 2024**: 「Design Systems for Better UX」チュートリアル開催
- **研究トレンド**: AI/MLとの統合、生成AIとの共創が注目
- **W3C標準化**: 2025年10月にDesign Tokens仕様が安定版に到達、業界横断の標準化が進行

#### 産業界での採用

**主要企業のデザインシステム**：

| 企業 | システム名 | 初公開 | 特徴 | オープンソース |
|---|---|---|---|---|
| Apple | Human Interface Guidelines | 1986年 | プラットフォーム固有の最適化、「Human Interface」概念の起源 | 部分的 |
| Google | Material Design | 2014年 | 物理的素材のメタファー、Material You（2021）でパーソナライズ対応 | Yes |
| Salesforce | Lightning Design System | 2015年 | 世界初のオープンソース・エンタープライズDS、Design Tokens発祥地 | Yes |
| IBM | Carbon Design System | 2016年 | 人間中心設計、アクセシビリティ最重視、IBM Plex書体 | Yes |
| Microsoft | Fluent Design System | 2017年 | 5要素（Light, Depth, Motion, Material, Scale）、クロスプラットフォーム | Yes |
| Shopify | Polaris | 2017年 | EC特化、インクルーシビティ | Yes |
| Atlassian | Design System | 2018年 | コラボレーションツール特化 | Yes |
| Adobe | Spectrum | 2019年 | クリエイティブツール統合 | Yes |

**コミュニティ・標準化活動**：

| 組織/活動 | 説明 | 主要人物 |
|---|---|---|
| W3C Design Tokens Community Group | デザイントークン標準化 | Jina Anne (Co-chair) |
| Clarity Conference | デザインシステム専門カンファレンス | Jina Anne (創設者) |
| Design Systems Slack | 実務者コミュニティ | Jina Anne (管理) |
| EightShapes | ガバナンス・チームモデル研究 | Nathan Curtis |

#### 主要批判

1. **Atomic Designへの批判**: 化学メタファーが非デザイナーには分かりにくい（一部組織では独自の命名を採用）
2. **過度な標準化**: 創造性を制限するリスク
3. **維持コスト**: 成熟したDSほど維持の労力が増大
4. **成熟度モデルの限界**: 線形的な成熟度モデルは、DSの反復的性質を正確に反映しない

### 4.4 The Elements of User Experience

#### 学術界での評価

- **位置づけ**: UX分野の基礎的フレームワークとして継続的に引用
- **適用領域**: Webデザイン、ゲーミフィケーション、複合現実、教育プラットフォーム

#### 産業界での評価

> 「ついに、UXの多様な構成要素を統合した簡潔な説明が登場した」
> — Louis Rosenfeld（『Web情報アーキテクチャ』共著者）

> 「デザイン、テクノロジー、ビジネスの融合から生まれた最も重要な発展を体系的かつシンプルに説明している」
> — Richard Grefé（AIGA エグゼクティブディレクター）

#### 主要批判

1. 概念の表面的な扱い（詳細な解説が不足）
2. 厳格な順序依存性がアジャイル開発と衝突
3. 元々Webデザイン向けに設計（非デジタル領域への限界）
4. 技術的な詳細リソースではない

---

## 5. モデル間の不整合分析

### 5.1 根本的な不整合

#### 5.1.1 学問的系統の相違

```mermaid
graph TB
    subgraph "不整合の根源"
        Origin[出自が完全に別分野]

        DDD_Origin[ドメインモデリング<br/>ソフトウェア工学 / DDD]
        IA_Origin[情報アーキテクチャ<br/>図書館情報学 / 認知科学]
        DS_Origin[デザインシステム<br/>グラフィック / HCI / フロントエンド]

        Origin --> DDD_Origin
        Origin --> IA_Origin
        Origin --> DS_Origin
    end
```

**主要な相違点**：

| 観点 | ドメインモデリング | IA | デザインシステム |
|---|---|---|---|
| 志向性 | 内部志向 | 人間志向 | 表現志向 |
| 重視する品質 | 精度・正確性 | 妥当性・理解可能性 | 再利用性・一貫性 |
| 成果物 | 概念モデル・コード | サイトマップ・タクソノミー | コンポーネント・トークン |
| 評価基準 | ビジネスルールの正確な表現 | ユーザーの迷わなさ | 見た目と振る舞いの一貫性 |

#### 5.1.2 組織的分離

典型的な組織における責任範囲の分離：

| 領域 | 担当部門 | 課題 |
|---|---|---|
| ドメイン | バックエンド / 業務側 | ユーザー視点の欠如 |
| IA | UX / プロダクト | 技術的制約の理解不足 |
| DS | フロントエンド / デザイン | ビジネスロジックの理解不足 |

> **問題**: 誰も全体構造を統合していない

### 5.2 概念レベルの不整合

#### 5.2.1 用語の不一致

同じ概念に対して異なる用語が使用されている：

| 概念 | DDD | IA | DS |
|---|---|---|---|
| 情報の分類単位 | エンティティ | コンテンツタイプ | コンポーネント |
| 命名規則 | ユビキタス言語 | ラベリング | 命名規約 |
| 境界の定義 | 境界づけられたコンテキスト | 情報空間 | デザイントークン |
| 階層構造 | アグリゲート | タクソノミー | Atomic階層 |

#### 5.2.2 抽象度の不一致

各手法が扱う抽象度レベルの違い：

```
高い抽象度 ─────────────────────────────────> 低い抽象度

ドメインモデリング:  [━━━━━━━━━━━━━━━]
                     ↑概念・ルール・制約

情報アーキテクチャ:        [━━━━━━━━━━━━━━━]
                           ↑情報構造・認知

デザインシステム:                    [━━━━━━━━━━━━━]
                                     ↑UI・視覚表現
```

### 5.3 時間軸・状態の扱いの不整合

#### 5.3.1 状態遷移の扱い

| 手法 | 状態の扱い |
|---|---|
| ドメインモデリング | 明示的（状態遷移、ドメインイベント） |
| IA | 暗黙的（ナビゲーションフロー程度） |
| デザインシステム | 部分的（コンポーネント状態） |

#### 5.3.2 The Elements of UX の限界

Garrettモデルは：
- **構造（空間）には強い**
- **状態・フロー・時間軸には弱い**

→ XState / BPMN / フロー設計とはほぼ接続されていない

### 5.4 実践的不整合

#### 5.4.1 現場で起きている失敗パターン

```mermaid
graph TD
    subgraph "よくある失敗"
        Domain[ドメインは正しい]
        UI[UIは綺麗]
        Gap[しかし意味が噛み合っていない]

        Domain --> Gap
        UI --> Gap
    end

    subgraph "原因"
        DM[ドメインモデル = 内部論理]
        DS[デザインシステム = 表現論理]
        Missing[認知翻訳レイヤ（IA）の欠落]

        DM --> Missing
        DS --> Missing
    end

    Gap --> Missing
```

**具体例**：
- ドメインモデルの「Order」がUIでは「カート」「注文」「購入履歴」に分散
- ユーザーは概念の断片化により混乱
- ドメインの一貫性とUIの一貫性が乖離

---

## 6. 統合モデル実現の可否

### 6.1 統合の可能性

#### 6.1.1 統合を可能にする要因

1. **共通の目的**: すべての手法は「現実世界の構造をデジタル製品として表現する」という目的を共有

2. **補完的関係**: 各手法は異なる変換を担当し、パイプラインとして接続可能
   ```
   現実 → [DDD] → 概念モデル → [IA] → 認知モデル → [DS] → UIモデル
   ```

3. **The Elements of UX の接続機能**: Garrettモデルはすでに「情報設計（IA）とデザインシステム（表現体系）を構造的に接続」している

4. **層の対応関係**: 各手法の層は、概念的にマッピング可能

#### 6.1.2 統合を困難にする要因

1. **学問的系統の断絶**: 研究コミュニティ間の交流が少ない

2. **組織的サイロ**: 実務では部門間の壁が高い

3. **用語の不統一**: 同じ概念に異なる用語が使用される

4. **時間軸の欠如**: 特にGarrettモデルは状態・遷移を扱わない

### 6.2 統合モデルの提案

#### 6.2.1 統合フレームワーク

```mermaid
graph TB
    subgraph "統合モデル: Unified Semantic Architecture"
        subgraph "Strategy Layer 戦略層"
            BS[ビジネス戦略]
            UN[ユーザーニーズ]
            DV[ドメインビジョン]
        end

        subgraph "Semantic Layer 意味層"
            DM[ドメインモデル<br/>エンティティ/アグリゲート]
            SM[セマンティック構造<br/>概念/関係]
        end

        subgraph "Cognitive Layer 認知層"
            IA_[情報アーキテクチャ<br/>組織化/ラベリング]
            MM[メンタルモデル<br/>ユーザー理解構造]
        end

        subgraph "Expression Layer 表現層"
            DS_[デザインシステム<br/>コンポーネント/トークン]
            UI[UIパターン<br/>インタラクション]
        end
    end

    BS --> DM
    UN --> MM
    DV --> SM

    DM --> IA_
    SM --> IA_

    IA_ --> DS_
    MM --> UI

    DS_ --> Implementation[実装]
    UI --> Implementation
```

#### 6.2.2 統合の原則

1. **セマンティック・ブリッジ原則**
   - ドメインモデルの概念をIAのラベリングシステムに反映
   - ユビキタス言語をUI上のテキストに一貫して適用

2. **認知翻訳原則**
   - ドメインの論理構造をユーザーの認知構造に翻訳
   - 内部論理と外部表現の明示的なマッピングを維持

3. **表現一貫性原則**
   - ドメイン概念とUIコンポーネントの対応関係を明確化
   - デザイントークンにセマンティックな意味を付与

### 6.3 結論：統合は実現可能

**判定: 統合モデルの実現は可能**

ただし、以下の条件が必要：

1. **共通語彙の確立**: 3つの手法を横断する統一用語体系の構築
2. **認知翻訳レイヤの明示化**: IAを中心とした翻訳機能の強化
3. **時間軸の補完**: 状態遷移モデル（XState等）との統合
4. **組織横断的チーム**: 専門領域を超えた協働体制の構築

---

## 7. 結論

### 7.1 研究の要約

本研究では、ドメインモデリング、情報アーキテクチャ、デザインシステムの3つのモデリング手法について、学術的観点から詳細な調査・分析を行った。

**主要な発見**：

1. **各手法の補完性**: 3つの手法は異なる変換（現実→概念、概念→認知、認知→UI）を担当し、パイプラインとして接続可能

2. **The Elements of UX の役割**: Garrettモデルは、IAとデザインシステムを接続する最初期のモデルとして、統合の基盤となる

3. **不整合の根源**: 学問的系統の相違と組織的サイロが、統合の主要な障壁

4. **統合の可能性**: 認知翻訳レイヤ（IA）の強化と共通語彙の確立により、統合は実現可能

### 7.2 実務への示唆

統合モデルの実現に向けて、以下の実務的アプローチを推奨する：

1. **ユビキタス言語の拡張**: ドメイン専門家、IAスペシャリスト、デザイナーが共同で用語体系を構築

2. **セマンティック・デザイン・トークン**: デザイントークンにドメイン概念との対応関係を明示

3. **クロスファンクショナルレビュー**: 各層の成果物を複数の専門家が横断的にレビュー

4. **モデル間マッピングの文書化**: ドメインモデル→IA→DSの対応関係を明示的に記録

### 7.3 今後の研究課題

1. **時間軸モデルの統合**: XState、BPMNとの接続方法の研究
2. **AI/MLによる自動化**: 各層間の翻訳を支援するAI技術の開発
3. **実証研究**: 統合モデルの実践適用と効果測定
4. **標準化の推進**: W3C Design Tokens仕様のような業界標準の拡張

---

## 8. 参考文献

### 8.1 主要文献

#### ドメインモデリング

1. Evans, E. (2003). *Domain-Driven Design: Tackling Complexity in the Heart of Software*. Addison-Wesley.
2. Fowler, M. (2002). *Patterns of Enterprise Application Architecture*. Addison-Wesley.
3. Fowler, M. (1996). *Analysis Patterns: Reusable Object Models*. Addison-Wesley.
4. Vernon, V. (2013). *Implementing Domain-Driven Design*. Addison-Wesley.
5. Khononov, V. (2021). *Learning Domain-Driven Design*. O'Reilly Media.

#### 情報アーキテクチャ

6. Rosenfeld, L., Morville, P., & Arango, J. (2015). *Information Architecture: For the Web and Beyond* (4th ed.). O'Reilly Media.
7. Wurman, R. S. (1989). *Information Anxiety*. Doubleday.
8. Ranganathan, S. R. (1933). *Colon Classification*. Madras Library Association.

#### デザインシステム

9. Frost, B. (2016). *Atomic Design*. Brad Frost. https://atomicdesign.bradfrost.com/
10. Kholmatova, A. (2017). *Design Systems: A practical guide to creating design languages for digital products*. Smashing Magazine.
11. Curtis, N. (2016-2025). *EightShapes Design Systems Articles*. Medium/EightShapes.
12. Apple Inc. (1986-2025). *Human Interface Guidelines*. Apple Developer Documentation.
13. Google. (2014-2025). *Material Design Guidelines*. material.io.
14. Salesforce. (2015-2025). *Lightning Design System*. lightningdesignsystem.com.
15. IBM. (2016-2025). *Carbon Design System*. carbondesignsystem.com.
16. Microsoft. (2017-2025). *Fluent Design System*. fluent2.microsoft.design.
17. W3C Design Tokens Community Group. (2025). *Design Tokens Format Module*. W3C. https://www.designtokens.org/

#### The Elements of User Experience

18. Garrett, J. J. (2011). *The Elements of User Experience: User-Centered Design for the Web and Beyond* (2nd ed.). New Riders.
19. Norman, D. A. (2013). *The Design of Everyday Things* (Revised ed.). Basic Books.
20. Nielsen, J. (1993). *Usability Engineering*. Morgan Kaufmann.

### 8.2 学術論文・業界レポート

21. Domain-Driven Design in software development: A systematic literature review. (2023-2025). *arXiv*.
22. Domain-Driven Design for Microservices: An Evidence-Based Investigation. (2024). *IEEE Transactions on Software Engineering*.
23. Sparkbox. (2020-2025). *Design System Maturity Model Assessment*. Sparkbox Foundry.
24. A Systematic Literature Review of Design Thinking Approach for User Interface Design. (2024). *JOIV: International Journal on Informatics Visualization*.

### 8.3 オンラインリソース

25. Martin Fowler's Blog: https://martinfowler.com/
26. DDD Community: https://www.dddcommunity.org/
27. Journal of Information Architecture: https://journalofia.org/
28. World Information Architecture Association: https://www.information-architecture.world/
29. Atomic Design: https://atomicdesign.bradfrost.com/
30. EightShapes Design Systems: https://medium.com/eightshapes-llc
31. Design Tokens Community Group: https://www.w3.org/community/design-tokens/
32. Clarity Design Conference (Jina Anne): https://www.clarityconf.com/
33. Design Systems Surf (事例集): https://designsystems.surf/

### 8.4 デザインシステム主要人物

| 人物 | 貢献 | 所属/関連組織 |
|---|---|---|
| Brad Frost | Atomic Design提唱、Pattern Lab開発 | 独立コンサルタント |
| Jina Anne | Design Tokens発明、W3C DTCG Co-chair | Salesforce (元)、Clarity創設者 |
| Nathan Curtis | DSガバナンスモデル、チームモデル研究 | EightShapes |
| Alla Kholmatova | DS設計原則の体系化 | FutureLearn (元)、Smashing Magazine |
| Matías Duarte | Material Designリード | Google |
| Jon Levine | Design Tokens共同発明 | Salesforce |

---

**Document Information**
- Author: AI Research Assistant
- Created: 2026-01-25
- Version: 1.0
- License: CC BY-SA 4.0
