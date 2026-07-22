# Changelog

Notable user-visible changes to Peel are recorded here. Peel is in active development, so this
changelog follows public signed releases rather than every internal commit.

Each entry links to its full release notes.

## Unreleased

### Documentation

- Added a public product overview, a complete feature map, and a task-focused swarm onboarding
  guide.
- Published the product page at https://cloke.github.io/peel-releases/, served from the
  `gh-pages` branch. Screenshots are still pending, so the page carries `robots noindex` until
  they land.
- Added `scripts/publish-page.sh`, which rebuilds `gh-pages` from `docs/` and refuses to publish
  if the content fails a denylist and OCR check.

## 2.7.0 - 2026-07-22

### ollama.chat: vision input + token usage
- `ollama.chat` now accepts base64 `images`, so vision-capable models (e.g. gemma4) can read documents and screenshots directly over the swarm inference path, with no separate OCR step. Text-only calls are unchanged.
- Responses now report `inputTokens` / `outputTokens` / `totalTokens` when the model provides them, for per-request cost estimation.

### RAG & fleet
- Auditable RAG transfer evidence and bounded transfer-ledger growth.
- Cancellable RAG indexing recovery and complete file scanning (RAGCore bump).
- Fleet coverage and policy scorecard; fleet version and Iroh health metrics.
- Workspace authority repair and canonical knowledge-scope healing.

### Fixes
- Stop Ollama embedding crash loops.
- Move MLX model cache to Application Support.
- Make Knowledge UI automation actionable; isolate XCTest from production runtime state.
- Analytics cards now steer the chart.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.7.0)

## 2.6.0 - 2026-07-22

## Unified knowledge for agents

Compatibility note: the deprecated `learnings.*`, `insights.*`, and `rag.lessons.*` MCP tools have been removed. Custom clients and plugins should use `knowledge.recall`, `knowledge.add`, and `knowledge.verdict`.

Peel now gives agents one durable knowledge surface for findings and guidance, plus reusable patterns and fixes. Entries are signed and content-addressed. Scope controls who can receive them, and the model jury evaluates them before they influence future work.

## Faster tool discovery

Agents now start with ten essential MCP tools and discover the rest on demand. This keeps initial prompts small while preserving access to Peel's full catalog through search and schema loading.

## Counts that explain themselves

Knowledge totals now separate universal and repository knowledge from workspace and private-device records. They also identify repository records that cannot travel between machines. Universal knowledge should agree across machines while local knowledge stays private by design.

## Stronger trust boundaries

Knowledge signatures bind the exact semantic content and verdicts bind to the matching schema and digest. Legacy records migrate conservatively, remote command payloads are no longer persisted, and plugin execution fails closed when its security boundary is unavailable.

The iOS companion now uses the same knowledge model as macOS, so both surfaces present consistent durable context.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.6.0)

## 2.5.1 - 2026-07-22

## Safer local RAG indexing

Peel now excludes local OAuth, Firebase, TURN, signing-key, and service-account credential files before source indexing. Ignored local configuration no longer appears in Peel source search snippets or shared RAG artifacts.

Existing Peel source indexes are cleaned on the next automatic checkout refresh. A new repository audit also prevents future changes from silently removing these protections.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.5.1)

## 2.5.0 - 2026-07-21

Peel now gives agents one trustworthy memory system, makes better swarm routing decisions under real machine load, and adds a local vision tool for image-aware work.

## Knowledge is one surface

Agent memory now lives in signed, scoped knowledge records instead of separate learnings, insights, guidance, and RAG lesson stores. Peel verifies authorship, keeps private records local, rebuilds its search projection automatically, and uses model-jury verdicts to separate durable guidance from weak or stale claims.

Recall is useful even when the semantic index is cold. Agents get deterministic lexical fallback, semantic paraphrase matching, repository-aware filtering, and a small digest they can hydrate on demand. Chain outcomes and review-quality feedback feed the same system without duplicate records.

The deprecated `learnings.*`, `insights.*`, and `rag.lessons.*` MCP tools have been removed. Integrations should use `knowledge.recall`, `knowledge.get`, `knowledge.add`, `knowledge.feedback`, `knowledge.verdict`, and `knowledge.adjudicate`.

## Smarter swarm routing

Dispatch now accounts for memory pressure, thermal state, and the real frontier-model headroom available on each machine. Brain-only nodes also announce themselves before capability filtering, so they can participate instead of disappearing from the fleet.

## Local vision

A new Labs-gated `vision.describe` tool runs image understanding locally through MLX VLM. It gives agents a private path for screenshot and image analysis without sending the source image to a hosted model.

## Quieter, more responsive operation

Screen capture no longer triggers an unexpected Screen Recording permission prompt. MCP clients identify themselves and can be inspected through `clients.list`, large request parsing stays off the main actor, and legacy knowledge migration is paged in the background so an established installation does not freeze during upgrade.

Signed and notarized Apple silicon macOS build. Source commit: `38e5a2acc48a6453bf7dcaa0caed933a166d21c7`.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.5.0)

## 2.4.0 - 2026-07-21

Repo announcements are now scoped per swarm, with vision support on more model routes and a batch of responsiveness fixes.

## Privacy: per-swarm repo announcements

A machine that belongs to more than one swarm used to tell every swarm about every repo it had indexed. Being indexed locally was enough to be announced. Now a machine announces only the repos you choose, per swarm.

The RAG overlay payload was already gated. This closes the matching gap on the announcement itself, across all three surfaces that carried it. Three new tools configure it at runtime: `swarm.announce.list`, `swarm.announce.add`, and `swarm.announce.remove`. Existing swarms are seeded once from what is already indexed, so nothing changes for them on upgrade.

## Set up a repo by pulling from a peer

If another machine in your swarm already has a repo indexed, you can pull that index and be ready to search. No local indexing needed. The RAG tab now leads with "Pull from <peer>" on a repo this machine has not indexed, and picks the right transfer shape for you.

## Vision on more routes

Local Ollama models now receive images, including for patrol review. OpenAI-style multimodal messages convert to the shape Ollama expects. The Copilot route refuses image content it cannot handle rather than silently dropping it.

## Responsiveness

- Heartbeats fast-fail to unreachable peers through a per-peer circuit breaker, so one dead machine no longer stretches every beat.
- Analyze and enrich report progress on the same throttle indexing already used.
- Ledger ingest is bounded so it cannot flood the main actor.
- The main-thread watchdog runs in release builds now, and stops reporting zeroes as health.

## Also

- Docling honors its OCR toggle and the rest of its preset knobs instead of always running OCR.
- Learning retraction has a single owner across all three stores, so a retracted learning stays retracted everywhere.
- Analysis numbers are reported honestly, and the analyzer pin is exposed.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.4.0)

## 2.3.1 - 2026-07-20

Three fixes to keep indexed repositories and their search data up to date.
[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.3.1)

### Fixed

- Followed workspaces stopped picking up new commits when their submodules were checked out
  detached. Sync updated the branch references but left files frozen on disk, so a repository
  could sit days behind while every sync reported success. Detached submodules now move forward
  when it's provably safe, meaning nothing uncommitted and nothing unique to lose.
- Enrichment could stall permanently. An oversized re-embedding batch could kill the local
  embedding server mid-request, and the same batch was retried every run, so affected
  repositories never finished. Batches are now sized by content length rather than a fixed
  count, and fall back to one chunk at a time.

### Changed

- Enrichment and quality scanning now run on a schedule. Both steps are incremental and
  previously only advanced when triggered by hand.

## 2.3.0 - 2026-07-20

Fleet-scale RAG management, and the app stays responsive during heavy indexing and sync.
[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.3.0)

### Added

- **Repository Fleet inspector.** One control plane for the whole RAG fleet, in the UI and over
  MCP, with grouped bulk management and atomic bulk writes.
- **Fleet-wide processing policy.** Choose full automatic processing or vector-index-only, at
  fleet, workspace, or repository scope.
- **Routing previews.** Bulk source changes resolve through a preview, and reviewed previews
  revalidate before any policy is written.
- **Workspace-aware source policy**, following a default, then workspace, then repository
  hierarchy.
- **Sign in with Apple for direct-download builds.** Developer ID builds can't carry the native
  entitlement, so the direct build runs Apple's web OAuth flow in-app.
- **Lane-aware transport QoS**, so interactive peer-to-peer requests no longer queue behind bulk
  RAG transfers.

### Changed

- RAG status polling is latency-bounded and reads from a cache, so it can't queue behind indexing
  or imports.
- Semantic search runs on a read-only lane and searches fleet partitions concurrently, degrading
  to the text projection when it has to.
- Text search stays responsive during indexing, served from a durable last-complete projection.
- Indexing fails fast when the embedding provider's vector width doesn't match the index, rather
  than corrupting state.

### Fixed

- UI automation clicks could deadlock the app.
- The swarm map looked frozen when idle. It now keeps a gentle ambient refresh.
- Stale plugin folder grants returned a generic server failure instead of something actionable.

## 2.2.2 - 2026-07-18

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.2.2)

### Fixed

- The direct `swarm.remote-tool-call <worker> app.update` form was blocked for your own verified
  machines, because it took a receive path that still hit an over-broad safety gate. Remote fleet
  updates already worked through the worker's local update trigger. Now the direct form works too.

## 2.2.1 - 2026-07-18

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.2.1)

### Fixed

- **Remote fleet updates work again.** One of your own machines can trigger another release-build
  machine to update itself through Sparkle, with no source checkout and no operator involved. An
  over-broad safety gate was blocking it.
- Hardened the headless updater so it runs strictly on demand and doesn't compete with the app's
  normal update checks.

## 2.2.0 - 2026-07-18

The direct-download build is unsandboxed again, which restores full local execution.
[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.2.0)

### Changed

- **The direct build is no longer sandboxed.** The App Sandbox blocked Peel from executing
  Homebrew-installed CLIs like `gh` and `node`, which meant agent chains and patrols couldn't run
  at all. The direct-download build is still notarized with a hardened runtime.

### Upgrade note

- App data moved out of the sandbox container to `~/Library/Application Support/Peel`. You may
  need to re-add your repositories after updating. Folder access no longer needs per-folder
  grants, and SSH and Homebrew tools work with no extra setup.
- The Mac App Store and TestFlight build stays sandboxed, because Apple requires it, and is a
  more limited variant. Use the direct download for the full agent workflow.

## 2.1.2 - 2026-07-17

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.1.2)

### Fixed

- **Local execution no longer hangs.** In 2.1.1, git operations, agent chains, and terminal
  commands could hang indefinitely, waiting on a helper connection that never completed. The app
  now falls back to in-sandbox execution immediately.
- **SSH git works** once you grant access to your `~/.ssh` folder. Passphrase-protected keys
  aren't supported in this build yet, so use a passphrase-less key for now.

## 2.1.1 - 2026-07-17

Repairs sign-in and session persistence in the direct-download build.
[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.1.1)

### Fixed

- **Google sign-in works again.** 2.1.0 couldn't save your session, showing a keychain error
  after signing in and then signing you out on every launch. The app now carries the keychain
  entitlements it needs.
- **No more launch crash from a denied keychain prompt.** Clicking Deny on a keychain dialog could
  crash the app at startup and keep crashing. It now continues and retries on a later launch.
- Repaired the release build pipeline so future updates ship reliably through the in-app updater.

### Notes

- You may see a handful of keychain prompts on first launch if you previously used a TestFlight or
  self-built copy. Click **Always Allow** on each and they won't return.
- Sign in with Apple isn't available in this build. Apple restricts that capability to App Store
  and TestFlight builds, so use Google sign-in here. (A web-based flow arrived in 2.3.0.)

## 2.1.0 - 2026-07-17

Repository intelligence becomes trustworthy enough that an agent can ask Peel what it needs, act
on the answer, and leave better knowledge behind.
[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.1.0)

### Added

- **One repository-scoped door for what agents need to know**, covering prior decisions, fixes,
  lessons, and source. Peel ranks the evidence within a context budget and makes stale or
  ambiguous knowledge visible instead of presenting it as timeless truth.
- **A Playground that understands the swarm.** Local chat can ground a conversation in a
  repository indexed on another Mac and use the model and retrieval tools available there. If that
  peer goes offline, Playground falls back to this Mac's synced overlay and explains the degraded
  route rather than losing the conversation.

### Changed

- Scheduled work stays active until its chain actually finishes, and records real failures instead
  of optimistic starts.
- A Mac receiving a RAG overlay no longer repeats the source machine's analysis and enrichment.
  Derived knowledge moves across the swarm while the expensive work stays put, which cuts latency,
  GPU load, and battery use.
- App Store and direct-download builds are now distinct artifacts. The Store build stays sandboxed
  and Sparkle-free, and the Developer ID build keeps signed updates.

### Fixed

- Peel preserves readable local stores when a build meets an unfamiliar schema, rather than
  treating them as corruption. Schema histories are frozen and model-shape fingerprints are pinned
  by tests.

### Upgrade note

- Peel 2.0.0 can find this release but can't launch Sparkle's sandboxed installer. Install 2.1.0
  once from the notarized DMG. Your existing store migrates in place, and later releases update
  normally from inside Peel.

## 2.0.0 - 2026-07-14

The first signed and notarized public release.
[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.0.0)

### Distribution

- Published the first signed and notarized public Peel release.
- Added a drag-to-Applications DMG installer.
- Added signed automatic updates through Sparkle.
- Published SHA-256 checksums for the DMG and updater ZIP.

### Included in this release

- Repository-centered agent runs, isolated in git worktrees behind review gates.
- Local RAG indexing with semantic and text search.
- Code analysis, dependency graphs, and repository skills.
- A unified Inbox covering local work, swarm work, pull requests, and background-agent
  observations.
- Workflow templates, long tasks, and schedules.
- Patrols, specialist agents, plugins, and skill packs.
- Distributed swarm execution with RAG overlay sharing and GPU routing.
- Live traffic and activity replay across Macs.
- More than 300 tools through MCP, plus an OpenAI-compatible local API.

## Project milestones

- **2026-01-17.** The application was renamed Peel, once repository intelligence and agent
  orchestration became the product focus.
- **2020-12-19.** The codebase began as a SwiftUI developer-tool experiment.
