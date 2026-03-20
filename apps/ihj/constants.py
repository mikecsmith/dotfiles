C = {
    # --- Text Styles ---
    "reset": "\033[0m",
    "bold": "\033[1m",
    "dim": "\033[2m",
    "italic": "\033[3m",
    "underline": "\033[4m",
    "blink": "\033[5m",  # Note: Not supported in all terminal emulators
    "reverse": "\033[7m",  # Inverts foreground and background colors (great for selected items!)
    "hidden": "\033[8m",  # Invisible text (useful for passwords/hidden state)
    "strikethrough": "\033[9m",
    # --- Foreground Colors (Standard) ---
    "black": "\033[30m",
    "red": "\033[31m",
    "green": "\033[32m",
    "yellow": "\033[33m",
    "blue": "\033[34m",
    "magenta": "\033[35m",
    "cyan": "\033[36m",
    "white": "\033[37m",  # Often renders as light gray
    "default": "\033[39m",  # The true default text color of your terminal theme
    # --- Foreground Colors (High Intensity) ---
    "gray": "\033[90m",  # Bright Black
    "bright_red": "\033[91m",
    "bright_green": "\033[92m",
    "bright_yellow": "\033[93m",
    "bright_blue": "\033[94m",
    "bright_magenta": "\033[95m",
    "bright_cyan": "\033[96m",
    "bright_white": "\033[97m",  # Crisp, high-intensity white
    # --- Background Colors (Standard) ---
    "bg_black": "\033[40m",
    "bg_red": "\033[41m",
    "bg_green": "\033[42m",
    "bg_yellow": "\033[43m",
    "bg_blue": "\033[44m",
    "bg_magenta": "\033[45m",
    "bg_cyan": "\033[46m",
    "bg_white": "\033[47m",
    "bg_default": "\033[49m",  # The true default background of your terminal theme
    # --- Background Colors (High Intensity) ---
    "bg_gray": "\033[100m",  # Bright Black background
    "bg_bright_red": "\033[101m",
    "bg_bright_green": "\033[102m",
    "bg_bright_yellow": "\033[103m",
    "bg_bright_blue": "\033[104m",
    "bg_bright_magenta": "\033[105m",
    "bg_bright_cyan": "\033[106m",
    "bg_bright_white": "\033[107m",
    # --- Terminal & Cursor Controls (Bonus for TUIs) ---
    "clear_screen": "\033[2J\033[H",  # Clears the entire screen and moves cursor to top left (0,0)
    "clear_line": "\033[2K",  # Clears the current line
    "hide_cursor": "\033[?25l",  # Hides the blinking terminal cursor
    "show_cursor": "\033[?25h",  # Restores the blinking terminal cursor
}
