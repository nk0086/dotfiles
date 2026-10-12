# dotfiles

Nix Flake + Home Manager で管理する macOS (Apple Silicon) / Linux 向け dotfiles。

## 構成

```
.
├── flake.nix                  # Flake 定義 (inputs / homeConfigurations)
├── home-manager/
│   ├── home.nix               # 共通設定・パッケージ一覧
│   ├── platforms/             # darwin.nix / linux.nix
│   └── programs/              # プログラムごとの設定
│       ├── bat.nix
│       ├── direnv.nix
│       ├── eza.nix
│       ├── gh.nix
│       ├── neovim.nix
│       ├── wezterm.nix         # 任意の GUI モジュール
│       └── zsh.nix
├── config/
│   ├── nvim/                  # Neovim 設定 (Lua)
│   │   ├── init.lua
│   │   ├── config/            # keymaps, LSP, formatter, autocmds 等
│   │   └── plugins/           # プラグイン設定
│   └── wezterm/               # WezTerm 設定 (Lua)
└── Taskfile.yml               # フォーマット・チェック用タスク
```

## セットアップ

### 前提

- macOS (aarch64-darwin) または Linux (x86_64-linux / aarch64-linux)
- [Nix](https://nixos.org/) がインストール済み（Flakes 有効）

### ホスト設定

| `TARGET` | Flake 出力 | OS / CPU | ホームディレクトリ |
|---|---|---|---|
| `mac`（既定） | `myHomeConfig` | macOS / Apple Silicon | `/Users/nk`（既存設定を維持） |
| `linux` | `linuxHomeConfig` | Linux / x86_64 | `/home/nk` |
| `linux-arm64` | `linuxArmHomeConfig` | Linux / aarch64 | `/home/nk` |

適用前に `home-manager/home.nix` の `home.username` と `platforms/` の
`home.homeDirectory` が対象ユーザーに一致することを確認する。
Linux は headless 向けで、GUI と clipboard コマンドを前提にしない。
WezTerm を使う Linux デスクトップでは `platforms/linux.nix` に
`imports = [../programs/wezterm.nix];` を追加できる。macOS では従来どおり有効。

### 初回セットアップ

まず lock ファイルを変更せずにビルドする。ビルドだけではホーム環境に適用されない。

```bash
git clone https://github.com/nk0086/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
nix build --no-update-lock-file .#homeConfigurations.myHomeConfig.activationPackage
```

内容を確認してから、同じ lock の Home Manager で適用する。
Linux の場合は上記と下記の出力名を対象ホストに合わせて置き換える。

```bash
nix run --no-update-lock-file --inputs-from . home-manager -- \
  switch --no-update-lock-file --flake .#myHomeConfig
```

`~/.safe-chain/scripts/init-posix.sh` は任意で、存在して読み込める場合だけ使用する。
Zsh 起動時には `~/.github_token` / `~/.openai_api_key` を読まず、トークンを自動 export しない。
必要なコマンドだけに渡す方法は下記を参照。
macOS の GPG SSH agent 連携は `gpgconf` がある場合だけ行う。Linux では既存の SSH agent を引き継ぐ。
端末がない場合に `tty` を呼ばない。
秘密情報はリポジトリや Nix 設定に埋め込まない。

### トークンを必要なコマンドだけに渡す

通常の `gh` は [公式の `gh auth login`](https://cli.github.com/manual/gh_auth_login) による
認証を使う。未設定の場合は自分で次を実行する。dotfiles の適用ではログイン・資格情報の移行は行わない。

```bash
gh auth login --hostname github.com --web
gh auth status
```

`gh` は利用可能なら OS の資格情報ストアを使うが、利用できない場合は平文ファイルへ保存する
フォールバックがある。ログイン時の案内と `gh auth status` で保存先を確認する。
`GH_TOKEN` / `GITHUB_TOKEN` が既に設定されていると
[保存済み認証より優先される](https://cli.github.com/manual/gh_help_environment)ため、移行時は下記の継承にも注意する。

既存の平文ファイルを使う必要がある場合だけ、Zsh の次のヘルパーを明示的に呼ぶ。

| ヘルパー | 読むファイル | 指定したプロセスに渡す変数 |
|---|---|---|
| `with-openai-key COMMAND [ARG ...]` | `~/.openai_api_key` | `OPENAI_API_KEY` |
| `with-github-token COMMAND [ARG ...]` | `~/.github_token` | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| `gh-with-token [ARG ...]` | `~/.github_token` | `gh` にだけ `GH_TOKEN` |

```bash
with-openai-key python ./script.py "argument with spaces"
with-github-token /path/to/github-tool  # 実際に使う GitHub MCP / SDK のコマンドに置き換える
gh-with-token pr list                  # 通常は gh pr list を使う
```

- 各ヘルパーは実行時に必要なファイルだけを読み、サブシェルで指定コマンドとその子プロセスに渡す。
  親シェルやその後の別コマンドには追加しない。コマンドの引数と終了コードは維持する。
- ファイルはトークン文字列のみ（末尾改行は可）。シェルスクリプトや `export KEY=...` の形式にはしない。
  存在しない・読めない・空・空白や途中改行を含む場合は、コマンドを起動せずエラーにする。
- ファイルを `source` せず、値をコマンド引数や helper のトレースに出さない。
  実行先自身のログ・デバッグ出力や子プロセスへの継承までは制限できないので、信頼するコマンドだけに使う。
- 秘密ファイルは Git 管理外かつ Nix store 外に置き、所有者のみ読める権限を自分で確認する。
  `builtins.readFile`、Nix 文字列への埋め込み、`home.file.*.text` / `.source` で秘密を管理しない。
  この設定は既存ファイルの作成・移動・削除・権限変更を行わない。

移行で変わる点:

- 以前の自動 export に依存する OpenAI API クライアントや GitHub MCP / SDK は、そのまま起動すると
  キーがなく認証に失敗することがある。上のヘルパーで必要なプロセスだけを起動する。
  `with-github-token` の変数名は `gh` 用ではないため、`gh` のファイル利用には `gh-with-token` を使う。
- ヘルパーは対話 Zsh の関数。GUI アプリ・サービス・非対話スクリプトの設定は自動では変わらない。
- 既に起動中のシェルやアプリに継承済みの変数は消さない。`source ~/.zshrc` や `exec zsh` だけでは
  古い値が残り得る。適用後、新しい端末を開くか、現在の端末で次のようにキーを除いた子シェルを開始する。
  他の起動中アプリの環境は変更しない。ヘルパーも既存の無関係な環境変数を削除しない。

```bash
env -u GH_TOKEN -u GITHUB_TOKEN -u GITHUB_PERSONAL_ACCESS_TOKEN -u OPENAI_API_KEY zsh
```

## コマンド

[go-task](https://taskfile.dev/) でタスクを実行する。
対象はコマンドラインの `TARGET` で指定し、省略時は従来どおり `mac`（`myHomeConfig`）。
`mac` / `linux` / `linux-arm64` 以外の値（空文字を含む）は、Nix の実行前にエラーになる。

| コマンド | 説明 |
|---|---|
| `task build TARGET=mac` | macOS の設定をビルド（適用しない） |
| `task build TARGET=linux` / `task build TARGET=linux-arm64` | 対象 Linux の設定をビルド（適用しない） |
| `task apply TARGET=mac` / `task apply TARGET=linux` / `task apply TARGET=linux-arm64` | 既存 lock で対象ホストに適用 |
| `task build` / `task apply` | 既定の macOS 設定をビルド / 適用 |
| `task sync` | `task apply` の互換エイリアス。`TARGET` も指定可能 |
| `task update` | `flake.lock` の更新のみ（ビルド・適用しない） |
| `task format` | Nix / Lua ファイルをフォーマット |
| `task check` | フォーマット・隔離した shell 起動・Task コマンドのチェック |

```bash
task build TARGET=linux
task --dry apply TARGET=linux-arm64  # 適用コマンドを表示するだけ
task check:shell   # 起動・トークンの限定注入を fixture で検証（実際の秘密ファイルや GPG agent は使わない）
task check:tasks   # 全 TARGET・既定値・不正値を dry-run で検証（Nix は実行しない）

# 依存更新が必要なときだけ、変更をレビューしてから別々に実行
task update
git diff -- flake.lock
task build TARGET=mac
task apply TARGET=mac
```

以前の `build:macos` / `build:linux` / `build:linux-arm64` と対応する `apply:*` は、
上記の `TARGET` 指定に統一した。出力名を直接指定する `HOME_CONFIG` の代わりに `TARGET` を使う。
`HOME_CONFIG` は参照しないため、対象の選択は `TARGET` のみに従う。
`build` / `apply` は lock の更新が必要なら失敗する。`home.stateVersion = "24.05"` は維持する。
各ホストのビルドは対応する OS / CPU（または明示的に設定した remote builder）で検証する。
Linux 上の評価だけでは macOS のビルド・起動確認にはならない。

### Neovim の実行ファイル

`programs/neovim.nix` の `extraPackages` に、現在の LSP / formatter 設定で使う
実行ファイルを宣言している。これらは Neovim 内の PATH に追加される。
Rust の解析に使う Cargo / rustc と、既存の native plugin のビルドに使う make / C compiler も含む。
バージョンは既存の `flake.lock` の nixpkgs に従う。
Lua のプラグイン取得は引き続き既存の lazy.nvim 設定を使うため、初回起動にはネット接続が必要。

## 主なパッケージ

- **エディタ**: Neovim (nightly)
- **ターミナル**: WezTerm
- **シェル**: Zsh + Starship
- **Git 関連**: git-extras, git-trim, tig, delta, gh
- **CLI ツール**: fzf, ripgrep, zoxide, bat, eza, httpie, ranger
- **開発言語/ツール**: Go, Python, Deno, Node.js, Zig, Nim, Gleam, Lua, Erlang
- **Nix**: nil (LSP), alejandra (formatter), nix-output-monitor
