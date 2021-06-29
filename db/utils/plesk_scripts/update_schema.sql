-- // Adding new elev_chpoints field with current checkpoint-elevator relation
-- ALTER TABLE public.elevator
-- ADD COLUMN elev_chpoints jsonb;
-- 
-- UPDATE public.elevator as el
-- set elev_chpoints = ch.chli_checkpoints || el.elev_checkpoints
-- 	
-- FROM
-- 	public.checklist as ch 
--     WHERE ch.chli_id = el.chli_id;

-- ALTER TABLE public.checkpoint_priority_config
-- ADD COLUMN chpr_test integer;

-- //The sequence is created and used to set starting values, incremental values, max & min values

-- create sequence public.checkpoint_priority_config_chpr_test_seq
-- INCREMENT 1
--     START 0
--     MINVALUE 0
--     MAXVALUE 9223372036854775807
--     CACHE 1;

-- //Then the created sequence is set to the new column we created.

-- UPDATE public.checkpoint_priority_config
-- set chpr_test = nextval('checkpoint_priority_config_chpr_test_seq');



-- ALTER TABLE public.estate
-- ADD COLUMN esta_created_by text;

-- ALTER TABLE public.elevator
-- ADD COLUMN elev_created_by text;

-- ALTER TABLE public.person
-- ADD COLUMN pers_created_by text;

-- ALTER TABLE public.estate 
--     ADD COLUMN test_column BOOLEAN DEFAULT FALSE;


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


