# Artifact Backup Workflow

## Save a Versioned Backup

After any significant artifact change, save a timestamped backup:

```bash
cd /Users/khainguyen/Projects/computational-imaging-notes/backups
./save-version.sh "description-of-change"
```

Examples:
```bash
./save-version.sh "clarity-improvements-week5"
./save-version.sh "removed-linear-algebra-views"
./save-version.sh "glossary-update"
```

This creates: `artifact-YYYY-MM-DD-HH-MM-SS-description.html`

## Before Publishing to Artifact

**Always:**
1. Read the artifact with Artifact tool → saves to `/tmp/index.html`
2. Make changes locally
3. Publish to artifact
4. **Immediately save backup**: `./save-version.sh "description"`
5. Verify the artifact looks correct
6. Commit the backup to git

## After Publishing

```bash
# Save timestamped backup
cd backups && ./save-version.sh "what-changed"

# Commit to git
git add backups/artifact-latest-good.html
git commit -m "Backup: artifact after [what-changed]"
git push origin main
```

## Backup Files

```
backups/
├── artifact-latest-good.html                    # Always points to the latest verified good version
├── artifact-2026-10-11-12-29-45-system-setup.html   # Timestamped versions (KEEP THESE)
├── artifact-2026-10-11-10-15-22-clarity-week5.html
├── artifact-2026-10-10-16-45-33-glossary-fix.html
└── BACKUP_PROCEDURE.md, save-version.sh, etc.
```

## Recovery

If artifact is corrupted:

1. **Find the backup you want:**
   ```bash
   ls -1t backups/artifact-*.html | head -10
   ```

2. **Restore it:**
   ```bash
   cp backups/artifact-2026-10-11-10-15-22-clarity-week5.html /tmp/index.html
   # Then use Artifact tool to republish with force:true
   ```

## Key Rules

✅ **DO:**
- Save backup after every significant change
- Commit backups to git
- Use descriptive names (e.g., "clarity-week5" not "fix")
- Verify backup contains all 5 weeks before committing

❌ **DON'T:**
- Publish artifact changes without saving a backup first
- Use broad regex operations (lesson learned)
- Delete backups manually (script auto-cleans old ones)
