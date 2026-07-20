# Peel Feature Guide

Peel is built around one idea. AI coding work should stay attached to the repository, stay visible
while it runs, and be reviewable before it lands.

This guide maps the product in user terms. Some areas are for everyday work. Others only become
useful once you add automation, local models, or another Mac.

## Start with the core loop

1. **Add a repository.** Clone one from GitHub or select a local checkout.
2. **Index it.** The local index is what gives search and agents context about this specific repo.
3. **Run a workflow.** Choose a template and a target repository.
4. **Watch the Inbox.** Peel streams progress there and keeps a record of the run.
5. **Review the result.** Look at the plan, the diff, and the checks before deciding.
6. **Keep the useful knowledge.** Insights and learnings feed into later work.

Boards supply the work. Schedules repeat it, a swarm spreads it around, and analytics tell you
whether it was worth doing.

## Home

Home is the command center. It summarizes repository state, active work, and which swarm machines
are connected. Use it when you want orientation rather than detail.

## Work

### Inbox

The Inbox collects work no matter where it came from. Agent runs you started, runs dispatched from
elsewhere in the swarm, anything waiting on review, failures that need you, open pull requests,
security alerts, and observations from background agents.

Open a run and you get its plan, its stage timeline, which models it used, the PR context, and the
review verdict. Runs that are still working can take further guidance while they go.

### Long Tasks

Some improvement programs are too big for one prompt or one PR. Documentation cleanup and
migration work are the usual examples. Long Tasks breaks that kind of job into durable slices and
keeps going across app restarts.

## Boards

Boards turns GitHub Projects v2 into an intake and dispatch surface. Pick a card, a workflow, and
the machines to run it on. Peel creates the isolated agent work while the planning stays visible in
GitHub.

## Repos

Repos brings local checkouts and GitHub repositories together. It tracks clone and pull state, open
PRs, active runs, and whether the repo is indexed and available to the swarm.

Each repository has six tabs:

- **Overview.** Attention items, open PRs, and what's scheduled.
- **Agents.** Repository-specific agents and configuration scaffolds.
- **Branches.** Changes and commits, plus run snapshots and approvals.
- **RAG.** Index, search, and the analysis and enrichment controls.
- **Graph.** Dependencies and structural impact.
- **Skills.** Conventions and guidance handed to agents working on this repo.

### RAG and code intelligence

Peel chunks code into a local SQLite index, then optionally adds embeddings and AI analysis.
Search comes in three modes. Vector finds meaning, Text finds exact phrases, and Hybrid does both.
Indexing is incremental, and analysis that hasn't changed gets reused rather than recomputed.

The dependency graph answers two questions: what does this file depend on, and what depends on it.
Skills record the conventions and pitfalls specific to a project. Framework Skill Packs can seed a
matching repository with curated guidance so you don't write it from scratch.

### Worktrees

Agent runs execute in isolated git worktrees rather than editing your primary checkout. Peel shows
both the worktrees it created and your ordinary ones, across every repository, including stale work
that's probably ready for cleanup.

## Agents

### Templates

Templates define reusable multi-step workflows. A chain can plan, implement, then review, with a
different model or a deterministic tool assigned to each step. Every run is scoped to one
repository and isolated in a worktree.

### Schedules and patrols

Schedules run workflows on a cadence. Patrols are recurring quality missions, like PR review or
security scanning. Machine ownership and power rules control where they run and when.

### Specialist agents

The Agent Directory manages always-on roles for things like operations, cost, and code quality. It
shows each agent's model, cadence, mission, and recent decisions, so background automation stays
inspectable instead of mysterious.

### Plugins and skill packs

Plugins add tools to Peel's MCP server and show their signature and trust status. They run in
separate processes with explicit permissions. Skill Packs are inert by comparison. They shape how
agents review code but never execute anything.

### Prompt rules

Global Prompt Rules set shared instructions, planner selection, and cost limits across every agent
chain.

## Observe

### Swarm

A swarm joins several Macs into a pool of workers. Peel routes agent tasks based on which machines
have the repository, the hardware, and the models to do the job. Observe gives you a console, a
topology dashboard, live message traffic, and a replay of work that ran while you weren't watching.

Peel is fully useful on one Mac. See the [Swarm Guide](SWARMS.md) when you're ready to add another.

### Models and GPU Mesh

The Playground lets you try an on-device MLX model, a local or remote Ollama endpoint, or a model
hosted on a swarm peer. Conversations can pull in repository context and use tool calling.

GPU Mesh shows which Macs can serve local inference, how much memory they have, and how deep their
queue is. Peel uses that to pick a machine.

### RAG Health

RAG Health shows how fresh each index is and how much of it has embeddings. It also flags the
problem cases: model or dimension mismatches across repositories and machines.

### Analytics

Analytics covers run success, model use, cost, and review quality over 24-hour, 7-day, and 30-day
windows. Scope it to one Mac or the whole swarm.

### Knowledge

Insights are findings and suggestions carrying a confidence score and a lifecycle. Learnings are
durable instructions injected into later work. A useful insight can graduate into a learning, and
insights authored elsewhere in the swarm can gather peer consensus first.

## MCP and API access

Peel is also a local server. MCP clients connect to `/rpc`. OpenAI-compatible clients use `/v1/*`.
More than 300 tools expose the same capabilities the app uses.

Progressive discovery keeps that surface manageable. Common tools carry full schemas immediately,
and specialized schemas load only when a client asks for them.

So work can start in Peel, in an IDE, or from a script, and still arrive in the same Inbox for
review.

## Choose a starting point

| If you want to… | Start here |
|---|---|
| Understand unfamiliar code | Add the repo, index it, then use RAG and Graph. |
| Have an agent implement a change | Agents → Templates, then Work → Inbox. |
| Review PRs repeatedly | Create a PR Review patrol under Agents → Schedules. |
| Use a stronger Mac for work | Follow the [Swarm Guide](SWARMS.md). |
| Try local models against code | Observe → Models → Playground. |
| Measure whether automation helps | Observe → Analytics and Observe → Knowledge. |
