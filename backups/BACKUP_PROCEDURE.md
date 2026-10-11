# Artifact Backup Procedure

## Problem
The artifact at https://claude.ai/artifact/4pG6rjMnLYwEzVmncvNH1r is the authoritative published copy of the study notes. Without version history in the UI, we must maintain our own backups.

## Solution

### 1. Before Any Major Artifact Changes
**Always follow this sequence:**

1. **Read the artifact** to disk with the Artifact tool
2. **Save it to `/backups/artifact-pre-change.html`** with a descriptive name
3. **Make the change** (edit markdown, regenerate HTML, etc.)
4. **Publish the new version**
5. **Verify it worked** by checking the live artifact
6. **Save the new version** to backups with a dated filename

### 2. Automated Frequent Backups
Run via cron. Choose one:

**Every 4 hours (recommended):**
```
0 */4 * * * /Users/khainguyen/Projects/computational-imaging-notes/backups/backup.sh
```

**Every 30 minutes (more aggressive):**
```
*/30 * * * * /Users/khainguyen/Projects/computational-imaging-notes/backups/backup.sh
```

**Every hour:**
```
0 * * * * /Users/khainguyen/Projects/computational-imaging-notes/backups/backup.sh
```

To set up: `crontab -e` and add one of the lines above.

### 3. Backup Naming Convention
```
artifact-YYYY-MM-DD-description.html    # Pre-change backups (manual, descriptive)
artifact-YYYY-MM-DD-HH-MM-SS.html       # Automated frequent backups (timestamped)
artifact-latest-good.html               # Known good version (always updated after successful changes)
```

### 4. Retention Policy
- **Keep:** Last 30 backups (rolling window)
- **Delete:** Anything older than 90 days
- **Result:** Recent backups available hourly/4-hourly for quick recovery, old ones auto-cleaned

### 5. Git Workflow
Commit only the "latest-good" snapshot (not every automated backup):
```bash
# After a successful change, update and commit
git add backups/artifact-latest-good.html
git commit -m "Backup: artifact after [description]"
git push origin main
```

### 6. Recovery Procedure
If the artifact is corrupted:

1. **Check `/backups` directory** for the most recent good version
2. **If not found locally**, check `/Users/khainguyen/.claude/projects/.../tool-results/` for cached copies
3. **Restore** with:
   ```bash
   cp backups/artifact-latest-good.html /tmp/index.html
   # Then republish via Artifact tool with force:true
   ```

## Current Status
- ✅ Backup directory created at `/backups/`
- ✅ Latest known-good backup saved as `artifact-latest-good.html`
- ⏳ Next: Set up weekly automated backups via cron

## Rules for Claude Code
- **Never use broad regex on the artifact** (lessons learned the hard way)
- **Always test changes** on markdown first, verify conversion
- **Always read artifact before publishing** changes to it
- **Always save a pre-change backup** with a descriptive name before major edits
