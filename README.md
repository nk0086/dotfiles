# dotfiles

Nix Flake + Home Manager で管理する macOS (Apple Silicon) 向け dotfiles。

## 構成

```
.
├── flake.nix                  # Flake 定義 (inputs / apps / homeConfigurations)
├── home-manager/
│   ├── home.nix               # Home Manager メイン設定・パッケージ一覧
│   └── programs/              # プログラムごとの設定
│       ├── bat.nix
│       ├── direnv.nix
│       ├── eza.nix
│       ├── gh.nix
│       ├── neovim.nix
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

- macOS (aarch64-darwin)
- [Nix](https://nixos.org/) がインストール済み（Flakes 有効）

### 初回セットアップ

```bash
git clone <repo-url> ~/.config/dotfiles
cd ~/.config/dotfiles
nix run nixpkgs#home-manager -- switch --flake .#myHomeConfig
```

## コマンド

[go-task](https://taskfile.dev/) でタスクを実行する。

| コマンド | 説明 |
|---|---|
| `task sync` | Home Manager の設定を適用 |
| `task update` | Flake を更新してから設定を適用 |
| `task format` | Nix / Lua ファイルをフォーマット |
| `task check` | フォーマットチェック (dry-run) |

```bash
task format        # Nix + Lua を一括フォーマット
task format:nix    # Nix のみ (alejandra)
task format:lua    # Lua のみ (stylua)
task check         # フォーマットチェック (dry-run)
```

## 主なパッケージ

- **エディタ**: Neovim (nightly)
- **ターミナル**: WezTerm
- **シェル**: Zsh + Starship
- **Git 関連**: git-extras, git-trim, tig, delta, gh
- **CLI ツール**: fzf, ripgrep, zoxide, bat, eza, httpie, ranger
- **開発言語/ツール**: Go, Python, Deno, Node.js, Zig, Nim, Gleam, Lua, Erlang
- **Nix**: nil (LSP), alejandra (formatter), nix-output-monitor
