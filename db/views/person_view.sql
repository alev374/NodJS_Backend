DROP MATERIALIZED VIEW IF EXISTS person_view;

CREATE MATERIALIZED VIEW person_view
AS

SELECT person.pers_id,
person.pers_firstname,
person.pers_lastname,
person.pers_username,
person_role_config.pero_scope as pers_scope,
person.pers_addresses,
person.pers_phone_numbers,
person.pers_email_addresses,
person.pers_is_active,
estates.pers_estates,
inspector_elevators.pers_inspector_elevators,
substitute_elevators.pers_substitute_elevators,
stakeholder_elevators.pers_stakeholder_elevators,
reports.inspector_reports,
reports.substitute_reports,
reports.stakeholder_reports,
person.pers_creation,
person.pers_last_updated,
person.pers_fulltext,
person_selfmanaged_limit.pese_elevator_limit,
person_selfmanaged_limit.pese_estate_limit,
person_selfmanaged_limit.pese_user_limit,
person_selfmanaged_limit.pese_elevator_created,
person_selfmanaged_limit.pese_estate_created,
person_selfmanaged_limit.pese_user_created
FROM person
-- join person_role_confing
LEFT JOIN person_role_config
ON person.pers_scope = person_role_config.pero_id
-- join person_selfmanaged_limit
LEFT JOIN person_selfmanaged_limit
ON person.pers_id = person_selfmanaged_limit.pers_id
-- join estate
LEFT JOIN
(
    SELECT person.pers_id, jsonb_agg(content.obj) as pers_estates 
    FROM person
    LEFT JOIN estate_stakeholder
    ON person.pers_id = estate_stakeholder.pers_id
    LEFT JOIN 
    (
        SELECT estate.esta_id, json_build_object('esta_id', estate.esta_id, 'esta_address', esta_address) as obj
        FROM estate
        LEFT JOIN estate_stakeholder
        ON estate.esta_id = estate_stakeholder.esta_id
    ) AS content
    ON estate_stakeholder.esta_id = content.esta_id
    WHERE content.obj IS NOT NULL
    GROUP BY person.pers_id
) AS estates
ON person.pers_id = estates.pers_id
-- join inspector_elevators
LEFT JOIN
(
    SELECT person.pers_id, jsonb_agg(content.obj) as pers_inspector_elevators 
    FROM person
    LEFT JOIN elevator
    ON person.pers_id = elevator.pers_inspector_id
    LEFT JOIN 
    (
        SELECT elev_id, json_build_object('elev_id', elev_id, 'elev_serial_number', elev_serial_number, 'elev_barcode', elev_barcode, 'elev_type', elev_type, 'elev_address', esta_address, 'esta_approach', esta_approach, 'elev_location', elev_location, 'elev_inspection_days', elev_inspection_days, 'elev_last_inspection', elev_last_inspection) as obj
        FROM elevator
        LEFT JOIN estate
        ON elevator.esta_id = estate.esta_id
    ) AS content
    ON elevator.elev_id = content.elev_id
    WHERE content.obj IS NOT NULL
    GROUP BY person.pers_id
) AS inspector_elevators
ON person.pers_id = inspector_elevators.pers_id
-- join substitute_elevators
LEFT JOIN
(
    SELECT person.pers_id, jsonb_agg(content.obj) as pers_substitute_elevators 
    FROM person
    LEFT JOIN elevator
    ON person.pers_id = elevator.pers_substitute_id
    LEFT JOIN 
    (
        SELECT elev_id, json_build_object('elev_id', elev_id, 'elev_serial_number', elev_serial_number, 'elev_barcode', elev_barcode, 'elev_type', elev_type, 'elev_address', esta_address, 'elev_inspection_days', elev_inspection_days, 'elev_last_inspection', elev_last_inspection) as obj
        FROM elevator
        LEFT JOIN estate
        ON elevator.esta_id = estate.esta_id
    ) AS content
    ON elevator.elev_id = content.elev_id
    WHERE content.obj IS NOT NULL
    GROUP BY person.pers_id
) AS substitute_elevators
ON person.pers_id = substitute_elevators.pers_id
-- join stakeholder_elevators
LEFT JOIN(
    SELECT person.pers_id, jsonb_agg(json_build_object('elev_id', elev_id, 'elev_serial_number', elev_serial_number, 'elev_barcode', elev_barcode, 'elev_type', elev_type, 'elev_address', esta_address, 'elev_inspection_days', elev_inspection_days, 'elev_last_inspection', elev_last_inspection)) pers_stakeholder_elevators from person
    LEFT JOIN estate_stakeholder
    ON estate_stakeholder.pers_id = person.pers_id
    LEFT JOIN estate
    ON estate.esta_id = estate_stakeholder.esta_id
    LEFT JOIN elevator
    ON elevator.esta_id = estate.esta_id
    WHERE estate.esta_id IS NOT NULL
    GROUP BY person.pers_id, pers_username
) AS stakeholder_elevators
ON person.pers_id = stakeholder_elevators.pers_id
-- join reports
LEFT JOIN
(
    SELECT person.pers_id, insp.inspector_reports, subs.substitute_reports, stak.stakeholder_reports FROM person
    -- join inspector_reports
    LEFT JOIN
    (
        SELECT person.pers_id, jsonb_agg(content.obj) as inspector_reports
        FROM person
        LEFT JOIN elevator
        ON person.pers_id = elevator.pers_inspector_id
        LEFT JOIN 
        (
            SELECT elevator.elev_id, row_to_json(reports) as obj
            FROM elevator
            LEFT JOIN
            (
                SELECT repo_id, repo_elevator ->> 'elev_id' as elev_id, repo_estate -> 'esta_address' as esta_address, repo_creation FROM report
            ) as reports
            ON elevator.elev_id = reports.elev_id
        ) AS content
        ON elevator.elev_id = content.elev_id
        WHERE content.obj IS NOT NULL
        GROUP BY person.pers_id
    ) AS insp
    ON person.pers_id = insp.pers_id
    -- join substitute_reports
    LEFT JOIN
    (
        SELECT person.pers_id, jsonb_agg(content.obj) as substitute_reports
        FROM person
        LEFT JOIN elevator
        ON person.pers_id = elevator.pers_substitute_id
        LEFT JOIN 
        (
            SELECT elevator.elev_id, row_to_json(reports) as obj
            FROM elevator
            LEFT JOIN
            (
                SELECT repo_id, repo_elevator ->> 'elev_id' as elev_id, repo_estate -> 'esta_address' as esta_address, repo_creation FROM report
            ) as reports
            ON elevator.elev_id = reports.elev_id
        ) AS content
        ON elevator.elev_id = content.elev_id
        WHERE content.obj IS NOT NULL
        GROUP BY person.pers_id
    ) AS subs
    ON person.pers_id = subs.pers_id
    -- join stakeholder_reports
    LEFT JOIN
    (
        SELECT person.pers_id, jsonb_agg(content.obj) as stakeholder_reports
        FROM person
        LEFT JOIN estate_stakeholder
        ON person.pers_id = estate_stakeholder.pers_id
        LEFT JOIN estate
        ON estate_stakeholder.esta_id = estate.esta_id
        LEFT JOIN 
        (
            SELECT elevator.esta_id, row_to_json(reports) as obj
            FROM elevator
            LEFT JOIN
            (
                SELECT repo_id, repo_elevator ->> 'elev_id' as elev_id, repo_estate -> 'esta_address' as esta_address, repo_creation FROM report
            ) as reports
            ON elevator.elev_id = reports.elev_id
        ) AS content
        ON estate.esta_id = content.esta_id
        WHERE content.obj IS NOT NULL
        GROUP BY person.pers_id
    ) AS stak
ON person.pers_id = stak.pers_id
) AS reports
ON person.pers_id = reports.pers_id
ORDER BY person_role_config.pero_scope, person.pers_lastname, person.pers_firstname

WITH DATA;

REFRESH MATERIALIZED VIEW person_view;