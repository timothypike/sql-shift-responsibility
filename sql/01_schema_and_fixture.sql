-- Table definition
CREATE TABLE shipment_snapshots (
  snapshot_time  TIMESTAMP WITH TIME ZONE NOT NULL,
  shipment_id    TEXT NOT NULL,
  warehouse      TEXT NOT NULL,
  cpt            TIMESTAMP WITH TIME ZONE NOT NULL,
  promise_date   DATE,
  status         TEXT NOT NULL,
  available_at   TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Fixture data (14 rows)
INSERT INTO shipment_snapshots VALUES
  -- SHP-001: CPT 03:00 UTC, three snapshots (in_progress → missed_cpt → ready)
  ('2026-11-06 02:00:00+00', 'SHP-001', 'WH-A', '2026-11-06 03:00:00+00', '2026-11-06', 'in_progress',  '2026-11-06 02:01:00+00'),
  ('2026-11-06 04:00:00+00', 'SHP-001', 'WH-A', '2026-11-06 03:00:00+00', '2026-11-06', 'missed_cpt', '2026-11-06 04:01:00+00'),
  ('2026-11-06 12:00:00+00', 'SHP-001', 'WH-A', '2026-11-06 03:00:00+00', '2026-11-06', 'ready',      '2026-11-06 12:01:00+00'),
  -- SHP-002: CPT 09:00 UTC, two snapshots (in_progress → missed_cpt, miss AFTER CPT)
  ('2026-11-06 02:00:00+00', 'SHP-002', 'WH-A', '2026-11-06 09:00:00+00', '2026-11-07', 'in_progress',  '2026-11-06 02:01:00+00'),
  ('2026-11-06 10:00:00+00', 'SHP-002', 'WH-A', '2026-11-06 09:00:00+00', '2026-11-07', 'missed_cpt', '2026-11-06 10:01:00+00'),
  -- SHP-003: CPT exactly at shift boundary 13:00 UTC, two snapshots
  ('2026-11-06 04:00:00+00', 'SHP-003', 'WH-A', '2026-11-06 13:00:00+00', '2026-11-06', 'in_progress',  '2026-11-06 04:01:00+00'),
  ('2026-11-06 13:01:00+00', 'SHP-003', 'WH-A', '2026-11-06 13:00:00+00', '2026-11-06', 'missed_cpt', '2026-11-06 13:02:00+00'),
  -- SHP-004: CPT 05:00 UTC, late snapshot (two identical rows = duplicate delivery)
  ('2026-11-06 10:00:00+00', 'SHP-004', 'WH-A', '2026-11-06 05:00:00+00', '2026-11-06', 'missed_cpt', '2026-11-06 14:00:00+00'),
  ('2026-11-06 10:00:00+00', 'SHP-004', 'WH-A', '2026-11-06 05:00:00+00', '2026-11-06', 'missed_cpt', '2026-11-06 14:00:00+00'),
  -- SHP-005: Different warehouse WH-B
  ('2026-11-06 04:00:00+00', 'SHP-005', 'WH-B', '2026-11-06 04:00:00+00', '2026-11-06', 'missed_cpt', '2026-11-06 04:01:00+00'),
  -- SHP-006: CPT 02:00 UTC, promise date Nov 8
  ('2026-11-06 04:00:00+00', 'SHP-006', 'WH-A', '2026-11-06 02:00:00+00', '2026-11-08', 'missed_cpt', '2026-11-06 04:01:00+00'),
  -- SHP-007: CPT in preceding day shift, observed as missed during night shift
  ('2026-11-06 04:00:00+00', 'SHP-007', 'WH-A', '2026-11-05 22:00:00+00', '2026-11-06', 'missed_cpt', '2026-11-06 04:01:00+00'),
  -- SHP-008: Non-missed, in_progress
  ('2026-11-06 04:00:00+00', 'SHP-008', 'WH-A', '2026-11-06 06:00:00+00', '2026-11-06', 'in_progress',  '2026-11-06 04:01:00+00'),
  -- SHP-009: CPT exactly at shift start 01:00 UTC
  ('2026-11-06 04:00:00+00', 'SHP-009', 'WH-A', '2026-11-06 01:00:00+00', '2026-11-06', 'missed_cpt', '2026-11-06 04:01:00+00');
