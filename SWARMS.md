# What Is a Peel Swarm?

A **swarm** is a group of Macs running Peel together. Each Mac joins as a worker and advertises what it can contribute: its repositories, its hardware, and the local models it has.

Peel can then run an agent task on the Mac that already has the repository, move local-model inference to a stronger GPU, and share repository analysis so the same work isn't done twice. You get one view across all of it.

You do **not** need a swarm to use Peel. Start with one Mac and add another when you want more capacity, an always-on worker, or access to repositories and models elsewhere.

## Local or cross-network

Macs on the same local network can participate without account sign-in. Choose **Not now** at the sign-in prompt and start the local swarm.

For durable membership, invite links, and coordination across networks, sign in with an available account provider. Peel uses Firestore for small coordination records like membership and worker state. Real-time and bulk peer traffic travels over Iroh instead. Source code and bulk data never go through Firestore.

## Create a swarm

On the first Mac:

1. Open **Peel → Settings → Swarm**.
2. Sign in, or choose **Not now** for local-LAN-only use.
3. Give the Mac a recognizable name under **This Device**.
4. Under **My Swarms**, click **Create Swarm…** and choose a name.
5. Click **Join Swarm** so the Mac registers as a worker.
6. Optionally enable **Join swarm automatically on launch**.
7. Set a **Swarm Clone Root** if peers may offer repositories this Mac does not have.

Open **Swarm Console** to see the swarm, this device, and reachable peers.

## Invite another Mac or person

Owners and admins can issue invites:

1. Open the swarm in **Swarm Console** and click **Invite**. You can also use **Settings → Swarm → My Swarms → Invite**.
2. Share the URL or QR code.
3. Check its expiration and usage limit.
4. Revoke it from the **Invites** tab when it is no longer needed.

An invite does not grant immediate execution access. New members remain pending until approved.

## Join an existing swarm

On the joining Mac:

1. Install and open Peel.
2. Open the invite URL or scan its QR code.
3. Sign in when prompted. Peel preserves an invite received before authentication and processes it afterward.
4. Complete the join request.
5. Open **Settings → Swarm** and click **Join Swarm** to register the Mac as a worker.
6. Wait for an owner or admin to approve the membership.

On the owner/admin Mac:

1. Open the swarm's **Members** tab.
2. Find the account or machine under **Pending**.
3. Choose **Approve** to admit it as a contributor, or **Reject** to deny it.

After approval, the worker appears under **Peer Machines** and can receive eligible work.

## Confirm the connection

In **Swarm Console**, verify:

- **This Device** has a green status and shows **Stop** rather than **Join Swarm**.
- **Peer Machines** lists the other Mac with a recent heartbeat.
- The header reports connected peers.
- The swarm's **Channel** records worker and task activity.

Use **Observe → Swarm → Dashboard** for hardware and topology, or **Swarm Traffic** for a live network view.

## Send the first task

1. Select the repository in **Repos**.
2. Open its swarm status control.
3. Enable **Accept Tasks** on a worker that has the repository.
4. If a peer needs to clone it, configure that peer's **Swarm Clone Root** first.
5. Launch from **Agents → Templates**, **Boards**, or an MCP client.

Peel picks an eligible worker based on who has the repository, what hardware and models they have, and how busy they are. The run appears in **Work → Inbox** no matter which Mac performs it.

## Safety and control

- Pending members cannot execute work or access shared RAG indexes.
- Owners and admins can revoke invites and reject requests.
- Each repository can remain local or be made available independently.
- Agent runs still use isolated git worktrees and review gates.
- Stopping the swarm does not delete repositories or run history.

## Troubleshooting

### I joined but still see Awaiting Approval

An owner or admin must approve the request from the swarm's **Members** tab.

### The other Mac does not appear

Check that both Macs are approved members of the same swarm and that both have clicked **Join Swarm**. Then confirm they're on a current Peel build with network access and recent heartbeats. Peer paths connect lazily, so the first task or peer operation may be what establishes the connection.

### No worker can take a task

At least one fresh worker must accept tasks for the repository and have the necessary agent CLI or model. Set a clone root before offering a missing repository to a peer.

### Search differs between Macs

Open **Observe → RAG Health** and compare the two Macs. Check index freshness and embedding coverage first, then whether they're running the same embedding model.
