-- Observation: shipments observed as late in snapshots captured during the night shift
-- Use the 16:00 UTC cutoff so all snapshots are available
SELECT DISTINCT s.shipment_id, s.cpt
FROM shipment_snapshots s
WHERE s.status = 'missed_cpt'
  AND s.warehouse = 'WH-A'
  AND s.available_at <= '2026-11-06 16:00:00+00'
  AND s.snapshot_time >= '2026-11-06 01:00:00+00'
  AND s.snapshot_time <  '2026-11-06 13:00:00+00'
ORDER BY s.cpt;
