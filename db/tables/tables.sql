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
    chpo_default boolean  NOT NULL,
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
    elev_chpoints jsonb  NOT NULL,
    elev_created_by text,
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
    esta_created_by text,
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
    pers_created_by text,
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

