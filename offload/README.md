# offload

Copies personal data off a work machine without taking the employer's code.

Written on a layoff day, from the mistakes made that day.

## Install

```bash
stow -d ~/github/marcuslyons/dotfiles -t ~ offload
```

Lands at `~/.local/bin/offload`, already on `PATH`.

## Use

```bash
offload --dest /Volumes/nas/offload-$(date +%F) --dry-run   # look first
offload --dest /Volumes/nas/offload-$(date +%F)             # copy, audit, verify
offload --dest /Volumes/nas/offload-2026-09-10 --audit-only # re-audit later

# bulk to the NAS, small irreplaceable set to iCloud as well
offload --dest /Volumes/nas/offload-$(date +%F) --icloud \
        --icloud-add va-claim-backup
```

Set `--work-terms` to your employer's repo and service names before first use,
or edit `WORK_TERMS_DEFAULT` in the script.

## Two destinations

A NAS you can only reach from home is not off-site, and one copy is not a
backup. `--icloud` writes a second copy of the small irreplaceable set: SSH
keys, plus anything named with `--icloud-add`.

Keep that list short. iCloud is for what you could never reconstruct, not for
bulk. It is also the right home for files over 100 MB, which GitHub rejects
outright.

**A file landing in the iCloud folder is not the same as it being uploaded.**
The script waits for `brctl status` to report `caught-up` and prints your
remaining quota. On a machine about to be wiped, that distinction is the whole
point. It also re-runs the work-term audit against the iCloud copy, because a
second destination is a second chance to leak.

Private key permissions are re-applied after the copy, so `0600` does not
become `0644` in transit.

## What it does

1. Refuses a destination inside `$HOME`, because that is the disk you are losing.
2. Copies personal directories, skipping caches, credentials, and Apple-synced data.
3. Deletes anything matching the work term list from the copy.
4. Audits the copy by file name **and file content**.
5. Scans for live credentials.
6. Reads the copy back and compares both directions.
7. Writes `MANIFEST.md` and `AUDIT.txt` into the destination.
8. With `--icloud`, copies the small set off-site and waits for the upload.

## Why each guard exists

Every one of these is a mistake that actually happened, not a hypothetical.

**Work source hides in Downloads.** A wholesale `rsync ~/Downloads` put a full
snapshot of the employer's main repo onto personal storage. A source archive on
your NAS is how a layoff becomes a lawsuit. The name filter catches it, and step
3 deletes it if it slips through.

**Names are the easy half.** A file called `notes.md` can hold an internal
architecture diagram. The audit greps contents as well as names.

**AI agent transcripts are source code.** Session logs under `.claude/projects/`
and `.codex/sessions/` contain file reads, diffs, and edits from work repos.
They look like config and they are not.

**Credentials travel in directories you copy for other reasons.** `.codex/auth.json`
came along inside an otherwise personal config folder.

**Browser profiles are work data.** History, cookies, and `Login Data` from a
work laptop are mostly work browsing and can hold live session tokens. Excluded
outright. Passwords belong in a password manager anyway.

**Apple already has some of it.** Photos, Messages, Notes, and Safari sync to
iCloud. Copying Messages alone would have added 18 GB to a transfer that had a
hard deadline.

**Verification must look both ways.** `rsync -an source dest` only reports what
the destination lacks. A `Documents` folder was tidied into the Trash minutes
after being copied, and the check reported success against a nearly empty
source. The script now counts files on both sides and says so when the source
shrinks.

## Exit codes

`0` clean, `1` the audit found something to review, `2` bad usage.

A non-zero audit is not automatically a failure. Names often match harmlessly.
Read `AUDIT.txt` and decide.

## What it will not do for you

- It does not push git repos. Do that separately and confirm every repo has a
  remote first.
- It does not verify archives beyond `unzip -t`. For Google Takeout archives
  over 4 GiB, see `zip-recover`.
- It cannot know which of your work is contractually yours. Get that in writing
  from someone senior, by email, while you still have an account.
