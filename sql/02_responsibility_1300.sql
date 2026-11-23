-- Responsibility: any snapshot showing a miss, available by the 13:00 UTC handover cutoff
-- Historical miss: snapshot_time >= cpt AND available_at >= cpt (miss cannot precede deadline)
-- A later ready status does not erase the miss
SELECT DISTINCT s.shipment_id, s.cpt
FROM shipment_snapshots s
WHERE s.status = 'missed_cpt'
  AND s.warehouse = 'WH-A'
  AND s.available_at <= '2026-11-06 13:00:00+00'
  AND s.snapshot_time >= s.cpt
  AND s.available_at >= s.cpt
  AND s.cpt >= '2026-11-06 01:00:00+00'
  AND s.cpt <  '2026-11-06 13:00:00+00'
ORDER BY s.cpt;
