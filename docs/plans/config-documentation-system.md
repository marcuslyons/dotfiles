# Config documentation system - planning doc

## Goal

Build a system inside this dotfiles repo that:

1. Manages third-party tool config (starting with Übersicht widgets) via stow in a way that survives upstream upgrades.
2. Publishes a per-tool settings reference doc, backfilling the undocumented parts of each tool.
3. Keeps those docs from rotting via a pre-commit check.
4. Eventually exposes a browsable index ("what's configured on this machine, and what do the settings mean") as a local webpage or CLI.

Scope fits into the existing stow migration already tracked in `PLAN.md`. This doc is additive to that plan, not a replacement.

## Hard questions to answer before coding

These will change the shape of every phase. Resolve before Phase 1.

1. **Vendor vs. overlay for Übersicht widgets.** simple-bar-lite is a git repo cloned from upstream. Two options:
   - **Overlay** (recommended default): bootstrap script clones upstream into `~/Library/Application Support/Übersicht/widgets/simple-bar-lite`, stow drops `custom-settings.json` on top via symlink. Pro: trivial upgrades (`git pull` in the widget dir). Con: any widget-level patches (e.g., a custom React component) have to live upstream or be applied as a script.
   - **Vendor**: fork simple-bar-lite, add it as a submodule under `ubersicht/widgets/simple-bar-lite/`. Pro: full control, custom components commit-able. Con: upgrade work, you own it now.
   - **Decision needed:** which one? My guess: overlay for now, revisit if you ever want a custom component.

2. **Where is the source of truth for settings defaults?** The doc reference for simple-bar-lite was reconstructed from upstream's `default-settings.json`. For a pre-commit check to be useful, it needs to read defaults from _somewhere_.
   - Option A: require the widget to be cloned locally; pre-commit reads from the live path. Fails in CI and on clean checkouts.
   - Option B: snapshot `default-settings.json` into `docs/snapshots/<tool>/` and diff against a pinned upstream SHA. Works offline, makes drift visible in git.
   - Option C: fetch upstream at commit time. Works online only, flaky.
   - **Decision needed:** B is the right default. A can be a local-dev fast path.

3. **Doc format: prose reference or machine-readable schema?** The current `simple-bar-lite-settings.md` is handwritten prose with tables. A pre-commit that checks "every key in defaults appears in the doc" needs to parse tables or keys out of the prose. Alternative: maintain a YAML/JSON settings schema per tool and generate the markdown from it.
   - Prose-only: easy to write, annoying to lint. Checker has to regex tables.
   - Schema-driven: strict, generates clean docs, but you now maintain a schema format.
   - Hybrid: prose markdown is the output; schema file is the input; human edits the schema, generator writes the `.md`.
   - **Decision needed:** prose-only for v1, schema-driven if it bites. Committing too early to a schema is how these projects die.

4. **Dashboard: read-only inventory or live introspection?**
   - Read-only: static site generated from `docs/` markdown. Hosted locally via `python -m http.server` or published as a GitHub Pages site off the dotfiles repo. Easy.
   - Live: reads actual current config files on the machine, diffs vs. defaults, shows per-package status. Much more useful, much more work. Effectively a custom inspector per tool.
   - **Decision needed:** start with static site generated from markdown. Live introspection is Phase 5 and probably overkill until you feel the pain.

5. **OS scoping.** The dotfiles repo is going cross-platform (macOS + Omarchy per `PLAN.md`). Übersicht is macOS-only. Other tools (yabai, skhd, karabiner, Ghostty) are also macOS-only. Any docs system needs to tag docs by OS and filter the dashboard by detected platform.
   - **Decision needed:** every settings doc declares an `os:` front-matter field (`macos`, `linux`, `both`). Dashboard filters on it.

## Phases

Each phase has an acceptance criterion. Phases are sequential; sub-tasks inside a phase can parallelize.

---

### Phase 1 - Übersicht widget stow package

**Goal:** `custom-settings.json` for simple-bar-lite is owned by dotfiles, symlinked into Übersicht's widget dir, survives `stow -R` cleanly.

**Acceptance:** Running `stow ubersicht` from repo root creates the expected symlink; removing it with `stow -D ubersicht` leaves the widget's upstream files intact.

**Tasks:**

- [ ] Decide vendor vs. overlay (see open question 1). Record in `docs/plans/config-documentation-system.md` under "Decisions".
- [ ] Add a `ubersicht/` stow package at the repo root, following the flat-package convention already in `PLAN.md`:
  ```
  ubersicht/
    Library/
      Application Support/
        Übersicht/
          widgets/
            simple-bar-lite/
              custom-settings.json
  ```
  Note the non-ASCII `Ü` in the path. Verify stow handles it on both HFS+ and APFS without NFC/NFD normalization drama.
- [ ] Move the current `~/Library/Application Support/Übersicht/widgets/simple-bar-lite/custom-settings.json` into the stow package.
- [ ] Write a bootstrap snippet (in `install.sh` per the existing migration plan) that:
  - installs Übersicht if missing (`brew install --cask ubersicht`)
  - clones simple-bar-lite if the target dir doesn't already contain a git repo pointing at the upstream remote
  - runs `stow -t "$HOME" ubersicht`
  - verifies the symlink exists and points at the package
- [ ] Guard the whole thing behind an OS check (`[[ "$(uname)" == "Darwin" ]]`).
- [ ] Decide whether other Übersicht widgets deserve management now or are added on-demand.

**Open risks:**

- The `Application Support` path contains a space; make sure any scripting quotes correctly.
- Übersicht caches compiled widgets; may need a `killall Übersicht && open -a Übersicht` after stowing to force a reload.
- If the user has edits in the existing `custom-settings.json` not represented in the repo version, the move overwrites them. Pre-flight diff before destructive move.

---

### Phase 2 - Settings doc template and simple-bar-lite doc (done)

**Goal:** A repeatable pattern for per-tool settings reference docs.

**Status:** Partially done. `docs/simple-bar-lite-settings.md` exists.

**Tasks:**

- [ ] Define the doc template: front-matter (os, source-repo, source-sha, last-verified-date), sections (Top-level, Nested blocks, Gotchas, Source map).
- [ ] Retrofit `simple-bar-lite-settings.md` to the template once defined.
- [ ] Decide a docs directory layout that scales:
  ```
  docs/
    settings/
      macos/
        simple-bar-lite.md
        yabai.md
        skhd.md
        karabiner.md
        ghostty.md
      linux/
        hyprland.md
        ...
      common/
        zsh.md
        starship.md
        nvim.md
        git.md
    snapshots/
      simple-bar-lite/
        default-settings.json  # vendored snapshot
        SHA                    # upstream commit pinned
    plans/
      config-documentation-system.md
  ```
- [ ] Move the existing doc to `docs/settings/macos/simple-bar-lite.md`.

**Acceptance:** Template file exists at `docs/settings/_template.md`. simple-bar-lite doc conforms to it.

---

### Phase 3 - Drift check (pre-commit)

**Goal:** A pre-commit hook that fails when a tool's upstream defaults have keys the local doc doesn't document, or vice versa.

**Acceptance:** Modifying the snapshotted `default-settings.json` without updating the doc causes `git commit` to fail with a readable error listing missing keys.

**Tasks:**

- [ ] Choose implementation: shell + `jq` (simple, works anywhere) vs. a Python script (richer, easier parsing).
- [ ] Write a drift checker that, for each tool with a snapshot:
  - reads `docs/snapshots/<tool>/default-settings.json`
  - flattens to dotted-path keys (e.g., `theme.dark.main`, `dataWidgets.battery.refreshFrequency`)
  - greps the corresponding markdown for each key (or parses code blocks / tables; decide based on doc format question)
  - reports undocumented keys and documented-but-missing keys
- [ ] Add a `make docs-check` or `just docs-check` target.
- [ ] Wire it into `pre-commit` (either the `pre-commit` framework or a raw `.git/hooks/pre-commit` - probably use the framework since `PLAN.md` implies other Python/shell tooling).
- [ ] Add an upstream-sync script: `scripts/sync-upstream-defaults.sh <tool>` that re-downloads `default-settings.json` from a known upstream, bumps the pinned SHA, and reports what changed. Run manually or on a schedule.
- [ ] Add CI step (GitHub Actions) that runs the same check on PRs.

**Open risks:**

- Prose docs are hard to parse deterministically. If the checker is too strict, everyone learns to bypass it. If too loose, it catches nothing.
- Some keys are dynamic (customComponents props depend on which component). Checker needs an allow-list for those.

---

### Phase 4 - Inventory generator

**Goal:** A command that walks the repo and emits a machine-readable index of "what packages are stowed on this OS, and what docs cover them."

**Acceptance:** `scripts/inventory.sh` (or similar) prints JSON like:

```json
{
  "os": "macos",
  "packages": [
    {
      "name": "ubersicht",
      "stowed": true,
      "target": "~/Library/Application Support/Übersicht/widgets/simple-bar-lite/custom-settings.json",
      "managed_files": ["..."],
      "docs": ["docs/settings/macos/simple-bar-lite.md"],
      "upstream": "https://github.com/Jean-Tinland/simple-bar-lite",
      "upstream_sha": "..."
    }
  ]
}
```

**Tasks:**

- [ ] Define the inventory schema.
- [ ] Write a script that reads each stow package, detects what it manages (`find pkg/ -type f`), maps back to OS target paths, and joins against the docs directory.
- [ ] Decide where metadata like `upstream` lives: inline in the doc's front-matter, or in a separate `ubersicht/.dotfiles-meta.yaml` per package. Prefer front-matter to keep metadata next to docs.
- [ ] Output formats: JSON (for the dashboard), Markdown summary (for humans in a terminal).

---

### Phase 5 - Dashboard (static site)

**Goal:** A local webpage rendering the inventory, grouping packages by OS, linking to each settings doc.

**Acceptance:** `make dashboard` (or a `just` recipe) builds a static site into `docs/_site/` and `make dashboard-serve` opens it in a browser.

**Tasks:**

- [ ] Pick a generator. Candidates, cheapest to richest:
  - Plain markdown + a simple Python/Node script that produces an `index.html` from the inventory JSON.
  - MkDocs (material theme). Good search, cheap to set up, the docs directory already fits.
  - Astro or Eleventy. Overkill unless you want interactivity.
  - **Recommended:** MkDocs Material. Known-good, supports front-matter, has built-in search, fits a `docs/` tree without restructuring.
- [ ] Generate an index page grouped by OS, pulling from Phase 4's inventory.
- [ ] For each package, render the settings doc page with upstream link and "last verified" date.
- [ ] Optional: a "diff" page per package showing which keys in `custom-settings.json` actively override defaults (requires reading the stowed file at build time, stays static at render time).
- [ ] Optional: deploy to GitHub Pages. Private repo = private pages, so no leakage concern.

**Open risks:**

- Scope creep. A dashboard with diffs is cool, but it's effectively a second product on top of the dotfiles repo. Keep v1 read-only.

---

### Phase 6 - Backfill other tools

**Goal:** Apply the Phase 2/3 pattern to every other tool in the repo.

**Tasks (one per tool, each a separate PR/commit):**

- [ ] yabai (`.yabairc`)
- [ ] skhd (`.skhdrc`)
- [ ] Karabiner (`karabiner.edn` / `karabiner.json`)
- [ ] Ghostty (`ghostty/config`)
- [ ] Starship (`starship.toml`)
- [ ] nvim (huge, probably just link to upstream docs and document overrides)
- [ ] zsh (aliases, functions, dispatcher setup already in `PLAN.md`)
- [ ] git config
- [ ] Homebrew Brewfile (a list, not really "settings", but belongs in the inventory)
- [ ] Whatever Omarchy-side tools show up (Hyprland, Waybar, etc.)

Most of these have good upstream docs already; the value is documenting _your overrides_, not re-documenting every option. For each tool, decide:

- Full reference (like simple-bar-lite because upstream was thin) OR
- Overrides-only doc that lists only the keys you set and why.

---

## Suggested execution order

- Phases 1-3 are the minimum viable system. Do them in order.
- Phase 4 is small and unlocks Phase 5; do it once Phase 3 has been used in anger for a week or two and the doc format has stabilized.
- Phase 5 can be deferred indefinitely; the docs are already useful as plain markdown in the repo.
- Phase 6 is a drip-feed, one tool at a time, not a blocker.

## Decisions log

Fill these in as they're made. Left blank intentionally.

- [ ] Vendor vs. overlay for Übersicht widgets:
- [ ] Defaults source-of-truth approach:
- [ ] Doc format (prose vs. schema-driven):
- [ ] Dashboard approach (static vs. live):
- [ ] Doc front-matter fields:
- [ ] Pre-commit framework (`pre-commit` vs. raw hook):
- [ ] Static site generator:

## Out of scope (on purpose)

- Secret management. `custom-settings.json` here has no secrets; other tools might. Not this project.
- Config validation against a tool's actual schema. JSON Schema for each tool would be nice but is a rabbit hole.
- Cross-machine sync of settings (e.g., different `locale` on different macs). Stow doesn't solve this; `chezmoi` does. If you feel this pain, it's a different project.
