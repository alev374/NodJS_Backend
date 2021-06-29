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