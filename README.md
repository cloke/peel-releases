# Peel

> Peel back the layers of your development environment.

Peel is a macOS workspace for developers who point AI coding agents at real repositories. Agent
runs, pull requests, and worktrees live in one place instead of five. You still decide what lands.

Peel is in active development and currently requires **macOS 26 (Tahoe)**.

[Download Peel](https://github.com/cloke/peel-releases/releases/latest) · [Explore every feature](FEATURES.md) · [Learn about swarms](SWARMS.md) · [Read the changelog](CHANGELOG.md)

## What Peel helps you do

- **Understand a repository.** Search by meaning, not just filename. Dependency graphs show what
  breaks if you change something.
- **Run agent workflows safely.** Every run gets its own git worktree. You see the diff and the
  checks before anything merges.
- **Keep one attention queue.** Finished runs, failures, and PRs waiting on review all land in the
  Inbox.
- **Automate recurring work.** Save a workflow as a template and put it on a schedule. Patrols
  keep going in the background.
- **Use hardware you already own.** Peel routes work across a swarm of Macs, including local model
  inference.
- **Connect the agents you already use.** Peel speaks MCP and the OpenAI API.

## The core workflow

1. Add or select a repository.
2. Index it, so Peel and its agents can search the code by meaning rather than filename.
3. Choose an agent workflow, or describe a task from an MCP client.
4. Peel creates an isolated worktree and streams the run into the Inbox.
5. Review what it did and decide whether it lands.

The repository stays at the center. Everything else hangs off the code it's meant to improve.

## A quick tour

| Area | What it is for |
|---|---|
| **Home** | Where you land. Current work and repository health at a glance. |
| **Work** | The Inbox, plus the detail on any run you want to dig into. |
| **Boards** | GitHub Projects, wired up so agents can pull work off them. |
| **Repos** | Everything about a repository. Branches, PRs, the search index, worktrees. |
| **Agents** | Templates and schedules. Plugins and skill packs live here too. |
| **Observe** | Swarm state, model routing, and whether any of it was worth it. |

The [Feature Guide](FEATURES.md) walks through each area and suggests where to begin.

## What is a swarm?

A swarm is a group of Macs running Peel together. Each one advertises what it has: repositories,
hardware, models. Peel sends a task to whichever machine is best equipped to run it, and can share
repository analysis so the same work isn't done twice.

One Mac works fine on its own. A swarm on your LAN doesn't need an account either. Signing in and
using invite links lets machines coordinate across networks.

See [What is a swarm, and how do I join one?](SWARMS.md) for the setup path.

## Install

1. Open the [latest Peel release](https://github.com/cloke/peel-releases/releases/latest).
2. Download the `.dmg` file.
3. Open it and drag **Peel** into **Applications**.
4. Launch Peel.

The app and DMG are signed with Developer ID and notarized by Apple, and we publish SHA-256
checksums for both. Updates come through a signed Sparkle feed.

## Connect an agent client

Peel runs a local MCP server at `http://127.0.0.1:8765/rpc` with more than 300 tools behind it.
They cover the same ground the app does: repositories and git, GitHub, code search, agent chains,
swarms, and diagnostics.

```json
{
  "mcpServers": {
    "peel": {
      "url": "http://127.0.0.1:8765/rpc"
    }
  }
}
```

Tool schemas use progressive discovery. Clients load the common capabilities first and fetch the
specialized schemas only when they need them.

## Project history

The codebase started on **December 19, 2020** as a small SwiftUI developer-tool experiment. It
grew into a workspace for Git, GitHub, and Homebrew, picked up agents along the way, and became
**Peel** on January 17, 2026 once the repository intelligence and distributed-agent direction took
shape.

Peel 2.0.0, published July 14, 2026, was the first signed and notarized public binary release.

## Release integrity

Every release ships four things:

- a signed and notarized drag-to-Applications DMG
- a signed ZIP that the in-app updater uses
- a Sparkle appcast
- SHA-256 checksums for the DMG and the ZIP

Release notes name the exact source commit embedded in the build.
