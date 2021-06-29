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