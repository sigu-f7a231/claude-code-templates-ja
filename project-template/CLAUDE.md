<!--
  ワークフロー用 CLAUDE.md テンプレート
  置き場所: ./CLAUDE.md(チーム共有)
  役割: 工程別 Skills(spec / plan-tasks / implement / test / review / commit / release)が参照する前提を書く。
  Skills は、ここに書かれたコマンドと規約を前提に動く。【 】を埋めて使う。
  200行未満に保つ。
-->

# 【プロジェクト名】

【プロジェクトの概要を1〜3行で】

## Rules(`.claude/rules/`)に書いてあるもの

次の内容は、`CLAUDE.md` ではなく `.claude/rules/` に書く。起動時に自動で読み込まれる(`code-style.md` は、パス限定の場合は該当ファイルを触るときだけ)。

| 知りたいこと | ファイル |
|---|---|
| 技術スタック | `.claude/rules/tech-stack.md` |
| よく使うコマンド(テスト・lint・ビルドなど) | `.claude/rules/commands.md` |
| コード規約 | `.claude/rules/code-style.md` |
| 作業ルール | `.claude/rules/work-rules.md` |
| 注意事項・落とし穴 | `.claude/rules/cautions.md` |

## ワークフロー(Skills)

作業は次の Skills で進める。いずれも `.claude/skills/` にある。

- `/spec <概要>`: 要件整理 → `docs/spec.md`
- `/plan-tasks <機能>`: 計画とタスク分解 → `docs/plan.md`(承認を待つ)
- `/implement <番号>`: 計画の1タスクを実装(範囲外はやらない)
- `/test`: テスト実行と修正
- `/review`: 差分のレビュー(読み取り専用)
- `/commit`: コミット(push はしない)
- `/release <版>`: 公開前チェック(公開操作は人が行う)

進め方: spec → plan-tasks → (implement → test → review → commit)を繰り返す → release

## ドキュメントの置き場所

- 仕様: `docs/spec.md`(要件・完了条件)
- 作業の流れ: `docs/workflow.md`
- 計画: `docs/plan.md`(タスクと進捗)
- 仕様にない機能は追加しない。仕様が変わるときは、先に `docs/spec.md` を更新する。

