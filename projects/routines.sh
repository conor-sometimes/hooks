# routines pre-commit: regenerate the markdown export (tools/export_markdown.py
# writes it with em dashes already stripped - see its _no_emdash - so this
# should never re-trigger common.sh's em-dash guard), then the full stdlib
# test suite, then ruff + the Hypothesis fuzz test if the repo's opt-in .venv
# is set up (skipped, not failed, if it isn't - matches CLAUDE.md's own
# zero-install stance). $ROOT set by pre-commit.

echo "pre-commit: regenerating markdown export..."
python3 "$ROOT/tools/export_markdown.py" >/dev/null
git -C "$ROOT" add markdown

echo "pre-commit: unittest suite..."
(cd "$ROOT" && python3 -m unittest discover -s tests)

if [ -x "$ROOT/.venv/bin/ruff" ]; then
    echo "pre-commit: ruff..."
    (cd "$ROOT" && .venv/bin/ruff check .)
else
    echo "pre-commit: .venv not set up, skipping ruff." >&2
fi

if [ -x "$ROOT/.venv/bin/python3" ]; then
    echo "pre-commit: fuzz checklist..."
    (cd "$ROOT" && .venv/bin/python3 tests/test_fuzz_checklist.py)
else
    echo "pre-commit: .venv not set up, skipping the fuzz test (self-skips in the plain suite too)." >&2
fi
