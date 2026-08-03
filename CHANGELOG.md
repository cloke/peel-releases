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

## 2.21.0 - 2026-08-03

Peel 2.21.0 puts asset generation where it belongs: on the swarm.

- Asset generation now dispatches to a heavy swarm node by default. Running a backend on the requesting Mac requires an explicit `node:"local"`, and a machine marked model-free (`models.allowLocalModelLoad` off) refuses local runs with a clear pointer to the swarm instead. No more surprise FLUX sessions on a laptop.
- Dispatch is honest about targets. A `workerId` that is not connected fails the job and names the connected workers rather than quietly running the work on a different machine.
- Exact-source image conditioning: `asset.image.generate` can condition on one completed generation with a pinned SHA-256, bounded deterministic preparation, and the full recipe recorded in provenance. Remote conditioning and image-to-mesh reconstruction must target the worker that produced the source.
- FLUX prompt handling got stricter and better. Geometry prompts adhere more reliably, and unsupported parameters such as negative prompts are rejected up front instead of being silently ignored.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.21.0)

## 2.20.3 - 2026-08-01

This release is about energy. A fleet-wide sync storm could keep Peel busy decoding, verifying, and re-persisting ledger state even while idle, which macOS rightly flagged as significant energy use. 2.20.3 completes the traffic diet started in 2.20.2.

### Swarm traffic diet
- The idle ledger is now quiet: counter-only writes are throttled and delta broadcasts coalesce instead of firing per change (#2019)
- Anti-entropy repairs only the buckets that actually diverge instead of exchanging full state (#2029)
- Presence beats on demand: every beat while working, slow cadence when idle (#2030)
- Worker status refreshes are change-gated instead of rebuilt on every beat (#2022)
- The audit log rolls up no-op merge receipts, writes at background priority, and caps itself at 64 MB (#2026)
- Swarm Traffic gained an efficiency strip so you can watch the diet working, and its header no longer crushes in narrow panes (#2023, #2025)

### Invites and swarm security
- An invite names exactly one person; redemption is bound to the named invitee (#2032)
- Invite refusals explain themselves without leaking policy internals, signed in or not (#2033, #2037)
- Cross-swarm key divergence is refused rather than merely audited, and reinstall rotation is distinguished from it (#2028, #2031)
- Revoked peers lose their sessions immediately; key rotations are audited; relayed pulses prove provenance (#2020)
- Remote tool calls are scoped to granted repos and workspaces (#2027)

### Fixes
- Update status reports an unresolvable baseline honestly instead of claiming zero stale peers (#2024)
- TestFlight detection probes the receipt file directly instead of an API deprecated in macOS 15 (#2035)

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.20.3)

## 2.20.2 - 2026-08-01

## Lower idle CPU from swarm sync

Peel was burning significant main-thread CPU on routine swarm traffic — up to 47% during a single 22-hour session. Ledger payload verification now happens off the main thread, and gossip rebroadcasts that every receiving peer was already rejecting have been removed instead of resent.

You should see less fan noise and better battery life on Macs that stay connected to a swarm.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.20.2)

## 2.20.1 - 2026-07-30

Repository Fleet now says exactly what it means when knowledge moves between your Macs.

## Choose who produced the knowledge

Peel now separates the machine that generated an artifact from the machine that delivers its bytes. Choose **Any compatible producer**, name a specific producer such as Bender, or keep a repository on **This Mac only**.

When you name a producer, Peel accepts that machine's artifact or an exact content-addressed replica. It will not silently substitute knowledge generated somewhere else.

## Settings are clearly scoped

Repository and workspace rows now show both the resolved value and where it came from. Labels such as **This Mac default**, **Workspace**, and **Swarm contract** replace the ambiguous “Inherited” wording.

Background work is shown separately from knowledge producer selection. You can accept knowledge produced by Bender while keeping automatic model work off on this Mac.

## Jury participation is your choice

Each Mac now has an off-by-default **Allow jury work from my other Macs** preference under Settings → Swarm. Repository Fleet shows which machines are available for distributed Knowledge review and which need an update or have chosen not to participate.

A Mac that has not opted in refuses remote jury requests. Manual model-jury work on that Mac still works normally.

## Safer fleet routing

Pull-only machines are no longer offered as producers or delivery sources. The repo-level pull menu now calls its machine preference **Preferred delivery**, making clear that it affects transport rather than producer identity.

The same producer, delivery, and jury status is available to agents through Peel's MCP tools.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.20.1)

## 2.20.0 - 2026-07-30

Peel can now tell you whether your agents are actually getting better.

Until this release, everything Peel measured was an input: files indexed, chunks embedded, megabytes synced. None of it answered the question that matters. This release adds the other half.

## Every run is now on the record

Peel writes one row per agent run, whatever executed it. Not just its own chains: Claude Code, Codex, and Copilot sessions are harvested and land in the same ledger, so "what did this machine actually do this week" spans every tool you use rather than only the ones Peel drove.

Each row carries the device, repo, commit, task type, gate outcomes, grounding score, wall clock, and real cost. Gate results are three-valued, so a skipped test is never mistaken for a passing one.

## The scorecard maintains itself

The model scorecard was a document somebody updated by hand, and its data was wrong in a way that proved the measurement was off rather than merely stale. Four models tied at exactly 100.0, and one scored 100 overall while scoring 0 on PR review.

It is now generated. Fixtures score whether a model produced the right artifact rather than whether its prose reads well, and closed-set tasks give no partial credit, so fluent text that never commits to an answer scores zero. The old table's failure is now arithmetically unreachable, not merely unlikely.

When nothing has been measured, the scorecard says so. It shows "unmeasured" with a reason, never a zero.

## Agents learn from what already happened here

Three new sources of judgement, all derived from your own repository rather than from generic training:

**Failure memory.** When the same file has failed its build or test gate more than once, the next agent about to touch it is told so at planning time, instead of being left to run a search it would never think to run.

**House rules.** Every review comment that led to a follow-up commit is a labeled correction. Peel harvests them into checkable rules and runs them as a pre-flight lint on the next agent diff, citing the original comment when one fires.

**Your repo as the benchmark.** Merged pull requests become eval tasks with the real diff as the reference answer, so model choice is measured against your codebase rather than someone else's.

## A faster, more truthful verification loop

`verify.fast` returns a structured verdict rather than a wall of build output: findings with file, line, and the failing assertion. A phase that did not run says so with a reason, and a test suite that executed nothing reports as skipped rather than passed. The answer is yes, no, or unproven, because a boolean cannot express "nobody checked".

Builds themselves got 39% faster for a small change. The cause turned out to be that a single per-build environment variable was invalidating SwiftPM's compiled-manifest cache, forcing all 73 package manifests to recompile every time.

## Runs survive interruption

A long run can now be corrected mid-flight and resumed from its last completed step, so a crash, a quit, or an app update no longer destroys work in progress. Steps are keyed by their definition, so editing a step re-runs from that point and everything before it replays.

## The swarm can compete, not just share

Idle machines can run competing attempts at the same step, each nudged toward a different approach, ranked on mechanical evidence: does it build, do the affected tests pass, is it grounded in real files, how large is the diff. No model's opinion of its own work is consulted.

If every attempt fails its gates, that is reported as a failed round. A best-of-N that always returns something is a ranking of failures.

## Honesty, made mechanical

A new check runs in CI for a specific class of bug: code that reports success over an empty or unverified result. A sweep of the codebase found and fixed 29 of them.

Two were serious. One could replace the shared model-approval record with a single entry when a read failed, and report success. The other allowed a transient network error during pull request review to be read as "nobody requested changes", which could let a change merge over a human's objection. Both now fail safe.

## Also in this release

- Auto-merge blocks when it cannot verify its checks rather than assuming they passed, including when a pull request has no CI results at all.
- Review verdicts that cannot be parsed are recorded as unparsed rather than defaulting to approval.
- Chain step durations are recorded as numbers again, having been silently absent from every run.
- An undecodable skills file no longer silently discards the skills stored in it.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.20.0)

## 2.19.8 - 2026-07-30

Peel 2.19.8 — agents get told the truth.

Most of this release fixes cases where Peel reported something that wasn't so.

**Navigation and verification**
- `ui.navigate` no longer reports failure for navigations that actually landed. The legacy compat write it made before navigating was itself a navigation, so the app moved to the wrong hub and the verifier honestly described that. Repo deep links now apply once instead of re-applying on every index rebuild.
- `screenshot.capture` refuses to return a blank image as a success. A window whose content has never rendered (a background relaunch under a sleeping display) now produces an explicit `windowNeverRendered` error naming the cause and the state-based checks that still work.
- The Home swarm map renders in occluded captures instead of a void.

**Inbox and visual language**
- One color grammar: blue means interactive, green passed, red failed, yellow in flight, orange waiting on you, everything else quiet. Status chips share one calm capsule whose icon carries the state.
- The accent color is defined for the first time — every `.tint(.accentColor)` in the app had previously been a silent no-op.
- The Chains card counts what is actually running; awaiting-review work is surfaced as review work.
- Dependency pull requests group into something you can review from, with wrapping chips and intent-derived template icons.

**Retrieval and the swarm**
- Query embedding budgets and local-model consent now follow the resolved execution plan, so an overlay-fed Mac gets semantic recall through its delegated peer instead of timing out by construction.
- A peer that denies a tool by policy opens a cooldown breaker instead of being re-dialed every query.
- Multi-word machine names stop being truncated; a mirror directory hash no longer appears where a repo name belongs.

**Build and tooling**
- The coordinated build cache verifies products, not just its stamp, and Peel is only stopped once its replacement build is verified.
- The knowledge detail pane keeps sentences' final punctuation.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.19.8)

## 2.19.7 - 2026-07-29

- Review dependency update bundles directly in the Inbox with grouped pull requests, risk context, and plan details in one place.
- Run the Knowledge jury with Claude Sonnet 5 through your signed-in Claude CLI, even when the bundled model catalog has not caught up yet.
- Keep RAG recall budgets and vector search consent aligned with the query encoding plan, with clearer behavior when remote embedding is unavailable.
- Improve navigation, workflow cards, filtering, Knowledge details, and accent readability across the app.
- Harden the shared build cache and MCP schema checks so stale products and contract drift fail visibly.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.19.7)

## 2.19.6 - 2026-07-29

- Land swarm contract and model authority cores: swarm leadership and the model catalog now write to a shared, signed source of truth instead of each machine guessing independently.
- Rightsize instruction layer and MCP tool schemas for Claude 5: trimmed and re-tuned CLAUDE.md and MCP tool schemas for the new model generation.
- Finish model authority Phase 3: call sites across the app now read models through the catalog, with the concrete registries made internal implementation detail.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.19.6)

## 2.19.5 - 2026-07-29

Swarm peers now recover more cleanly from reconnects. Peel waits for a fresh, real Iroh heartbeat before starting background ledger and swarm-log convergence, so stale registry state cannot trigger a large sync.

A single stale or flapping machine can no longer occupy half of the swarm's convergence capacity. Interactive commands keep their independent lane, while background convergence allows one active operation per peer.

Reconnect-triggered ledger synchronization is now single-flight and cancellation-aware. Replacement sessions stop older full-state pipelines instead of stacking duplicate chunked sends.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.19.5)

## 2.19.4 - 2026-07-28

Inbox is now an action brief instead of an inventory dump: dependency-update pull requests are grouped by repository and next step, lower-priority work stays behind Browse all, and completed agent output opens as a concise Decision Brief with raw output still available.

Knowledge now leads with the answer and an honest trust state. Author estimates, jury evidence, contested tallies, provenance, and locators are clearly separated and progressively disclosed.

Swarm admins can choose a fleet RAG source in one click. That worker defines canonical artifact identity, while another online worker may serve an overlay only when its nonempty hash matches exactly. Local-only and push-only safeguards remain hard boundaries.

This release also fixes the analytics crash reported on July 28 by preventing blank dynamic Firestore field names from reaching the SDK.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.19.4)

## 2.19.3 - 2026-07-28

- Push-only RAG sources now keep Update and background maintenance local instead of trying to pull an overlay from the swarm.
- The RAG screen makes the source role explicit with **Serving overlays** and removes pull controls that do not apply.
- Policy blocks now explain the machine's Push-only or Pull-only role instead of reporting a misleading peer connectivity failure.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.19.3)

## 2.19.2 - 2026-07-28

- Local AI models now stay off until you explicitly enable them. Existing background RAG processing choices reset to Manual after this update. Peel pulls a usable remote artifact before considering local indexing.
- Inbox is more action-oriented, with stable selection, focused remediation bundles, type-aware empty states, and useful cross-machine run details.
- Knowledge is retrieval-first, removes repeated detail text, and quarantines unsafe universal entries created by automation.
- RAG health now separates actionable work from raw inventory and reports more trustworthy counts.
- Repository Fleet, Model Lab, Worktrees, Boards, Analytics, and Templates use space more effectively on compact Macs.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.19.2)

## 2.19.1 - 2026-07-27

- Manual RAG pulls now recover immediately when a peer becomes reachable after a brief interruption.
- RAG transfer errors show recovery status and the remaining cooldown instead of a generic timeout message.
- The Swarm traffic map uses the available pane more effectively and adds a compositor-backed scene option.
- Updated swarm tools and the published plugin catalog for the current Iroh transport.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.19.1)

## 2.19.0 - 2026-07-27

## Shared indexes stay on main

Peel now builds shared RAG indexes from an isolated `origin/main` snapshot.
Your feature branch, uncommitted edits, generated files, and local RAG settings
cannot change the corpus shared with the swarm.

## Repair a mismatched index

The repository RAG menu now offers **Replace with full index from <peer>**
when a peer is available. Use it to replace an older or incomplete local index
instead of applying another overlay. Local index actions are now clearly named
**Update from main** and **Rebuild from main**.

## More focused review work

Inbox triage is easier to scan and act on, with clearer filtering and a better
view of parallel worktree activity.

## Safer agent commands

Peel further tightens command handling for remote and automated agent work,
keeping terminal execution constrained to validated argument boundaries.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.19.0)

## 2.18.1 - 2026-07-27

## Automatic updates actually default on

A machine whose update preference was never touched ran as if it were
explicitly set to Never, while the Settings picker displayed Daily. The cause
was an unset preference reading as the numeric value for Never, which also
made the app overwrite Sparkle's own "automatically check" setting to off on
every launch, so ticking that checkbox appeared not to persist.

An untouched preference now means what the UI says: daily unattended installs.
An explicit Never remains Never. This is the last release that machines with
untouched preferences need to install by hand.

## Run cleanup and nested repositories

Run cleanup and nested repository resolution fixes from parallel work.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.18.1)

## 2.18.0 - 2026-07-27

## Crash reports over the swarm

Two new read-only tools let one Peel machine retrieve Apple crash reports from
another without remote shell access or arbitrary filesystem reads.

`diagnostics.crash-reports.list` returns recent `.ips` and `.crash` reports for a
process (default Peel) from the diagnostic reports folders as opaque report ids.
`diagnostics.crash-reports.read` returns one report's UTF-8 content plus a
SHA-256 for provenance, capped at 512 KiB by default and 2 MiB hard. The reader
takes no filesystem paths, refuses symlinks and traversal, and does its file
I/O off the main actor.

These are sensitive-data tools. Machines signed into the same account reach them
through fleet trust; anyone else needs an explicit per-peer grant. A new
crash-diagnostics skill documents the retrieval and symbolication workflow.

## Member revocation actually removes the machines

Revoking a swarm member now runs through an authenticated Cloud Function with
transactional role checks that deletes the membership and every worker
registration the member owns. Owners can revoke anyone; admins can revoke only
strictly lower roles, enforced server side. A Firestore delete trigger acts as a
backstop for memberships removed directly from the console. The backing function
and rules are deployed.

## Peer identity through reconnects

Machine names carried on Iroh heartbeats now survive worker state transitions.
A peer that dropped offline previously lost its display name and showed a raw
node id until the next identity delivery. The per-heartbeat capability rescan
also now fires only when a heartbeat first delivers a peer's identity, instead
of on every beat from every peer.

## Known issue

The crash on long-running nodes (#1754) is unchanged: an Apple runtime fault,
documented on the issue with a controlled experiment and register analysis.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.18.0)

## 2.17.0 - 2026-07-25

Corpus safety and de-hardcoded models.

**Converging an analyzer corpus can no longer destroy it.** `rag.analyze` with `converge: true` cleared a repo's analysis and then rebuilt it, but the rebuild sat behind a guard that skips local analysis on overlay-fed machines. The clear was not behind that guard, so converging on such a machine wiped the corpus and reported success over an empty result. Convergence now checks first and refuses without changing anything.

**A skipped analysis no longer reports as a completed one.** When a machine declines to run local analysis, the response says so and carries the reason, instead of returning "AI analysis complete" with a count of zero.

**Embedding delegation is reachable across your own machines.** Triggering a swarm-wide reindex was already possible from any of your Macs, but reading or setting the delegation that decides where embedding and analysis run was not. Since that delegation is also what silently disables local analysis, a producer that had quietly become overlay-fed could only be diagnosed from a shell on it.

**PR-review models moved out of the code.** Three of the four local reviewers named a model literally, repeated again in the preflight gate and the runner's required-model list. All four now resolve through the model registry, so changing a reviewer is a config edit rather than a release. Defaults are unchanged.

Note the bundled defaults still use moving `:latest` tags, which resolve to whatever each machine happens to have pulled. The same role can be a 26B model on one Mac and an 8B on another while both report the same name. Pinning explicit sizes is now a config edit.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.17.0)

## 2.16.1 - 2026-07-25

A patch release with two fixes: the Inbox no longer freezes the app, and cleaning up a repository's search index no longer removes the repository.

## The Inbox could lock the app once other Macs were working

If your swarm had peers running chains, opening the Inbox could send Peel to 100% CPU and stop the interface responding. Quitting and reopening bought a minute or two before it happened again.

Two things in the sidebar were fighting each other on every frame. Rendering the list created a stored database record for each run reported by another Mac, and storing a record tells the interface something changed, so it drew the list again, which created the records again. At the same time the list was writing a value it also read while drawing. Either one alone causes a redraw loop; together they saturated a core.

A run happening on another Mac is now held in memory as plain data rather than written to the local database, which is the honest description of it: it is someone else's work, and this machine was never meant to keep a copy. Assembling the list also moved out of the drawing path, so it happens when the underlying runs actually change instead of on every frame.

Sorting, filtering, badge counts and row selection all behave as before, including keeping your selected row when the list refreshes underneath you.

This was verified against a running app with five Macs online, sitting on the Inbox, rather than by reading the code: the redraw loop is gone from the profile entirely.

## Cleaning a polluted index no longer deletes the repository

A repository that had absorbed its nested projects' files was being removed outright to clear the duplication. That is too blunt a remedy. Such a repository is still real, and on the store that prompted this it owned 204 of its 7,732 indexed files, including a workspace tree, CI configuration, a README and a script. Removing the row would have taken those with it, dropped the repository off your list, and required a full re-index to get any of it back.

Now only the nested subtrees are stripped. The repository keeps its identity and its own files, and nothing needs re-indexing to come back.

Local model identifiers also stopped being hardcoded in this path, so they follow the configured registry like everywhere else.

## Upgrading

Nothing to do. If you are on 2.16.0 and the Inbox has been freezing, this is the fix.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.16.1)

## 2.16.0 - 2026-07-25

RAG corpus integrity.

**One analyzer no longer counts as many.** The `analyzer_model` stamp is free text, and three kinds of noise inflated the "analyzed by N models" badge: the `chunk-analyzer` sentinel (not a model), and the same weights spelled `Qwen2.5-Coder-7B` by MLX and `qwen2.5-coder:7b` by Ollama. Those now collapse before anything reports on them, and off-pin drift is measured on canonical names so a pin is not reported as drifted by its own weights under another spelling. Moving tags like `gemma4:latest` are deliberately left alone — nothing recorded what the alias resolved to.

**Sub-repos are no longer indexed twice.** RAGCore 2.16.0 stops the scanner walking into checkouts that already have their own row. On one superproject with 13 submodules this was 4,637 duplicate files and roughly 21,300 redundant chunks: double embedding cost, double analysis cost, and two search hits for every match inside a submodule.

**Corpus data now carries a contract.** A producer declares what it guarantees about its corpus, and a receiver refuses anything below its minimum. Without this a clean machine re-imported the duplication on every pull from a stale peer and the fix never converged. Refusal names the peer and the remedy.

*This is a hard cutover:* once a machine is on 2.16.0 it stops accepting corpus data from peers still on older builds. Update the whole fleet and let each producer re-index.

**Existing duplication cleans itself.** On first launch, repo rows that are only a re-index of their own children are purged and the store is stamped. Recoverable — the superproject re-indexes from the checkout on disk.

**Fleet maintenance works across your own machines.** RAG read and maintenance tools are now reachable under fleet trust, so a drifted or duplicated corpus can be repaired from any of your own Macs instead of needing a shell on the one holding it. Same-owner only; a stranger's peer still needs an explicit grant, and skill mutation stays withheld.

**Inbox:** the default view drops patrols that found nothing, rather than hiding the entire patrol class.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.16.0)

## 2.15.0 - 2026-07-25

## Inbox filters now mean what they say

The Inbox carries six kinds of item and was slicing them with filters that
overlapped, hid things, and reused one word for three adjacent controls.

**Alerts is now Health and Security.** Machine health and dependency advisories
were sharing a bucket, so asking what was wrong with your machines also returned
security advisories. Security also covers Dependabot pull requests, since the
advisory and the pull request that closes it belong together. That removed the
separate "Dependabot only" toggle, which was a fourth filter dimension doing a
job the type filter already does.

**Patrols are a kind of item, not a hidden mode.** Patrol entries used to be
removed from every selection except Patrols, so "All Types" was not showing all
types and there was no way to tell from the screen. A patrol that found something
is now an ordinary row. A patrol that scanned and found nothing is still filtered
out as noise, which is what kept the list clear in the first place.

**New Machine filter.** Scope the Inbox to one Mac. Runs, tasks, cross machine
runs and health observations all report which machine they came from. Pull
requests and advisories belong to a repository rather than a Mac, so they drop
out when you pick a machine instead of appearing under all of them. The control
only shows up once you actually have work from more than one machine.

**Three controls no longer all say "All".** They now read All, All Kinds and All
Repos.

## Known issues

This release does not fix #1754. That crash is inside Apple's executor identity
check, reached from Apple's own frameworks. Register state across four builds
shows the same constant bit pattern rather than the varying garbage that memory
corruption produces, which points away from a heap problem in the app. Full
analysis is on the issue.

The `llama-server` crash loop is also unresolved. Neither the Ollama upgrade nor
removing the quantized KV cache changed the rate, which rules out both the
version and that configuration and points upstream into the decode path.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.15.0)

## 2.14.0 - 2026-07-25

## Local inference problems now reach the Inbox

2.13.0 added runtime health checks but they only wrote to the log and to
`system.doctor`, so on a machine that was actually in trouble nothing was visible.
Findings now become Inbox rows carrying a severity and the command that fixes them.

Rows are deduplicated against unresolved rows rather than a time window. A machine
that relaunches constantly is exactly the case these checks exist for, so a row per
launch would bury the Inbox in copies of one problem. Resolving a row arms it again,
so a real recurrence still reports.

## Correction to an earlier claim in these notes

An earlier version of this release page claimed that removing a quantized KV cache
had eliminated a `llama-server` crash loop, and printed a table showing 216 model
loads with zero crashes. **That claim was wrong and has been withdrawn.**

The zero was a measurement error. macOS writes crash reports to
`~/Library/Logs/DiagnosticReports/` and moves them to `Retired/` only later. The
count was taken from `Retired/` alone, for an hour that was still in progress, so
reports that had not yet been moved were read as crashes that never happened. The
same hour later showed 23 crashes against those 216 loads.

Corrected measurements:

| ollama | env | Model loads | Runner crashes | Rate |
|---|---|---|---|---|
| 0.32.3 | `q8_0` + flash attention | 218 | 31 | 14.2% |
| 0.32.3 | `q8_0` + flash attention | 438 | 55 | 12.6% |
| 0.32.3 | neither | 216 | 23 | 10.6% |

10.6% against a 12 to 14% baseline is noise, not a fix.

What the data does establish is negative and still useful. Restarting the service
regenerated its LaunchAgent, which dropped both `OLLAMA_KV_CACHE_TYPE` and
`OLLAMA_FLASH_ATTENTION`, and crashes continued with neither set. Upgrading ollama
from 0.31.1 to 0.32.3 did not change the rate either. Both environment variables and
the ollama version are therefore ruled out, which points at an upstream heap
corruption bug in the llama.cpp decode path rather than local configuration.

Peel's `inference.runtime.kvCache` check still warns on a quantized KV cache. Treat
that as general upstream caution, not as an established cause.

Worth repeating for anyone measuring this: count both crash report directories, never
score an hour that is still in progress, and always report crashes per model load
rather than a raw count, since an idle hour also shows zero.

## Security

Fleet trust is now an allowlist over the tool catalog rather than a denylist, so a
newly added tool is not reachable by peers until it is explicitly granted.

## Known issue

This release does not fix #1754. That crash is inside Apple's executor identity
check, reached from Apple's own frameworks, and register state across four builds
shows the same constant bit pattern rather than the varying garbage that memory
corruption would produce.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.14.0)

## 2.13.0 - 2026-07-25

## Local inference runtime health

Peel already knew when Ollama was offline and did nothing with it, so a machine
whose inference runtime died overnight stayed dead until someone noticed. The
system doctor now checks the runtime properly and repairs the one thing that is
safe to repair unattended.

Detected at launch and in every doctor run:

- Ollama installed but not running
- `llama-server` crash-looping, counted from crash reports in the last hour
- A quantized KV cache configured into the same decode path where the runner aborts
- Two competing Ollama installs racing for the same port
- A service log grown past half a gigabyte with no rotation

Repaired automatically: only a service that is installed and simply is not
running. That action is idempotent and reversible. Everything else is reported
with the command that fixes it rather than applied, because silently rewriting
this runtime's configuration is itself a good way to take it down.

The repair is bounded to three attempts, five minutes apart, and only a real
success resets that budget. A healer that restarts a service which dies on
startup would reproduce the restart storm it is supposed to be reporting.

Findings currently go to the log and the doctor report. Surfacing them in the
Inbox needs the daemon-scoped observation path and is a separate change.

## Known issue

This release does not fix #1754, the crash seen on long-running nodes, which is
reproduced on 2.12.0. The fault is inside Apple's executor identity check,
reached from Apple's own frameworks. Register state across four builds now shows
the same constant bit pattern rather than the varying garbage that memory
corruption would produce, so the remaining heap-guard theory looks unlikely.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.13.0)

## 2.12.0 - 2026-07-24

## Knowledge

`knowledge.compact` collapses mechanical redundancy in the knowledge corpus without
involving the jury. It only removes duplication that needs no judgement, such as
private pre-migration copies with a surviving canonical twin, the same title stored
under a second kind, byte-identical copies, and empty bodies. It is dry-run by
default and only touches entries the device itself authored. Anything requiring
taste is still left to the jury. `knowledge.add` now also refuses a title that
already exists under a different scope or kind and hands back the existing ref,
which is what was minting near-duplicate twins.

## Boards and runs

Closed cards are archived off the Peel Roadmap board automatically (#1785).
Merged `parallel/*` branches are deleted after merge, and stale debris is flagged
rather than left to accumulate (#1740).

## Playground

Per-message telemetry persists across sessions, and tool calls collapse so a long
transcript stays readable (#1857).

## Release engineering

Releases are now always cut from the main checkout. `git rev-parse --show-toplevel`
returns the worktree root when the script runs inside one, so a worktree that
happened to be on main passed every guard while its build artifacts landed in a
directory that gets pruned. That is why v2.9.0 through v2.11.0 left no recoverable
symbols behind.

Each release now archives its `Peel.app.dSYM` to `~/Library/Developer/PeelSymbols`
with a UUID manifest. The shipped binary is stripped, so this is the only way a
crash report from a release can be symbolicated. Spotlight indexes that path by
dSYM UUID, so `atos` and `lldb` resolve it automatically. Symbols stay on the build
machine and are not published.

Release notes now fetch merged PRs from the resolved repo instead of an environment
variable that was never set (#1702).

## Known issue

This release does not fix #1754, the crash seen on long-running nodes. That fault
is inside Apple's `swift_task_isCurrentExecutorWithFlags` executor identity check,
reached from Apple's own frameworks, and it reproduces across two app builds and
two OS seeds. Symbolication landed in this cycle, so the next occurrence on this
release can be read in minutes rather than days.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.12.0)

## 2.10.0 - 2026-07-23

### Choose which CLI the knowledge jury runs on
The jury's **Review** popover gains a **Run on** control for cloud models: keep *Match machine* to follow this Mac's CLI preference, or pin the jury to the **Claude CLI** (your own account) or **Copilot CLI** for that session — without changing the machine-wide preference. Availability still applies, so a pinned-but-unavailable CLI falls back to Copilot rather than failing.

Under the hood, `runCloudAgentSession` gains an optional provider override any caller can use, laying groundwork for per-role provider routing.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.10.0)

## 2.9.0 - 2026-07-23

### Knowledge review: run the model jury on demand or on a schedule
The Knowledge view gains a **Review** control that runs the model jury over pending knowledge entries — pick how many to judge (5 / 10 / 20) and which model judges them (cloud or local), and it casts signed verdicts. For hands-off curation, schedule the new **Knowledge Adjudication** patrol; each Mac judges with its own local model, so running it on more than one machine builds the keep/retire quorum and model-family diversity.

### Local model ids as data
Local/ollama model ids now resolve through a Firestore-backed registry (`config/ollama_models`) with bundled offline defaults, mirroring the existing Copilot and MLX model registries. Adding a HuggingFace/ollama model or swapping a patrol's reviewer becomes a data edit — no rebuild, no fleet redeploy.

### Fixes
- Branch-aware RAG indexing (`rag.branch.index`) now diffs `origin/main` instead of a stale local `main`, so the changed-file set for a worktree or feature-branch index is correct.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.9.0)

## 2.8.0 - 2026-07-22

### vision.ocr: on-device Apple Vision OCR
- New `vision.ocr` MCP tool performs OCR with Apple's Vision framework (VNRecognizeText), running on the Neural Engine and GPU. It reads an image or rasterizes a PDF per page, entirely on-device with no Python and no network, and returns the recognized text, page count, timing, and optional per-line boxes with confidence. On scanned documents it is dramatically faster than CPU-bound OCR.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.8.0)

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
