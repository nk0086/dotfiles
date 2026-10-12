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

| Flake 出力 | OS / CPU | ホームディレクトリ |
|---|---|---|
| `myHomeConfig` | macOS / Apple Silicon | `/Users/nk`（既存設定を維持） |
| `linuxHomeConfig` | Linux / x86_64 | `/home/nk` |
| `linuxArmHomeConfig` | Linux / aarch64 | `/home/nk` |

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

`~/.github_token`、`~/.openai_api_key`、`~/.safe-chain/scripts/init-posix.sh` は任意。
存在して読み込める場合だけ使用し、未作成なら既存の環境変数を維持する。
macOS の GPG SSH agent 連携は `gpgconf` がある場合だけ行う。Linux では既存の SSH agent を引き継ぐ。
端末がない場合に `tty` を呼ばない。
秘密情報はリポジトリや Nix 設定に埋め込まない。

## コマンド

[go-task](https://taskfile.dev/) でタスクを実行する。既定の対象は従来どおり `myHomeConfig`。

| コマンド | 説明 |
|---|---|
| `task build:macos` / `task build:linux` / `task build:linux-arm64` | 対象ホストの設定をビルド（適用しない） |
| `task apply:macos` / `task apply:linux` / `task apply:linux-arm64` | 既存 lock で対象ホストに適用 |
| `task build` / `task apply` | `HOME_CONFIG` で指定した出力をビルド / 適用 |
| `task sync` | `task apply` の互換エイリアス |
| `task update` | `flake.lock` の更新のみ（ビルド・適用しない） |
| `task format` | Nix / Lua ファイルをフォーマット |
| `task check` | フォーマットチェックと隔離した shell 起動テスト |

```bash
task build HOME_CONFIG=linuxHomeConfig
task check:shell   # 実際の秘密ファイルや GPG agent は使わない

# 依存更新が必要なときだけ、変更をレビューしてから別々に実行
task update
git diff -- flake.lock
task build:macos
task apply:macos
```

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
