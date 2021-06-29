-- // Adding new elev_chpoints field with current checkpoint-elevator relation
ALTER TABLE public.elevator
ADD COLUMN elev_chpoints jsonb;

UPDATE public.elevator as el
set elev_chpoints = ch.chli_checkpoints || el.elev_checkpoints
	
FROM
	public.checklist as ch 
    WHERE ch.chli_id = el.chli_id;

ALTER TABLE public.checkpoint
ADD COLUMN chpo_sort integer;

-- //The sequence is created and used to set starting values, incremental values, max & min values

create sequence public.checkpoint_chpo_sort_seq
INCREMENT 1
    START 0
    MINVALUE 0
    MAXVALUE 9223372036854775807
    CACHE 1;

-- //Then the created sequence is set to the new column we created.

UPDATE public.checkpoint
set chpo_sort = nextval('checkpoint_chpo_sort_seq');

ALTER TABLE public.estate
ADD COLUMN esta_created_by text;

ALTER TABLE public.elevator
ADD COLUMN elev_created_by text;

ALTER TABLE public.person
ADD COLUMN pers_created_by text;

ALTER TABLE public.checkpoint 
    ADD COLUMN chpo_default BOOLEAN DEFAULT FALSE;

CREATE TABLE person_selfmanaged_limit (
    pers_id text NOT NULL,
    pese_elevator_limit int,
    pese_estate_limit int,
    pese_user_limit int,
    pese_elevator_created int,
    pese_estate_created int,
    pese_user_created int,
    CONSTRAINT person_selfmanaged_limit_ak_1 UNIQUE (pers_id) NOT DEFERRABLE  INITIALLY IMMEDIATE
);

-- delete elevator

CREATE OR REPLACE FUNCTION elevator_delete()
RETURNS trigger AS
$BODY$
BEGIN
	DELETE FROM access_log
	WHERE access_log.aclo_content_id = OLD.elev_id;
	DELETE FROM elevator_checkpoint_relation
	WHERE elevator_checkpoint_relation.elev_id = OLD.elev_id;
	UPDATE person_selfmanaged_limit SET 
	pese_elevator_created = pese_elevator_created - 1
	WHERE pers_id = OLD.elev_created_by;
	RETURN OLD;
END;
$BODY$ LANGUAGE 'plpgsql';


DROP TRIGGER IF EXISTS elevator_deleted on elevator;
CREATE TRIGGER elevator_deleted
BEFORE DELETE
ON elevator
FOR EACH ROW
EXECUTE PROCEDURE elevator_delete();

-- delete estate

CREATE OR REPLACE FUNCTION estate_delete()
RETURNS trigger AS
$BODY$
BEGIN
	DELETE FROM access_log
	WHERE access_log.aclo_content_id = OLD.esta_id;
	DELETE FROM estate_stakeholder
	WHERE estate_stakeholder.esta_id = OLD.esta_id;
	DELETE FROM elevator
	WHERE elevator.esta_id = OLD.esta_id;
	UPDATE person_selfmanaged_limit SET 
	pese_estate_created = pese_estate_created - 1
	WHERE pers_id = OLD.esta_created_by;
	RETURN OLD;
END;
$BODY$ LANGUAGE 'plpgsql';


DROP TRIGGER IF EXISTS estate_deleted on estate;
CREATE TRIGGER estate_deleted
BEFORE DELETE
ON estate
FOR EACH ROW
EXECUTE PROCEDURE estate_delete();

-- after person_selfmanaged insert

CREATE OR REPLACE FUNCTION person_selfmanaged_after_insert()
  RETURNS TRIGGER AS
$code$
BEGIN
	REFRESH MATERIALIZED VIEW checklist_view;
	REFRESH MATERIALIZED VIEW checkpoint_view;
	REFRESH MATERIALIZED VIEW elevator_view;
	REFRESH MATERIALIZED VIEW estate_view;
	REFRESH MATERIALIZED VIEW person_view;
	RETURN NEW;
END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS person_selfmanaged_after_insert_trg on person_selfmanaged_limit;
CREATE TRIGGER person_selfmanaged_after_insert_trg
AFTER INSERT OR UPDATE
ON person_selfmanaged_limit
FOR EACH ROW
EXECUTE PROCEDURE person_selfmanaged_after_insert();

-- delete person

CREATE OR REPLACE FUNCTION person_delete()
RETURNS trigger AS
$BODY$
BEGIN
	UPDATE elevator SET 
	pers_inspector_id = NULL
	WHERE pers_inspector_id = OLD.pers_id;
	UPDATE elevator SET 
	pers_substitute_id = NULL
	WHERE pers_substitute_id = OLD.pers_id;
	DELETE FROM access_log
	WHERE access_log.aclo_owner = OLD.pers_id OR access_log.aclo_content_id = OLD.pers_id;
	DELETE FROM person_selfmanaged_limit
	WHERE person_selfmanaged_limit.pers_id = OLD.pers_id;
	UPDATE person_selfmanaged_limit SET 
	pese_user_created = pese_user_created - 1
	WHERE pers_id = OLD.pers_created_by;
	RETURN OLD;
END;
$BODY$ LANGUAGE 'plpgsql';


DROP TRIGGER IF EXISTS person_deleted on person;
CREATE TRIGGER person_deleted
BEFORE DELETE
ON person
FOR EACH ROW
EXECUTE PROCEDURE person_delete();

-- Checkpoint View
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

--Elevator View

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

--estate View

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

--person View

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

-- Refresh All Views
REFRESH MATERIALIZED VIEW checklist_view;
REFRESH MATERIALIZED VIEW checkpoint_view;
REFRESH MATERIALIZED VIEW elevator_view;
REFRESH MATERIALIZED VIEW estate_view;
REFRESH MATERIALIZED VIEW person_view;

--Insert Owner Selfmanaged Role
INSERT INTO public.person_role_config("pero_id", "pero_scope") VALUES (5, 'owner_selfmanaged');

--Change Field Null Restriction
ALTER TABLE public.elevator ALTER COLUMN elev_checkpoints DROP not null;

ALTER TABLE public.estate ALTER COLUMN esta_facility_manager DROP not null;
