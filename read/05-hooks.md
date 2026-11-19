# Claude Code Hooks とは・書き方

出典: 公式ドキュメント [Hooks guide](https://code.claude.com/docs/en/hooks-guide) / [Hooks reference](https://code.claude.com/docs/en/hooks)(2026-11-19 時点)
関連ファイル: `02-claude-md.md` / `03-rules.md` / `04-skills.md` / `01-prompt-rules-skills-diff.md`
※ 公式ページの一部(SessionStart・UserPromptSubmit の入力スキーマ、HTTP レスポンス処理の節など)は要約経由で、原文を確認できていません。細部は公式で確認してください。

## 1. Hooks とは

Claude Code のライフサイクルの特定のタイミングで、**自動的に実行されるユーザー定義の処理**です。処理の種類は、シェルコマンド、HTTP エンドポイント、MCP ツール呼び出し、LLM プロンプト、サブエージェントのいずれかです。

- 目的は**決定的な制御**。「Claude が気づいたらやる」ではなく、「必ずやる / 必ず止める」を実現します。
- CLAUDE.md / Rules / Skills は Claude への「お願い(コンテキスト)」ですが、Hooks はプログラムとして**確実に実行**されます。

| | CLAUDE.md / Rules / Skills | Hooks |
|---|---|---|
| 性質 | 指示(Claude が従うかは保証されない) | 処理(確実に実行される) |
| 書くもの | Markdown の文章 | settings.json の設定 + スクリプト |
| 向いている用途 | 規約・手順・知識 | 強制・自動化・ブロック・通知 |

## 2. 設定場所

| 場所 | 適用範囲 | 共有 |
|---|---|---|
| `~/.claude/settings.json` | 自分の全プロジェクト | しない |
| `.claude/settings.json` | そのプロジェクト | できる(コミット) |
| `.claude/settings.local.json` | そのプロジェクト | しない(gitignore) |
| 管理ポリシー設定 | 組織全体 | 管理者が配布 |
| プラグインの `hooks/hooks.json` | プラグイン有効時 | プラグインと一緒に配布 |
| Skill のフロントマター | スキル呼び出し後、セッション中 | できる |
| サブエージェントのフロントマター | そのサブエージェント実行中 | できる |

- 各レベルの設定は**マージ**されます(ユーザー/プロジェクト設定で、管理設定のフックを消すことはできない)。
- 現在の設定の確認は `/hooks`(読み取り専用のブラウザ)。削除は設定ファイルから該当エントリを消します。

## 3. 設定の構造

**イベント → マッチャーグループ → フックハンドラー** の 3 階層です。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.sh",
            "args": []
          }
        ]
      }
    ]
  }
}
```

### ハンドラーの種類(`type`)

| type | 内容 |
|---|---|
| `command` | シェルコマンドを実行。入力は stdin、結果は終了コードと stdout/stderr |
| `http` | 入力 JSON を POST。レスポンスは同じ JSON 形式 |
| `mcp_tool` | 設定済み MCP サーバーのツールを呼ぶ |
| `prompt` | LLM に単発で判定させる(`{"ok": true/false, "reason": "..."}`) |
| `agent` | Read/Grep/Glob を使えるサブエージェントで検証(実験的) |

### 主なフィールド

| フィールド | 内容 |
|---|---|
| `matcher` | どのツール名/ソースで発火するか(下記) |
| `if` | 権限ルール形式の追加フィルタ(例 `"Bash(git *)"`, `"Edit(*.ts)"`)。ツール系イベントのみ。ベストエフォートなので、確実な制限は権限システムで |
| `timeout` | 秒。既定: command/http/mcp_tool は 600、prompt は 30、agent は 60 |
| `statusMessage` | 実行中に表示するスピナー文言 |
| `once` | 初回成功後に削除(Skill のフロントマターのみ有効) |
| `async` | バックグラウンド実行(ブロックはできない) |
| `onFailure` | `"continue"` / `"block"`(失敗時にブロックする。v2.1.295 以上) |

### マッチャーの書き方

- `"*"`、`""`、省略: すべてに一致。
- 英数字・`_`・`-`・スペース・`,`・`|` のみ: 完全一致のリスト(`Edit|Write`、`Edit, Write`)。
- それ以外: JavaScript の正規表現(部分一致)。MCP ツールは `mcp__<server>__<tool>` 形式で、`mcp__memory__.*` のように書く。
- 大文字小文字は区別される。

### パスの書き方

- `${CLAUDE_PROJECT_DIR}` でプロジェクトルートを指す。
- シェル形式ではダブルクォートで囲む(`"$CLAUDE_PROJECT_DIR"/.claude/hooks/x.sh`)。
- `args` を指定する exec 形式なら、シェルを介さず直接起動される(パスの扱いが安全)。

## 4. 主なイベント

| イベント | 発火タイミング | ブロック可 |
|---|---|---|
| `SessionStart` | セッション開始・再開 | × |
| `UserPromptSubmit` | プロンプト送信後、処理前 | ○ |
| `PreToolUse` | ツール実行の**前** | ○ |
| `PermissionRequest` | 権限確認が必要なとき | (decision で制御) |
| `PostToolUse` | ツール成功の**後** | ×(実行済み) |
| `PostToolUseFailure` | ツール失敗の後 | × |
| `Notification` | 通知の送信時 | × |
| `SubagentStart` / `SubagentStop` | サブエージェントの開始/終了 | Stop は○ |
| `Stop` | Claude が応答を終えたとき | ○(続行させる) |
| `PreCompact` / `PostCompact` | コンテキスト圧縮の前/後 | Pre は○ |
| `InstructionsLoaded` | CLAUDE.md や rules の読み込み時 | × |
| `ConfigChange` | セッション中の設定変更 | ○ |
| `CwdChanged` / `FileChanged` | ディレクトリ変更/監視ファイルの変更 | × |
| `SessionEnd` | セッション終了 | × |

他にも `Setup`、`UserPromptExpansion`、`PermissionDenied`、`PostToolBatch`、`TaskCreated`、`TaskCompleted`、`WorktreeCreate` など多数あります(全一覧は公式のリファレンス参照)。

マッチャーが効くイベント: ツール系(`PreToolUse` など)はツール名、`SessionStart` は開始元(`startup` / `resume` / `clear` / `compact`)、`Notification` は通知種別(`permission_prompt` / `idle_prompt`)など。`UserPromptSubmit` や `Stop` はマッチャー非対応で、常に発火します。

## 5. 入力と出力

### 入力(stdin に JSON)

共通: `session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`。ツール系は `tool_name` と `tool_input` が入ります。

```json
{
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": { "command": "npm test", "description": "Run test suite" }
}
```

- Edit/Write の `tool_input` には `file_path`(常に絶対パス)が入る。Windows ではバックスラッシュなので正規化が必要。
- PostToolUse には `tool_response` も入る。

### 終了コード

| 終了コード | 意味 |
|---|---|
| `0` | 成功。stdout が単一の JSON オブジェクトなら解析される |
| `2` | **ブロッキングエラー**。stderr が理由として Claude に返る(ブロック可能なイベントのみ) |
| その他(`1` を含む) | 非ブロッキングエラー。処理は続行される |

- **`exit 1` ではブロックされません。** ブロックしたいときは必ず `exit 2` を使います。
- `exit 0` は承認ではありません。PreToolUse でも、通常の権限フローに進みます。

### JSON 出力(exit 0 のとき)

イベント固有の決定は `hookSpecificOutput` の中に書きます(トップレベルに書くと無視される)。

PreToolUse:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep for better performance"
  }
}
```

- `permissionDecision`: `allow`(確認を省略。ただし deny/ask ルールは有効)/ `deny` / `ask` / `defer`
- `updatedInput` で入力を書き換え、`additionalContext` で Claude に文脈を追加できる。
- 複数フックの優先順位: `deny` > `defer` > `ask` > `allow`。

PostToolUse / Stop / SubagentStop はトップレベルの `decision`:

```json
{ "decision": "block", "reason": "Must be provided when Claude is blocked from stopping" }
```

UserPromptSubmit は `additionalContext` でプロンプトに文脈を足せます(plain な stdout も文脈として追加される)。

### 複数フック

一致したフックは**並列**で実行され、すべて完了まで走ります。あるフックの deny が、他のフックの副作用を止めるわけではありません。

## 6. 何を書けばよいか(代表的な用途)

### a. 入力待ちのデスクトップ通知(macOS)

`~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

Linux は `notify-send 'Claude Code' 'Claude Code needs your attention'`。`permission_prompt` や `idle_prompt` に絞ることも可能です。

### b. 編集後に自動フォーマット

`.claude/settings.json`(`jq` が必要):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path') && npx prettier --write --ignore-unknown \"$f\""
          }
        ]
      }
    ]
  }
}
```

### c. 危険なコマンドをブロック

`.claude/hooks/no-rm.sh`:

```bash
#!/bin/bash
input=$(cat)
command=$(jq -r '.tool_input.command' <<<"$input")

if [[ "$command" == rm* ]]; then
  echo "Blocked: rm commands are not allowed" >&2
  exit 2  # ブロッキングエラー: ツール実行が止まる
fi

exit 0  # 判断なし: 通常の権限フローへ
```

登録(`if` で `rm` コマンドのときだけスクリプトを起動):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/no-rm.sh"
          }
        ]
      }
    ]
  }
}
```

`chmod +x` で実行権限を付けるのを忘れずに。

### d. 重要ファイルの編集を禁止

`.claude/hooks/protect-files.sh`:

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
FILE_PATH="${FILE_PATH//\\//}"   # Windows のバックスラッシュを正規化

PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/")

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH matches protected pattern '$pattern'" >&2
    exit 2
  fi
done

exit 0
```

登録(マッチャーは `Edit|Write`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ]
  }
}
```

シェルコマンド経由の書き換えは防げないため、`permissions.deny` やサンドボックスとの併用が推奨されています。

### e. コンパクション後にコンテキストを再注入

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing.'"
          }
        ]
      }
    ]
  }
}
```

毎セッション必要な内容は、フックではなく CLAUDE.md に書きます。

### f. コマンドの実行ログを残す

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "jq -r .tool_input.command >> ~/.claude/bash.log" }
        ]
      }
    ]
  }
}
```

### g. その他(公式にある例)

- `Stop` + `prompt`/`agent` フック: タスクやテストが終わるまで Claude を止めさせない
- `PermissionRequest` で `ExitPlanMode` を自動承認(マッチャーを広くしすぎると全プロンプトを承認してしまうので注意)
- `SessionStart` / `CwdChanged` で direnv の環境変数を読み込み
- `type: "http"` で外部サーバーに通知・審査を委譲

## 7. 書かないほうがよいもの・注意点

- **ブロックしたいのに `exit 1` を使う。** 非ブロッキング扱いで素通りします。`exit 2` を使う。
- **PostToolUse で取り消そうとする。** ツールは実行済みで、取り消せません。止めたいなら PreToolUse。
- **広すぎるマッチャーでの自動承認。** 全リクエストを承認してしまう危険があります。
- **`if` だけに頼る。** ベストエフォートです。確実な制限は `permissions` で。
- **Stop フックの無限ループ。** 入力の `stop_hook_active` が `true` なら `exit 0` で終える。8 回連続で続行させると、Claude Code が強制的にターンを終了させます。
- **シェルのプロファイル出力。** 無条件の `echo` があると JSON が壊れて無視されます。
- **タイムアウトの放置。** PreToolUse のタイムアウトは、`onFailure: "block"` がない限りブロックしません。

## 8. セキュリティ

- コマンドフックは**自分のユーザー権限で**実行されます。ファイルの読み書き・削除が可能なので、内容を確認・テストしてから使います。
- 対話セッションでは、ワークスペースの信頼ダイアログを承認するまでフックは保留されます。
- `claude -p` や SDK ではダイアログが出ず、リポジトリ内の `.claude/settings.json` のフックがそのまま動きます。**他人が書いたリポジトリでは先に `.claude/` を確認する**か、`--settings '{"disableAllHooks": true}'` を渡します。
- スクリプトでは、変数をクォートする(`"$VAR"`)、`..` を含むパスを拒否する、絶対パスを使う、`.env` や鍵ファイルに触れない。
- 組織向けの制御: `allowManagedHooksOnly`、`allowedHttpHookUrls` など。
- 一時的に全フックを無効化するには `"disableAllHooks": true`(フック単位の無効化はない)。
- `deny` は `bypassPermissions` モードでもブロックしますが、`allow` は deny ルールを回避できません。

## 9. デバッグ

| 目的 | 方法 |
|---|---|
| 設定の確認 | `/hooks` |
| ログの出力 | `claude --debug-file <path>`、または `claude --debug`(ログは `~/.claude/debug/<session-id>.txt`) |
| セッション中にログを有効化 | `/debug` |
| 実行結果の確認 | `Ctrl+O` でトランスクリプトを表示 |
| 手動テスト | 入力 JSON を `echo '{"tool_name":"Bash","tool_input":{"command":"rm x"}}' \| ./hook.sh` で流し、`echo $?` で終了コード確認 |

| 症状 | 確認すること |
|---|---|
| 発火しない | `/hooks` に出ているか、イベント名・マッチャー(大文字小文字)・`if` |
| `command not found` / `No such file or directory` | 絶対パスか `${CLAUDE_PROJECT_DIR}`、`chmod +x` |
| JSON が無視される | シェルのプロファイル出力、決定が `hookSpecificOutput` 内にあるか |
| ブロックされない | `exit 2` を使っているか(`exit 1` は不可) |

## 10. 最小の始め方

1. `.claude/hooks/` にスクリプトを作成し、`chmod +x` する。
2. `.claude/settings.json` の `hooks` に、イベントとマッチャーを書いて登録する。
3. `/hooks` で認識されていることを確認する。
4. 手動で入力 JSON を流して、終了コードと出力をテストする。
5. 実際に Claude に操作させて動作を確認し、うまくいかなければ `--debug` でログを見る。

## 補足: どれを使うか

| やりたいこと | 向いているもの |
|---|---|
| 規約・前提を伝える | CLAUDE.md / Rules |
| 手順を呼び出す | Skills |
| 編集のたびに自動でフォーマット | Hooks(PostToolUse) |
| 特定のコマンド・ファイルを**確実に**止める | Hooks(PreToolUse)/ `permissions.deny` |
| 作業完了の通知 | Hooks(Notification) |

## 配置場所(使うときに、どこに置くか)

Hooks は「設定(いつ・何を実行するか)」と「スクリプト(実行する中身)」の2つで構成され、置き場所が別です。

### 設定(`hooks` キー)

| 範囲 | 置く場所 | 共有 | 使いどころ |
|---|---|---|---|
| プロジェクト | `<プロジェクト>/.claude/settings.json` | ○(Git でコミット) | チームで共通のフック。**基本はここ** |
| 個人用(そのプロジェクトだけ) | `<プロジェクト>/.claude/settings.local.json` | ×(gitignore) | 自分だけのフック(通知など) |
| ユーザー(全プロジェクト共通) | `~/.claude/settings.json` | × | どのプロジェクトでも使う個人のフック |
| 組織(管理) | 管理ポリシー設定 | 組織全員 | 管理者が配布 |
| プラグイン | `<プラグイン>/hooks/hooks.json` | 配布 | プラグインと一緒に配布 |
| Skill / Subagent | それぞれのフロントマターの `hooks` | ○ | そのスキル・サブエージェントの実行中だけ |

### スクリプト

```text
<プロジェクト>/
└── .claude/
    ├── settings.json       ← "hooks" で、下のスクリプトを登録する
    └── hooks/
        ├── block-push.sh   ← chmod +x を忘れずに
        ├── protect-files.sh
        └── show-progress.sh
```

- スクリプトは `.claude/hooks/` に置き、設定からは **`"$CLAUDE_PROJECT_DIR"/.claude/hooks/<名前>.sh`** のように参照します(作業ディレクトリが変わっても動く)。
- **`chmod +x`**(実行権限)が必要です。`jq` が入っていることも確認してください。
- 設定は、各レベルのものが**マージ**されます(個人用の設定で、チームや組織のフックを消すことはできません)。
- 確認: `/hooks`(設定の一覧。読み取り専用)。
- 雛形の入手元: `../templates/hooks/`(`settings-hooks.json` はフックだけの雛形)、`../project-template/.claude/hooks/` と `../project-template/.claude/settings.json`(権限 + フック登録)。

---

## テンプレートと使い方

- テンプレート: [`../templates/hooks/settings-hooks.json`](../templates/hooks/settings-hooks.json)(設定)/ [`../templates/hooks/block-dangerous.sh`](../templates/hooks/block-dangerous.sh) / [`../templates/hooks/protect-files.sh`](../templates/hooks/protect-files.sh)(スクリプト)

### 使い方(手順)

1. スクリプトを `.claude/hooks/` にコピーし、`chmod +x` を付ける。
2. `settings-hooks.json` の必要なイベントだけを `.claude/settings.json` の `hooks` にマージする。
3. `/hooks` で認識されていることを確認する。
4. 入力 JSON を手動で流して、終了コードを確認する(例: `echo '{"tool_input":{"command":"rm -rf /"}}' | .claude/hooks/block-dangerous.sh; echo $?`)。ブロックは `exit 2`。
5. 動かないときは `claude --debug` でログを見る。
