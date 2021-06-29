-- SET TIMEZONE

SET TIME ZONE 'Europe/Berlin';

DROP TABLE IF EXISTS access_log CASCADE;
DROP TABLE IF EXISTS checklist CASCADE;
DROP TABLE IF EXISTS checklist_checkpoint_relation CASCADE;
DROP TABLE IF EXISTS checkpoint CASCADE;
DROP TABLE IF EXISTS checkpoint_priority_config CASCADE;
DROP TABLE IF EXISTS elevator CASCADE;
DROP TABLE IF EXISTS elevator_checkpoint_relation CASCADE;
DROP TABLE IF EXISTS estate CASCADE;
DROP TABLE IF EXISTS estate_stakeholder CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS person_role_config CASCADE;
DROP TABLE IF EXISTS report CASCADE;
DROP TABLE IF EXISTS report_delivery_log CASCADE;
DROP TABLE IF EXISTS person_selfmanaged_limit CASCADE;

-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2017-08-29 11:24:48.945

-- tables
-- Table: access_log
CREATE TABLE access_log (
    aclo_id serial  NOT NULL,
    aclo_content_id text  NOT NULL,
    aclo_content_table text  NOT NULL,
    aclo_owner text  NOT NULL,
    CONSTRAINT access_log_ak_1 UNIQUE (aclo_content_id, aclo_owner, aclo_content_table) NOT DEFERRABLE  INITIALLY IMMEDIATE,
    CONSTRAINT access_log_pk PRIMARY KEY (aclo_id)
);

-- Table: checklist
CREATE TABLE checklist (
    chli_id text  NOT NULL,
    chli_name text  NOT NULL,
    chli_checkpoints jsonb  NOT NULL,
    chli_creation timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    chli_last_updated timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    chli_fulltext tsvector  NULL,
    CONSTRAINT checklist_ak_1 UNIQUE (chli_name) NOT DEFERRABLE  INITIALLY IMMEDIATE,
    CONSTRAINT checklist_pk PRIMARY KEY (chli_id)
);

-- Table: checklist_checkpoint_relation
CREATE TABLE checklist_checkpoint_relation (
    chli_id text  NOT NULL,
    chpo_id text  NOT NULL,
    CONSTRAINT checklist_checkpoint_relation_ak_1 UNIQUE (chli_id, chpo_id) NOT DEFERRABLE  INITIALLY IMMEDIATE
);

-- Table: checkpoint
CREATE TABLE checkpoint (
    chpo_id text  NOT NULL,
    chpo_headline text  NOT NULL,
    chpo_description text  NOT NULL,
    chpo_long_description text  NOT NULL,
    chpo_emergency_description text  NULL,
    chpo_priority int  NOT NULL,
    chpo_creation timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    chpo_last_updated timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    chpo_fulltext tsvector  NULL,
    chpo_sort int  NOT NULL,
    chpo_default boolean NOT NULL,
    CONSTRAINT checkpoint_pk PRIMARY KEY (chpo_id)
);

-- Table: checkpoint_priority_config
CREATE TABLE checkpoint_priority_config (
    chpr_id serial  NOT NULL,
    chpr_description text  NOT NULL,
    chpr_priority int  NOT NULL,
    CONSTRAINT checkpoint_priority_config_ak_1 UNIQUE (chpr_priority) NOT DEFERRABLE  INITIALLY IMMEDIATE,
    CONSTRAINT checkpoint_priority_config_pk PRIMARY KEY (chpr_id)
);

-- Table: elevator
CREATE TABLE elevator (
    elev_id text  NOT NULL,
    elev_serial_number text  NOT NULL,
    elev_barcode text  NOT NULL,
    elev_manufacturer text  NOT NULL,
    elev_build_year text  NOT NULL,
    elev_location text  NOT NULL,
    elev_type text  NOT NULL,
    elev_is_active boolean  NOT NULL,
    elev_emergency_information jsonb  NOT NULL,
    elev_inspection_days jsonb  NOT NULL,
    pers_inspector_id text  NULL,
    pers_substitute_id text  NULL,
    esta_id text  NOT NULL,
    chli_id text  NULL,
    elev_checkpoints jsonb  NOT NULL,
    elev_last_inspection timestamp  NULL,
    elev_creation timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    elev_last_updated timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    elev_fulltext tsvector  NULL,
    CONSTRAINT elevator_ak_1 UNIQUE (elev_barcode) NOT DEFERRABLE  INITIALLY IMMEDIATE,
    CONSTRAINT elevator_pk PRIMARY KEY (elev_id)
);

-- Table: elevator_checkpoint_relation
CREATE TABLE elevator_checkpoint_relation (
    elev_id text  NOT NULL,
    chpo_id text  NOT NULL,
    CONSTRAINT elevator_checkpoint_relation_ak_1 UNIQUE (elev_id, chpo_id) NOT DEFERRABLE  INITIALLY IMMEDIATE
);

-- Table: estate
CREATE TABLE estate (
    esta_id text  NOT NULL,
    esta_approach text  NOT NULL,
    esta_facility_manager jsonb  NOT NULL,
    esta_address jsonb  NOT NULL,
    esta_creation timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    esta_last_updated timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    esta_fulltext tsvector  NULL,
    CONSTRAINT estate_pk PRIMARY KEY (esta_id)
);

-- Table: estate_stakeholder
CREATE TABLE estate_stakeholder (
    pers_id text  NOT NULL,
    esta_id text  NOT NULL,
    CONSTRAINT estate_stakeholder_ak_1 UNIQUE (pers_id, esta_id) NOT DEFERRABLE  INITIALLY IMMEDIATE
);

-- Table: person
CREATE TABLE person (
    pers_id text  NOT NULL,
    pers_firstname text  NOT NULL,
    pers_lastname text  NOT NULL,
    pers_is_active boolean  NOT NULL,
    pers_addresses jsonb  NOT NULL,
    pers_username text  NOT NULL,
    pers_password text  NOT NULL,
    pers_phone_numbers jsonb  NOT NULL,
    pers_email_addresses jsonb  NOT NULL,
    pers_scope int  NOT NULL,
    pers_creation timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pers_last_updated timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pers_fulltext tsvector  NULL,
    CONSTRAINT person_ak_username UNIQUE (pers_username) NOT DEFERRABLE  INITIALLY IMMEDIATE,
    CONSTRAINT person_pk PRIMARY KEY (pers_id)
);

-- Table: person_role_config
CREATE TABLE person_role_config (
    pero_id serial  NOT NULL,
    pero_scope text  NOT NULL,
    CONSTRAINT person_role_ak_1 UNIQUE (pero_scope) NOT DEFERRABLE  INITIALLY IMMEDIATE,
    CONSTRAINT person_role_config_pk PRIMARY KEY (pero_id)
);

-- Table: person_selfmanaged_limit
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

-- Table: report
CREATE TABLE report (
    repo_id text  NOT NULL,
    repo_checkpoints jsonb  NOT NULL,
    repo_inspector jsonb  NOT NULL,
    repo_elevator jsonb  NOT NULL,
    repo_estate jsonb  NOT NULL,
    repo_creation timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    repo_last_updated timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    repo_fulltext tsvector  NULL,
    CONSTRAINT report_pk PRIMARY KEY (repo_id)
);

-- Table: report_delivery_log
CREATE TABLE report_delivery_log (
    redelo_id serial  NOT NULL,
    redelo_delivery_time timestamp  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pers_id text  NOT NULL,
    repo_id text  NOT NULL,
    CONSTRAINT report_delivery_log_ak_1 UNIQUE (pers_id, repo_id) NOT DEFERRABLE  INITIALLY IMMEDIATE,
    CONSTRAINT report_delivery_log_pk PRIMARY KEY (redelo_id)
);

-- foreign keys
-- Reference: checklist_checkpoint_relation_checklist (table: checklist_checkpoint_relation)
ALTER TABLE checklist_checkpoint_relation ADD CONSTRAINT checklist_checkpoint_relation_checklist
    FOREIGN KEY (chli_id)
    REFERENCES checklist (chli_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: checklist_checkpoint_relation_checkpoint (table: checklist_checkpoint_relation)
ALTER TABLE checklist_checkpoint_relation ADD CONSTRAINT checklist_checkpoint_relation_checkpoint
    FOREIGN KEY (chpo_id)
    REFERENCES checkpoint (chpo_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: elevator_checklist (table: elevator)
ALTER TABLE elevator ADD CONSTRAINT elevator_checklist
    FOREIGN KEY (chli_id)
    REFERENCES checklist (chli_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: elevator_checkpoint_relation_checkpoint (table: elevator_checkpoint_relation)
ALTER TABLE elevator_checkpoint_relation ADD CONSTRAINT elevator_checkpoint_relation_checkpoint
    FOREIGN KEY (chpo_id)
    REFERENCES checkpoint (chpo_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: elevator_checkpoint_relation_elevator (table: elevator_checkpoint_relation)
ALTER TABLE elevator_checkpoint_relation ADD CONSTRAINT elevator_checkpoint_relation_elevator
    FOREIGN KEY (elev_id)
    REFERENCES elevator (elev_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: elevator_estate (table: elevator)
ALTER TABLE elevator ADD CONSTRAINT elevator_estate
    FOREIGN KEY (esta_id)
    REFERENCES estate (esta_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: inspector (table: elevator)
ALTER TABLE elevator ADD CONSTRAINT inspector
    FOREIGN KEY (pers_inspector_id)
    REFERENCES person (pers_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: person_person_role_config (table: person)
ALTER TABLE person ADD CONSTRAINT person_person_role_config
    FOREIGN KEY (pers_scope)
    REFERENCES person_role_config (pero_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: report_delivery_log_report (table: report_delivery_log)
ALTER TABLE report_delivery_log ADD CONSTRAINT report_delivery_log_report
    FOREIGN KEY (repo_id)
    REFERENCES report (repo_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: substitute (table: elevator)
ALTER TABLE elevator ADD CONSTRAINT substitute
    FOREIGN KEY (pers_substitute_id)
    REFERENCES person (pers_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: user_estate_realtion_estate (table: estate_stakeholder)
ALTER TABLE estate_stakeholder ADD CONSTRAINT user_estate_realtion_estate
    FOREIGN KEY (esta_id)
    REFERENCES estate (esta_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: user_estate_realtion_user (table: estate_stakeholder)
ALTER TABLE estate_stakeholder ADD CONSTRAINT user_estate_realtion_user
    FOREIGN KEY (pers_id)
    REFERENCES person (pers_id)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.



-- CONTENT

INSERT INTO person_role_config (pero_scope) VALUES
('admin'),
('manager'),
('inspector'),
('owner')
;

INSERT INTO checkpoint_priority_config (chpr_description, chpr_priority) VALUES
('normal', 0),
('wichtig', 1),
('Verletzungsgefahr', 2)
;

INSERT INTO  person (
    pers_id,
    pers_firstname,
    pers_lastname,
    pers_is_active,
    pers_addresses,
    pers_username,
    pers_password,
    pers_phone_numbers,
    pers_email_addresses,
    pers_scope,
    pers_creation,
    pers_last_updated
)
VALUES
('q7n92lf60yLE3IuhHPZQ9SrkbtwbJOkHyAz', 'Maximilian', 'Lindsey', true, '[]', 'creator_admin', '$2a$15$IskvDQFJIM63nLNvT.hDd.rRX3bCs6nJfim7Obhj8fD14Q/yuSvuK', '[]', '[{"email_address": "tools@loveforpixels.com","email_type": "private","email_is_receiving": true,"email_notification_time": "12"}]', 1, '2017-05-22T17:00:00+02:00', '2017-05-22T17:00:00+02:00')
;


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
checkpoints.elev_checkpoints,
estate.elev_estate, 
inspector.elev_inspector,
substitute.elev_substitute,
inspector_short.elev_inspector_short,
substitute_short.elev_substitute_short,
reports.elev_reports,
elevator.elev_last_inspection,
elevator.elev_creation,
elevator.elev_last_updated,
elevator.elev_fulltext,
elevator.elev_chpoints
FROM elevator
-- join checkpoints
LEFT JOIN
(
    SELECT elev_id, jsonb_agg(checkpoints.checkpoint_object ORDER BY checkpoints.idx) as elev_checkpoints
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
    FROM es 
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
DROP MATERIALIZED VIEW IF EXISTS report_view;

CREATE MATERIALIZED VIEW report_view
AS

SELECT repo_id,
json_build_object('pers_id', repo_inspector ->> 'pers_id', 'pers_firstname', repo_inspector ->> 'pers_firstname', 'pers_lastname', repo_inspector ->> 'pers_lastname') as repo_inspector,
json_build_object('elev_id', repo_elevator ->> 'elev_id', 'elev_serial_number', repo_elevator ->> 'elev_serial_number', 'elev_barcode', repo_elevator ->> 'elev_barcode', 'elev_type', repo_elevator ->> 'elev_type') as repo_elevator,
json_build_object('esta_id', repo_estate ->> 'esta_id', 'esta_address', repo_estate -> 'esta_address') as repo_estate,
repo_creation
FROM report
ORDER BY repo_creation DESC


WITH DATA;


-- after checklist_checkpoint_relation insert
CREATE OR REPLACE FUNCTION checklist_relation_fulltext_update_function() RETURNS TRIGGER
AS
$code$
  BEGIN
	REFRESH MATERIALIZED VIEW checklist_view;
	REFRESH MATERIALIZED VIEW checkpoint_view;
	REFRESH MATERIALIZED VIEW elevator_view;
	REFRESH MATERIALIZED VIEW estate_view;
	REFRESH MATERIALIZED VIEW person_view;
  	UPDATE checklist
	SET  chli_fulltext = 
	 	 to_tsvector('german', '')
	;
	RETURN NEW;
  END;
$code$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS checklist_relation_fulltext_update_trigger on checklist;
DROP TRIGGER IF EXISTS checklist_relation_fulltext_update_trigger on checklist_checkpoint_relation;
CREATE TRIGGER checklist_relation_fulltext_update_trigger AFTER INSERT OR UPDATE
ON checklist_checkpoint_relation
FOR EACH ROW 
EXECUTE PROCEDURE
  checklist_relation_fulltext_update_function();
;
DROP INDEX IF EXISTS checklist_fulltext_index CASCADE;
CREATE INDEX checklist_fulltext_index ON checklist USING gin(chli_fulltext);


-- before checklist insert
CREATE OR REPLACE FUNCTION checklist_fulltext_update_function() RETURNS TRIGGER
AS
$code$
	BEGIN
	REFRESH MATERIALIZED VIEW checklist_view;
	NEW.chli_fulltext =
			to_tsvector('german', 	coalesce(NEW.chli_name, '')
			)
	;
	NEW.chli_last_updated = CURRENT_TIMESTAMP;
	RETURN NEW;
	END;
$code$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS checklist_fulltext_update_trigger on checklist;
CREATE TRIGGER checklist_fulltext_update_trigger BEFORE INSERT OR UPDATE
ON checklist
FOR EACH ROW 
EXECUTE PROCEDURE
  checklist_fulltext_update_function();
;

-- after checklist insert

CREATE OR REPLACE FUNCTION checklist_after_insert()
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

DROP TRIGGER IF EXISTS checklist_after_insert_trg on checklist;
CREATE TRIGGER checklist_after_insert_trg
  AFTER INSERT OR UPDATE
  ON checklist
  FOR EACH ROW
  EXECUTE PROCEDURE checklist_fulltext_update_function();
  -- EXECUTE PROCEDURE checklist_after_insert();


-- checklist_delete

CREATE OR REPLACE FUNCTION checklist_delete()
  RETURNS trigger AS
$BODY$
	BEGIN
		DELETE FROM access_log
		WHERE access_log.aclo_content_id = OLD.chli_id;
		DELETE FROM checklist_checkpoint_relation
		WHERE checklist_checkpoint_relation.chli_id = OLD.chli_id;
		UPDATE elevator SET 
		chli_id = NULL
		WHERE chli_id.chli_id = OLD.chli_id;
		RETURN OLD;
	END;
$BODY$ LANGUAGE 'plpgsql';


DROP TRIGGER IF EXISTS checklist_deleted on checklist;
CREATE TRIGGER checklist_deleted
  BEFORE DELETE
  ON checklist
  FOR EACH ROW
  EXECUTE PROCEDURE checklist_delete();

CREATE OR REPLACE FUNCTION checklist_after_delete()
  RETURNS TRIGGER AS
$code$
	BEGIN
		REFRESH MATERIALIZED VIEW checklist_view;
		REFRESH MATERIALIZED VIEW checkpoint_view;
		REFRESH MATERIALIZED VIEW elevator_view;
		REFRESH MATERIALIZED VIEW estate_view;
		REFRESH MATERIALIZED VIEW person_view;
	RETURN OLD;
END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS checklist_after_delete_trg on checklist;
CREATE TRIGGER checklist_after_delete_trg
  AFTER DELETE
  ON checklist
  FOR EACH ROW
  EXECUTE PROCEDURE checklist_after_delete();  

REFRESH MATERIALIZED VIEW checklist_view;
REFRESH MATERIALIZED VIEW checkpoint_view;
REFRESH MATERIALIZED VIEW elevator_view;
REFRESH MATERIALIZED VIEW estate_view;
REFRESH MATERIALIZED VIEW person_view;
-- before checkpoint insert
DROP INDEX IF EXISTS checkpoint_fulltext_index CASCADE;
CREATE INDEX checkpoint_fulltext_index ON checkpoint USING gin(chpo_fulltext);

CREATE OR REPLACE FUNCTION checkpoint_fulltext_update_function() RETURNS TRIGGER
AS
$code$
	BEGIN
		NEW.chpo_fulltext =
			to_tsvector('german', 	coalesce(NEW.chpo_headline, '')
			)
	;
	NEW.chpo_last_updated = CURRENT_TIMESTAMP;
	RETURN NEW;
	END;
$code$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS checkpoint_fulltext_update_trigger on checkpoint;
CREATE TRIGGER checkpoint_fulltext_update_trigger BEFORE INSERT OR UPDATE
ON checkpoint
FOR EACH ROW 
EXECUTE PROCEDURE
	checkpoint_fulltext_update_function();
;

-- after checkpoint insert

CREATE OR REPLACE FUNCTION checkpoint_after_insert()
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

DROP TRIGGER IF EXISTS checkpoint_after_insert_trg on checkpoint;
CREATE TRIGGER checkpoint_after_insert_trg
	AFTER INSERT OR UPDATE
	ON checkpoint
	FOR EACH ROW
	EXECUTE PROCEDURE checkpoint_after_insert();


-- delete checkpoint

CREATE OR REPLACE FUNCTION checkpoint_delete()
	RETURNS trigger AS
$BODY$
BEGIN
 	DELETE FROM access_log
 	WHERE access_log.aclo_content_id = OLD.chpo_id;
 	DELETE FROM checklist_checkpoint_relation
 	WHERE checklist_checkpoint_relation.chpo_id = OLD.chpo_id;
 	DELETE FROM elevator_checkpoint_relation
 	WHERE elevator_checkpoint_relation.chpo_id = OLD.chpo_id;
	UPDATE checklist
	SET chli_checkpoints = chli_checkpoints #- ('{' || checkpoints.i || '}')::text[]
	FROM
	(
	SELECT checklist.chli_id, i
	FROM checklist, generate_series(0, jsonb_array_length(chli_checkpoints) - 1 ) AS i
	WHERE (chli_checkpoints -> i)::text = '{"chpo_id": "' || OLD.chpo_id::text || '"}'
	) checkpoints
	WHERE checklist.chli_id = checkpoints.chli_id;
	UPDATE elevator
	SET elev_checkpoints = elev_checkpoints #- ('{' || checkpoints.i || '}')::text[]
	FROM
	(
	SELECT elevator.elev_id, i
	FROM elevator, generate_series(0, jsonb_array_length(elev_checkpoints) - 1 ) AS i
	WHERE (elev_checkpoints -> i)::text = '{"chpo_id": "' || OLD.chpo_id::text || '"}'
	) checkpoints
	WHERE elevator.elev_id = checkpoints.elev_id;
 RETURN OLD;
END;
$BODY$ LANGUAGE 'plpgsql';


DROP TRIGGER IF EXISTS checkpoint_deleted on checkpoint;
CREATE TRIGGER checkpoint_deleted
	BEFORE DELETE
	ON checkpoint
	FOR EACH ROW
	EXECUTE PROCEDURE checkpoint_delete();


CREATE OR REPLACE FUNCTION checkpoint_after_delete()
	RETURNS TRIGGER AS
$code$
	BEGIN
		REFRESH MATERIALIZED VIEW checklist_view;
		REFRESH MATERIALIZED VIEW checkpoint_view;
		REFRESH MATERIALIZED VIEW elevator_view;
		REFRESH MATERIALIZED VIEW estate_view;
		REFRESH MATERIALIZED VIEW person_view;
		RETURN OLD;
	END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS checkpoint_after_delete_trg on checkpoint;
CREATE TRIGGER checkpoint_after_delete_trg
	AFTER DELETE
	ON checkpoint
	FOR EACH ROW
	EXECUTE PROCEDURE checkpoint_after_delete();

REFRESH MATERIALIZED VIEW checklist_view;
REFRESH MATERIALIZED VIEW checkpoint_view;
REFRESH MATERIALIZED VIEW elevator_view;
REFRESH MATERIALIZED VIEW estate_view;
REFRESH MATERIALIZED VIEW person_view;
-- before elevator insert
CREATE OR REPLACE FUNCTION elevator_fulltext_update_function() RETURNS TRIGGER
AS
$code$
	BEGIN
	REFRESH MATERIALIZED VIEW elevator_view;
	NEW.elev_fulltext =
			to_tsvector('german', 	coalesce(NEW.elev_serial_number, '')
						|| ' ' ||	coalesce(elev.content, '')
			)
			FROM
			(
				SELECT coalesce(estate.address, '') as content
				FROM 
				(
					SELECT CAST(esta_address ->> 'address_street_name' as TEXT) || ' ' || CAST(esta_address ->> 'address_street_number' as TEXT) || ' ' || CAST(esta_address ->> 'address_city' as TEXT) || ' ' || CAST(esta_address ->> 'address_zipcode' as TEXT) || ' ' || CAST(esta_address ->> 'address_country' as TEXT) as address 
					FROM estate
					WHERE NEW.esta_id = estate.esta_id
					GROUP BY address
				) estate
			) elev
	;
	NEW.elev_last_updated = CURRENT_TIMESTAMP;
	RETURN NEW;
	END;
$code$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS elevator_fulltext_update_trigger on elevator;
CREATE TRIGGER elevator_fulltext_update_trigger BEFORE INSERT OR UPDATE
ON elevator
FOR EACH ROW 
EXECUTE PROCEDURE
  elevator_fulltext_update_function();
;

-- after elevator insert

CREATE OR REPLACE FUNCTION elevator_after_insert()
  RETURNS TRIGGER AS
$code$
BEGIN
	REFRESH MATERIALIZED VIEW elevator_view;
	REFRESH MATERIALIZED VIEW checkpoint_view;
	REFRESH MATERIALIZED VIEW checklist_view;
	REFRESH MATERIALIZED VIEW estate_view;
	REFRESH MATERIALIZED VIEW person_view;
	REFRESH MATERIALIZED VIEW report_view;
	DELETE FROM access_log
	WHERE access_log.aclo_content_id = NEW.elev_id;
	IF NEW.pers_inspector_id IS NOT NULL THEN
		INSERT INTO access_log (aclo_content_id, aclo_content_table, aclo_owner) VALUES
		(NEW.elev_id, 'elevator', NEW.pers_inspector_id)
		ON CONFLICT DO NOTHING;
	END IF;
	IF NEW.pers_substitute_id IS NOT NULL THEN
		INSERT INTO access_log (aclo_content_id, aclo_content_table, aclo_owner) VALUES
		(NEW.elev_id, 'elevator', NEW.pers_substitute_id)
		ON CONFLICT DO NOTHING;
	END IF;
	INSERT INTO access_log (aclo_content_id, aclo_content_table, aclo_owner)
	(
		SELECT NEW.elev_id, 'elevator', jsonb_array_elements(esta_stakeholders::jsonb) ->> 'pers_id' as aclo_owner
		FROM estate_view
		WHERE esta_id = NEW.esta_id

	)
	ON CONFLICT DO NOTHING
	;
	RETURN NEW;
END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS elevator_after_insert_trg on elevator;
CREATE TRIGGER elevator_after_insert_trg
  AFTER INSERT OR UPDATE
  ON elevator
  FOR EACH ROW
  EXECUTE PROCEDURE elevator_after_insert();

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


CREATE OR REPLACE FUNCTION elevator_after_delete()
	RETURNS TRIGGER AS
$code$
	BEGIN
		REFRESH MATERIALIZED VIEW checklist_view;
		REFRESH MATERIALIZED VIEW checkpoint_view;
		REFRESH MATERIALIZED VIEW elevator_view;
		REFRESH MATERIALIZED VIEW estate_view;
		REFRESH MATERIALIZED VIEW person_view;
		RETURN OLD;
	END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS elevator_after_delete_trg on elevator;
CREATE TRIGGER elevator_after_delete_trg
AFTER DELETE
ON elevator
FOR EACH ROW
EXECUTE PROCEDURE elevator_after_delete();

REFRESH MATERIALIZED VIEW checklist_view;
REFRESH MATERIALIZED VIEW checkpoint_view;
REFRESH MATERIALIZED VIEW elevator_view;
REFRESH MATERIALIZED VIEW estate_view;
REFRESH MATERIALIZED VIEW person_view;
-- after estate_stakeholder insert
CREATE OR REPLACE FUNCTION estate_stakeholder_fulltext_update_function() RETURNS TRIGGER
AS
$code$
  BEGIN
  REFRESH MATERIALIZED VIEW checklist_view;
	REFRESH MATERIALIZED VIEW checkpoint_view;
	REFRESH MATERIALIZED VIEW elevator_view;
	REFRESH MATERIALIZED VIEW estate_view;
	REFRESH MATERIALIZED VIEW person_view;
  	UPDATE estate
	SET  esta_fulltext = 
	 	 to_tsvector('german', '')
	;
	RETURN NEW;
  END;
$code$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS estate_stakeholder_fulltext_update_trigger on estate_stakeholder;
CREATE TRIGGER estate_stakeholder_fulltext_update_trigger AFTER INSERT OR UPDATE
ON estate_stakeholder
FOR EACH ROW 
EXECUTE PROCEDURE
  estate_stakeholder_fulltext_update_function();
;
-- before estate insert
CREATE OR REPLACE FUNCTION estate_fulltext_update_function() RETURNS TRIGGER
AS
$code$
	BEGIN
	NEW.esta_fulltext =
			to_tsvector('german', 	coalesce(NEW.esta_address ->> 'address_street_name', '')
						|| ' ' ||	coalesce(NEW.esta_address ->> 'address_zipcode', '')
						|| ' ' ||	coalesce(NEW.esta_address ->> 'address_city', '')
						|| ' ' ||	coalesce(NEW.esta_facility_manager ->> 'facility_manager_name', '')
			)
	;
	NEW.esta_last_updated = CURRENT_TIMESTAMP;
	RETURN NEW;
	END;
$code$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS estate_fulltext_update_trigger on estate;
CREATE TRIGGER estate_fulltext_update_trigger BEFORE INSERT OR UPDATE
ON estate
FOR EACH ROW 
EXECUTE PROCEDURE
  estate_fulltext_update_function();
;

-- estate_after_insert

CREATE OR REPLACE FUNCTION estate_after_insert()
  RETURNS TRIGGER AS
$code$
BEGIN
	REFRESH MATERIALIZED VIEW checklist_view;
	REFRESH MATERIALIZED VIEW checkpoint_view;
	REFRESH MATERIALIZED VIEW elevator_view;
	REFRESH MATERIALIZED VIEW estate_view;
	REFRESH MATERIALIZED VIEW person_view;
	INSERT INTO access_log (aclo_content_id, aclo_content_table, aclo_owner)
	(
		SELECT NEW.esta_id, 'estate', jsonb_array_elements(esta_stakeholders::jsonb) ->> 'pers_id' as aclo_owner
		FROM estate_view
		WHERE esta_id = NEW.esta_id

	)
	ON CONFLICT DO NOTHING;
	RETURN NEW;	
END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS estate_after_insert_trg on estate;
CREATE TRIGGER estate_after_insert_trg
  AFTER INSERT OR UPDATE
  ON estate
  FOR EACH ROW
  EXECUTE PROCEDURE estate_after_insert();

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


CREATE OR REPLACE FUNCTION estate_after_delete()
	RETURNS TRIGGER AS
$code$
	BEGIN
		REFRESH MATERIALIZED VIEW checklist_view;
		REFRESH MATERIALIZED VIEW checkpoint_view;
		REFRESH MATERIALIZED VIEW elevator_view;
		REFRESH MATERIALIZED VIEW estate_view;
		REFRESH MATERIALIZED VIEW person_view;
		RETURN OLD;
	END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS estate_delete_trg on elevator;
CREATE TRIGGER estate_delete_trg
AFTER DELETE
ON elevator
FOR EACH ROW
EXECUTE PROCEDURE estate_after_delete();

REFRESH MATERIALIZED VIEW checklist_view;
REFRESH MATERIALIZED VIEW checkpoint_view;
REFRESH MATERIALIZED VIEW elevator_view;
REFRESH MATERIALIZED VIEW estate_view;
REFRESH MATERIALIZED VIEW person_view;
-- person fulltext update

UPDATE person
SET pers_fulltext =
	to_tsvector('german',           coalesce(pers_firstname, '')
						  || ' ' || coalesce(pers_lastname, '') 
						  || ' ' || coalesce(pers_username, '')
			   )
;

-- before person insert

DROP INDEX IF EXISTS person_fulltext_index CASCADE;
CREATE INDEX person_fulltext_index ON person USING gin(pers_fulltext);

CREATE OR REPLACE FUNCTION person_fulltext_update_function() RETURNS TRIGGER
AS
$code$
  BEGIN
	NEW.pers_fulltext =
		  to_tsvector('german',     coalesce(NEW.pers_firstname, '')
						  || ' ' || coalesce(NEW.pers_lastname, '') 
						  || ' ' || coalesce(NEW.pers_username, '')
			   )
	;
	NEW.pers_last_updated = CURRENT_TIMESTAMP;
	RETURN NEW;
  END;
$code$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS person_fulltext_update_trigger on person;
CREATE TRIGGER person_fulltext_update_trigger BEFORE INSERT OR UPDATE
ON person
FOR EACH ROW 
EXECUTE PROCEDURE
  person_fulltext_update_function();
;


-- after person insert

CREATE OR REPLACE FUNCTION person_after_insert()
  RETURNS TRIGGER AS
$code$
BEGIN
	REFRESH MATERIALIZED VIEW checklist_view;
	REFRESH MATERIALIZED VIEW checkpoint_view;
	REFRESH MATERIALIZED VIEW elevator_view;
	REFRESH MATERIALIZED VIEW estate_view;
	REFRESH MATERIALIZED VIEW person_view;
	INSERT INTO access_log (aclo_content_id, aclo_content_table, aclo_owner) VALUES
	(NEW.pers_id, 'person', NEW.pers_id)
	ON CONFLICT DO NOTHING
	;
	RETURN NEW;
END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS person_after_insert_trg on person;
CREATE TRIGGER person_after_insert_trg
  AFTER INSERT OR UPDATE
  ON person
  FOR EACH ROW
  EXECUTE PROCEDURE person_after_insert();

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
	RETURN OLD;
END;
$BODY$ LANGUAGE 'plpgsql';


DROP TRIGGER IF EXISTS person_deleted on person;
CREATE TRIGGER person_deleted
BEFORE DELETE
ON person
FOR EACH ROW
EXECUTE PROCEDURE person_delete();

CREATE OR REPLACE FUNCTION person_after_delete()
	RETURNS TRIGGER AS
$code$
	BEGIN
		REFRESH MATERIALIZED VIEW checklist_view;
		REFRESH MATERIALIZED VIEW checkpoint_view;
		REFRESH MATERIALIZED VIEW elevator_view;
		REFRESH MATERIALIZED VIEW estate_view;
		REFRESH MATERIALIZED VIEW person_view;
		RETURN OLD;
	END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS person_after_delete_trg on elevator;
CREATE TRIGGER person_after_delete_trg
AFTER DELETE
ON elevator
FOR EACH ROW
EXECUTE PROCEDURE person_after_delete();

REFRESH MATERIALIZED VIEW checklist_view;
REFRESH MATERIALIZED VIEW checkpoint_view;
REFRESH MATERIALIZED VIEW elevator_view;
REFRESH MATERIALIZED VIEW estate_view;
REFRESH MATERIALIZED VIEW person_view;
-- before report insert
CREATE OR REPLACE FUNCTION report_fulltext_update_function() RETURNS TRIGGER
AS
$code$
	BEGIN
	NEW.repo_fulltext =
			to_tsvector('german', 	coalesce(NEW.repo_elevator ->> 'elev_serial_number', '')
						|| ' ' || 	coalesce(NEW.repo_inspector ->> 'pers_firstname', '')
						|| ' ' || 	coalesce(NEW.repo_inspector ->> 'pers_lastname', '')
						|| ' ' || 	coalesce(CAST(NEW.repo_estate -> 'esta_address' as JSONB) ->> 'address_street_name' , '')
						|| ' ' || 	coalesce(CAST(NEW.repo_estate -> 'esta_address' as JSONB) ->> 'address_zipcode' , '')
						|| ' ' || 	coalesce(CAST(NEW.repo_estate -> 'esta_address' as JSONB) ->> 'address_city' , '')
			)
	;
	RETURN NEW;
	END;
$code$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS report_fulltext_update_trigger on report;
CREATE TRIGGER report_fulltext_update_trigger BEFORE INSERT OR UPDATE
ON report
FOR EACH ROW 
EXECUTE PROCEDURE
  report_fulltext_update_function();
;


-- after report insert

CREATE OR REPLACE FUNCTION report_after_insert()
  RETURNS TRIGGER AS
$code$
BEGIN
	REFRESH MATERIALIZED VIEW report_view;
	REFRESH MATERIALIZED VIEW checklist_view;
	REFRESH MATERIALIZED VIEW checkpoint_view;
	REFRESH MATERIALIZED VIEW elevator_view;
	REFRESH MATERIALIZED VIEW estate_view;
	REFRESH MATERIALIZED VIEW person_view;
	INSERT INTO access_log (aclo_content_id, aclo_content_table, aclo_owner) VALUES
	(NEW.repo_id, 'report', NEW.repo_inspector ->> 'pers_id')
	ON CONFLICT DO NOTHING
	;
	INSERT INTO access_log (aclo_content_id, aclo_content_table, aclo_owner)
	(
		SELECT NEW.repo_id, 'report', jsonb_array_elements(NEW.repo_estate -> 'esta_stakeholders') ->> 'pers_id' as pers_id
	)
	ON CONFLICT DO NOTHING
	;
	UPDATE elevator SET 
	elev_last_inspection = NEW.repo_creation
	WHERE NEW.repo_elevator ->> 'elev_id' = elevator.elev_id;
	RETURN NEW;
END;
$code$ 
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS report_after_insert_trg on report;
CREATE TRIGGER report_after_insert_trg
  AFTER INSERT OR UPDATE
  ON report
  FOR EACH ROW
  EXECUTE PROCEDURE report_after_insert();

REFRESH MATERIALIZED VIEW checklist_view;
REFRESH MATERIALIZED VIEW checkpoint_view;
REFRESH MATERIALIZED VIEW elevator_view;
REFRESH MATERIALIZED VIEW estate_view;
REFRESH MATERIALIZED VIEW person_view;
