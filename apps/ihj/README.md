# ihj — The Instant High-speed Jira CLI 😉

> [!CAUTION]
> **PRE-ALPHA SOFTWARE: USE AT YOUR OWN RISK**
> This tool is currently in a "works on my machine" state. It performs direct write operations to your Jira instance. It may delete your favorite sub-tasks, rename your Epics, or simply crash and lose your unsaved 500-word comment. You have been warned.

`ihj` is a lightweight, clean-architecture, Python-native TUI designed to get you in and out of Jira as fast as possible. It bridges the gap between a fast FZF dashboard, your local editor, and the Jira API.

Supports macOS and Linux natively.

---

## 🛠 Prerequisites

You must have the following installed and available in your `$PATH`:

1.  **[fzf](https://github.com/junegunn/fzf):** The fuzzy finder that powers the main UI.
2.  **[yq](https://github.com/mikefarah/yq):** The Go-based YAML processor (specifically the Mike Farah version).

**Optional OS Integrations (for Branch Copying & Toasts):**

- **macOS:** Uses built-in `pbcopy` and `osascript`.
- **Linux:** Install `wl-copy` (Wayland) or `xclip` / `xsel` (X11) for clipboard support. Install `notify-send` for desktop notifications.

---

## 🔑 Authentication

`ihj` uses a Personal Access Token (PAT) for authentication.

### 1. Generate your PAT

- **Jira Data Center:** Click your Profile Icon -> **Personal Access Tokens** -> **Create Token**.
- **Jira Cloud:** Go to **Account Settings** -> **Security** -> **Create and manage API tokens**.

### 2. Export the Environment Variable

Add this to your `.zshrc`, `.bashrc`, or `.env` file:

```bash
export JIRA_BEARER_TOKEN="your_token_here"
```

---

## ⚙️ Configuration

The CLI looks for its configuration file at `~/.config/ihj/config.yaml`.

### Example Configuration

```yaml
server: "[https://foo-company.atlassian.net](https://foo-company.atlassian.net)"
default_board: "foo"
editor: "nvim"

custom_fields:
  # Required custom fields
  team: 15000
  epic_name: 10009
  epic_link: 10008
  # Arbitrary custom fields can be added here
  points: 10016

boards:
  foo:
    id: 12345
    name: "Foo Engineering"
    team_uuid: "e8b7c4a1-8d23-4b5c-9f6a-123456789abc"
    project_key: "FOO"
    jql: 'project = "{project_key}" AND {team} = "{team_uuid}"'
    modes:
      active: "(statusCategory != Done) OR (statusCategory = Done AND status changed TO Done AFTER -2w)"
      all: ""
      me: "assignee = currentUser()"
      backlog: "statusCategory = 'To Do'"
    transitions:
      - "Backlog"
      - "In Refinement"
      - "In Progress"
      - "In Review"
      - "Done"

types:
  - id: 6
    name: Epic
    order: 1
    color: magenta
    has_children: true
  - id: 7
    name: Task
    order: 2
    color: default
    has_children: true
    template: |
      ## Technical Task 

      ## Acceptance Criteria
      - Given [user], when [they do something], then [the following behaviour is required]
  - id: 8
    name: Story
    order: 2
    color: cyan
    has_children: false
    template: |
      ## User Story
      As a [user], I want [feature] so that [reason].

      ## Acceptance Criteria
      - [ ] Criterion 1
  - id: 9
    name: Sub-task
    order: 3
    color: white # light grey for me currently but it supposedly maps to white
    has_children: false
```

### Understanding the Config Blocks

- **`custom_fields`:** Maps friendly names to Jira's internal integer IDs.
  - **Required:** `team`, `epic_name`, and `epic_link` are mandatory for the CLI to function.
  - **Arbitrary:** You can add any other custom fields (like `points`) to be used in your JQL filters or modes.
- **`types`:** Defines the issue hierarchy and terminal rendering.
  - `order`: Dictates the view hierarchy in the TUI (e.g., nesting Sub-tasks under Stories).
  - `has_children`: Plays into validation rules (ensuring you can't assign a Sub-task as the parent of an Epic).
  - `color`: Dictates the syntax highlighting color used in the FZF list.
  - `template`: A multiline Markdown string used to pre-populate the editor body when creating a new issue of this type.

---

## 🔍 JQL & Modes Interpolation

`ihj` dynamically builds your queries using a powerful templating system.

### Base JQL Expansion

The `jql` string defined in your board config is **required** and acts as the foundation for all queries. Variables inside `{}` are interpolated dynamically:

1.  **Top-Level Board Fields:** Variables like `{project_key}` and `{team_uuid}` pull directly from your `boards` config block.
2.  **Custom Fields:** Variables like `{team}` are checked against the `custom_fields` dictionary. The script automatically expands these to the appropriate Jira format (either `customfield_XXXXX` or `cf[XXXXX]`).

> [!WARNING]
> **Do not clobber top-level board keys!** When adding to `custom_fields`, ensure your keys do not share a name with a top-level `boards` key (e.g., do not create a custom field named `team_uuid`).

TODO: Add a JSON schema for the `config.yaml` file.

### Modes

Modes allow you to quickly toggle views within a board using `Alt-s` in the TUI. The keys defined under `modes` (e.g., `active`, `my`) populate the selection menu.

When a mode is selected, its JQL is concatenated to the Base JQL using an `AND` operator:
`Base JQL` + `AND` + `(Mode JQL)`

_Example resulting JQL for the `my` mode:_
`(project = "FOO" AND cf[15000] = "e8b7c4a1-8d23-4b5c-9f6a-123456789abc") AND (assignee = currentUser())`

---

## 🚀 CLI Usage & Dry Runs

While `ihj` launches the interactive dashboard, the tool also features a fully-featured CLI for direct operations, complete with contextual help (`ihj <command> -h`).

```bash
# Launch the dashboard
ihj tui foo active

# Safely test what an edit payload would look like without hitting the API
ihj edit FOO-123 -s "Updated Summary" -S "In Progress" --dry-run

# Direct issue creation
ihj create -b foo -t Task -s "Fix the database schema" -p High
```

---

## 📝 Editor Integration

When you create (`Ctrl-n`) or edit (`Alt-e`) an issue, `ihj` generates a temporary Markdown file with a YAML frontmatter block. If creating a new issue, the body of the markdown file will be pre-populated with the `template` defined for that issue type in your config.

### Workflow

1.  **Metadata:** Edit the fields inside the YAML frontmatter block (e.g., `status: "In Progress"`).
2.  **Description:** Write your issue description using standard Markdown below the frontmatter. `ihj` natively converts this into Jira's Atlassian Document Format (ADF) upon saving.
3.  **Resilient Execution:** If Jira rejects your payload (e.g., a missing parent key on a Sub-task), the CLI will halt and provide a Recovery Menu. You can jump back into the editor to fix the error, or rescue your buffer to the clipboard.
4.  **LSP Integration:** `ihj` automatically generates your JSON schemas based on your config and injects a `# yaml-language-server` directive at the top. This provides instant autocomplete and validation for statuses, types, and custom fields if your editor supports block scoped LSPs.

**Note:** If you exit without making any changes - `ihj` will assume you were aborting and won't show the recovery menu.

### Configuring Your Editor

Set the `editor` key at the root of your `config.yaml`. Multi-word commands and arguments are fully supported. If omitted, the CLI falls back to your `$EDITOR` environment variable, or `vim`.

- **Vim / Neovim:** `editor: "nvim"` (Native support; automatically drops into insert mode at the exact line of your summary).
- **VS Code:** `editor: "code --wait"` (The `--wait` flag is **mandatory**. `ihj` must wait for you to close the editor tab before reading the file and pushing to Jira).

---

## ⌨️ Default Keybindings (FZF)

| Key      | Action                                                                                     |
| :------- | :----------------------------------------------------------------------------------------- |
| `Enter`  | **Close FZF** (Exits the dashboard)                                                        |
| `Alt-e`  | **Edit** metadata and description                                                          |
| `Alt-c`  | **Comment** (Opens a blank buffer)                                                         |
| `Alt-a`  | **Assign** to yourself (Silent)                                                            |
| `Alt-t`  | **Transition** status (Numeric menu)                                                       |
| `Alt-o`  | **Open** in browser                                                                        |
| `Alt-s`  | **Switch** Mode (Active, Me, Backlog, etc.)                                                |
| `Alt-r`  | **Reload** cache and refresh list                                                          |
| `Alt-n`  | **Branch** (Copies a `git checkout -b <name>` to the clipboard based on issue key/summary) |
| `Ctrl-n` | **New** issue creation (Numeric menu for type)                                             |

---

## 💡 Tips & Known Limitations

### Clickable Terminal Links

`ihj` uses **OSC 8 terminal hyperlinks**. When viewing issue descriptions or comments in the preview pane, hyperlinks will render cleanly without exposing the raw URL.
_(Note: If `fzf`'s mouse capture is blocking your click, hold `Shift` while clicking to bypass it and you may also need whatever modifier key your terminal expects)._

### The "FZF Tree" Filtering Quirk

`ihj` natively nests sub-tasks under their parents to create a clean, hierarchical view. However, because `fzf` operates as a flat text filter, it has no concept of parent/child relationships.

If you type a search term that matches a child issue but _not_ its parent, the parent will be filtered out. The child issue will remain visible, but it may look "orphaned" (e.g., `  └─ Fix the DB`) without its parent context above it.

**Workaround:** If you lose track of what an orphaned sub-task belongs to, simply check the preview pane on the right for full context, or press `Backspace` to clear your search query and restore the full visual tree.
