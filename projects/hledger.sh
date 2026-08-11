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
        # stdout (the diff preview) is noise, but let stderr through - a
        # silently crashing formatter would otherwise look identical to a
        # working one.
        "$FMT" --fix --exit-zero-on-changes $FILES >/dev/null || true
        # Re-stages ENTIRE files. This workflow always stages whole files
        # (git add -A); if partial staging ever becomes a thing, this clobbers it.
        git add -- $FILES
        echo "✓ hledger-fmt: formatted staged journal file(s)."
    else
        echo "⚠ hledger-fmt not found; skipping auto-format (commit continues)." >&2
    fi
fi

# --- ban inline amount+assertion on one posting line ---
# "2.00 EUR = 13144.29 EUR" and the "0 EUR = X" checker variant are BANNED.
# Movements get their own lines; each assert stands alone (= <balance>).
# Any 3-letter (ISO-currency) commodity on both sides of '=' triggers the ban,
# so JPY/GBP stay covered when they arrive. (Comment lines are ignored;
# VUAA-style share asserts don't match - tickers are 4+ letters.)
if [ -n "$FILES" ]; then
    BAD=$(grep -nE '[0-9][0-9.,]* +[A-Z]{3} +=+ *-?[0-9][0-9.,]* +[A-Z]{3}( |$)' $FILES /dev/null \
          | grep -vE '^[^:]+:[0-9]+:[[:space:]]*;' || true)
    if [ -n "$BAD" ]; then
        echo "✗ banned assert format (amount and assertion share a line); commit aborted:" >&2
        echo "$BAD" >&2
        exit 1
    fi
fi

# --- sweep entries must carry their canonical title ---
# status.sh totals round-up sweeps via desc:'spare change' - the one literal
# description the reporting layer machine-reads. Structural check: a staged
# years/ transaction that MOVES money between both Revolut Savings and Current
# (movement lines, not bare asserts) must be titled 'Spare Change' or
# 'Transfer ...', or it silently drops out of that total.
SWEEPFILES="$(echo "$FILES" | grep -E '(^|/)years/[^/]+\.journal$' || true)"
if [ -n "$SWEEPFILES" ]; then
    BAD=$(awk '
        function check() {
            if (sav && cur && title !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] +([*!] +)?(Spare Change|Transfer)/)
                print FILENAME ":" tline ": " title
        }
        /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ { check(); title=$0; tline=FNR; sav=0; cur=0 }
        /^[[:space:]]+Assets:Revolut:Savings[[:space:]]+-?[0-9]/ { sav=1 }
        /^[[:space:]]+Assets:Revolut:Current[[:space:]]+-?[0-9]/ { cur=1 }
        END { check() }
    ' $SWEEPFILES)
    if [ -n "$BAD" ]; then
        echo "✗ Savings↔Current movement without a canonical sweep title" >&2
        echo "  (must be 'Spare Change' or 'Transfer ...'); commit aborted:" >&2
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
