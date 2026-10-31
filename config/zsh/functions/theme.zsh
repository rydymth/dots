# leaf takes its theme by name, so pass along the one `theme` selected
leaf() {
    local t
    t=$(theme --current 2>/dev/null)
    if [[ -n $t ]]; then command leaf --theme "$t" "$@"; else command leaf "$@"; fi
}
