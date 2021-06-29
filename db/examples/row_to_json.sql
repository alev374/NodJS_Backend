-- https://hashrocket.com/blog/posts/faster-json-generation-with-postgresql

SELECT "checklist"."chli_id", json_agg("content"."chpo_data") AS elev_checkpoints
FROM "checklist"
LEFT JOIN "checklist_checkpoint_relation" 
ON "checklist_checkpoint_relation"."chli_id" = "checklist"."chli_id"
LEFT JOIN
(
	SELECT "content"."chpo_id", row_to_json("content") as chpo_data FROM
	(
		SELECT "chpo_id", "chpo_headline", "chpo_description", "chpo_priority" FROM checkpoint
	) "content"
) as "content"
ON "content"."chpo_id" = "checklist_checkpoint_relation"."chpo_id"
GROUP BY "checklist"."chli_id"


-- 

select person.*, aclo_owners.aclo_data from person 
left join
(
SELECT "person"."pers_id", json_agg("content"."chpo_data") AS aclo_data
FROM "person"
LEFT JOIN "access_log" 
ON "access_log"."aclo_content_id" = "person"."pers_id"
LEFT JOIN
(
	SELECT "content"."aclo_id", row_to_json("content") as chpo_data FROM
	(
		SELECT * FROM access_log
	) "content"
) as "content"
ON "content"."aclo_id" = "access_log"."aclo_id"
GROUP BY "person"."pers_id"
) as aclo_owners
on aclo_owners.pers_id = person.pers_id
WHERE aclo_owners.pers_id = 'q7n92lf60yLE3IuhHPZQ9SrkbtwbJOkHyAz'
