---
name: plan-to-issues
description: docs/plan.md のタスクを GitHub Issue にする。作成前に一覧を提示して確認を取り、作成後に Issue 番号を plan.md に書き戻す。「計画を Issue にして」と言われたときに使う。
argument-hint: [タスク番号の範囲(省略可。例: 3-5)]
disable-model-invocation: true
allowed-tools: Bash(gh auth status) Bash(gh repo view *) Bash(gh issue list *) Bash(gh issue create *) Bash(git remote *)
---

<!--
  【任意 Skill】計画を GitHub Issue にする(/plan-to-issues)
  置き場所: .claude/skills/plan-to-issues/SKILL.md
  標準の7つの Skills には含まれていない。Issue 管理をしたい場合だけ追加する。
  前提:
    - GitHub にリポジトリがあり、git の remote が設定されている
    - gh コマンド(GitHub CLI)がインストールされ、ログイン済み(gh auth status)
  注意:
    - Issue は外部(GitHub)に残り、通知も飛ぶ。作成前に必ず人が確認する(手動実行のみ・確認ステップあり)。
    - 公開リポジトリでは、本文に秘密情報・社内情報を書かない。
    - allowed-tools の gh issue create は、プロジェクトの運用(ラベル、担当者の指定など)に合わせて調整する。
    - このテンプレートの gh の使い方は一般的な書き方に基づく例で、環境での動作は未確認。
-->

`docs/plan.md` のタスクを GitHub Issue にしてください。対象: $ARGUMENTS(空なら、Issue 番号が未記入のタスクすべて)

## 手順

1. **環境を確認する。** `gh auth status` と `gh repo view` で、ログイン済みで、対象リポジトリが分かることを確認する。できなければ、状況を報告して止まる。
2. `docs/plan.md` を読み、対象タスクを選ぶ。すでに Issue 番号が書かれているタスクは対象外とする。
3. `gh issue list` で、同じタイトルの Issue が既にないか確認する(重複防止)。
4. **作成する Issue の一覧を提示して、確認を待つ。** この時点では、Issue を作らない。各 Issue について、次を示す。
   - タイトル: `【タスク番号】タスクの題名`
   - 本文: 目的(spec への参照)、変更予定のファイル、確認方法、依存するタスク、完了条件のチェックリスト
   - ラベル(あれば。存在しないラベルは付けない)
5. **「作成してよいか」の返事があった場合のみ**、`gh issue create` で1件ずつ作成する。
6. 作成した Issue の番号を、`docs/plan.md` の該当タスクに書き戻す(例: `- [ ] **3. …** (#12)`)。
7. 作成した Issue の一覧(番号・タイトル・URL)を報告する。

## 制約

- 確認なしに Issue を作らない。
- 本文に、秘密情報(キー、パスワード、個人情報)を書かない。
- Issue のクローズ、編集、削除はしない(作成のみ)。
- `docs/plan.md` のタスク内容は変更しない(Issue 番号の追記のみ)。
