# hledger ledger checks (finances). Sourced by pre-commit: $ROOT, $HOOKS_DIR set.

# --- locate hledger-fmt (cargo's bin dir is often not on a hook's minimal PATH) ---
FMT="$(command -v hledger-fmt || true)"
if [ -z "$FMT" ] && [ -x "$HOME/.cargo/bin/hledger-fmt" ]; then
    FMT="$HOME/.cargo/bin/hledger-fmt"
fi

# --- auto-format staged journal files ---
FILES="$(git diff --cached --name-only --diff-filter=ACM \
         | grep -E '\.journal$' || true)"
if [ -n "$FILES" ]; then
    if [ -n "$FMT" ]; then
        # paths from git have no spaces here; intentional word-split on $FILES.
        "$FMT" --fix --exit-zero-on-changes $FILES >/dev/null 2>&1 || true
        git add -- $FILES
        echo "✓ hledger-fmt: formatted staged journal file(s)."
    else
        echo "⚠ hledger-fmt not found; skipping auto-format (commit continues)." >&2
    fi
fi

# --- ban inline amount+assertion on one posting line ---
# "2.00 EUR = 13144.29 EUR" and the "0 EUR = X" checker variant are BANNED.
# Movements get their own lines; each assert stands alone (= <balance>).
# (Comment lines are ignored; VUAA-style share asserts don't match, since the
# pattern requires EUR on BOTH sides of the '='.)
if [ -n "$FILES" ]; then
    BAD=$(grep -nE '[0-9][0-9.,]* +EUR +=+ *-?[0-9][0-9.,]* +EUR' $FILES /dev/null \
          | grep -vE '^[^:]+:[0-9]+:[[:space:]]*;' || true)
    if [ -n "$BAD" ]; then
        echo "✗ banned assert format (amount and assertion share a line); commit aborted:" >&2
        echo "$BAD" >&2
        exit 1
    fi
fi

# --- validate (same checks as CI and status.sh: strict + ordereddates + tags) ---
if hledger -f "$ROOT/main.journal" check --strict ordereddates tags; then
    echo "✓ ledger validates; committing."
else
    echo "✗ ledger validation FAILED; commit aborted. Fix the above and retry." >&2
    exit 1
fi
