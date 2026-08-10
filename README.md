# hooks

Generic git hooks, reusable in any repo.

- `pre-commit` - blocks em dashes in newly added lines (use `-`).
- `commit-msg` - blocks AI/co-author attribution trailers and em dashes
  in commit messages.

Enable per repo:

```
git config core.hooksPath ~/hooks
```

Or globally, for every repo:

```
git config --global core.hooksPath ~/hooks
```

Note: a repo with its own hooks dir (like finances) keeps using its local
ones; fold these checks in there instead.
