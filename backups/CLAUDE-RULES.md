# Claude Code Artifact Backup Rules

**These rules are binding on every artifact operation in this project.**

## Rule: Auto-Backup After Every Artifact Publish

Whenever the Artifact tool publishes to https://claude.ai/artifact/4pG6rjMnLYwEzVmncvNH1r:

1. **Read the artifact** (verify it published correctly)
2. **Immediately save backup**: Call `backups/auto-backup.sh "brief-description"`
3. **Do not proceed to other work** until backup confirms success (week-5 verification)

## When This Triggers

- After `Artifact action:publish` (any URL to this artifact)
- Before starting new work
- Before closing conversation where artifact changed

## Examples

```bash
# After publishing Week 5 clarity improvements
backups/auto-backup.sh "clarity-improvements-week5"

# After removing linear-algebra sections
backups/auto-backup.sh "removed-linear-algebra-views"

# After fixing typo
backups/auto-backup.sh "typo-fix"
```

## What Auto-Backup Does

1. Saves `/tmp/index.html` to `artifact-TIMESTAMP-description.html`
2. Verifies it contains all 5 weeks
3. Updates `artifact-latest-good.html`
4. **Automatically commits to git** with message "Auto-backup: artifact after [desc]"
5. **Automatically pushes to origin/main**

## Failure Mode

If auto-backup fails:
- Do not continue other work
- Check error messages
- Manually investigate `/tmp/index.html`
- Do not attempt workarounds

## Recovery

Every artifact change has a timestamped backup in:
- Local disk: `/backups/artifact-TIMESTAMP-*.html`
- Git history: Commit history with "Auto-backup:" messages
- Latest-good: Always current `/backups/artifact-latest-good.html`

---

**Status:** ✓ Live as of 2026-10-11. All future artifact changes will auto-backup.
