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