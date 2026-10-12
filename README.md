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

| `TARGET` | Flake 出力 | OS / CPU |
|---|---|---|
| `mac`（既定） | `myHomeConfig` | macOS / Apple Silicon |
| `linux` | `linuxHomeConfig` | Linux / x86_64 |
| `linux-arm64` | `linuxArmHomeConfig` | Linux / aarch64 |

`TARGET` は OS / CPU の選択。ユーザー名とホームは、Nix を評価するプロセスの
環境変数 `USER` / `HOME` から `builtins.getEnv` で取得する。
`home-manager/home.nix` の共通設定で扱い、`/Users/<user>` や `/home/<user>` へ変換しない。
空白を含むパスや独自の場所も使えるが、`HOME` は絶対パスである必要がある。
`USER` / `HOME` が未設定・空、または `HOME` が相対パスなら明示的にエラーにする。

Flake の通常の pure 評価では環境変数を読めないため、ビルドと Home Manager の
`switch` には `--impure` が必要（下記の Task コマンドでは設定済み）。
同じリポジトリ・lock でも `USER` / `HOME` が変われば生成物が変わるため、
ユーザーごとの設定は完全に再現可能な pure Flake ではない。
lock による依存バージョンの固定は維持する。ユーザー名・ホームのパスは生成物に含まれ得る。

必ず適用対象ユーザーとして実行し、事前に次を確認する。`sudo` / `sudo -E` や root シェルでは
実行しない。環境変数の上書きは実際のログインユーザーを切り替えず、誤ったユーザーやホームを
指定する原因になる。環境変数と OS のアカウント情報の一致は自動では検証しない。

```bash
printf 'USER=%s\nHOME=%s\n' "$USER" "$HOME"
```

Linux は headless 向けで、GUI と clipboard コマンドを前提にしない。
WezTerm を使う Linux デスクトップでは `platforms/linux.nix` に
`imports = [../programs/wezterm.nix];` を追加できる。macOS では従来どおり有効。

### 初回セットアップ

まず lock ファイルを変更せずにビルドする。ビルドだけではホーム環境に適用されない。

```bash
git clone https://github.com/nk0086/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
nix build --impure --no-update-lock-file .#homeConfigurations.myHomeConfig.activationPackage
```

内容を確認してから、同じ lock の Home Manager で適用する。
Linux の場合は上記と下記の出力名を対象ホストに合わせて置き換える。
直接 `switch` を実行するときも、実行ホストの OS / CPU に対応する出力を選ぶ。
Home Manager を導入した後は、下記の `task apply TARGET=...` が OS / CPU の不一致を事前に検出する。

```bash
nix run --no-update-lock-file --inputs-from . home-manager -- \
  switch --impure --no-update-lock-file --flake .#myHomeConfig
```

`~/.safe-chain/scripts/init-posix.sh` は任意で、存在して読み込める場合だけ使用する。
Zsh 起動時には `~/.github_token` / `~/.openai_api_key` を読まず、トークンを自動 export しない。
GitHub CLI の認証は下記の標準機能を使う。
macOS の GPG SSH agent 連携は `gpgconf` がある場合だけ行う。Linux では既存の SSH agent を引き継ぐ。
端末がない場合に `tty` を呼ばない。
秘密情報はリポジトリや Nix 設定に埋め込まない。

### GitHub の認証

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

既存のトークンファイルは読み書き・削除せず、独自の認証ヘルパーも定義しない。
以前の自動 export で既に起動中のシェルやアプリへ渡された変数は、この変更では消えない。
`source ~/.zshrc` / `exec zsh` だけでは値が残る場合があるため、必要なら現在の端末で
次のように古い値を除いた子シェルを開始する。他のアプリの環境は変更しない。

```bash
env -u GH_TOKEN -u GITHUB_TOKEN -u GITHUB_PERSONAL_ACCESS_TOKEN -u OPENAI_API_KEY zsh
```

## コマンド

[go-task](https://taskfile.dev/) でタスクを実行する。
対象はコマンドラインの `TARGET` で指定し、省略時は従来どおり `mac`（`myHomeConfig`）。
`mac` / `linux` / `linux-arm64` 以外の値（空文字を含む）は、Nix の実行前にエラーになる。
`task apply` / `task sync` は、`uname` で確認した実行ホストの OS / CPU が `TARGET` に
一致しない場合も失敗する（`--dry` でもこの確認は行う）。

| コマンド | 説明 |
|---|---|
| `task build TARGET=mac` | macOS の設定をビルド（適用しない） |
| `task build TARGET=linux` / `task build TARGET=linux-arm64` | 対象 Linux の設定をビルド（適用しない） |
| `task apply TARGET=mac` / `task apply TARGET=linux` / `task apply TARGET=linux-arm64` | 既存 lock で対象ホストに適用 |
| `task build` / `task apply` | 既定の macOS 設定をビルド / 適用 |
| `task sync` | `task apply` の互換エイリアス。`TARGET` も指定可能 |
| `task update` | `flake.lock` の更新のみ（ビルド・適用しない） |
| `task format` | Nix / Lua ファイルをフォーマット |
| `task check` | フォーマット・隔離した shell 起動・HOME/USER 評価・Task コマンドのチェック |

```bash
task build TARGET=linux
task --dry build TARGET=linux-arm64  # ビルドコマンドを表示するだけ
task check:shell   # 起動・トークンを読まないことを fixture で検証（実際の秘密ファイルや GPG agent は使わない）
task check:tasks   # 全 TARGET・既定値・不正値・OS/CPU ガードを fixture の uname と dry-run で検証
task check:identity  # Nix で HOME/USER の fixture を評価（実際のホーム・flake inputs・ビルドは使わない）

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
`task build` は別 OS / CPU を選べるが、remote builder を使っても `USER` / `HOME` は
評価を開始した側の環境を使い、ビルド先のアカウントやホームへ自動変換しない。
別ホスト向けのビルド時だけ値を指定したい場合は、例えば次のように環境変数として渡す。

```bash
USER=example HOME="/srv/custom homes/example" task build TARGET=linux
```

この指定でログインユーザーや所有権は変わらない。適用は対象ホストの対象ユーザーで
`USER` / `HOME` を再確認してから `task apply TARGET=...` を実行する。
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
