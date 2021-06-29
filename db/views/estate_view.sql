DROP MATERIALIZED VIEW IF EXISTS estate_view;

CREATE MATERIALIZED VIEW estate_view
AS

SELECT estate.esta_id,
estate.esta_approach,
estate.esta_facility_manager,
estate.esta_address,
stakeholders.esta_stakeholders, 
elevators.esta_elevators,
reports.esta_reports,
estate.esta_creation, 
estate.esta_last_updated ,
estate.esta_fulltext
FROM estate
-- join stakeholders
LEFT JOIN
(
    SELECT estate.esta_id, jsonb_agg(content.obj) as esta_stakeholders 
    FROM estate
    LEFT JOIN estate_stakeholder
    ON estate.esta_id = estate_stakeholder.esta_id
    LEFT JOIN 
    (
        SELECT estate.esta_id, json_build_object('pers_id', person.pers_id, 'pers_firstname', pers_firstname, 'pers_lastname', pers_lastname, 'pers_addresses', pers_addresses, 'pers_email_addresses', pers_email_addresses, 'pers_scope', person_role_config.pero_scope) as obj
        FROM person
        LEFT JOIN estate_stakeholder
        ON person.pers_id = estate_stakeholder.pers_id
        LEFT JOIN person_role_config
        ON person.pers_scope = person_role_config.pero_id
        LEFT JOIN estate
        ON estate_stakeholder.esta_id = estate.esta_id
        WHERE estate.esta_id IS NOT NULL
    ) AS content
    ON estate_stakeholder.esta_id = content.esta_id
    WHERE content.obj IS NOT NULL
    GROUP BY estate.esta_id
) AS stakeholders
ON estate.esta_id = stakeholders.esta_id
-- join elevators
LEFT JOIN
(
    SELECT estate.esta_id, jsonb_agg(content.obj) as esta_elevators 
    FROM estate
    LEFT JOIN elevator
    ON estate.esta_id = elevator.esta_id
    LEFT JOIN 
    (
        SELECT elev_id, json_build_object('elev_id', elev_id, 'elev_serial_number', elev_serial_number, 'elev_barcode', elev_barcode, 'elev_type', elev_type, 'elev_address', esta_address) as obj
        FROM elevator
        LEFT JOIN estate
        ON elevator.esta_id = estate.esta_id
    ) AS content
    ON elevator.elev_id = content.elev_id
    WHERE content.obj IS NOT NULL
    GROUP BY estate.esta_id
) AS elevators
ON estate.esta_id = elevators.esta_id
-- join reports
LEFT JOIN
(
    SELECT estate.esta_id, jsonb_agg(content.obj ORDER BY content.repo_creation DESC) as esta_reports 
    FROM estate
    LEFT JOIN elevator
    ON estate.esta_id = elevator.esta_id
    LEFT JOIN report
    ON elevator.elev_id = report.repo_elevator ->> 'elev_id'
    LEFT JOIN 
    (
        SELECT report.repo_id, report.repo_creation, json_build_object('repo_id', report.repo_id, 'repo_elevator', report.repo_elevator, 'repo_creation', report.repo_creation) obj
        FROM report
        ORDER BY report.repo_creation DESC
        LIMIT 10
        ) AS content
    ON report.repo_id = content.repo_id
    WHERE content.obj IS NOT NULL
    GROUP BY estate.esta_id
) AS reports
ON estate.esta_id = reports.esta_id
ORDER BY 
estate.esta_address ->> 'address_zipcode', estate.esta_address ->> 'address_street_name', estate.esta_address ->> 'address_street_number'

WITH DATA;

REFRESH MATERIALIZED VIEW estate_view;