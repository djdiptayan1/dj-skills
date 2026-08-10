# Project Checkpoints — template

Copy this to the **root of the repository you want reviewed**, as `project-checkpoints.md`,
and replace the examples with your own. Every review agent in this suite reads it (alongside
`AGENTS.md`, `CLAUDE.md`, and `.cursorrules`) before reporting findings.

This file is where **your** hard-won, repo-specific knowledge lives — the bugs that already bit
you once. Keeping it here instead of inside the agent prompts is what lets the suite stay
portable: the agents ship the general craft, your repo ships its own scar tissue.

> Rule of thumb: if a checkpoint mentions a table name, a domain entity, a framework version,
> or a flow that only exists in your product — it belongs in this file, not in an agent prompt.

---

## How to write a checkpoint

Each entry needs three things, or an agent cannot act on it:

```markdown
### <Short name>
**Detect:** the observable pattern in the code — what to grep for, what shape to match.
**Why:** the incident or class of bug this prevents. One sentence.
**Correct form:** what the code should look like instead.
```

Keep the list short and real. A checkpoint that has never caught anything is noise; delete it.
Order by how much damage the bug did.

---

## Example: domain-model checkpoints

### Server-side validation of client-supplied references
**Detect:** a server action or API route that accepts an array of IDs from the client and uses
them directly in a write or a scoped query, without re-deriving ownership server-side.
**Why:** a client can submit IDs belonging to a tenant/org/campus it does not own.
**Correct form:** derive the parent scope from the session server-side, then verify every
supplied child ID belongs to it before the write. Never trust a client-selected list.

### Ownership chains
**Detect:** any query filtering on a leaf entity without walking its ownership chain.
**Why:** cross-tenant data leakage.
**Correct form:** validate the full chain for your domain. *Replace with yours*, e.g.
`Student -> Squad -> Batch -> Campus`, `User -> Team -> Org`, `Order -> Account -> Tenant`.

---

## Example: error-handling checkpoints

### Error swallowing vs. rethrowing
**Detect:** a `try/catch` around a database or infrastructure call that returns `null`,
`[]`, or `"skipped"` for **any** error.
**Why:** a connection failure becomes an empty result set, and the bug surfaces days later as
missing data rather than as an alert.
**Correct form:** rethrow genuine infrastructure/query errors so they fail loudly. Return a
custom default **only** for an explicit, expected "not found".

---

## Example: framework checkpoints

### Unstable dependencies passed to data-fetching components
**Detect:** an inline function or object literal passed as a prop/dependency to a component
that refetches on identity change.
**Why:** infinite refetch loop; usually found in production, by the database.
**Correct form:** memoize with `useCallback`/`useMemo`, or hoist the definition out of render.

### Toast semantics
**Detect:** a successful no-op reported with the `destructive` variant, or a failure reported
as `success`.
**Why:** users learn to ignore the toast.
**Correct form:** variant matches the outcome; the description says what actually happened.

---

## Example: query-scale checkpoints

### Unbounded `IN` / `whereIn` filters
**Detect:** a query that collects a large or unbounded set of IDs into memory and pushes them
into an `IN` clause, especially on a paginated path.
**Why:** the query grows with the table and eventually exceeds parameter limits or times out.
**Correct form:** a server-side `JOIN` or subquery, or chunked batches with a hard cap.

---

## Example: flow-consistency checkpoints

### Parallel flows must share validation
**Detect:** two entry points to the same operation — a manual flow and a bulk/CSV import, a UI
path and an API path — whose validation rules have drifted apart.
**Why:** the stricter path is bypassed by using the looser one.
**Correct form:** both call the same validation function. If one skips null references, the
other must too, and the shared rule lives in one place.

---

## Optional: conventions the reviewers should not fight

List anything the suite would otherwise flag that is a deliberate choice here:

- e.g. "We use `Result<T, E>` return values rather than exceptions at service boundaries."
- e.g. "Data-transfer types are plain structures by design — property chains over them are not
  Law-of-Demeter violations."
- e.g. "Snapshot tests in `src/emails/` are reviewed on every change; they are not stale."
