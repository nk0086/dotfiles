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

- macOS (Apple Silicon) / Linux (x86_64 / aarch64)
- [Nix](https://nixos.org/)（Flakes 有効）と [go-task](https://taskfile.dev/) を使用

```bash
git clone https://github.com/nk0086/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles
```

`Taskfile.yml` の `TARGET` を使うマシンに合わせて一度設定する。
`mac` は macOS / Apple Silicon、`linux` は Linux / x86_64、`linux-arm64` は Linux / aarch64。

```yaml
vars:
  TARGET: mac
```

以降は `TARGET` をコマンドに付けずに実行できる。
ユーザー名とホームは環境変数 `USER` / `HOME` を使うため、適用するユーザーで実行する（`sudo` は使わない）。

```bash
task build   # ビルドして確認
task apply   # 設定を適用
```

Linux は headless 向け。WezTerm を使う場合は `home-manager/platforms/linux.nix` に
`imports = [../programs/wezterm.nix];` を追加する。

## コマンド

| コマンド | 説明 |
|---|---|
| `task build` | 既存の lock でビルド |
| `task apply` | 設定を適用（`task sync` も同じ） |
| `task update` | `flake.lock` の更新のみ |
| `task format` | Nix / Lua をフォーマット |
| `task check` | フォーマットとテストを実行 |

依存を更新するときは次の順に実行する。

```bash
task update
git diff -- flake.lock
task build
task apply
```

## 主なパッケージ

- **エディタ**: Neovim (nightly)
- **ターミナル**: WezTerm
- **シェル**: Zsh + Starship
- **Git 関連**: git-extras, git-trim, tig, delta, gh
- **CLI ツール**: fzf, ripgrep, zoxide, bat, eza, httpie, ranger
- **開発言語/ツール**: Go, Python, Deno, Node.js, Zig, Nim, Gleam, Lua, Erlang
- **Nix**: nil (LSP), alejandra (formatter), nix-output-monitor
