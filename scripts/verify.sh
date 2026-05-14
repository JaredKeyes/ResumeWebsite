#!/usr/bin/env bash
# verify.sh — the "done" check for the resume-website shell.
# Asserts every requirement from
# docs/superpowers/specs/2026-05-13-resume-website-design.md §9.

set -uo pipefail

cd "$(dirname "$0")/.."

red()   { printf '\033[0;31m%s\033[0m' "$*"; }
green() { printf '\033[0;32m%s\033[0m' "$*"; }
ok()   { printf '  %s %s\n' "$(green ✓)" "$*"; }
fail() { printf '  %s %s\n' "$(red ✗)" "$*"; FAILED=1; }

FAILED=0

# 1. npm install resolves cleanly.
if npm install --silent >/dev/null 2>&1; then
    ok "npm install resolves"
else
    fail "npm install failed"
fi

# 2. npm run build exits 0.
if npm run build --silent >/dev/null 2>&1; then
    ok "npm run build exits 0"
else
    fail "npm run build failed (run 'npm run build' to see the error)"
fi

# 3. Each expected page exists in dist/.
for page in \
    "dist/index.html" \
    "dist/about/index.html" \
    "dist/resume/index.html" \
    "dist/projects/index.html" \
    "dist/projects/placeholder/index.html" \
    "dist/contact/index.html" \
    "dist/404.html"; do
    if [[ -f "$page" ]]; then
        ok "page exists: $page"
    else
        fail "page missing: $page"
    fi
done

# 4. JetBrains Mono is referenced in the bundled CSS.
if grep -lqsR 'JetBrains Mono' dist/_astro/*.css 2>/dev/null; then
    ok "bundled CSS references JetBrains Mono"
else
    fail "bundled CSS does not reference JetBrains Mono"
fi

# 5. Every design token is defined in the bundled CSS.
for token in --bg --fg --fg-muted --accent --border --prompt; do
    if grep -qsR -- "$token *:" dist/_astro/*.css 2>/dev/null; then
        ok "token defined: $token"
    else
        fail "token missing: $token"
    fi
done

# 6. Every built page renders the Prompt component (grep class="prompt").
shopt -s globstar nullglob
for page in dist/**/*.html; do
    if ! grep -q 'class="prompt"' "$page"; then
        fail "page missing class=\"prompt\": $page"
    fi
done
shopt -u globstar nullglob
[[ $FAILED -eq 0 ]] && ok "every page contains class=\"prompt\""

# 7. Placeholder marker convention is in use.
for page in \
    "dist/about/index.html" \
    "dist/resume/index.html" \
    "dist/projects/placeholder/index.html" \
    "dist/contact/index.html"; do
    if [[ -f "$page" ]] && grep -q '<<' "$page"; then
        ok "placeholder marker present: $page"
    else
        fail "placeholder marker missing: $page"
    fi
done

# 8. No <script> tags in any built page (zero-JS rule).
shopt -s globstar nullglob
SCRIPT_HITS=0
for page in dist/**/*.html; do
    if grep -q '<script' "$page"; then
        fail "page contains <script> tag: $page"
        SCRIPT_HITS=$((SCRIPT_HITS+1))
    fi
done
shopt -u globstar nullglob
[[ "$SCRIPT_HITS" -eq 0 ]] && ok "no <script> tags in built pages"

# 9. Bundled CSS parses (balanced braces).
for css in dist/_astro/*.css; do
    [[ -f "$css" ]] || continue
    opens=$(tr -cd '{' < "$css" | wc -c)
    closes=$(tr -cd '}' < "$css" | wc -c)
    if [[ "$opens" -eq "$closes" ]]; then
        ok "CSS braces balanced: $(basename "$css")"
    else
        fail "CSS braces unbalanced ($opens vs $closes): $css"
    fi
done

echo
if [[ "$FAILED" -eq 0 ]]; then
    green "verify.sh: ALL CHECKS PASSED"
    echo
    exit 0
else
    red "verify.sh: ONE OR MORE CHECKS FAILED"
    echo
    exit 1
fi
