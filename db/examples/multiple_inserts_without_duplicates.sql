-- https://stackoverflow.com/a/24769231/1098122

WITH data (aclo_content_id, aclo_content_table, pers_id) as(
	VALUES
		('1eGMz4b8Vp', 'person', 'q7n92lf60yLE3IuhHPZQ9SrkbtwbJOkHyAz'),
		('1eGMz4b8Vp', 'person', 'e9r5C03wdJ')
)
INSERT INTO access_log (aclo_content_id, aclo_content_table, pers_id)
SELECT * FROM data 
WHERE NOT EXISTS(
	SELECT * FROM access_log where access_log.aclo_content_id = data.aclo_content_id and access_log.pers_id = data.pers_id
)
