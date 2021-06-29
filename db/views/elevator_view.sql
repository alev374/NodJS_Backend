DROP MATERIALIZED VIEW IF EXISTS elevator_view;

CREATE MATERIALIZED VIEW elevator_view
AS

SELECT elevator.elev_id,
elevator.elev_serial_number, 
elevator.elev_barcode, 
elevator.elev_manufacturer, 
elevator.elev_build_year, 
elevator.elev_location, 
elevator.elev_type, 
elevator.elev_is_active, 
elevator.elev_emergency_information,
elevator.elev_inspection_days,
checklist.elev_checklist, 
checkpoints.elev_chpoints,
estate.elev_estate, 
inspector.elev_inspector,
substitute.elev_substitute,
inspector_short.elev_inspector_short,
substitute_short.elev_substitute_short,
reports.elev_reports,
elevator.elev_last_inspection,
elevator.elev_creation,
elevator.elev_last_updated,
elevator.elev_fulltext
FROM elevator
-- join checkpoints
LEFT JOIN
(
    SELECT elev_id, jsonb_agg(checkpoints.checkpoint_object ORDER BY checkpoints.idx) as elev_chpoints
    FROM
    (
        SELECT checkpoint_order.i as idx, checkpoint_order.elev_id, json_build_object('chpo_id', checkpoint.chpo_id, 'chpo_headline', chpo_headline, 'chpo_description', chpo_description, 'chpo_long_description', chpo_long_description, 'chpo_emergency_description', chpo_emergency_description, 'chpo_priority', chpr_description) as checkpoint_object
        FROM checkpoint
        LEFT JOIN checkpoint_priority_config
        ON checkpoint.chpo_priority = checkpoint_priority_config.chpr_priority
        LEFT JOIN
        (
            SELECT generate_series(0, jsonb_array_length(elev_chpoints) - 1 ) AS i, jsonb_array_elements(elev_chpoints) ->> 'chpo_id' chpo_id, elev_id
            FROM elevator
        ) checkpoint_order
        ON checkpoint.chpo_id = checkpoint_order.chpo_id
        ORDER BY checkpoint_order.i
    ) checkpoints
    WHERE elev_id IS NOT NULL 
    GROUP BY elev_id
) AS checkpoints
ON elevator.elev_id = checkpoints.elev_id
-- join checklist
LEFT JOIN
(
    SELECT elevator.elev_id, json_build_object('chli_id', content.chli_id, 'chli_name', content.chli_name, 'chli_checkpoints', content.chli_checkpoints) as elev_checklist
    FROM elevator
    LEFT JOIN 
    (
        SELECT chli_id, chli_name, jsonb_agg(checkpoints.checkpoint_object ORDER BY checkpoints.idx) as chli_checkpoints
        FROM
        (
            SELECT checkpoint_order.i as idx, checkpoint_order.chli_id, checkpoint_order.chli_name, json_build_object('chpo_id', checkpoint.chpo_id, 'chpo_headline', chpo_headline, 'chpo_description', chpo_description, 'chpo_long_description', chpo_long_description, 'chpo_emergency_description', chpo_emergency_description, 'chpo_priority', chpr_description) as checkpoint_object
            FROM checkpoint
            LEFT JOIN checkpoint_priority_config
            ON checkpoint.chpo_priority = checkpoint_priority_config.chpr_priority
            LEFT JOIN
            (
                SELECT generate_series(0, jsonb_array_length(chli_checkpoints) - 1 ) AS i, jsonb_array_elements(checklist.chli_checkpoints) ->> 'chpo_id' chpo_id, chli_id, chli_name
                FROM checklist
                ) checkpoint_order
            ON checkpoint.chpo_id = checkpoint_order.chpo_id
            ORDER BY checkpoint_order.i
            ) checkpoints
        WHERE chli_id IS NOT NULL 
        GROUP BY chli_id, chli_name
    ) AS content
    ON elevator.chli_id = content.chli_id
) AS checklist
ON elevator.elev_id = checklist.elev_id
-- join estate
LEFT JOIN
(
    SELECT elevator.elev_id, json_build_object('esta_id', estate.esta_id, 'esta_address', esta_address, 'esta_facility_manager', esta_facility_manager, 'esta_approach', esta_approach, 'esta_stakeholders', stakeholders.esta_stakeholders) as elev_estate 
    FROM elevator
    LEFT JOIN estate
    ON elevator.esta_id = estate.esta_id
    LEFT JOIN
    (
        SELECT estate.esta_id, jsonb_agg(content.obj) as esta_stakeholders 
        FROM estate
        LEFT JOIN estate_stakeholder
        ON estate.esta_id = estate_stakeholder.esta_id
        LEFT JOIN 
        (
            SELECT person.pers_id, json_build_object('pers_id', person.pers_id, 'pers_firstname', pers_firstname, 'pers_lastname', pers_lastname, 'pers_addresses', pers_addresses, 'pers_email_addresses', pers_email_addresses, 'pers_scope', person_role_config.pero_scope) as obj
            FROM person
            LEFT JOIN estate_stakeholder
            ON person.pers_id = estate_stakeholder.pers_id
            LEFT JOIN person_role_config
            ON person.pers_scope = person_role_config.pero_id
            GROUP BY person.pers_id, person_role_config.pero_scope
        ) AS content
        ON estate_stakeholder.pers_id = content.pers_id
        WHERE content.obj IS NOT NULL
        GROUP BY estate.esta_id
    ) AS stakeholders
    ON estate.esta_id = stakeholders.esta_id
) AS estate
ON elevator.elev_id = estate.elev_id
-- join inspector
LEFT JOIN
(
    SELECT elevator.elev_id, content.obj as elev_inspector
    FROM elevator
    LEFT JOIN person
    ON elevator.pers_inspector_id = person.pers_id
    LEFT JOIN 
    (
        SELECT person.pers_id, json_build_object('pers_id', person.pers_id, 'pers_firstname', pers_firstname, 'pers_lastname', pers_lastname, 'pers_addresses', pers_addresses, 'pers_email_addresses', pers_email_addresses, 'pers_phone_numbers', pers_phone_numbers, 'pers_scope', person_role_config.pero_scope) as obj
        FROM person
        LEFT JOIN person_role_config
        ON person.pers_scope = person_role_config.pero_id
    ) AS content
    ON person.pers_id = content.pers_id
    WHERE content.obj IS NOT NULL
    -- GROUP BY elevator.elev_id
) AS inspector
ON elevator.elev_id = inspector.elev_id
-- join substitute
LEFT JOIN
(
    SELECT elevator.elev_id, content.obj as elev_substitute
    FROM elevator
    LEFT JOIN person
    ON elevator.pers_substitute_id = person.pers_id
    LEFT JOIN 
    (
        SELECT person.pers_id, json_build_object('pers_id', person.pers_id, 'pers_firstname', pers_firstname, 'pers_lastname', pers_lastname, 'pers_addresses', pers_addresses, 'pers_email_addresses', pers_email_addresses, 'pers_phone_numbers', pers_phone_numbers, 'pers_scope', person_role_config.pero_scope) as obj
        FROM person
        LEFT JOIN person_role_config
        ON person.pers_scope = person_role_config.pero_id
    ) AS content
    ON person.pers_id = content.pers_id
    WHERE content.obj IS NOT NULL
    -- GROUP BY elevator.elev_id
) AS substitute
ON elevator.elev_id = substitute.elev_id
-- join inspector_short
LEFT JOIN
(
    SELECT elevator.elev_id, content.obj as elev_inspector_short
    FROM elevator
    LEFT JOIN person
    ON elevator.pers_inspector_id = person.pers_id
    LEFT JOIN 
    (
        SELECT person.pers_id, json_build_object('pers_id', person.pers_id, 'pers_firstname', pers_firstname, 'pers_lastname', pers_lastname, 'pers_scope', person_role_config.pero_scope) as obj
        FROM person
        LEFT JOIN person_role_config
        ON person.pers_scope = person_role_config.pero_id
    ) AS content
    ON person.pers_id = content.pers_id
    WHERE content.obj IS NOT NULL
    -- GROUP BY elevator.elev_id
) AS inspector_short
ON elevator.elev_id = inspector_short.elev_id
-- join substitute_short
LEFT JOIN
(
    SELECT elevator.elev_id, content.obj as elev_substitute_short
    FROM elevator
    LEFT JOIN person
    ON elevator.pers_substitute_id = person.pers_id
    LEFT JOIN 
    (
        SELECT person.pers_id, json_build_object('pers_id', person.pers_id, 'pers_firstname', pers_firstname, 'pers_lastname', pers_lastname, 'pers_scope', person_role_config.pero_scope) as obj
        FROM person
        LEFT JOIN person_role_config
        ON person.pers_scope = person_role_config.pero_id
    ) AS content
    ON person.pers_id = content.pers_id
    WHERE content.obj IS NOT NULL
    -- GROUP BY elevator.elev_id
) AS substitute_short
ON elevator.elev_id = substitute_short.elev_id
-- join reports
LEFT JOIN
(
    SELECT elevator.elev_id, array_to_json(reports.reports[0:10]) elev_reports FROM elevator
    LEFT JOIN
    (SELECT elevator.elev_id, array_agg(json_build_object('repo_id', reports.repo_id, 'repo_creation', reports.repo_creation, 'repo_checkpoints', reports.repo_checkpoints)) reports from elevator
        LEFT JOIN
        (
            SELECT repo_chpo_rel.elev_id, repo_chpo_rel.repo_id, repo_chpo_rel.repo_creation, jsonb_agg(json_build_object('chpo_id', checkpoint.chpo_id, 'chpo_headline', checkpoint.chpo_headline, 'chpo_is_ok', repo_chpo_rel.chpo_is_ok)) repo_checkpoints
            FROM checkpoint
            LEFT JOIN
            (
                SELECT report.repo_id, report.repo_elevator ->> 'elev_id' elev_id, report.repo_creation, jsonb_array_elements(report.repo_checkpoints) ->> 'chpo_id' chpo_id, jsonb_array_elements(report.repo_checkpoints) ->> 'chpo_is_ok' chpo_is_ok
                FROM report
                ) AS repo_chpo_rel
            ON repo_chpo_rel.chpo_id = checkpoint.chpo_id
            GROUP BY repo_chpo_rel.repo_id, elev_id, repo_chpo_rel.repo_creation
            ORDER BY repo_chpo_rel.repo_creation DESC
        ) reports
        ON elevator.elev_id = reports.elev_id
        GROUP BY elevator.elev_id
    ) reports
    ON elevator.elev_id = reports.elev_id
) AS reports
ON elevator.elev_id = reports.elev_id
ORDER BY estate.elev_estate -> 'esta_address' ->> 'address_zipcode', estate.elev_estate -> 'esta_address' ->> 'address_street_name', estate.elev_estate -> 'esta_address' ->> 'address_street_number'

WITH DATA;

REFRESH MATERIALIZED VIEW elevator_view;