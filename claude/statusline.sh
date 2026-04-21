#!/usr/bin/env bash
# ~/.claude/statusline.sh
# Claude Code status line — tokyo-night, LazyVim aesthetic.
# Reads rate_limits + cost directly from Claude Code's stdin JSON (v2.1+).
# Zero external dependencies beyond jq, git, and awk.
#
# Layout (inline, no forced right-align to avoid width-detection games):
#   [████░░░░░░] £1.23   repo  branch   ▃ 35%   ◕ 62%
#
# Env var overrides:
#   CLAUDE_STATUSLINE_GBP_RATE   default 0.79   (USD→GBP conversion)

set -u
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

GBP_RATE="${CLAUDE_STATUSLINE_GBP_RATE:-0.79}"

# ── Colours (tokyo-night truecolor) ──────────────────────────────────────────
C_RESET=$'\e[0m'
C_BOLD=$'\e[1m'
C_DIM=$'\e[38;2;86;95;137m'         # comment grey
C_CYAN=$'\e[38;2;134;225;252m'      # info cyan
C_BLUE=$'\e[38;2;130;170;255m'      # hl blue
C_GREEN=$'\e[38;2;158;206;106m'     # green
C_AMBER=$'\e[38;2;224;175;104m'     # amber / folder tint
C_ORANGE=$'\e[38;2;255;158;100m'    # orange
C_RED=$'\e[38;2;247;118;142m'       # red

pct_colour() {
  local p=$1
  if   (( p < 50 ));  then printf '%s' "$C_GREEN"
  elif (( p < 80 ));  then printf '%s' "$C_AMBER"
  elif (( p < 100 )); then printf '%s' "$C_ORANGE"
  else                     printf '%s' "$C_RED"
  fi
}

# ── Read Claude Code JSON ───────────────────────────────────────────────────
input=$(cat)

readarray -t _j < <(jq -r '
  [ .cost.total_cost_usd                              // 0
  , .workspace.current_dir // .cwd                    // ""
  , .context_window.current_usage.input_tokens        // 0
  , .context_window.current_usage.cache_read_input_tokens // 0
  , .context_window.context_window_size               // 0
  , .rate_limits.five_hour.used_percentage            // -1
  , .rate_limits.seven_day.used_percentage            // -1
  ] | .[]' <<<"$input" 2>/dev/null)

cost_usd="${_j[0]:-0}"
cwd="${_j[1]:-}"
ctx_in="${_j[2]:-0}"
ctx_cr="${_j[3]:-0}"
ctx_size="${_j[4]:-0}"
pct_5h="${_j[5]:--1}"
pct_week="${_j[6]:--1}"

# ── Context bar (narrow chars only) ─────────────────────────────────────────
window="$ctx_size"
(( window <= 0 )) && window=200000
used=$(( ctx_in + ctx_cr ))
(( used > window )) && used=$window

bar_width=10
filled=0
(( window > 0 && used > 0 )) && filled=$(( used * bar_width / window ))
(( filled > bar_width )) && filled=$bar_width
empty=$(( bar_width - filled ))

bar_fill=""
(( filled > 0 )) && bar_fill="${C_CYAN}$(printf '█%.0s' $(seq 1 $filled))${C_RESET}"
bar_empty=""
(( empty  > 0 )) && bar_empty="${C_DIM}$(printf '░%.0s'  $(seq 1 $empty))${C_RESET}"
ctx_bar="${C_DIM}[${C_RESET}${bar_fill}${bar_empty}${C_DIM}]${C_RESET}"

# ── Cost (session total, GBP) ───────────────────────────────────────────────
# Muted grey while in-plan; red+bold when either rate limit crosses 100%.
cost_gbp=$(awk -v u="$cost_usd" -v r="$GBP_RATE" 'BEGIN{printf "%.2f", u*r}')
over_plan=0
(( pct_5h >= 100 || pct_week >= 100 )) && over_plan=1
if (( over_plan )); then
  cost_seg="${C_RED}${C_BOLD}£${cost_gbp}${C_RESET}"
else
  cost_seg="${C_DIM}£${cost_gbp}${C_RESET}"
fi

# ── Project + branch (NF glyphs, distinct from starship) ───────────────────
project=""; branch=""; dirty=0
if [[ -n "$cwd" && -d "$cwd" ]]; then
  if git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null); then
    project=$(basename "$git_root")
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    [[ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)" ]] && dirty=1
  else
    project=$(basename "$cwd")
  fi
fi
GLYPH_DIR=$''          # nf-oct-file_directory
GLYPH_BRANCH=$''       # nf-dev-git_branch

proj_seg=""
[[ -n "$project" ]] && proj_seg="${C_AMBER}${GLYPH_DIR}${C_RESET} ${C_BOLD}${C_BLUE}${project}${C_RESET}"

branch_seg=""
if [[ -n "$branch" ]]; then
  bcol="$C_GREEN"; bstar=""
  (( dirty )) && { bcol="$C_AMBER"; bstar="${C_AMBER}*${C_RESET}"; }
  branch_seg="${bcol}${GLYPH_BRANCH}${C_RESET} ${bcol}${branch}${C_RESET}${bstar}"
fi

# ── Usage indicators ────────────────────────────────────────────────────────
# Weekly: MDI circle_slice 1/8..8/8 for clockwise fill progression (Nerd Font).
# 5h:     vertical block bar, 8 levels — visually distinct from the circle.
CIRCLE_EMPTY=$'\U000F0766'                              # nf-md-circle_outline
CIRCLES=($'\U000F0A9E' $'\U000F0A9F' $'\U000F0AA0' $'\U000F0AA1' \
         $'\U000F0AA2' $'\U000F0AA3' $'\U000F0AA4' $'\U000F0AA5')
BLOCKS=('▁' '▂' '▃' '▄' '▅' '▆' '▇' '█')

pick_block() {
  local p=$1 i
  (( p < 0 )) && { printf '0'; return; }
  i=$(( p * 8 / 100 ))
  (( i < 0 )) && i=0
  (( i > 7 )) && i=7
  printf '%d' "$i"
}

pick_circle() {
  # 1-94% → slice_1..slice_7, 95-100+% → slice_8 (full).
  # 50% lands in slice_4 (half filled), which matches intuition.
  local p=$1 i
  (( p <= 0 )) && { printf -- '-1'; return; }
  if (( p >= 95 )); then
    printf '7'; return
  fi
  i=$(( p * 7 / 94 ))
  (( i < 0 )) && i=0
  (( i > 6 )) && i=6
  printf '%d' "$i"
}

fmt_week() { # weekly — circle fill + percentage
  local p=$1
  if (( p < 0 )); then
    printf '%s%s —%s' "$C_DIM" "$CIRCLE_EMPTY" "$C_RESET"; return
  fi
  if (( p == 0 )); then
    printf '%s%s 0%%%s' "$C_DIM" "$CIRCLE_EMPTY" "$C_RESET"; return
  fi
  local ci colour
  ci=$(pick_circle "$p"); colour=$(pct_colour "$p")
  printf '%s%s %d%%%s' "$colour" "${CIRCLES[$ci]}" "$p" "$C_RESET"
}

fmt_5h() { # 5h — block bar + percentage
  local p=$1
  if (( p < 0 )); then
    printf '%s▁ —%s' "$C_DIM" "$C_RESET"; return
  fi
  local bi colour
  bi=$(pick_block "$p"); colour=$(pct_colour "$p")
  printf '%s%s %d%%%s' "$colour" "${BLOCKS[$bi]}" "$p" "$C_RESET"
}

week_seg=$(fmt_week "$pct_week")
five_seg=$(fmt_5h   "$pct_5h")

# ── Assemble (inline, spaces between segments) ─────────────────────────────
# Order: weekly usage, 5h usage, current-session context bar, cost, folder, branch
parts=( "$week_seg" "$five_seg" "$ctx_bar" "$cost_seg" )
[[ -n "$proj_seg"   ]] && parts+=( "$proj_seg" )
[[ -n "$branch_seg" ]] && parts+=( "$branch_seg" )

(IFS=' '; printf '%s' "${parts[*]}")
