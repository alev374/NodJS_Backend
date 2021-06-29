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