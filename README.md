# SQL work sample: overnight shift responsibility

Two people ask about "the night shift" and need different answers. This repo shows how I'd write and check the SQL for both, using synthetic shipment snapshots. It's an independent work sample. All data is made up.

Full write-up: [timpike.dev/solutions/sql-evaluation](https://timpike.dev/solutions/sql-evaluation)

## The questions

- **Responsibility (shift lead at handover):** which shipments missed their deadline (CPT, critical pull time) during this shift? Ownership follows CPT, not promise date.
- **Observation (operations analyst):** which late states were seen in snapshots taken during this shift? This includes shipments owned by another shift.

## Rules the queries encode

| Rule | Why it matters |
|---|---|
| Shift window is half-open: `cpt >= shift_start AND cpt < shift_end` | A CPT exactly at handover belongs to the next shift |
| Report cutoff is inclusive: `available_at <= cutoff` | A snapshot counts only once the reporting system had it |
| A miss needs `snapshot_time >= cpt` and `available_at >= cpt` | A miss can't be recorded before the deadline passed |
| A later `ready` status does not erase an earlier miss | Keeping only the latest status per shipment hides real misses |
| Count each shipment once | Duplicate deliveries of the same snapshot must not double count |

Example shift: Nov 5 night shift, America/Phoenix (UTC-7, no daylight saving): 2026-11-06 01:00 to 13:00 UTC. The updated review is at 16:00 UTC.

## Expected results

| Query | Result |
|---|---|
| Responsibility, 13:00 UTC cutoff | 4: SHP-001, SHP-002, SHP-006, SHP-009 |
| Responsibility, 16:00 UTC cutoff | 5: adds SHP-004 (its snapshot arrived late) |
| Observation, 16:00 UTC cutoff | 6: adds SHP-007 (seen late, but owned by the previous shift) |

## Run it

Requires Node.js 20+. The test runs PostgreSQL in-process with [PGlite](https://pglite.dev), so no database install is needed.

```bash
npm ci
npm test
```

The test runs every file in `sql/` and checks the counts, the exact shipment IDs, and each edge case: shift-start and shift-end boundaries, warehouse filtering, duplicate delivery, late arrival, historical-miss preservation, and observed-versus-owned.

## Files

- `sql/01_schema_and_fixture.sql`: table definition and the 14-row fixture
- `sql/02_responsibility_1300.sql`, `sql/03_responsibility_1600.sql`: the responsibility query at each cutoff
- `sql/04_observation_1600.sql`: the observation query
- `test/verify.mjs`: runs the queries and asserts the results

## Scope

These queries answer "did any eligible snapshot ever show a miss?", so they don't select a latest state. A current-status report would pick the latest eligible snapshot per shipment, and would need an explicit tie-break for snapshots with equal timestamps.

MIT licensed.
