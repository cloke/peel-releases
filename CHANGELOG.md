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

## 2.45.0 - 2026-09-01

### PR reviews fail closed on invalid scope

This release ends the false-approval failure mode measured on 2026-09-01, where every patrol review shipped `APPROVE` + `peel:approved` over an empty or wrong commit range.

- A review verdict can no longer post, label, or feed readiness/auto-merge without run-bound evidence that the PR's own diff was reviewed: the scope gate records the changed-file paths and a digest of the exact diff bytes, and the submission boundary re-verifies them against live PR metadata at publication time. Stale, self-referential, zero-file, or unverifiable scope is a refusal, not a pass.
- Reviewers now have a legal exit: `NO_CHANGES` and `INVALID_REVIEW_SCOPE` are terminal verdicts — nothing posts, nothing is labeled, and no approval signal is produced. Previously `APPROVE` was the only reachable verdict on an empty range.
- Findings struck for citing files outside the PR no longer collapse into an APPROVE; a review whose evidence describes a different PR is withheld, even when it never uses `[Comment on …]` markers and even when no diff text is available.
- Auto-merge gains a hardcoded scope gate: a PR with no verifiable current scope cannot merge.
- PR-review worktrees now start at `pull/N/head` (the fetch was previously unreachable), and the scope gate materializes the PR head locally so reviewers inspect the PR's actual code.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.45.0)

## 2.44.3 - 2026-08-31

- Repository-scoped RAG searches now accept stable identifiers such as `github.com/org/repo`. Peel resolves the local index or overlay first, then chooses a live authorized peer when remote retrieval is needed.
- RAG indexing now rejects embedding model and dimension mismatches before modifying the index, with clearer recovery guidance.
- Swarm synchronization is more resilient. Idle Iroh gossip subscriptions close deterministically, and ledger payloads are bounded before expensive decoding or merging.
- GitHub issue lists now handle actions performed by GitHub Apps instead of failing to decode the response.
- Leased Claude background sessions can now join coordinator-managed shared-main work. Agent coordination also validates submitted result commits and reports expired leadership more precisely.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.44.3)

## 2.44.2 - 2026-08-30

Peel 2.44.2 makes agent work more durable and provider selection explicit.

- Persistent Codex and Claude sessions now keep transcripts and reconnect through a provider-neutral control plane, so longer work survives normal app and channel interruptions.
- Agent dispatch now separates authentication from authorization. Claude and Codex can be enabled for frontier work while Copilot stays signed in for diagnostics but cannot receive coding tasks.
- Chain steps bind models to exact providers and fail closed instead of silently falling back. Dry runs report provider policy failures before catalog errors.
- Scheduled work no longer overlaps an existing live run, and the build coordinator reports liveness and topology state more accurately.
- Ollama can switch transactionally between Homebrew and the official signed app, with rollback and bounded redacted activation diagnostics for safer swarm upgrades.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.44.2)

## 2.44.1 - 2026-08-29

This release closes several reliability gaps found while using Peel to coordinate Peel work across machines.

- Move a managed Mac from Homebrew Ollama to the signed official Ollama app through Peel. The migration drains loaded models, verifies the replacement server, and rolls back on failure. Official-app launches now stay unattended even when installing a global command-line symlink would require administrator approval.
- Add the provider-neutral JSON-RPC transport core for persistent agent sessions. It preserves follow-ups, steering, typed approvals, user input, cancellation, usage, and replayable provider events. Model Lab persistence and swarm wiring remain follow-up work.
- Add fenced leader, work-intent, source-lane, question, decision, and approval contracts for coordinated agent work. Build requests from linked Peel checkouts now converge on one durable steward, and launches no longer inherit stale build context.
- Make model scorecards safer and easier to audit with harness-revisioned results and published OpenRouter evidence. Private fixtures fail closed, and an unreadable local scorecard store can no longer be replaced by an empty merge.
- Restore RAG text-search recall to the earlier substring baseline while keeping ranked retrieval substantially faster on Peel's measured corpus.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.44.1)

## 2.44.0 - 2026-08-29

This release gives multi-agent work a durable coordination layer and makes model evaluation easier to trust.

- Queue builds, tests, and releases through one FIFO steward shared by all callers. Every job keeps its exact commit and can be observed or cancelled by durable ID.
- Require a separate explicit approval after release preflight. A successful build alone cannot start publication.
- Record the exact OpenRouter model and provider. Scorecards preserve usage and latency, with failures and provenance attached. Free-model execution fails closed unless both prompt and completion prices are explicitly zero.
- Run review patrols on a 15-minute policy with cheap or local preliminary work and Claude Opus 5 reserved for escalation.
- Make RAG indexing and search more reliable by preparing every raw chunk-writing connection before use and serving `rag.search` text mode through ranked BM25 while keeping the substring lane explicit.

OpenRouter routing aliases remain excluded from scorecards because a published score must identify the exact model that answered.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.44.0)

## 2.43.0 - 2026-08-28

This release expands Peel's model and agent choices while making remote work easier to follow.

- Use Codex CLI as an agent backend alongside the existing local CLI providers.
- Score authenticated Claude CLI models and every exact zero-priced OpenRouter chat model, with provider cost and token attribution preserved.
- Discover free OpenRouter models from the live upstream catalog without changing your normal model-picker allowlist.
- See live progress on remote chain run cards instead of waiting on an opaque running state.

OpenRouter routing aliases remain excluded from scorecards because a published score must identify the exact model that answered. Paid and unknown-price OpenRouter models are never included in free-model runs.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.43.0)

## 2.42.0 - 2026-08-28

## OpenRouter, as a first-class model provider

One API key fronting roughly 400 models from about 40 vendors, including a
rotating set of zero-cost ones. This is Peel's first remote HTTP chat provider —
the other cloud models are driven through agent CLIs, and the other HTTP chat
path (Ollama) is local.

- The key lives in the keychain, with an `OPENROUTER_API_KEY` environment
  override. Settings reports which source actually won, so an environment
  variable shadowing the saved key says so instead of displaying a key that is
  not the one in use.
- The catalog is fetched live from OpenRouter and cached on disk. A bundled list
  would be wrong within a week; the cache exists so a cold launch or an offline
  machine degrades to "last known" rather than to nothing.
- "Free" is decided by the price being zero on both sides, not by the `:free`
  suffix on the model id. Those disagree upstream — 21 models are zero-priced
  while only 18 carry the suffix — and price is what determines whether a
  request costs money. A price that cannot be parsed is deliberately not
  treated as free.
- Model kind comes from the output modality, which keeps the zero-priced music
  models out of the free-chat list a picker offers.
- Routing dispatches enabled OpenRouter ids to OpenRouter before any
  local-versus-peer decision. Without that step an OpenRouter id found no peer
  that could hold its weights and fell through to local Ollama, failing with
  "model not found" for a model the picker had just offered.
- Responses carry real token counts and dollar cost, and provider failures
  surface their actionable text rather than a bare "Provider returned error".

## Release notes that describe an actual deploy

The release-note path could previously produce a note when nothing had shipped.
Three separate causes, all of them the same shape — the data was never there:

- The fetch was not a deploy. It listed the last twenty merged PRs with no time
  window, so every run saw twenty merges whether or not anything shipped. A
  deploy is the range between two deploy commits, which git can state exactly.
- `PEEL_TRACKED_REPOS` was empty. It read only the manually tracked list, which
  has been empty on this fleet throughout, and now falls back to every
  registered checkout. This also unblocks the morning digest's shipped-work
  section.
- The daemon gate keyed on a proxy — "the aggregate output was non-empty" — which
  is true with zero deploys, because that output also carries event summaries. It
  now keys on a deploy marker present in every real deploy section and nowhere
  else.

Peel itself is skipped, correctly: it ships by tag and has no `production`
branch, so branch-watching can never describe it and must not pretend to.

## Hosted models in the scorecard

The model scorecard measures chat output, so its third tier could not be the
local in-process embedding fallback — `NLEmbedding` and hash vectors do not
answer a chat fixture. Tier 3 is now an explicitly enabled hosted chat provider,
and every row carries where it ran: local Ollama, a delegated swarm peer, or a
hosted provider named alongside the measurement.

- Hosted rows keep the measuring device, because that Mac ran the fixture and
  the grader — but device memory and GPU rank never select a hosted headline,
  since the Mac did not run the model.
- Provider-reported cost and token counts stay optional. Missing accounting is
  recorded as unknown rather than rewritten as zero.
- Routing aliases like `openrouter/free` are refused outright: a bakeoff row has
  to name the concrete model it measured. An enabled hosted id resolves straight
  to its provider, so this is a model-scoped lane rather than a silent cloud
  fallback after a local or peer failure.

The first OpenRouter code-edit bakeoff is recorded in the leaderboard, which now
carries 224 rows.

## Fleet safety

- Fleet route receipts report what actually happened rather than what was
  intended, and the worker lifecycle path carries a release-only hard guard.

## Housekeeping

- The OpenRouter settings surface routes its colors through the theme's semantic
  roles, so a hue means a status rather than a category.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.42.0)

## 2.41.9 - 2026-08-27

## Swarm control you can trust

- Trusted peers can now query `peel.version` without an avoidable remote-policy denial, making fleet readiness and post-update verification deterministic.
- Update receipts distinguish Sparkle and TestFlight history from source-build history, and expose the latest authoritative status for the active channel.

## Truthful RAG execution receipts

- RAG search now reports whether a query embedding actually ran and whether it ran remotely, locally, or not at all.
- A failed remote embedding delegation is no longer misreported as local-model execution when local loading was not authorized.

These changes make dispatch diagnostics more useful for model routing, token optimization, and proving that Bender—not the coordinating Mac—performed inference work.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.9)

## 2.41.8 - 2026-08-27

## Reliable exact-revision RAG

- Exact-revision RAG checks now use the same repository identity as the indexed catalog, so canonical sync receipts remain verifiable across the swarm.
- Dispatch still fails closed when the requested source revision is unavailable. It will not silently answer from stale or mismatched code.
- New regression coverage protects remote-backed, first-commit, and local-only repository identities.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.8)

## 2.41.7 - 2026-08-27

- Pinned swarm runs now survive slow local-model inference and reuse one authenticated session instead of failing on the first request.
- RAG-assisted work is tied to the requested repository and exact source commit. Missing or stale index receipts stop the run clearly instead of returning plausible answers from old code.
- Read-only analysis can run directly on Bender without creating a disposable worktree, while any mutating or unpinned workflow keeps the existing isolation boundary.
- Completed runs retain durable proof of the machine, worker, transport, and tool rounds that produced the result.
- Canonical RAG mirrors now refresh by repository identity and record completion only after the exact source revision is verified.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.7)

## 2.41.6 - 2026-08-26

- RAG-assisted Ollama steps now stay on the swarm worker Peel selected, including every follow-up turn in the tool loop.
- The originating machine keeps control of repository tools and returns only the requested evidence to the inference worker.
- Run results now identify the machine that actually served each model response.
- Malformed or unresolved remote tool calls stop with a clear error instead of silently falling back to local inference.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.6)

## 2.41.5 - 2026-08-26

Peel makes long-running agent work safer and review results easier to act on.

- Active chain worktrees are protected from stale cleanup while background tasks are still using them.
- Posted PR reviews use one predictable structure, keeping findings and evidence clear while process metadata stays compact.
- Clean approvals stay brief, reducing noise without removing required attribution.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.5)

## 2.41.4 - 2026-08-26

Peel now makes agent handoffs reflect the exact code that will merge.

- Agent runs wait for background verification to finish and stop leftover verification processes before review begins.
- Reviewers evaluate the committed branch diff, while run statistics report that same immutable tree.
- Approval and merge stop with clear guidance when a worktree contains uncommitted implementation changes.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.4)

## 2.41.3 - 2026-08-26

- Review performance data is now durable across scheduled patrols, daemon runs, manual reviews, and re-reviews. Reports retain the actual model, repository, verdict, and run provenance.
- Failed metrics writes queue safely for idempotent recovery without posting a duplicate GitHub review. Recent history is backfilled only when the evidence is unambiguous.
- Managed agent filesystem searches now have native scope and time limits across shell wrappers, substitutions, globs, and multiple roots.
- Verified same-owner peers can inspect the fleet RAG catalog while anonymous and default access remain restricted.
- Release verification now reads signed entitlements from Apple's supported DER format and audits the exact public ZIP users download.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.3)

## 2.41.2 - 2026-08-26

- Verified machines now send local-model work to the target machine's durable permission policy, so dispatch keeps working across Peel and tool-catalog updates.
- Remote policy inspection is clearer and safer. Duplicate records repair automatically, repository scopes remain enforced, and credentials cannot be delegated.
- MCP clients can use this Mac's own `.local` hostname without weakening DNS-rebinding protection.
- Harbor handles absent public output and duplicate publication more predictably, with clearer role and headline comparisons.
- Source updates now use a clean Xcode dependency graph, preventing the package-resolution crash found while updating Bender.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.2)

## 2.41.1 - 2026-08-25

## What’s new

- RAG transfer history now applies peer, repository, and completion-time filters together, so sparse combined matches are returned accurately.
- Transfer-history storage now removes records older than 30 days and caps the database at 20,000 rows, including bounded cleanup for existing oversized stores.
- MCP clients now receive clear returned, matched, and total counts. Invalid completion timestamps return a direct validation error, while the existing `rowCount` field remains compatible.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.1)

## 2.41.0 - 2026-08-25

## What's new

**Remote checkout provisioning is opt-in.** Peel can now dispatch work by a stable repository identity instead of assuming every Mac uses the sender's local path. A RAG index is treated as read context, never as a writable checkout. If a worker is missing the repo, choose a Swarm Clone Root and enable checkout provisioning on that worker. Peel then clones through its registered SSH remote, validates the origin and waits for the checkout to be advertised before dispatch can continue. Canonical RAG mirrors are never used for agent writes.

**Long swarm jobs now have enough time to finish.** The default dispatch window is thirty minutes, with an explicit per-task override. Priorities now match the documented names and invalid values fail clearly. Status responses identify the worker that actually ran the task, so a late remote result is no longer recorded as an immediate local failure. This release was dogfooded with a Bender implementation that ran for more than ten minutes and completed successfully.

**Knowledge recall can use the RAG data that is already there.** Semantic recall now has a measured 1.5-second budget. Its last-resort projected lexical lane gets two seconds instead of giving up after 100 milliseconds. Healthy local indexes should return useful context instead of reporting that retrieval is unavailable, while real timeouts still explain which budget expired and where to inspect projection health.

**Fleet updates now follow each worker's distribution channel.** Source workers rebuild from the selected commit. Direct-release workers update through the same-owner Sparkle path. The tool contract explains both routes and their skip conditions. The release compile gate now covers the App Store target, the Direct target and the iOS companion so shared-code drift is caught before publication.

**Harbor posts are shorter and more trustworthy.** One formatter now removes internal scaffolding and long device identifiers. Repeated alerts stay in their existing thread unless new facts arrive. Channel creation states its visibility and refuses private channels with no members, preventing successful writes that nobody can see.

Peel also reports a missing swarm security-rotation Cloud Function as a deployment problem instead of a generic network error. No RAG reindex or data migration is required.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.41.0)

## 2.40.0 - 2026-08-25

## What's new

**Local inference is no longer killed while it is working.** Two hard time limits sat under the generation path, and both counted elapsed time rather than progress. One capped a request's total lifetime at ten minutes, sized in its own comment for a 4,096-token completion — smaller than a reasoning model's thinking phase, so a slower peer would abandon a run that was streaming fine and return nothing at all rather than a partial answer. The other force-released the GPU after four minutes and handed it to a second caller while the first was still generating. Both are now bounded by stall instead: a run is cut off when it stops producing tokens, not when it has been going a long time, so a legitimately long task finishes.

**Agent-facing UI controls no longer confirm work they did not do.** Ten automation controls for selecting workspaces, worktrees, git repositories, branches and commits wrote preference keys that no view reads, while the tool that reports UI state read those same keys back — so an agent that selected something and then verified it received its own write as confirmation. The lists of valid values offered alongside them had no writer at all and were permanently empty, telling an agent that a machine with forty worktrees had none. Those controls are gone, and asking for one now returns a plain refusal instead of a false success.

**A tool built to stop code decay was quietly deleting its own records.** Running the file-size ratchet's baseline update against a single path erased every ceiling outside that path and exited reporting success — twenty-three tracked limits became twenty on a scoped run. A partial scan can no longer overwrite the whole record; it refuses and says why. Two smaller counting errors in the same tool were fixed alongside it.

## Under the hood

Three hundred and fifty-one declarations that nothing referenced were removed, along with the last protocols that existed only to be conformed to once. Every removal was verified individually against the app, its tests, the iOS companion target and each local package's own test suite, and two that turned out to be reachable were caught and restored before shipping. Nothing user-visible changes; the app carries less dead weight.

No reindex or manual migration is required.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.40.0)

## 2.39.0 - 2026-08-24

## What’s new

**Patrols now tell you whether they did anything.** A scheduled patrol that ran and correctly found nothing to do was counted as a success, identical to one that actually reviewed a pull request or filed a finding. Across this fleet that produced patrols reporting success rates in the nineties over roughly 1,700 runs, with no way to ask which of those runs produced anything. A run now settles as one of three things — it did work, it ran and found nothing, or it failed — and "found nothing" moves no success counter, breaks no streak, and raises no alert. Schedule lists report the share of runs that did work, so a patrol that no longer earns its cadence is visible instead of flattering.

**A patrol that cannot run somewhere now says so instead of looking quiet.** The chain runner used to guess at what a stopped patrol meant by reading its output for words like "skip", and a patrol blocked from running on a given Mac printed exactly that word. Nine consecutive pull-request review runs recorded success while reviewing nothing, and every review requested from Slack was silently discarded before it started. Patrol steps now declare whether they stopped because there was no work or because they could not run, the runner obeys the declaration rather than inferring one, and anything that stops without declaring is treated as a failure — including a virtual machine or container that never launched the step at all. The reason reaches you verbatim, with the machine to fix.

**The morning digest can finally report shipped work.** It was told to fetch pull requests through a tool that has never existed, so its "Shipped" section could not be filled in by any model, and its quiet-day rule read that permanent blindness as a quiet night. Digest data now comes from a real fetch, a failed source can no longer be reported as a quiet day, and the digest stops before paying for a summary that has nowhere to be delivered.

**Worktrees that agents create are actually cleaned up.** The auto-cleanup setting removed database rows while leaving the directories on disk, because the hourly pass looked each path up in a list nothing could populate. Cleanup is now driven by what is on disk, removes worktrees through git rather than deleting directories outright, keeps any worktree with uncommitted changes, and honours both the retention window and the disk cap. A worktree survives when git cannot confirm it is safe to remove.

**Patrol history reads at a glance.** Last-run outcomes distinguish four states rather than two: did work, ran and found nothing, never started, and failed. A patrol that keeps coming back all-clear now looks healthy rather than broken, and the number an operator should react to — consecutive failures — has its own row.

No reindex or manual migration is required.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.39.0)

## 2.38.0 - 2026-08-24

## What’s new

**Local reviews that returned nothing now return reviews.** A reasoning model emits its entire thinking trace before its first answer token, and Peel capped local model output at 4096 tokens — smaller than the thinking phase alone on a real pull request. The model would think for 15,000 characters, hit the cap, and return an empty answer; because Peel strips reasoning before display, the reviewer appeared to say nothing at all. Reasoning models now run without an output cap, bounded by the existing request timeout instead. Measured on a 27B local model reviewing an 11K-token diff: 6,757 tokens of thinking before the first answer token, and a complete review where there had been silence.

**Reasoning effort now follows the job.** Local models used to run every task at whichever single effort level the machine was set to — maximum reasoning on a commit message, or minimal on a security review. Peel now picks per task: low for commit messages, triage, summaries and pull-request authoring; medium for review; high for code edits, plans, architecture and decision gates. When work is delegated to another machine in your swarm, that machine chooses the effort using its own settings and its own knowledge of what its models support, and reports back which effort it used.

**Goal runs can be capped in dollars.** A goal run accepts a spend ceiling based on cost actually reported by the model provider, rather than an estimate. Because only some providers report cost, every run also reports how many of its steps could not be priced, so a total is never mistaken for the whole story.

**Runaway chains are actually bounded now.** A depth limit on agent-spawned chains had been in place since March but nothing ever supplied the depth, so the limit could never trigger and a chain could spawn chains without bound. Depth is now stamped by the server rather than reported by the agent, and it covers chains started directly as well as spawned subtasks.

**Smaller, faster app.** Roughly 2,900 lines of dead code removed across 112 files, and a new project check keeps the largest source files from quietly growing back.

No reindex or manual migration is required.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.38.0)

## 2.37.8 - 2026-08-23

## What’s new

- Remote semantic search now runs reliably on an authorized indexer peer such as Bender instead of stopping at a local-model consent prompt.
- Direct local semantic search still requires explicit model-load approval. Remote execution uses the target machine’s authenticated fleet authorization.
- Peer execution context is now server-owned and cannot be forged by a normal MCP caller.

No reindex or manual migration is required.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.37.8)

## 2.37.7 - 2026-08-23

## RAG privacy and learning

- Peel now reports when reranking used a remote service and requires a separate explicit opt-in before sending search results for remote reranking.
- Retrieval feedback stays local, redacts sensitive query content, and uses bounded retention. It is never shared with the fleet.
- Stable result identifiers let Peel measure which search results actually help later reads and edits. This lays the groundwork for improving retrieval quality from real usage.

No reindex or manual action is required for this update.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.37.7)

## 2.37.6 - 2026-08-23

## More reliable Bender-powered search

- Vector searches now use a live Bender connection immediately after Peel launches, wakes, or reconnects.
- A recent Iroh connection flap no longer forces a healthy remote embedding query into text-only fallback.
- Search still falls back quickly when Bender is genuinely offline, without waiting on a long transport timeout.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.37.6)

## 2.37.5 - 2026-08-22

## Reliable MCP startup

- Keeps Peel's local loopback MCP server available when macOS preferences are temporarily unavailable or `cfprefsd` is unresponsive.
- Preserves an explicit operator choice to disable MCP and leaves LAN/TLS exposure disabled by default.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.37.5)

## 2.37.4 - 2026-08-22

## Safe analyzer corpus rebuilds

- Analyzer convergence now builds a complete replacement generation while search and swarm overlays keep serving the current corpus.
- Summaries and enriched vectors switch together in one atomic promotion. A failed or cancelled rebuild leaves active search unchanged and can resume later.
- The RAG view shows replacement-generation progress and makes it clear that active search remains available.
- Agents can inspect, commit, or abort staged generations through one explicit fleet-authorized control.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.37.4)

## 2.37.3 - 2026-08-22

- RAG artifacts discovered through the shared catalog are now republished after hydration, so eligible peers can find the newly available corpus without waiting for another indexing cycle.
- A missing swarm security epoch now stops transfer candidates before history or retry work is created. Automatic retries stay quiet until the epoch becomes available, while an operator-requested attempt still records a clear failure.
- Peel now removes credential-policy exclusions left in older RAG corpora at launch. The cleanup uses RAGCore's canonical store operation, does not load a model or rebuild an index, and never changes source files.
- Development launches no longer hang after stopping Peel when the macOS preferences service is unresponsive. Preference setup is now bounded, the replacement still launches, and failed-launch recovery retains the full previous app path.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.37.3)

## 2.37.2 - 2026-08-22

- RAG search now accepts a real checkout path and finds the matching clean `origin/main` corpus, even when that checkout was not registered with Peel.
- Analysis and enrichment started through MCP now publish progress to the same RAG view you use for work started in the app.
- A swarm with missing encryption setup now refuses RAG transfer immediately and reports one clear repair action. Repairing the security epoch does not rebuild or delete the corpus.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.37.2)

## 2.37.1 - 2026-08-22

This patch release makes fleet RAG failures immediate and actionable.

- A peer that cannot load its swarm encryption epoch now tells the requesting Mac at once instead of leaving the transfer queued until a reachability timeout.
- The error identifies the supported owner or admin repair for legacy swarms that have no active security epoch.
- Same-owner Macs can run default-safe fleet diagnostics again while explicit repository and workspace limits remain enforced.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.37.1)

## 2.37.0 - 2026-08-22

This release focuses on dependable long-running work across your Macs.

- Fleet RAG maintenance can now inspect, repair, analyze, and synchronize a corpus across your own machines with clear progress and cancellation controls.
- RAG transfers verify the producer's live corpus before export, preserve the achieved compatibility contract, and refuse unsafe bundles before spending time on transfer.
- Analysis patrols use a clean `origin/main` mirror without changing your working branch. Pull request reviews still use the exact pull request head.
- Agent runs preserve active and dirty worktrees across rebuilds, relaunches, cancellation, and cleanup so recoverable work is not deleted mid-run.
- Build coordination reuses content-addressed Iroh artifacts and prevents redundant cross-worktree builds from racing each other.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.37.0)

## 2.36.0 - 2026-08-20

Swarm inference routing, model capability, and ledger write amplification.

**A late gossip heartbeat no longer makes a machine look empty.** Model inventory was published over both transports and read only from the volatile Iroh blackboard, so a peer whose GPU state aged past the 60s freshness window was indistinguishable from a machine with no models installed. A 256 GB Mac Studio holding 22 models, answering round-trips in 119ms and actively serving a chain, was reported as having none — and scorecard regeneration declared 18 of 19 models unavailable for hours. Routing now resolves against the durable worker registry, with liveness only ordering the candidates (#2281, #2277).

**Reasoning models return their answers again.** Peel sets Ollama's `think` field on every chat request, which splits the reply into a reasoning channel and a content channel, and then read only the content. A model that spent its budget reasoning produced a well-formed stream that Peel turned into an empty success. Nemotron, Qwen and Gemma all answer semantic prompts through Peel chat again (#2283).

**A tool loop that produces nothing is now a failed step.** A model that stopped calling tools early was never asked to synthesise, and an empty result was reported as `completed / failed: 0` — only the output body distinguished a correct analysis from silence (#2071).

**You can tell which model ran.** Dispatch results carry execution provenance, so `swarm.tasks` and `dispatch-status` report the model that served each step (#2071).

**The ledger stopped rewriting 2.2 MB every 30 seconds.** `knowledge` and `knowledgeVerdicts` are 2.07 MB of effectively static content that were rewritten in full on every flush, putting Peel at three times the macOS per-process disk-write budget from a single file. Sections now persist independently: 77.8 KB/s to 5.5 KB/s (#2114).

**Two machines running the same daemon no longer erase each other.** `agentActivity` was keyed by bare daemon id, so two peers running "cfo" wrote the same CRDT key and last-writer-wins discarded one of them (#2021).

Also: one capability vocabulary replacing four (#1750), one Firestore-freshness rule replacing two kept in sync by a comment (#1554), `taskType` narrowing a scorecard pass rather than only its report (#2277), Firestore removed as a task dispatch backend, and `ROADMAP.md` reconciled against live issue state.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.36.0)

## 2.35.0 - 2026-08-18

## PR patrol: reviews that no longer argue with themselves

Measured across 161 posted patrol reviews: 13 of the 85 since Aug 1 said
**APPROVE** at the top, `VERDICT: REQUEST_CHANGES` at the bottom, and carried a
`peel:approved` label. One PR got that treatment three rounds running.

Twelve of the thirteen came from a single line. `extractActionableIssueLines`
treated any fully-bold line as a section heading — which is also the shape of
every finding — so it stopped at the first one, reported an empty Issues list,
and the `actionable-issues-required` gate concluded the reviewer had nothing to
say and rewrote the verdict.

**The suppressed findings turned out to be false positives**, which changes what
the fix has to be. The broken gate was accidentally acting as a crude precision
filter, so repairing the parser without a precision control would have converted
suppressed noise into posted `peel:changes-requested` labels. Both ship together.

### Integrity

- A bold line closes the Issues section only when it names a known section
- A review whose body contradicts its own label is **not posted**
- A gate that changes a verdict rewrites the body's verdict line and names itself
- Two reviewers that emitted nothing are "no verdict from either", not
  `agreement: Yes (UNKNOWN)` — 31 of 161 reviews published that
- The reviewer is told the CI state the patrol already verified; 137 of 161
  used to say "not visible to local reviewer" about a hard entry gate

### Precision

- A missing-import claim whose symbol is a template built-in is struck
- The shipped claim patterns had never fired once, because none could parse
  Peel's own mandated `file:L1-L27 — claim` citation format

### Measurement

`Tools/check-review-integrity.py` reads posted reviews back off GitHub and gates
on what is decidable — verdict integrity, label integrity, panel honesty —
reporting the judgement-shaped rest. Baseline at the time of the fix: **42.2%**.
Finding precision is reported only over the slice it can adjudicate, with the
denominator named, because a precision figure over an unstated denominator is
worse than none.

### Security lane

A deterministic scan locates candidate spans — sinks, *removed* authorization
lines, decisions inside access-control files — and a security-bound model judges
only those, skipped entirely when the scan finds nothing. It may not cite a
location the scan did not supply, which is what makes a model with high security
recall and weak grounding safe to ask. On nine real pull requests: 12 and 8 spans
on the two identity-token guard PRs, exactly the one removed line on a
deleted-policy-grant PR, and zero on four feature PRs.

## Also in this build

- Patrol graph seeded for pr-review with quorum confirmation (#2267)
- A peer's first direct-command timeout is forgiven rather than blacking it out (#2265)

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.35.0)

## 2.34.0 - 2026-08-17

## Local model reasoning effort, and a context window that matches the model

### Reasoning effort is now a real setting

Local reasoning used to be all-or-nothing: let a model think, or suppress it
entirely. That is a poor fit for modern reasoning models, which default to
maximum effort and can spend tens of thousands of reasoning tokens on a trivial
prompt — while turning reasoning fully off degrades multi-step tool work.

Settings → Agent → Reasoning now offers explicit effort levels alongside the
existing two:

- **Low** — short thinking trace, for mechanical work like code fixes and
  commit messages
- **Medium** — balanced, the general-purpose setting for review and analysis
- **High** — extended, for genuinely hard multi-step analysis
- **Maximum** — the longest trace; choose it deliberately

**Allow reasoning** and **Suppress reasoning** behave exactly as before, so
nothing changes unless you pick one of the new levels.

Effort is sent only to models that advertise a thinking mode. Models without
one are unaffected, and a server that rejects the setting is detected and
retried without it rather than failing your request.

### Larger context windows on capable machines

Peel previously asked every local model for at most a 32K context window, a
limit sized years ago for a much smaller model. Many current models advertise
262144 — including the ones in everyday use here — so long prompts were being
trimmed to fit a ceiling the model never actually had. PR review felt this most,
since reviewer prompts accumulate a diff plus file context plus prior reviews.

The window is now the smaller of what the model advertises and what your
machine's memory can hold:

| Machine memory | Maximum context |
|---|---|
| Under 32GB | 32768 (unchanged) |
| Under 96GB | 65536 |
| 96GB and above | 131072 |

Smaller Macs are deliberately untouched. Peel still requests the smallest window
that fits the prompt, so short requests do not pay for a large allocation.

### Fixed

- Errors from the streaming local-chat path now carry the server's message
  instead of a bare status code, so recoverable failures are recognized and
  retried rather than surfacing as an opaque error.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.34.0)

## 2.33.0 - 2026-08-17

## The fleet stops lying to itself

- **Update success now means the swap happened.** `app.update` restarts onto the new binary by default, exit 0 without a process swap reports the new `built_not_restarted` outcome (visible in `app.update.status` and Settings), and the restart helper verifies the running process is on the built commit. The `--restart` path had been a silent no-op for months — its product path predated the derived-data move and a missing bundle exited 0.
- **Clone rebuilds can't ship the template Firebase plist.** Self-update sources the real credential from the running app (or the local MCP, or the canonical checkout) before building, and refuses to deploy a placeholder build with the fix named. When a build IS credential-dead, pipe health says `firebaseCredentialsUnusable` instead of the misleading `firestoreOffline`.
- **models.pull verifies the model actually landed** (terminal success line + `/api/tags` presence) before reporting completed — a 17 GB pull that Ollama never finalized used to read as success.
- **The scorecard stops scoring calls that never reached a model**: sub-25 ms router failures classify as unmeasured with honest counts, so one real sample plus N transport failures can no longer publish a blended row.

## Mixed-fleet honesty

- A peer on a pre-hardening build now gets an immediate, decodable "update required" error (with the fix named) instead of silent timeouts that read as a wedged listener — and both timeout messages name the incompatible-build possibility. The admission gate itself is now a pure, fully-tested reducer.

## Iroh at scale, continued

- **Held-open remote calls survive connection churn.** Transport blips no longer kill pending calls (results arrive over redialed sends); goodbye, revocation, stale silence, and peer restart still fail them fast and say which. Long remote operations are no longer capped by session stability.
- **Every lane now evicts on send timeout** — a convergence send parked against a live-but-not-reading peer used to strand a task per anti-entropy cycle, forever.
- **The heartbeat breaker can't be pinned open by a one-way peer**: inbound traffic half-opens it (memory kept, backoff escalates) instead of erasing the failure history.
- **Churn storms get one bounded response**: when the windowed watch attributes a sustained storm to one peer, that session is evicted (per-peer cooldown) instead of only being reported. Departed peers also stop re-firing the stale sweep sixteen times each.

## Faster, quieter launch

- The synchronous Ollama probe, the session-event-log SQLite open, and the checkpoint scan are off the main thread at startup; embedding-model resolution defers to first use. MainActor guardrails are now CI-gated with a ratcheting baseline.

## Fleet note

This release's `app.update` restarts by default (pass `restart:false` to opt out). Machines updating FROM v2.32.0 report honestly through the new outcome; the first update onto a credential-less clone (e.g. a /tmp self-update clone without the gitignored plist) will refuse with exit 5 and name the file to provide — that refusal is the fix working.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.33.0)

## 2.32.0 - 2026-08-16

## Iroh at scale

- **Storm-proof accept path**: a peer that dials over and over without speaking the protocol — an old build, or a wedged Peel — is now closed at the door by a per-peer accept budget instead of parking a handler per attempt. Connections that never open a stream, and streams that never identify their channel, are closed on deadline; closing is also what unsticks the reader waiting on them, so a wedged-but-alive peer can no longer lock a handler forever.
- **Dial damping**: a failing peer gets one redial per cooldown instead of one per queued send — the dial-per-send storm that burned CPU for hours is structurally gone. Recovery is never delayed: cached and re-established connections bypass the cooldown.
- **Storms are visible**: transport counters now carry per-minute rates, and pipe health gains a `churnStorm` verdict that names the dominant peer. The storm that once read "healthy" for nine hours now reads as what it is, in `net.trace` and the dashboard.

## RAG security boundary (RAGCore 2.20.0)

- **Credential files are never read**: keys and signing material, `.env` variants, service-account and OAuth JSON, platform credential bundles, and secret stores are refused before ingestion touches a byte — independent of `.ragignore`, symlink-aware, with root `.gitignore` patterns honored as excludes. Refused paths are reported per index run (names only, never contents).
- **Existing corpora can converge**: new audit and purge operations remove already-indexed credential rows, including AI-analysis rows that previous cleanup paths left behind.
- **Analyzer reliability**: cold model loads no longer poison analysis runs — a 10-minute deadline, per-request keep-alive, and attributable timeout errors replace the old 60-second guaranteed failure. Namespaced Qwen3 models (hf.co/…) now get the thinking-suppression fast path.

## Also

- rag.analyze/rag.enrich return operation handles, and convergence stops being capped mid-run.
- Settings no longer rebuilds its tab view on a timer (AppStorage churn fix).
- The GPU mesh stays visible: publishes to the deadline and reports stale peers as stale.

## Fleet note

Machines still on v2.30.x lose gossip visibility of updated machines until they update, and pre-v2.31 callers get command-channel timeouts against updated peers (a loud-rejection fix is tracked). Update owned machines promptly.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.32.0)

## 2.31.0 - 2026-08-15

## Security & policy

- Iroh swarm boundaries hardened: gossip payloads are encrypted, knowledge-projection tools are reachable only under fleet trust, and two dispatch gateways now refuse non-local HTTP callers.
- The last ungated review path runs behind the grounding net.
- New Firestore collections (`workerSummaries`, `securityEpochs`) back worker discovery; the matching rules are already deployed.

## Honest failures

- Peer-call errors now report what the local machine actually observed instead of asserting the peer is down, and `swarm.reconnect` gives a channel-failure diagnosis a recovery step.
- Release builds refuse placeholder Firebase credentials outright — the v2.30.x "Firebase not configured" fleet freeze cannot ship again.
- `chains.run` rejects unresolvable repo identifiers loudly, and `dryRun` now reports the plan without starting the chain — no queue slot, no patrol claim, no worktree.

## Boards

- Closed cards actually get archived: after a verified board load, cards whose issue/PR has been closed past a 14-day grace period are archived automatically, at most once per project per day. `boards.archive.closed` remains for manual sweeps.

## Performance

- AuditTrail no longer loads 192 MB at launch.
- Home resolves open PRs once per body pass instead of seven times; run-snapshot detail decodes once per render instead of ~21 times.
- Convergence stops broadcasting to peers that are not answering.
- Chain concurrency is sized to the machine instead of hard-coded to 1.

## Correctness

- The build cache fingerprints untracked file contents, so uncompiled edits can no longer cache-hit.
- Scheduler phase primitive staggers same-cadence patrols after a restart.
- Inbox status vocabulary and the RAG corpus contract now report what a machine actually achieved.

## Mixed-fleet note

Gossip payload encryption means machines still on 2.30.x lose gossip visibility of updated machines until they update. Update owned machines promptly; other-owner beta machines will lag by however long their owners take.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.31.0)

## 2.30.2 - 2026-08-13

## What's new in 2.30.2

2.30.2 is identical to 2.30.1 in content; it exists to advance the update
sequence past a build-number collision so machines that installed 2.30.0
are offered the fix through the normal update flow.


### Fixes broken swarm sign-in in 2.30.0

2.30.0 was built without the real Firebase configuration, so Settings showed
"Firebase not configured", presence and worker records stopped updating, and
cross-network coordination silently degraded. Local mesh and LAN behavior were
unaffected. 2.30.1 is the same code with the credential restored. If you
installed 2.30.0, update as soon as convenient.

### Inline chains can now run local Ollama models (#2192, from 2.30.0)

A `chains.run` chainSpec step can name a local model directly, either bare
(`nemotron-3.5-lightning:30b`) or in catalog form (`ollama:qwen3-coder:latest`),
and the chain runs exactly that model on the worker or on a peer that serves it.

- chainSpec validation errors are targeted: each names the step, the field, and
  the offending value.
- A local model that is not installed on the worker and not advertised by any
  reachable peer is rejected before a worktree is created, with `models.pull`
  named as the remedy.
- Chain step results record the backend that served each step alongside the
  exact model, so model comparisons are auditable after the fact.

### Benchmarks (from 2.30.0)

- Small-model band scorecard rows added; VibeThinker-3B clears the security
  floor (#2187).

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.30.2)

## 2.30.1 - 2026-08-13

## What's new in 2.30.1

### Fixes broken swarm sign-in in 2.30.0

2.30.0 was built without the real Firebase configuration, so Settings showed
"Firebase not configured", presence and worker records stopped updating, and
cross-network coordination silently degraded. Local mesh and LAN behavior were
unaffected. 2.30.1 is the same code with the credential restored. If you
installed 2.30.0, update as soon as convenient.

### Inline chains can now run local Ollama models (#2192, from 2.30.0)

A `chains.run` chainSpec step can name a local model directly, either bare
(`nemotron-3.5-lightning:30b`) or in catalog form (`ollama:qwen3-coder:latest`),
and the chain runs exactly that model on the worker or on a peer that serves it.

- chainSpec validation errors are targeted: each names the step, the field, and
  the offending value.
- A local model that is not installed on the worker and not advertised by any
  reachable peer is rejected before a worktree is created, with `models.pull`
  named as the remedy.
- Chain step results record the backend that served each step alongside the
  exact model, so model comparisons are auditable after the fact.

### Benchmarks (from 2.30.0)

- Small-model band scorecard rows added; VibeThinker-3B clears the security
  floor (#2187).

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.30.1)

## 2.30.0 - 2026-08-13

## What's new in 2.30.0

### Inline chains can now run local Ollama models (#2192)

A `chains.run` chainSpec step can name a local model directly, either bare
(`nemotron-3.5-lightning:30b`) or in catalog form (`ollama:qwen3-coder:latest`),
and the chain runs exactly that model on the worker or on a peer that serves it.
Previously any local model id collapsed into a generic "Invalid chainSpec" parse
error, which blocked dynamic model bake-offs dispatched over the swarm.

- chainSpec validation errors are now targeted: each one names the step, the
  field, and the offending value.
- A local model that is not installed on the worker and not advertised by any
  reachable peer is rejected before a worktree is created, with `models.pull`
  named as the remedy.
- Chain step results now record the backend that served each step alongside the
  exact model, so model comparisons are auditable after the fact.

### Benchmarks

- Small-model band scorecard rows added; VibeThinker-3B clears the security
  floor (#2187).

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.30.0)

## 2.29.0 - 2026-08-12

## Patrols become programmable graphs

Patrols are no longer compiled step lists — they're editable JSON documents describing a dataflow: deterministic scan gates, model judgement nodes, multi-model fan-out panels spread across your machines, mechanical vote/merge aggregation, and reports. The Security Patrol ships as the first seeded graph: a deterministic scan feeding a three-model panel whose seats are chosen by measured scorecard columns, merged by quorum, reported honestly — including per-node degradation when a machine or model is unavailable. Delete the document to restore the shipped default; edit it to reshape the patrol without rebuilding anything.

New tools: `patrol.graph.validate`, `patrol.graph.mermaid` (accurate diagrams for free), and `patrol.graph.run`.

## The scorecard measures topologies, not just models

`models.scorecard` gains a `topology` argument: run the fixture set through a panel-plus-merge subgraph as a unit and get a row beside the individual models — "what the panel bought" becomes a subtraction anyone can read. Per-seat debug dumps (`topologyDebug`) make surprising rows readable instead of deducible.

## Fleet model management

`models.pull` installs a registry model on whichever of your machines runs it, and `ollama.upgrade` performs the full brew upgrade + service restart + version verification in one step. Both are owner-commanded across the fleet via `swarm.remote-tool-call`, and both respect a per-machine consent gate (default off) plus a free-disk floor — refusals say exactly why.

## Model routing honesty

Tier-bound steps (`.bestStandard` and friends) were silently wedged on Claude Sonnet 4.6 when the catalog recommended the Claude 5 family: the recommendation was discarded without a log because the model enum couldn't spell it. The enum now knows Fable 5, Opus 5, and Sonnet 5; standard-tier work resolves to Sonnet 5; and any future un-spellable recommendation logs loudly instead of silently downgrading. The planner's model-selection guidance moves to the 5 family as well.

## Also

- Findings-style measurement payloads align with their serialized field names.
- Panel seat resolution never seats the same model twice, and quorum counts machines, not repetitions.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.29.0)

## 2.28.0 - 2026-08-11

## Model scorecard: security review measurement

The model scorecard gains a **Security Review** task type — the first find-the-set grader. It measures the judgement step of the security patrol (code span in, findings out) with recall and precision kept apart: missing a planted defect and inventing one are different failures, and the score (F1) can't be gamed from either side. Fixtures come in pairs — planted defects and clean controls — because false positives are what make a patrol get ignored.

The leaderboard is regenerated against the new fixture set for four local models, with per-sample stability and structural-failure rates recorded.

## GPU mesh: delegation fixes

Three fixes for machines whose local Ollama is running but doesn't hold the requested chat model:

- Model enumeration now merges locally installed and peer-advertised models (embedding-only peer models are excluded when capabilities are known).
- Routing now delegates to a capable peer instead of attempting a guaranteed-to-fail local load when the model isn't installed locally.
- The recorded inference plan names the peer routing will actually pick, not an arbitrary one.

## Security hardening

- Remote repo scoping is now fail-closed: searches that implicitly address all repositories are denied under a configured repo scope, plural repo-identifier arguments are scope-checked, and nested gateway calls can't launder an out-of-scope repo.
- Release tooling resolves its helpers from the validated main checkout rather than the invoking directory.

## Performance

- Settings no longer performs a launchd round-trip on every render: the login-item status is cached and refreshed only when it can change. This removes a main-thread stall that made dashboard animations drop frames once Settings had been opened.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.28.0)

## 2.27.0 - 2026-08-10

## Scorecard cells are measurements, not coin flips

A model scorecard cell used to come from a single ask per fixture. For a model
that emits malformed output intermittently, that single draw was a coin flip
between 0 and 100 that moved on every pass with nothing to explain it.

Each fixture is now asked several times (three by default, configurable from 1
to 10), and the cell reports what stands behind it: how many asks were taken,
the run-to-run spread within a fixture, and the fraction of samples whose
output could not be consumed at all. A pass that runs out of budget reports the
smaller honest sample count rather than claiming the full one. Rows measured
before this change still decode cleanly and read as measured once.

## Format failure and capability failure are no longer the same score

An unparseable answer scores 0 — 40 points below a well-formed wrong one. That
is the right floor, but on its own it cannot distinguish "cannot do the task"
from "will not emit the envelope", and those call for opposite responses: drop
the model, or adapt the prompt.

A sample that fails the output contract now gets exactly one restatement,
identical for every model. The repaired score is reported beside the original,
never folded into it — published numbers keep their meaning, because the first
answer is what callers actually get. The delta between the two is a
counterfactual worth acting on: adding one repair turn to the pipeline would
move this cell by that much. A merely wrong answer is never retried, since
re-asking until a model agrees measures persistence, not task success.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.27.0)

## 2.26.1 - 2026-08-09

## Peer recovery stays bounded

Repeated disconnects and reconnects can no longer multiply peer lifecycle work
without limit. Peel coalesces duplicate recovery events, caps its network queues,
and retires superseded connection attempts promptly.

## Iroh path retries cannot run away

Peel now ships a bounded Iroh recovery path for the QUIC failure that caused a
peer under heavy network churn to consume tens of gigabytes. Duplicate path
retries are suppressed, overload is contained, and persistent failures back off
instead of creating exponential work.

## Better live network diagnostics

`net.trace` now reports endpoint connection counts, queue pressure, and Iroh
path-retry activity. Stream failures and duplicate connections carry clearer
reasons, making it easier to distinguish normal reconnect churn from an
unhealthy peer before responsiveness is affected.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.26.1)

## 2.26.0 - 2026-08-07

Three audit passes over the last week went looking for memory that never comes
back, work that lands on the main thread, and success reported as failure. They
found more than we expected. This release is what came out of that, plus video
generation.

## Long-running machines stop accumulating memory

A Peel process that had been up for 21 hours was holding 2.19 GB in suspended
task stacks and another 2.13 GB in repository listings it had no further use
for. Two separate causes, both now fixed.

Inbound network channels were handled in a task group that is never destroyed,
because the stream feeding it never ends. A plain group holds onto every child
until the group itself goes away, so every channel handled since launch stayed
charged to the process at about 1,310 bytes each. At roughly 27 channels a
second that adds up fast. Switching to a group that frees each child as it
finishes took a 200,000-child probe from 261.4 MB down to 11.1 MB.

The other cause was a queue of waiters that had no way to identify any single
one of them. A cancelled waiter was never resumed and never removed, and a
suspended task holds its entire stack frame, so each one pinned a full
21-repository listing. Waiters are now keyed by id and drained on cancellation.
A probe that cancels 20,000 parked waiters leaves the queue at zero where it
used to leave 20,000.

A third instance of the same pattern turned up in the inference queue during a
later pass and got the same fix.

## The interface stops freezing

The worst stall we found was several seconds long. Chain runs ask for impact
analysis on the files they are about to touch, and that question ran a
full-corpus database join on the main thread. One scan is about two thirds of a
second against a 2.4 GB store. It ran once per file hint, so a step naming ten
files froze the app for over six seconds. It now scans once in the background
and matches every file against that single result.

Three smaller stalls went with it. A redaction pass was recompiling eleven
regular expressions on every call, which cost about 170 ms per knowledge
rebuild and ran on the main thread for every line a plugin wrote to standard
error. The command palette was re-ranking the full 300-tool catalog on every
view pass, about 10 ms per keystroke, two thirds of it duplicate work. Copying a
repository index between branches held the main thread for 1.42 seconds.

Parsing a run's review output was also happening several times per view pass, at
11 to 13 ms each on a real 40 KB output. It is now computed once.

## Semantic knowledge search works again

Peel could not answer a semantic knowledge query, and any manual attempt to fix
it was undone within the hour.

The background rebuild computed its work set against the current embedding
provider, but its fallback path stamped rows with a different model name. Every
row therefore looked stale on the next pass, so the rebuild re-embedded the
entire corpus every time and never converged. That same stamp is what the search
side rejects, so all 623 rows on the live store were unreadable to it. The
fallback now derives its work set from the model it is actually about to stamp.

## Sync stops calling success a failure

Two normal outcomes were being reported as errors. An overlay sync that carries
no files is the ordinary answer to "nothing has changed since you last asked",
and it was being surfaced as a failure. It now reports as up to date.

Machines that deliberately index repositories they do not check out were in a
worse spot: their imports worked, wrote real data, and were marked failed
anyway, with a summary that said in the same breath that the overlay had landed.
Having no local checkout is not the same as having applied nothing, and the two
cases are now told apart.

Automatic pull retries decide from the typed failure reason rather than by
reading error text, so a transient failure retries and a permanent one does not.

## Connectors that die get noticed

In sandboxed builds, which includes TestFlight, nothing ever told the app that a
connector's process had exited. The app learns about it by the output stream
ending, and that stream simply went quiet instead. A dead connector kept
reporting itself ready, restart policies never fired, and callers kept routing
work to it. The exit now crosses the process boundary, carrying the real exit
code so that restart-on-failure can tell a crash from a clean shutdown.

Three more went with it. A network proxy leaked a file descriptor and a live
connection on every tunnel it closed. Reopening a window in background mode
re-ran the startup path against the same object, duplicating connector
subprocesses and menu bar items with nothing to tear them down. And a streamed
subprocess that wrote more than 64 KB to standard error would deadlock forever,
which is a bug we had already fixed once in the sibling code path and left
here.

## Background energy

The swarm re-encoded an identical ledger digest every 20 seconds, 4,320 times a
day, producing bytes byte-for-byte the same as the previous round. The encoding
is now reused when nothing has been written. The digest still goes out every
round, because skipping the send would change how machines converge.

Appending to the swarm message log went from 0.506 ms to 0.00053 ms once it
stopped rebuilding a 45,000-element set on every append.

## Video generation

`asset.video.generate` is new, and runs against MiniMax's cloud API. It covers
text to video, image to video with a first frame, and subject reference, across
the Hailuo and T2V/I2V model families. Set an API key in the keychain or the
environment and poll `asset.status` the same way as the other asset tools.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.26.0)

## 2.25.0 - 2026-08-05

## Peel stops holding gigabytes it does not need

Syncing a RAG artifact could push Peel past four gigabytes of physical memory,
far enough to trip its own memory guard and pause swarm work until the pressure
cleared. The cause was not the size of the index. It was how the index was
checked.

Every file in an artifact bundle is verified by SHA256 before it is applied, and
one of those files is `rag.sqlite` — gigabytes on a machine that indexes a lot.
The importer read each file **whole** into memory purely to hash it, then threw
the bytes away. Worse, the helper that was supposed to hash in fixed-size chunks
was not actually streaming: `FileHandle` hands back memory the system reclaims
only when a pool drains, and on a background task nothing ever drained one. It
read in chunks and kept every chunk, which costs exactly as much as reading the
whole file at once.

Both paths now stream for real. Hashing a 2.4 GB index went from **2347 MB of
peak memory to 3.8 MB**, for a byte-identical digest at the same speed. The
integrity check is unchanged; only the cost of running it is.

## Launch stops rebuilding an index that never changed

Peel keeps a fast read-only projection of the search corpus, and rebuilds it
when the corpus is newer. That comparison could never come out in favour of
reuse, so every launch rebuilt from scratch — a full copy of every chunk in a
multi-gigabyte database, on a corpus that had not changed.

The rebuild was invalidating itself. It finished by asking SQLite to analyse its
work, and the unscoped form of that request analyses *every* attached database,
including the source it had just read. That wrote to the source and moved its
timestamp past the projection's, so the next launch always concluded the corpus
was newer. Scoping the request to the projection alone leaves the source
untouched, and reuse works as intended.

## Pointless overlay transfers stop before they start

When two machines have indexed a repository at different commits, their overlay
data cannot line up: the file hashes will not match and nothing will apply. Peel
discovered this the expensive way — transferring the whole overlay, comparing
commits at the end, applying zero rows, and discarding the result. On one
machine that was eight repository pairs repeating the same wasted transfer.

Machines now publish the commit they have each repository indexed at, so a pull
that cannot possibly apply is declined before any data moves. The check is
deliberately conservative: it only declines when **both** machines have reported
a commit and the two differ. A machine that reports nothing is treated as
unknown, never as diverged, so this can only skip transfers that were going to
apply nothing.

Nothing is parked or remembered. The verdict is recomputed from what machines
currently report, so reindexing either side resumes syncing on its own. Skipped
pairs are listed in swarm diagnostics with both commits and the fix — reindex
both machines at the same commit — so a repository that is not syncing says so
instead of going quiet.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.25.0)

## 2.24.0 - 2026-08-05

## One role per machine, shown where you need it

A machine's RAG posture used to be assembled from three independent dials in
three different places, and one of them had no interface at all. Nothing showed
the resolved answer to the two questions an operator actually asks: what does
this machine provide, and where does this repository pull from.

Both questions now have one answer each, in one place.

**Machines roster.** Repository Fleet's inspector gains a row per machine
showing what it provides. This Mac's row is a role picker — Producer, Mirror, or
Consumer — that writes the sync direction and the background-work default
together, rather than leaving you to assemble three settings by hand and
discover later that they disagree.

Serving is a single machine-wide switch, so a machine cannot mirror one
repository and not another. That is exactly why the serve control lives on the
machine row and not in the repository table.

**A machine is never rounded to the nearest role.** Settings that match no named
role read as **Custom** and list what the machine actually does. A role is
matched on consequences rather than exact values, so a producer left on
bidirectional still serves, builds, and publishes, and still reads as Producer.

**Peers report only what they advertise.** A peer publishes its sync direction
and nothing else — its background-work policy and publish list are readable only
on the machine that owns them. So a peer shows *Serves artifacts*, *Serves
nothing*, or *Not reported*, never a role name assembled from settings nobody
measured. When repositories name a peer as their producer and its sync direction
prevents it from serving, the row says so and names the count. That specific
mistake — a machine set to pull-only while the fleet still routes producer work
to it — served nothing, silently, and was invisible at the surface that reported
it.

## Repository knowledge says which scope decided it

The repository RAG card now shows resolved values rather than duplicate
controls:

- **This Mac's role**, read-only, with the resolved pull direction beneath it:
  *"Pulls from <machine> · synced 12m ago, inherited from <workspace>"*. The
  headline names the machine that would actually deliver, not the producer the
  policy names — those diverge exactly when something is wrong, and the tooltip
  says so when they do.
- **Background-model inheritance.** The picker stays, because that setting is
  genuinely per repository, but it now says which scope produced the current
  value and offers to hand the repository back to that scope instead of only
  ever creating an override. Where a swarm contract or a checked-in
  configuration caps the level, the menu offers only the values you can actually
  reach and names the cap; it used to offer higher ones that wrote a preference
  and changed no behavior.
- **Producer conflicts** are called out on the repository that causes them: when
  a repository names this Mac as its producer and this Mac cannot fill the role,
  the card explains why in the resolver's own words.

## Two settings moved to the scope they act on

**Automatic pulling** and **preferred delivery** each write a single setting for
the whole Mac, but they used to render inside an individual repository's card.
Changing either one "for this repository" changed it for every repository, and
nothing on screen said so. Both now live in Repository Fleet → Machines. The
repository card shows their resolved values read-only, each naming its scope.

LAN and WAN preferred delivery remain independent, and a preference pointing at
a machine that is currently offline keeps naming that machine rather than
quietly reading as automatic.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.24.0)

## 2.23.0 - 2026-08-05

## Fleet self-diagnosis

The RAG fleet scorecard now catches two failures it used to report nothing about.

**No producer assigned.** When the fleet replicates repositories that no swarm
contract or policy names a producer for, the scorecard says so and names the
online machine best placed to take the job, with the `swarm.contract.publish`
repair one preview away. Previously an empty contract looked identical to a
healthy one: with nobody assigned, every publisher's vector space was treated as
equally authoritative, which is what produced "assigned producers publishing
incompatible spaces" for a fleet with zero assignments.

**Off-standard publications.** Published registry rows are now compared to the
fleet's declared embedding standard regardless of whether the machine that
published them is awake. A publication does not become correct when its author
closes the laptop, and stale-registry pruning leaves the row in place while that
worker identity is still alive. A publisher that is back online on the standard
is treated as stale history awaiting a republish, not as a disagreement.

Both appear in the Repository Fleet topology rail (Authority and Quality) and in
`rag.fleet.scorecard`, which gains `unassignedProducerCount` and
`offStandardPublicationCount` in its summary view so neither hides behind a bare
error count.

## Swarm

- RAG provider settings collapse into a single role concept instead of separate
  dials.
- Worker-name resolution is now loud on eviction, ambiguity, and no-target
  instead of failing quietly.
- Fleet memory watch names duplicate-connection peers, tracks heartbeat
  footprints, and escalates sustained growth.

## Performance

- The RAG source-search projection is reused when the corpus has not changed.

## Removed

- The legacy WKWebView-backed product manual view.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.23.0)

## 2.22.5 - 2026-08-04

Peel 2.22.5 closes out the memory-growth work from the 2.22.x line: the swarm transport runaway found after the 2.22.4 rollout is fixed at its root, and connector subprocess output is now bounded end to end.

- Fixed a swarm networking runaway where a peer holding more than one QUIC connection could enter an exponential path-negotiation loop, consuming tens of gigabytes of memory within the hour. Peel now enforces a single connection per peer, removing the precondition entirely.
- Bumped the pinned iroh transport crate to 1.0.3.
- Connector subprocess pipes are now memory-bounded. stderr streams to the log line by line as it arrives instead of accumulating until the process exits, an oversized protocol line is dropped with an explicit log entry instead of buffering without bound, and every evicted byte is counted and surfaced rather than silently discarded.

A misbehaving or wedged connector can no longer grow Peel's footprint for as long as it runs, and its final output before a crash now reaches the log.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.22.5)

## 2.22.4 - 2026-08-04

Peel 2.22.4 fixes a swarm startup priority inversion discovered during the 2.22.3 fleet rollout.

- Identity challenge and response traffic now uses a dedicated critical-control lane, so heartbeat churn and RAG reachability preflights cannot leave a peer connected but unverified.
- Failed identity frames retry on a small bounded schedule using the same nonce; retries do not duplicate RAG data or create an unbounded queue.
- RAG request metadata, convergence messages, and bulk content-addressed blobs remain on their existing lower-priority bounded paths.

This preserves the security gate for sensitive remote commands while allowing trusted Auto-update peers to recover cleanly after a restart.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.22.4)

## 2.22.3 - 2026-08-04

## Automatic fleet updates report the right preference

- A machine using the displayed Daily default now advertises Daily to the swarm instead of being mistaken for Never.
- Explicit Never and Weekly choices remain unchanged and are still respected by fleet-wide update requests.
- Sparkle configuration and swarm capability gossip now use one shared preference resolver, preventing the two paths from drifting again.

This is a focused follow-up to 2.22.2. No user action is required.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.22.3)

## 2.22.2 - 2026-08-04

## Memory stays bounded during startup and swarm sync

- Peel now coalesces repeated RAG inventory work at startup and applies large incoming bundles one at a time instead of multiplying the same scan and decode work.
- RAG bundles now stream directly to disk, and integrity checks run off the UI thread without loading the full artifact into memory.
- Automatic RAG pulls pause while memory pressure is high and resume after recovery. Memory monitoring also starts earlier, before swarm convergence begins.
- Retired Knowledge keeps the clocks needed to prevent stale resurrection without retaining the full rejected payload in the active ledger.

These changes remove the startup and convergence amplification that could drive Peel far beyond the machine's physical memory. No user action is required.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.22.2)

## 2.22.1 - 2026-08-03

## Bounded memory during swarm convergence

- Peel now pauses background ledger convergence before process memory can grow into a machine-wide incident. Sync resumes automatically after memory recovers.
- Large swarm ledgers travel in a few bounded frames instead of dozens of tiny frames that each repeated decode, signature verification, and merge work.
- Incoming ledger work now has strict per-peer frame and byte limits, preventing a noisy or reconnecting peer from building an unbounded in-memory backlog.
- Repeated verification of the same immutable Knowledge block is reused safely across repair rounds while remaining bound to the exact payload, signature, and author key.

No user action is required.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.22.1)

## 2.22.0 - 2026-08-03

## Clear leadership without giving up peer-to-peer operation

- Every machine remains a peer. Swarm contracts can now name an ordered leader and deputy while keeping leadership separate from repository and model duties.
- Swarm leaders can send durable messages and propose a knowledge producer for another Mac. The receiving user reviews the plan locally before anything changes.
- Repository Fleet now distinguishes the contract embedding standard from active producer conflicts and old publication history, making mixed embedding warnings actionable.
- Repository discovery now keeps real local checkouts ahead of canonical mirrors and recognizes nested checkouts more reliably.
- Routine swarm and GPU ledger updates no longer rebuild the knowledge corpus, reducing idle work and unnecessary embedding churn.
- Leader, Deputy, Peer, Producer, and Consumer labels replace the old overlapping role vocabulary throughout Peel and its agent tools.

[Release notes](https://github.com/cloke/peel-releases/releases/tag/v2.22.0)

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
