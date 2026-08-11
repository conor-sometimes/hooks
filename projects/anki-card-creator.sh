# anki-card-creator pre-commit: offline pytest suite, then ruff, if the
# repo's opt-in .venv is set up (skipped, not failed, if it isn't -- same
# zero-install stance as routines.sh). Live suites (marked live/live_anki/
# live_voicevox/live_images) need real local services running and are never
# part of pre-commit -- STABILITY.md's own checklist runs those by hand.
# $ROOT set by pre-commit.

if [ -x "$ROOT/.venv/bin/python3" ]; then
    echo "pre-commit: offline pytest suite..."
    (cd "$ROOT" && .venv/bin/python3 -m pytest -m "not live and not live_anki and not live_voicevox and not live_images" -q)
else
    echo "pre-commit: .venv not set up, skipping pytest." >&2
fi

if [ -x "$ROOT/.venv/bin/ruff" ]; then
    echo "pre-commit: ruff..."
    (cd "$ROOT" && .venv/bin/ruff check .)
else
    echo "pre-commit: .venv not set up, skipping ruff." >&2
fi
