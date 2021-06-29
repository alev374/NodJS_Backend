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