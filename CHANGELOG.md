# Changelog

Notable user-visible changes to Peel are recorded here. Peel is in active development, so this
changelog follows public signed releases rather than every internal commit.

## Unreleased

### Documentation

- Added a public product overview, a complete feature map, and a task-focused swarm onboarding
  guide.
- Published the product page at https://cloke.github.io/peel-releases/, served from the
  `gh-pages` branch. Screenshots are still pending, so the page carries `robots noindex` until
  they land.
- Added `scripts/publish-page.sh`, which rebuilds `gh-pages` from `docs/` and refuses to publish
  if the content fails a denylist and OCR check.

## 2.0.0 - 2026-07-14

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

[Download Peel 2.0.0](https://github.com/cloke/peel-releases/releases/tag/v2.0.0)

## Project milestones

- **2026-01-17.** The application was renamed Peel, once repository intelligence and agent
  orchestration became the product focus.
- **2020-12-19.** The codebase began as a SwiftUI developer-tool experiment.
