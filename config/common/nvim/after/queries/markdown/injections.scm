; extends

; Quarto-style curly-brace fenced code blocks e.g. ```{ojs}, ```{python}, ```{r}.
; The base query captures the language node verbatim — including the braces —
; so the injection lookup fails. Strip the braces before dispatch.
((fenced_code_block
  (info_string (language) @injection.language)
  (code_fence_content) @injection.content)
  (#lua-match? @injection.language "^{.+}$")
  (#gsub! @injection.language "[{}]" ""))
