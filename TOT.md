# Train of Thought

## 2026-06-06 — Where should `~/.claude/output-styles/` be managed?

Three options considered for adding output-style management to iahp:

1. **Symlink `~/.claude/output-styles` → `iahp/output-styles/`** (mirror skills convention via `setup.sh`). Cleanest mechanically but locks the user out of dropping ad-hoc local styles outside the repo.
2. **Per-file copy in `setup.sh`** — safer for coexistence with user-local styles, but `setup.sh` is supposed to stay minimal (it only handles the skills symlink).
3. **Make the `setup` skill responsible** — canonical sources live in `setup/references/output-styles/`, synced into `~/.claude/output-styles/` on every `/setup` invocation. User chose this.

Why option 3 won: keeps `setup.sh` narrow (skills link only); puts user-facing config under a skill that's already responsible for bootstrapping the user's Claude environment; allows interactive confirmation on divergence (which `setup.sh` can't do cleanly); leaves user-local styles untouched.

Open question for later: should other `~/.claude/` artifacts (settings.json, hooks/, agents/) follow the same canonical-source-under-`setup/references/` pattern? Not addressed this session.
