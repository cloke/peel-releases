# Peel Feature Guide

Peel is built around one idea: AI coding work should remain attached to the repository, visible while it runs, and reviewable before it lands.

This guide maps the product in user terms. Some areas are intended for everyday work; others become useful as you add automation, local models, or more Macs.

## Start with the core loop

1. **Add a repository.** Clone one from GitHub or select a local checkout.
2. **Index it.** The local RAG index gives search and agents repository-specific context.
3. **Run a workflow.** Choose a template and target repository.
4. **Watch the Inbox.** Peel streams progress and records the run in one attention queue.
5. **Review the result.** Inspect the plan, timeline, output, diff, checks, and PR context.
6. **Keep the useful knowledge.** Insights and learnings improve later work.

Boards provide work, schedules repeat it, a swarm distributes it, and analytics show whether it was worthwhile.

## Home

Home is the command center. It summarizes repository state, active work, RAG health, and connected swarm machines. Use it when you want orientation rather than detail.

## Work

### Inbox

The Inbox combines work regardless of where it originated:

- local and swarm-dispatched agent runs;
- work waiting for review or approval;
- failed runs that need intervention;
- open pull requests and review results;
- dependency and security alerts;
- observations from background agents.

A run detail shows its plan, chain pipeline, stage timeline, model use, PR context, review verdict, child runs, and available actions. Active runs can accept guidance while they are still working.

### Long Tasks

Long Tasks handle improvement programs too large for one prompt or PR: documentation cleanup, migration work, test expansion, or repeated code-quality refinement. Peel works through durable slices and continues across app restarts.

## Boards

Boards turns GitHub Projects v2 into an intake and dispatch surface. Select a project card, workflow, and machines; Peel creates isolated agent work while planning remains visible in GitHub.

## Repos

Repos combines local checkouts and GitHub repositories. It tracks clone and pull state, PRs, active runs, worktrees, indexing, and swarm availability.

Each repository has six tabs:

- **Overview** — attention items, PRs, active work, schedules, and tracking.
- **Agents** — repository-specific agents and configuration scaffolds.
- **Branches** — changes, commits, branches, run snapshots, PRs, and approvals.
- **RAG** — index, search, analysis, enrichment, and scan controls.
- **Graph** — dependencies and structural impact relationships.
- **Skills** — conventions and guidance supplied to agents for this repository.

### RAG and code intelligence

Peel chunks code into a local SQLite index and can add embeddings and AI analysis. Search supports Vector for meaning, Text for exact phrases, and Hybrid for both. Indexing is incremental, and unchanged analysis can be reused.

The dependency graph answers what a file depends on and what depends on it. Skills record project conventions, build instructions, and known pitfalls. Framework Skill Packs can seed matching repositories with curated guidance.

### Worktrees

Agent runs execute in isolated git worktrees instead of editing the primary checkout. Peel shows both agent-created and ordinary worktrees across all repositories, including stale work that may be ready for cleanup.

## Agents

### Templates

Templates define reusable multi-step workflows. A chain can plan, implement, test, and review with different models or deterministic tools assigned to each step. Every run is scoped to a repository and isolated in a worktree.

### Schedules and patrols

Schedules run workflows on a cadence. Patrols are recurring quality missions such as PR review, security scanning, code health, or UX auditing. Machine ownership and power rules control where and when they run.

### Specialist agents

The Agent Directory manages always-on roles for operations, cost, security, releases, or code quality. It exposes each agent's model, cadence, mission, and recent decisions so background automation remains inspectable.

### Plugins and skill packs

Plugins add tools to Peel's MCP server and display their signature and trust status. They run in separate processes with explicit permissions. Skill Packs are inert framework guidance: they shape agent reviews but do not execute code.

### Prompt rules

Global Prompt Rules set shared instructions, planner selection, cost limits, and RAG expectations across all agent chains.

## Observe

### Swarm

A swarm joins multiple Macs into a pool of workers. Peel routes agent tasks based on repository availability, hardware, models, and load. Observe includes a console, topology dashboard, live message traffic, and a replay of unattended work.

Peel remains fully useful on one Mac. See the [Swarm Guide](SWARMS.md) when you are ready to add another.

### Models and GPU Mesh

The Playground lets you try an on-device MLX model, a local or remote Ollama endpoint, or a model hosted on a swarm peer. Conversations can use repository RAG and optional tool calling.

GPU Mesh shows which Macs can serve local inference, their memory, installed models, and queue depth. Peel uses that information to choose a suitable machine.

### RAG Health

RAG Health shows index freshness, embedding coverage, model or dimension mismatches, overlay transfers, and the active embedder across repositories and machines.

### Analytics

Analytics covers run success, model use, cost, review quality, patrol value, and background-agent activity over 24-hour, 7-day, and 30-day windows. Data can be scoped to one Mac or the swarm.

### Knowledge

Insights are findings, suggestions, ideas, and opportunities with confidence and a lifecycle. Learnings are durable instructions injected into later work. Useful insights can graduate into learnings, and swarm-authored insights can gather peer consensus.

## MCP and API access

Peel is also a local server. MCP clients connect to `/rpc`, while OpenAI-compatible clients can use `/v1/*`. More than 300 tools expose the same capabilities used by the app.

Progressive discovery keeps the surface manageable: common tools include full schemas immediately, while specialized schemas load only when requested.

This lets work start in Peel, an IDE, a script, or another model client and still arrive in the same Inbox for review.

## Choose a starting point

| If you want to… | Start here |
|---|---|
| Understand unfamiliar code | Add the repo, index it, then use RAG and Graph. |
| Have an agent implement a change | Agents → Templates, then Work → Inbox. |
| Review PRs repeatedly | Create a PR Review patrol under Agents → Schedules. |
| Use a stronger Mac for work | Follow the [Swarm Guide](SWARMS.md). |
| Try local models against code | Observe → Models → Playground. |
| Measure whether automation helps | Observe → Analytics and Observe → Knowledge. |
