-- add this to get array of all element owners + only the entrys of a certain person
SELECT * FROM person
LEFT JOIN
(SELECT access_log.*, aclo_owners.owners FROM access_log 
LEFT JOIN 
(SELECT access_log.aclo_content_id, jsonb_agg(access_log.pers_id) as owners
	FROM access_log
	GROUP BY access_log.aclo_content_id) as aclo_owners
ON access_log.aclo_content_id = aclo_owners.aclo_content_id) aclo
ON person.pers_id = aclo.aclo_content_id
WHERE aclo.pers_id = 'q7n92lf60yLE3IuhHPZQ9SrkbtwbJOkHyAz'

-- subquery
SELECT access_log.*, aclo_owners.owners as aclo_owners FROM access_log 
LEFT JOIN 
(SELECT access_log.aclo_content_id, jsonb_agg(access_log.pers_id) as owners
	FROM access_log
	GROUP BY access_log.aclo_content_id) as aclo_owners
ON access_log.aclo_content_id = aclo_owners.aclo_content_id
WHERE access_log.pers_id = 'q7n92lf60yLE3IuhHPZQ9SrkbtwbJOkHyAz'

(SELECT access_log.*, aclo_owners.owners as aclo_owners FROM access_log 
LEFT JOIN 
(SELECT access_log.aclo_content_id, jsonb_agg(access_log.pers_id) as owners
	FROM access_log
	GROUP BY access_log.aclo_content_id) as aclo_owners
ON access_log.aclo_content_id = aclo_owners.aclo_content_id
WHERE access_log.pers_id = 'q7n92lf60yLE3IuhHPZQ9SrkbtwbJOkHyAz') aclo
ON person.pers_id = aclo.aclo_content_id


SELECT person.*, person_role_config.pero_scope, aclo.aclo_owners FROM person
LEFT JOIN
(SELECT access_log.*, aclo_owners.owners as aclo_owners FROM access_log 
LEFT JOIN 
(SELECT access_log.aclo_content_id, jsonb_agg(access_log.pers_id) as owners
	FROM access_log
	GROUP BY access_log.aclo_content_id) as aclo_owners
ON access_log.aclo_content_id = aclo_owners.aclo_content_id) aclo
ON person.pers_id = aclo.aclo_content_id
LEFT JOIN person_role_config 
ON person_role_config.pero_id = person.pers_scope
WHERE aclo.pers_id = 'q7n92lf60yLE3IuhHPZQ9SrkbtwbJOkHyAz'