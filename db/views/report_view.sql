DROP MATERIALIZED VIEW IF EXISTS report_view;

CREATE MATERIALIZED VIEW report_view
AS

SELECT repo_id,
json_build_object('pers_id', repo_inspector ->> 'pers_id', 'pers_firstname', repo_inspector ->> 'pers_firstname', 'pers_lastname', repo_inspector ->> 'pers_lastname') as repo_inspector,
json_build_object('elev_id', repo_elevator ->> 'elev_id', 'elev_serial_number', repo_elevator ->> 'elev_serial_number', 'elev_barcode', repo_elevator ->> 'elev_barcode', 'elev_type', repo_elevator ->> 'elev_type') as repo_elevator,
json_build_object('esta_id', repo_estate ->> 'esta_id', 'esta_address', repo_estate -> 'esta_address') as repo_estate,
repo_creation
FROM report
ORDER BY repo_creation DESC


WITH DATA;
