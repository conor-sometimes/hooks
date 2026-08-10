# Universal pre-commit checks, every repo. (AI/co-author attribution is
# blocked by the commit-msg hook; the message doesn't exist yet here.)

# --- no em dashes in newly added lines ---
EMDASH=$(git diff --cached --unified=0 | grep '^+' | grep -v '^+++' \
         | LC_ALL=C grep -n $'\xe2\x80\x94' || true)
if [ -n "$EMDASH" ]; then
    echo "✗ em dash in newly added lines; commit aborted. Use '-' instead:" >&2
    echo "$EMDASH" >&2
    exit 1
fi
