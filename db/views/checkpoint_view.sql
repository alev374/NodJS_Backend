DROP MATERIALIZED VIEW IF EXISTS checkpoint_view;

CREATE MATERIALIZED VIEW checkpoint_view
AS

SELECT checkpoint.chpo_id,
checkpoint.chpo_headline, 
checkpoint.chpo_description,
checkpoint.chpo_long_description,
checkpoint.chpo_emergency_description,
checkpoint_priority_config.chpr_description as chpo_priority, 
checklists.chpo_checklists, 
elevators.chpo_elevators,
checkpoint.chpo_creation,
checkpoint.chpo_last_updated,
checkpoint.chpo_fulltext,
checkpoint.chpo_sort,
checkpoint.chpo_default
FROM checkpoint
-- join checklist_priority_config
LEFT JOIN checkpoint_priority_config
ON checkpoint.chpo_priority = checkpoint_priority_config.chpr_priority
-- join checklists
LEFT JOIN
(
	SELECT checkpoint.chpo_id, jsonb_agg(content.obj) as chpo_checklists 
	FROM checkpoint
	LEFT JOIN checklist_checkpoint_relation
	ON checkpoint.chpo_id = checklist_checkpoint_relation.chpo_id
	LEFT JOIN 
	(
		SELECT chli_id, json_build_object('chli_id', chli_id, 'chli_name', chli_name) as obj
		FROM checklist
	) AS content
	ON checklist_checkpoint_relation.chli_id = content.chli_id
	WHERE content.obj IS NOT NULL
	GROUP BY checkpoint.chpo_id
) AS checklists
ON checkpoint.chpo_id = checklists.chpo_id
-- join elevators
LEFT JOIN
(
	SELECT checkpoint.chpo_id, jsonb_agg(content.obj) as chpo_elevators
	FROM checkpoint
	LEFT JOIN elevator_checkpoint_relation
	ON checkpoint.chpo_id = elevator_checkpoint_relation.chpo_id
	LEFT JOIN 
	(
		SELECT elev_id, json_build_object('elev_id', elev_id, 'elev_serial_number', elev_serial_number, 'elev_barcode', elev_barcode, 'elev_type', elev_type, 'elev_address', esta_address) as obj
		FROM elevator
		LEFT JOIN estate
		ON elevator.esta_id = estate.esta_id
	) AS content
	ON elevator_checkpoint_relation.elev_id = content.elev_id
	WHERE content.obj IS NOT NULL
	GROUP BY checkpoint.chpo_id
) AS elevators
ON checkpoint.chpo_id = elevators.chpo_id
-- ORDER BY checkpoint.chpo_headline
ORDER BY checkpoint.chpo_sort

WITH DATA;
