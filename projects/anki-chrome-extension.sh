# anki-chrome-extension pre-commit: fast unit tests only (no live Anki
# dependency). See test/integration/ for the AnkiConnect-backed test,
# run manually via `npm run test:live` / `just test-live`.
echo "pre-commit: npm test..."
(cd "$ROOT" && npm test)
