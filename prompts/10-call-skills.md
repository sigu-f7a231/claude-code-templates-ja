<!--
  Skills を呼び出す指示テンプレート
  使い方: 作業の段階に合わせて、必要な部分をコピーして Claude Code に貼る。
  ポイント:
    - スキルを直接実行するには、メッセージの先頭に /スキル名 を書く(文中に書くだけでは直接実行にならない)。
    - 引数はスペース区切りで続ける(例: /implement 3)。
    - 副作用のあるスキル(implement / commit / release)は、手動実行のみに設定してある。
    - 各スキルの終了時に Claude が報告するので、内容を確認してから次へ進む。
-->

# Skills 呼び出し集

## A. 通しの流れ(1機能を作る場合)

```text
/spec 【機能名または概要】
```
→ 質問に答える → `docs/spec.md` を確認・修正する

```text
/plan-tasks 【機能名】
```
→ `docs/plan.md` の計画を確認して承認する(修正があれば伝える)

```text
/implement 1
```
→ 報告を確認 → `/test` → 問題なければ `/review` → `/commit`

```text
/test
/review
/commit
```
→ タスクが残っている間、`/implement 2` 以降を繰り返す

```text
/release 【バージョン】
```
→ チェック結果を確認し、公開操作は自分で行う

## B. 1タスクごとのサイクル

```text
/implement 【タスク番号】
/test
/review
```
→ レビューの指摘に対応する場合:

```text
レビューの指摘のうち、重要度「高」と「中」を修正してください。修正後に /test を実行してください。
```

```text
/commit
```

## C. 計画をスキップしない小さな修正

```text
【修正内容を具体的に】。実装後に /test を実行してください。
```

(小さな修正は、スキルを使わず通常の依頼で十分です。)

## D. Skills を使うことを Claude に伝える一括指示

```text
次の順で進めてください。各ステップの終わりで報告し、私の承認を待ってから次へ進んでください。
1. /spec 【機能名】
2. /plan-tasks 【機能名】
3. 計画の承認後、タスクごとに /implement → /test → /review → /commit
```

## E. 状況別

| 状況 | 呼び出し |
|---|---|
| 何を作るか曖昧 | `/spec 【概要】` |
| 作業が大きい | `/plan-tasks 【機能名】` |
| 実装を始める | `/implement 【番号】` |
| テストが落ちる | `/test 【対象】` |
| 変更を確認したい | `/review` |
| 区切りがついた | `/commit` |
| 公開前 | `/release 【バージョン】` |

## F. CLAUDE.md に書いておくと便利な一節

```markdown
## ワークフロー(Skills)

作業は次の Skills で進める。いずれも `.claude/skills/` にある。
- `/spec`: 要件整理(`docs/spec.md`)
- `/plan-tasks`: 計画とタスク分解(`docs/plan.md`)
- `/implement <番号>`: 計画の1タスクを実装
- `/test`: テスト実行と修正
- `/review`: 差分のレビュー(読み取り専用)
- `/commit`: コミット(push はしない)
- `/release <版>`: 公開前チェック(公開操作は人が行う)

進め方: spec → plan-tasks → (implement → test → review → commit)を繰り返す → release
```
