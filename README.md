# Peel

> Peel back the layers of your development environment.

Peel is a macOS workspace for developers who use AI coding agents across real repositories. It brings repository context, agent runs, pull requests, worktrees, local models, and multiple Macs into one place—while keeping review and merge decisions visible.

Peel is in active development and currently requires **macOS 26 (Tahoe)**.

[Download Peel](https://github.com/cloke/peel-releases/releases/latest) · [Explore every feature](FEATURES.md) · [Learn about swarms](SWARMS.md) · [Read the changelog](CHANGELOG.md)

## What Peel helps you do

- **Understand a repository** with local semantic search, exact-text search, dependency graphs, and durable project guidance.
- **Run agent workflows safely** in isolated git worktrees, with live progress, review gates, diffs, and pull-request context.
- **Keep one attention queue** for active runs, failed work, PR reviews, alerts, and completed changes awaiting a decision.
- **Automate recurring work** with templates, schedules, patrols, long-running tasks, and always-on specialist agents.
- **Use the hardware you already own** by routing work and local-model inference across a swarm of Macs.
- **Connect other agent clients** through Peel's MCP and OpenAI-compatible APIs.

## The core workflow

1. Add or select a repository.
2. Index it so Peel and its agents can search the code by meaning, not only by filename.
3. Choose an agent workflow or describe a task from an MCP client.
4. Peel creates an isolated worktree and streams the run into the Inbox.
5. Review the plan, output, diff, checks, and pull request before deciding what lands.

The repository stays at the center. RAG, agents, worktrees, schedules, and learnings all attach back to the code they are meant to improve.

## A quick tour

| Area | What it is for |
|---|---|
| **Home** | A command center for current work, repository health, and swarm activity. |
| **Work** | The Inbox, agent-run details, long tasks, and everything waiting for attention. |
| **Boards** | GitHub Projects as a dispatch surface for agent work. |
| **Repos** | Repositories, branches, PRs, RAG, graphs, skills, and worktrees. |
| **Agents** | Workflow templates, schedules, patrols, specialist agents, plugins, and skill packs. |
| **Observe** | Swarm state, models, GPU routing, analytics, RAG health, traffic, replay, and knowledge. |

The [Feature Guide](FEATURES.md) explains each area in practical terms and suggests where to begin.

## What is a swarm?

A swarm is a group of Macs running Peel together. Each Mac becomes a **worker** that advertises its repositories, hardware, models, and availability. Peel can send a task to the machine best equipped to perform it, share reusable repository analysis, or route local-model inference to a stronger GPU.

You can use Peel entirely on one Mac. A local LAN swarm does not require an account; account sign-in and invite links let machines coordinate across networks.

See [What is a swarm, and how do I join one?](SWARMS.md) for the setup path.

## Install

1. Open the [latest Peel release](https://github.com/cloke/peel-releases/releases/latest).
2. Download the `.dmg` file.
3. Open it and drag **Peel** into **Applications**.
4. Launch Peel.

The app and DMG are signed with Developer ID, notarized by Apple, and distributed with SHA-256 checksums. Peel uses a signed Sparkle feed for future updates.

## Connect an agent client

Peel exposes more than 300 tools from its local MCP server at `http://127.0.0.1:8765/rpc`. Tools cover repositories, git, GitHub, RAG, agent chains, worktrees, swarms, insights, UI automation, and diagnostics.

```json
{
  "mcpServers": {
    "peel": {
      "url": "http://127.0.0.1:8765/rpc"
    }
  }
}
```

Tool schemas use progressive discovery so clients load common capabilities first and fetch specialized schemas only when needed.

## Project history

The codebase began on **December 19, 2020** as a small SwiftUI developer-tool experiment. It grew into a Git, GitHub, Homebrew, and agent workspace, then became **Peel** on January 17, 2026 as its repository intelligence and distributed-agent direction took shape.

Peel 2.0.0, published July 14, 2026, was the first signed and notarized public binary release.

## Release integrity

Each release includes:

- a signed and notarized drag-to-Applications DMG;
- a signed ZIP used by the in-app updater;
- a Sparkle appcast;
- SHA-256 checksums for the DMG and ZIP.

Release notes identify the exact source commit embedded in the build.
