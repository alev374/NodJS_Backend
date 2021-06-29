INSERT INTO "checklist_checkpoint_relation" ("chli_id", "chpo_id")
SELECT DISTINCT *
FROM (VALUES ('E0K75etgD2', '123456789'), ('E0K75etgD2', '123456789')) sub ON CONFLICT ("chli_id", "chpo_id") DO
UPDATE SET "chli_id" = "checklist_checkpoint_relation"."chli_id", "chpo_id" = "checklist_checkpoint_relation"."chpo_id";