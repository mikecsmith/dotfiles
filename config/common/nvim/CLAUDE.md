# Neovim Config — Claude Context

## Setup
- LazyVim distro on lazy.nvim
- Kitty terminal with kitty-navigator.nvim (`<M-h/j/k/l>`)
- Snacks.nvim for terminals, pickers, explorer, dashboard

## Reserved `<leader>` Keymaps

When adding keymaps, check this list to avoid conflicts. Sorted by prefix.

### Top-level
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>,` | Buffers | snacks_picker |
| `<leader>.` | Toggle Scratch Buffer | snacks util |
| `<leader>/` | Grep (Root Dir) | snacks_picker |
| `<leader>:` | Command History | snacks_picker |
| `<leader>-` | Split Window Below | LazyVim |
| `<leader>\|` | Split Window Right | LazyVim |
| `<leader>D` | Toggle DBUI | lang/sql |
| `<leader>e` | Explorer (root dir) | snacks_explorer |
| `<leader>E` | Explorer (cwd) | snacks_explorer |
| `<leader>K` | Keywordprg | LazyVim |
| `<leader>l` | Lazy | LazyVim |
| `<leader>L` | LazyVim Changelog | LazyVim |
| `<leader>n` | Notification History | snacks_picker |
| `<leader>N` | Messages | user: fathom.lua |
| `<leader>p` | Yank History | coding/yanky |
| `<leader>S` | Select Scratch Buffer | snacks util |

### `<leader>a` — AI
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>aa` | Accept diff | claudecode |
| `<leader>ab` | Add current buffer | claudecode |
| `<leader>ac` | Toggle Claude | claudecode |
| `<leader>aC` | Continue Claude | claudecode |
| `<leader>ad` | Deny diff | claudecode |
| `<leader>af` | Focus Claude | claudecode |
| `<leader>am` | Select Claude model | claudecode |
| `<leader>ar` | Resume Claude | claudecode |
| `<leader>as` | Send to Claude (visual) / Add file (tree) | claudecode |

### `<leader>b` — Buffer
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>bb` | Switch to Other Buffer | LazyVim |
| `<leader>bd` | Delete Buffer | LazyVim |
| `<leader>bD` | Delete Buffer and Window | LazyVim |
| `<leader>bj` | Pick Buffer | bufferline |
| `<leader>bl` | Delete Buffers to Left | bufferline |
| `<leader>bo` | Delete Other Buffers | LazyVim |
| `<leader>bp` | Toggle Pin | bufferline |
| `<leader>bP` | Delete Non-Pinned Buffers | bufferline |
| `<leader>br` | Delete Buffers to Right | bufferline |

### `<leader>c` — Code
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>ca` | Code Action | lsp |
| `<leader>cA` | Source Action | lsp |
| `<leader>cc` | Run Codelens | lsp |
| `<leader>cC` | Refresh Codelens | lsp |
| `<leader>cd` | Line Diagnostics | LazyVim |
| `<leader>cD` | Fix all diagnostics (TS) | lang/typescript |
| `<leader>cf` | Format | LazyVim |
| `<leader>cF` | Format Injected Langs | conform |
| `<leader>ch` | Switch Source/Header | lang/clangd |
| `<leader>cl` | Lsp Info | lsp |
| `<leader>cm` | Mason | lsp |
| `<leader>cM` | Add missing imports (TS) | lang/typescript |
| `<leader>co` | Organize Imports | lang/typescript |
| `<leader>cp` | Markdown Preview | lang/markdown |
| `<leader>cr` | Rename | inc-rename |
| `<leader>cR` | Rename File | lsp |
| `<leader>cs` | Symbols (Trouble) | trouble |
| `<leader>cS` | LSP refs/defs (Trouble) | trouble |
| `<leader>cu` | Remove unused imports (TS) | lang/typescript |
| `<leader>cv` | Select VirtualEnv | lang/python |
| `<leader>cV` | Select TS workspace version | lang/typescript |

### `<leader>d` — Debug
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>da` | Run with Args | dap |
| `<leader>db` | Toggle Breakpoint | dap |
| `<leader>dB` | Breakpoint Condition | dap |
| `<leader>dc` | Run/Continue | dap |
| `<leader>dC` | Run to Cursor | dap |
| `<leader>de` | Eval | dap-ui |
| `<leader>dg` | Go to Line (No Execute) | dap |
| `<leader>di` | Step Into | dap |
| `<leader>dj` | Down | dap |
| `<leader>dk` | Up | dap |
| `<leader>dl` | Run Last | dap |
| `<leader>do` | Step Out | dap |
| `<leader>dO` | Step Over | dap |
| `<leader>dP` | Pause | dap |
| `<leader>dph` | Profiler Highlights Toggle | LazyVim |
| `<leader>dpp` | Profiler Toggle | LazyVim |
| `<leader>dps` | Profiler Scratch Buffer | snacks util |
| `<leader>dr` | Toggle REPL | dap |
| `<leader>ds` | Session | dap |
| `<leader>dt` | Terminate | dap |
| `<leader>du` | Dap UI | user: debug.lua |
| `<leader>dw` | Widgets | dap |

### `<leader>f` — File/Find
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>fb` | Buffers | snacks_picker |
| `<leader>fB` | Buffers (all) | snacks_picker |
| `<leader>fc` | Find Config File | snacks_picker |
| `<leader>fe` | Explorer (root dir) | snacks_explorer |
| `<leader>fE` | Explorer (cwd) | snacks_explorer |
| `<leader>ff` | Find Files (Root Dir) | snacks_picker |
| `<leader>fF` | Find Files (cwd) | snacks_picker |
| `<leader>fg` | Find Files (git-files) | snacks_picker |
| `<leader>fn` | New File | LazyVim |
| `<leader>fp` | Projects | snacks_picker |
| `<leader>fr` | Recent | snacks_picker |
| `<leader>fR` | Recent (cwd) | snacks_picker |
| `<leader>ft` | Terminal (Root Dir) | LazyVim |
| `<leader>fT` | Terminal (cwd) | LazyVim |

### `<leader>g` — Git
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>gb` | Git Blame Line | LazyVim |
| `<leader>gB` | Git Browse (open) | LazyVim |
| `<leader>gc` | Code Review (Root Dir) | user: tuicr.lua |
| `<leader>gC` | Code Review (Working Tree) | user: tuicr.lua |
| `<leader>gd` | Git Diff (hunks) | snacks_picker |
| `<leader>gD` | Git Diff (origin) | snacks_picker |
| `<leader>gf` | Git Current File History | LazyVim |
| `<leader>gg` | Lazygit (Root Dir) | LazyVim |
| `<leader>gG` | Lazygit (cwd) | LazyVim |
| `<leader>gi` | List Issues (Octo) | octo |
| `<leader>gI` | Search Issues (Octo) | octo |
| `<leader>gl` | Git Log | LazyVim |
| `<leader>gL` | Git Log (cwd) | LazyVim |
| `<leader>gp` | List PRs (Octo) | octo |
| `<leader>gP` | Search PRs (Octo) | octo |
| `<leader>gr` | List Repos (Octo) | octo |
| `<leader>gs` | Git Status | snacks_picker |
| `<leader>gS` | Search (Octo) | octo |
| `<leader>gY` | Git Browse (copy) | LazyVim |

### `<leader>gh` — Git Hunks
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>ghb` | Blame Line | gitsigns |
| `<leader>ghB` | Blame Buffer | gitsigns |
| `<leader>ghd` | Diff This | gitsigns |
| `<leader>ghD` | Diff This ~ | gitsigns |
| `<leader>ghp` | Preview Hunk Inline | gitsigns |
| `<leader>ghr` | Reset Hunk | gitsigns |
| `<leader>ghR` | Reset Buffer | gitsigns |
| `<leader>ghs` | Stage Hunk | gitsigns |
| `<leader>ghS` | Stage Buffer | gitsigns |
| `<leader>ghu` | Undo Stage Hunk | gitsigns |

### `<leader>m` — Multicursor
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>ma` | Align cursors | user: multicursor.lua |
| `<leader>mA` | Select all matches | user: multicursor.lua |
| `<leader>mj` | Add cursor below | user: multicursor.lua |
| `<leader>mJ` | Skip cursor below | user: multicursor.lua |
| `<leader>mk` | Add cursor above | user: multicursor.lua |
| `<leader>mK` | Skip cursor above | user: multicursor.lua |
| `<leader>ml` | Add cursors (operator) | user: multicursor.lua |
| `<leader>mM` | Match by regex | user: multicursor.lua |
| `<leader>mn` | Add next match | user: multicursor.lua |
| `<leader>mN` | Add prev match | user: multicursor.lua |
| `<leader>mr` | Restore cursors | user: multicursor.lua |
| `<leader>ms` | Skip next match | user: multicursor.lua |
| `<leader>mS` | Split by regex | user: multicursor.lua |
| `<leader>mt` | Toggle cursor | user: multicursor.lua |
| `<leader>mx` | Transpose forward | user: multicursor.lua |
| `<leader>mX` | Transpose backward | user: multicursor.lua |

### `<leader>M` — Metals (Scala)
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>Mc` | Metals compile cascade | user: scala.lua |
| `<leader>Me` | Metals commands | user: scala.lua |
| `<leader>Mh` | Metals hover worksheet | user: scala.lua |

### `<leader>q` — Quit/Session
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>qd` | Don't Save Current Session | persistence |
| `<leader>ql` | Restore Last Session | persistence |
| `<leader>qq` | Quit All | LazyVim |
| `<leader>qs` | Restore Session | persistence |
| `<leader>qS` | Select Session | persistence |

### `<leader>s` — Search
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>s"` | Registers | snacks_picker |
| `<leader>s/` | Search History | snacks_picker |
| `<leader>sa` | Autocmds | snacks_picker |
| `<leader>sb` | Buffer Lines | snacks_picker |
| `<leader>sB` | Grep Open Buffers | snacks_picker |
| `<leader>sc` | Command History | snacks_picker |
| `<leader>sC` | Commands | snacks_picker |
| `<leader>sd` | Diagnostics | snacks_picker |
| `<leader>sD` | Buffer Diagnostics | snacks_picker |
| `<leader>sg` | Grep (Root Dir) | snacks_picker |
| `<leader>sG` | Grep (cwd) | snacks_picker |
| `<leader>sh` | Help Pages | snacks_picker |
| `<leader>sH` | Highlights | snacks_picker |
| `<leader>si` | Icons | snacks_picker |
| `<leader>sj` | Jumps | snacks_picker |
| `<leader>sk` | Keymaps | snacks_picker |
| `<leader>sl` | Location List | snacks_picker |
| `<leader>sm` | Marks | snacks_picker |
| `<leader>sM` | Man Pages | snacks_picker |
| `<leader>sp` | Plugin Spec | snacks_picker |
| `<leader>sq` | Quickfix List | snacks_picker |
| `<leader>sr` | Search and Replace | grug-far |
| `<leader>sR` | Resume | snacks_picker |
| `<leader>ss` | LSP Symbols | snacks_picker |
| `<leader>sS` | LSP Workspace Symbols | snacks_picker |
| `<leader>st` | Todo | todo-comments |
| `<leader>sT` | Todo/Fix/Fixme | todo-comments |
| `<leader>su` | Undotree | snacks_picker |
| `<leader>sw` | Word (Root Dir) | snacks_picker |
| `<leader>sW` | Word (cwd) | snacks_picker |

### `<leader>t` — Test
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>ta` | Attach to Test | neotest |
| `<leader>td` | Debug Nearest | neotest/dap |
| `<leader>tl` | Run Last | neotest |
| `<leader>to` | Show Output | neotest |
| `<leader>tO` | Toggle Output Panel | neotest |
| `<leader>tr` | Run Nearest | neotest |
| `<leader>ts` | Toggle Summary | neotest |
| `<leader>tS` | Stop | neotest |
| `<leader>tt` | Run File | neotest |
| `<leader>tT` | Run All Test Files | neotest |
| `<leader>tw` | Toggle Watch | neotest |

### `<leader>u` — UI Toggles
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>ua` | Toggle Animate | LazyVim |
| `<leader>uA` | Toggle Tabline | LazyVim |
| `<leader>ub` | Toggle Dark Background | LazyVim |
| `<leader>uc` | Toggle Conceal Level | LazyVim |
| `<leader>uC` | Colorschemes | snacks_picker |
| `<leader>ud` | Toggle Diagnostics | LazyVim |
| `<leader>uD` | Toggle Dim | LazyVim |
| `<leader>uf` | Toggle Auto Format (Global) | LazyVim |
| `<leader>uF` | Toggle Auto Format (Buffer) | LazyVim |
| `<leader>ug` | Toggle Indent | LazyVim |
| `<leader>uG` | Toggle Git Signs | gitsigns |
| `<leader>uh` | Toggle Auto-Hover | user: auto-hover.lua |
| `<leader>ui` | Inspect Pos | LazyVim |
| `<leader>uI` | Inspect Tree | LazyVim |
| `<leader>ul` | Toggle Line Number | LazyVim |
| `<leader>uL` | Toggle Relative Number | LazyVim |
| `<leader>um` | Toggle Render Markdown | lang/markdown |
| `<leader>un` | Dismiss All Notifications | snacks |
| `<leader>ur` | Redraw / Clear hlsearch | LazyVim |
| `<leader>us` | Toggle Spelling | LazyVim |
| `<leader>uS` | Toggle Scroll | LazyVim |
| `<leader>uT` | Toggle Treesitter | LazyVim |
| `<leader>uw` | Toggle Wrap | LazyVim |
| `<leader>uz` | Toggle Zen | LazyVim |
| `<leader>uZ` | Toggle Zoom | LazyVim |

### `<leader>w` — Windows
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>wd` | Delete Window | LazyVim |
| `<leader>wm` | Toggle Zoom | LazyVim |

### `<leader>x` — Diagnostics/Quickfix
| Key | Description | Source |
|-----|-------------|--------|
| `<leader>xl` | Location List | LazyVim |
| `<leader>xL` | Location List (Trouble) | trouble |
| `<leader>xq` | Quickfix List | LazyVim |
| `<leader>xQ` | Quickfix List (Trouble) | trouble |
| `<leader>xt` | Todo (Trouble) | todo-comments |
| `<leader>xT` | Todo/Fix/Fixme (Trouble) | todo-comments |
| `<leader>xx` | Diagnostics (Trouble) | trouble |
| `<leader>xX` | Buffer Diagnostics (Trouble) | trouble |

### `<leader><tab>` — Tabs
| Key | Description | Source |
|-----|-------------|--------|
| `<leader><tab><tab>` | New Tab | LazyVim |
| `<leader><tab>[` | Previous Tab | LazyVim |
| `<leader><tab>]` | Next Tab | LazyVim |
| `<leader><tab>d` | Close Tab | LazyVim |
| `<leader><tab>f` | First Tab | LazyVim |
| `<leader><tab>l` | Last Tab | LazyVim |
| `<leader><tab>o` | Close Other Tabs | LazyVim |

## Free `<leader>` Prefixes

These single-letter prefixes have NO keymaps and are fully available:
`h`, `i`, `j`, `k`, `o`, `r`, `v`, `y`, `z`

## Partially Used Prefixes (have free slots)

- `<leader>g` — `ga`, `gH`, `gj`, `gk`, `gm`, `gn`, `go`, `gq`, `gt`, `gu`, `gv`, `gw`, `gx`, `gz` are free
- `<leader>a` — `ae`, `ag`, `ah`, `ai`, `aj`, `ak`, `al`, `an`, `ao`, `ap`, `aq`, `at`, `au`, `av`, `aw`, `ax`, `ay`, `az` are free
