// Runs every query in sql/ against the fixture in an in-process PostgreSQL (PGlite)
// and checks the expected shipment IDs and edge cases. Exit code 1 on any failure.
import { PGlite } from '@electric-sql/pglite'
import { readFileSync } from 'node:fs'

const sql = (name) => readFileSync(new URL(`../sql/${name}`, import.meta.url), 'utf-8')
const pg = new PGlite()
await pg.exec(sql('01_schema_and_fixture.sql'))

const ids = async (file) => (await pg.query(sql(file))).rows.map((r) => r.shipment_id)
const q1 = await ids('02_responsibility_1300.sql')
const q2 = await ids('03_responsibility_1600.sql')
const q3 = await ids('04_observation_1600.sql')

let passed = 0
let failed = 0
const sameSet = (a, b) => JSON.stringify([...a].sort()) === JSON.stringify([...b].sort())
const check = (name, ok, detail = '') => {
  if (ok) passed++; else failed++
  console.log(`${ok ? 'PASS' : 'FAIL'}: ${name}${detail ? '  ' + detail : ''}`)
}

console.log('Responsibility at 13:00 UTC:', q1.length, q1.join(', '))
console.log('Responsibility at 16:00 UTC:', q2.length, q2.join(', '))
console.log('Observation at 16:00 UTC:  ', q3.length, q3.join(', '))
console.log()
check('Responsibility 13:00 = 4 shipments', sameSet(q1, ['SHP-001', 'SHP-002', 'SHP-006', 'SHP-009']), q1.join(','))
check('Responsibility 16:00 = 5 shipments', sameSet(q2, ['SHP-001', 'SHP-002', 'SHP-004', 'SHP-006', 'SHP-009']), q2.join(','))
check('Observation 16:00 = 6 shipments', sameSet(q3, ['SHP-001', 'SHP-002', 'SHP-004', 'SHP-006', 'SHP-007', 'SHP-009']), q3.join(','))
check('Shift-start boundary is inclusive (SHP-009, CPT 01:00)', q1.includes('SHP-009'))
check('Shift-end boundary is exclusive (SHP-003, CPT 13:00)', !q1.includes('SHP-003'))
check('Other warehouse excluded (SHP-005, WH-B)', !q1.includes('SHP-005'))
check('Duplicate delivery counted once (SHP-004)', q2.filter((x) => x === 'SHP-004').length === 1)
check('Later "ready" does not erase a historical miss (SHP-001)', q1.includes('SHP-001'))
check('Late-arriving snapshot excluded before it was available (SHP-004 at 13:00)', !q1.includes('SHP-004'))
check('Late-arriving snapshot included once available (SHP-004 at 16:00)', q2.includes('SHP-004'))
check('Observed but owned by previous shift (SHP-007 in observation only)', q3.includes('SHP-007') && !q2.includes('SHP-007'))
check('Snapshot after shift end is not an observation (SHP-003)', !q3.includes('SHP-003'))

console.log(`\nResults: ${passed} passed, ${failed} failed`)
process.exit(failed ? 1 : 0)
