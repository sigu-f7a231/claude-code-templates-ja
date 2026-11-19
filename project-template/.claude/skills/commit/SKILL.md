---
name: commit
description: 変更内容を確認して、適切な粒度でコミットする。「コミットして」と言われたときに使う。
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *) Bash(git diff *) Bash(git log *)
---

<!--
  【ワークフロー Skill 6/7】コミット(/commit)
  置き場所: .claude/skills/commit/SKILL.md
  役割: 差分の確認とコミット。push はしない。
  副作用があるので手動実行のみ(disable-model-invocation: true)。
  allowed-tools には git push を入れない(push は人が行う)。
-->

## 現在の状態

- 状態: !`git status --short`
- 直近のコミット: !`git log --oneline -5`

## 手順

1. 差分(`git diff`)を確認し、変更が**1つの目的**にまとまっているか確認する。複数の目的が混ざっていれば、分けてコミットすることを提案する。
2. 秘密情報(キー、パスワード、`.env`)や、不要なファイル(ビルド成果物、一時ファイル)が含まれていないか確認する。あれば、ステージせずに報告する。
3. 関連するファイルだけを `git add` で個別にステージする(`git add -A` は避ける)。
4. コミットメッセージを書く。
   - 1行目: 変更の要約(50文字程度、「何を」「なぜ」が分かるように)
   - 必要なら、空行のあとに理由や補足
   - 直近のコミットの書式に合わせる
5. コミットして、結果(ハッシュとメッセージ)を報告する。

## 制約

- `git push`、`git reset --hard`、`git rebase`、履歴の書き換えはしない。
- フック(pre-commit など)が失敗した場合は、`--no-verify` で回避せず、原因を報告して直す。
