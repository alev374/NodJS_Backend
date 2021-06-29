DROP MATERIALIZED VIEW IF EXISTS checklist_view;

CREATE MATERIALIZED VIEW checklist_view
AS

SELECT checklist.chli_id,
checklist.chli_name,
checkpoints.chli_checkpoints, 
elevators.chli_elevators,
checklist.chli_creation,
checklist.chli_last_updated,
checklist.chli_fulltext
FROM checklist
-- join checkpoints
LEFT JOIN
(
	SELECT chli_id, jsonb_agg(checkpoints.checkpoint_object ORDER BY checkpoints.idx) as chli_checkpoints
	FROM
	(
		SELECT checkpoint_order.i as idx, checkpoint_order.chli_id, json_build_object('chpo_id', checkpoint.chpo_id, 'chpo_headline', chpo_headline, 'chpo_priority', chpr_description) as checkpoint_object
		FROM checkpoint
		LEFT JOIN checkpoint_priority_config
		ON checkpoint.chpo_priority = checkpoint_priority_config.chpr_priority
		LEFT JOIN
		(
			SELECT generate_series(0, jsonb_array_length(chli_checkpoints) - 1 ) AS i, jsonb_array_elements(checklist.chli_checkpoints) ->> 'chpo_id' chpo_id, chli_id
			FROM checklist
		) checkpoint_order
		ON checkpoint.chpo_id = checkpoint_order.chpo_id
		ORDER BY checkpoint_order.i
	) checkpoints
	WHERE chli_id IS NOT NULL 
	GROUP BY chli_id
) AS checkpoints
ON checklist.chli_id = checkpoints.chli_id
-- join elevators
LEFT JOIN
(
	SELECT checklist.chli_id, jsonb_agg(content.obj) as chli_elevators
	FROM checklist
	LEFT JOIN elevator
	ON checklist.chli_id = elevator.chli_id
	LEFT JOIN 
	(
		SELECT elev_id, json_build_object('elev_id', elev_id, 'elev_serial_number', elev_serial_number, 'elev_barcode', elev_barcode, 'elev_type', elev_type, 'elev_address', esta_address) as obj
		FROM elevator
		LEFT JOIN estate
		ON elevator.esta_id = estate.esta_id
	) AS content
	ON elevator.elev_id = content.elev_id
	WHERE content.obj IS NOT NULL
	GROUP BY checklist.chli_id
) AS elevators
ON checklist.chli_id = elevators.chli_id
ORDER BY checklist.chli_name, checklist.chli_creation

WITH DATA;
