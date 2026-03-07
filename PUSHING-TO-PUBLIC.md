# Pushing to Public

This file documents the process for publishing changes to the public repository. It is gitignored from the public repo and should never be included in public commits.

## Remotes

- `origin` — private repo (`iahp-private`). Day-to-day work happens here.
- `iahp` — public repo (`iahp`). Receives curated, collapsed commits.

## Workflow

### 1. Prepare

Ensure all work is committed to `origin/main`. No uncommitted changes.

```bash
git status   # must be clean
```

### 2. Review for sensitive content

Before any public push, scan the entire diff since the last public commit for:

- **PII**: names, emails, addresses, phone numbers, usernames (other than the repo owner)
- **Project references**: client names, internal project names, company names, proprietary codenames
- **Affiliations**: employer names, team names, org references, internal URLs
- **Credentials**: API keys, tokens, passwords, connection strings
- **Internal paths**: home directories, local file paths that reveal system structure
- **Skill content**: any skill SKILL.md that references specific personal projects, clients, or internal tooling by name

```bash
# Diff everything since last public push
git diff iahp/main..HEAD

# Search for common PII/leak patterns
git diff iahp/main..HEAD | grep -iE '(client|internal|private|secret|password|token|api.?key|@gmail|@company|\bNDA\b)'
```

Review flagged lines manually. If anything is found, fix it in private first, then re-run.

### 3. Collapse and push

Push all commits since the last public sync as a single squash commit:

```bash
# Create a temporary branch from the public state
git checkout -b public-push iahp/main

# Squash-merge current main into it
git merge --squash main

# Remove private-only files before committing
git reset HEAD PUSHING-TO-PUBLIC.md
git checkout -- PUSHING-TO-PUBLIC.md 2>/dev/null || true

# Commit with a summary message
git commit -m "Update skill library"

# Push to public
git push iahp public-push:main

# Clean up
git checkout main
git branch -D public-push
```

### 4. Verify

```bash
git fetch iahp
git diff main..iahp/main   # should show no diff (or only this file and other gitignored items)
```

## GACP integration

When `/gacp` runs and this file is present, it should:
- **Never stage this file** for commits intended for the public remote
- **Never reference** this file, the public/private distinction, or the existence of multiple remotes in commit messages
- Treat `origin` as the default push target (private). Public pushes are always manual and explicit.

## Files excluded from public

These files exist in private but must never appear in public commits:
- `PUSHING-TO-PUBLIC.md` (this file)
- Any file listed under "Internal working files" in `.gitignore`

## Checklist (before every public push)

- [ ] All work committed to private
- [ ] `git diff iahp/main..HEAD` reviewed line by line
- [ ] No PII, client names, or internal project references
- [ ] No credentials or tokens
- [ ] No local paths that reveal personal system structure
- [ ] Collapsed to single commit
- [ ] Pushed and verified
