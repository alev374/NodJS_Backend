
-- sql
select * from person_sql where to_tsvector('german', pers_sql_firstname || ' ' || pers_sql_lastname) @@ to_tsquery('Lin:*');

-- json
select * from person where to_tsvector('german', CAST(pers_data->>'firstname' as text)|| ' ' || CAST(pers_data->>'lastname' as text)) @@ to_tsquery('Max:* | Lin:*');

select pers_id, pers_data->>'email_addresses' from person where to_tsvector('german', CAST(pers_data->>'email_addresses' as text)|| ' ' || CAST(pers_data->>'lastname' as text)) @@ to_tsquery('m:*');


-- search with trigger
ALTER TABLE person ADD COLUMN pers_fulltext TSVECTOR;

UPDATE person
SET pers_fulltext =
    to_tsvector('german',           pers_firstname
                          || ' ' || pers_lastname
                          || ' ' || CAST(jsonb_array_elements(pers_email_addresses) ->> 'pers_address' as TEXT)
               )
;

DROP INDEX IF EXISTS person_fulltext_index CASCADE;
CREATE INDEX person_fulltext_index ON person USING gin(pers_fulltext);

DELIMITER //
CREATE OR REPLACE FUNCTION person_fulltext_update_function() RETURNS TRIGGER
AS
$code$
  BEGIN
    NEW.pers_fulltext =
      to_tsvector('german',           NEW.pers_firstname
                            || ' ' || NEW.pers_lastname
                            || ' ' || CAST(jsonb_array_elements(NEW.pers_email_addresses) ->> 'pers_address' as TEXT)
                 )
    ;
    RETURN NEW;
  END
$code$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS person_fulltext_update_trigger on person;
CREATE TRIGGER person_fulltext_update_trigger BEFORE INSERT OR UPDATE
ON person
FOR EACH ROW 
EXECUTE PROCEDURE
  person_fulltext_update_function();
;


select *
from person
where person.pers_fulltext @@ to_tsquery('Max:*');

-- https://stackoverflow.com/a/44166002/1098122
select *
from person,
jsonb_array_elements(pers_email_addresses)
where to_tsvector('simple', value->>'pers_address') @@ to_tsquery('soli@auf:*');