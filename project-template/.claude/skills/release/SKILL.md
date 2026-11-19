---
name: release
description: 公開前のチェックリストを実行し、公開の準備を整える。「リリースして」「公開前の確認をして」と言われたときに使う。
argument-hint: [バージョンまたはリリース名]
disable-model-invocation: true
allowed-tools: Bash(npm test *) Bash(npm run build) Bash(npm run lint) Bash(git status *) Bash(git log *)
---

<!--
  【ワークフロー Skill 7/7】リリース準備(/release)
  置き場所: .claude/skills/release/SKILL.md
  役割: 公開前のチェックと準備まで。本番へのデプロイ・push・タグ付けは、人の確認を挟む。
  手動実行のみ(disable-model-invocation: true)。
  allowed-tools はプロジェクトのコマンドに合わせて書き換える(Flutter なら flutter build など)。
-->

リリース「$ARGUMENTS」の準備をしてください。**本番への公開操作は行いません。**

## チェック手順

1. 作業ツリーがきれいか確認する(`git status`)。未コミットの変更があれば報告して止まる。
2. テストと lint を実行し、すべて通ることを確認する。
3. ビルドを実行し、成功することを確認する。
4. `docs/spec.md` の完了条件を1つずつ照合し、未達があれば報告する。
5. 次を確認する。
   - 秘密情報がコードや設定に含まれていない(`.env` がコミットされていない)
   - `README` のセットアップ・起動手順が最新
   - 変更履歴(`CHANGELOG` など)があれば更新が必要か
6. 前回のリリースからの変更点を、`git log` から要約する。

## 報告

- チェック結果の一覧(OK / 要対応)
- 要対応の項目と、提案する対処
- リリースノートの下書き
- 公開のために**人が実行する手順**(デプロイ、タグ付け、ストア申請など)

## 制約

- デプロイ、`git push`、タグの作成、ストア申請などは実行しない。手順の提示までとする。
