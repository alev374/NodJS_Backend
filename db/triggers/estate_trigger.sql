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