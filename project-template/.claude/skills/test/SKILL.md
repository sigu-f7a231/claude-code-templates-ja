---
name: test
description: テストを実行して結果を分析し、失敗があれば原因を調べて修正する。「テストして」「テストが落ちる」と言われたときに使う。
argument-hint: [対象(省略可。ファイルやテスト名)]
allowed-tools: Bash(npm test *) Bash(npm run lint) Bash(git status *) Bash(git diff *)
---

<!--
  【ワークフロー Skill 4/7】テスト(/test)
  置き場所: .claude/skills/test/SKILL.md
  役割: テストの実行・失敗の分析・修正。
  allowed-tools: テスト実行コマンドの事前許可。プロジェクトのコマンド(npm test など)に合わせて書き換える。
  Flutter なら Bash(flutter test *) Bash(flutter analyze)、Python なら Bash(pytest *) など。
-->

テストを実行して、結果を確認してください。対象: $ARGUMENTS(空なら全体)

## 手順

1. よく使うコマンド(`.claude/rules/commands.md`)のテスト・lint を確認する。
2. 対象のテストを実行する。続けて lint も実行する。
3. 失敗がある場合:
   - 失敗したテスト名とエラーメッセージを整理する。
   - 原因を、**テストが誤っているのか、実装が誤っているのか**を切り分けて調べる。
   - 実装を直す。仕様に反しない限り、テストを通すためにテストを弱めない。
   - 再実行して、通ることを確認する。
4. 次を報告する: 実行したコマンド、結果(成功/失敗の件数)、直した内容と原因、残っている問題。

## 制約

- 失敗するテストを削除・スキップして通さない。やむを得ない場合は理由を示して確認する。
- 仕様の変更が必要そうな場合は、修正せずに報告する。
