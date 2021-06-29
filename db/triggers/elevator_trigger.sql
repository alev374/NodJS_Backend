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