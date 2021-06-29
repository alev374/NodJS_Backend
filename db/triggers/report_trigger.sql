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