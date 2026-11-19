# 指示文の雛形(Claude Code に貼り付けて使う)

Claude Code に渡す**指示文(プロンプト)**のひな形です。`【 】` を埋めて貼り付けます。解説は [`../read/11-prompt-templates.md`](../read/11-prompt-templates.md) にあります。

## 一覧

### 開発の最初に使う(プロジェクトの種類別)

| ファイル | 種類 | 向いているもの |
|---|---|---|
| `00-first-instruction.md` | **最初の指示(共通)** | どの種類でも最初に使う。質問 → 計画 → 承認 → 実装の流れを伝える |
| `01-static-page.md` | 静的ページ | 1〜数ページの HTML/CSS。ビルド・サーバー不要 |
| `02-landing-page.md` | LP | 1つの目的(申込・問い合わせ等)に絞った縦長 1 ページ |
| `03-homepage.md` | HP | 会社・店舗の複数ページのサイト(更新・運用あり) |
| `04-web-app.md` | Web アプリ | ログイン・データ操作を伴う業務/サービス系 |
| `05-responsive-web-app.md` | レスポンシブ Web アプリ | PC・タブレット・スマホ全対応(PWA も可) |
| `06-mobile-app-flutter.md` | スマホアプリ(Dart/Flutter) | 1つのコードで iOS と Android |
| `07-native-app.md` | ネイティブアプリ | iOS(Swift)/ Android(Kotlin)の OS 専用 |

### 工程別ワークフロー(`../project-template/`)と一緒に使う

| ファイル | 内容 |
|---|---|
| `10-call-skills.md` | Skills(`/spec` 〜 `/release`)の呼び出し方の指示集。通しの流れ、1タスクごとのサイクル、状況別の早見表 |
| `11-spec-input.md` | `/spec` に渡すアイデアメモのひな形(`/spec docs/idea.md` で渡す) |

## 使い方

1. 作るものの種類を選ぶ(選び方は `../read/11-prompt-templates.md`)。
2. `00-first-instruction.md` を埋めて貼り付ける(まず質問と計画だけをさせる)。
3. 続けて、種類別のテンプレートを埋めて貼り付ける。
4. 計画に合意したら、`../project-template/` を導入し、`10-call-skills.md` の流れで進める。
   手順の全体は `../read/13-from-instruction-to-release.md`。

## 注意

- これらは、公式ドキュメントの内容ではなく、一般的な開発の進め方をもとに私が作成した例です。
- 技術名(React、Riverpod、Room など)は例です。指定しなければ、Claude に提案させられます。
