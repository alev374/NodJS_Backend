-- CONTENT

INSERT INTO person_role_config (pero_scope) VALUES
('admin'),
('manager'),
('inspector'),
('owner')
('owner_selfmanaged')
;

INSERT INTO checkpoint_priority_config (chpr_description, chpr_priority) VALUES
('normal', 0),
('wichtig', 1),
('Verletzungsgefahr', 2)
;

INSERT INTO  person (
    pers_id,
    pers_firstname,
    pers_lastname,
    pers_is_active,
    pers_addresses,
    pers_username,
    pers_password,
    pers_phone_numbers,
    pers_email_addresses,
    pers_scope,
    pers_creation,
    pers_last_updated
)
VALUES
('q7n92lf60yLE3IuhHPZQ9SrkbtwbJOkHyAz', 'Maximilian', 'Lindsey', true, '[]', 'creator_admin', '$2a$15$IskvDQFJIM63nLNvT.hDd.rRX3bCs6nJfim7Obhj8fD14Q/yuSvuK', '[]', '[{"email_address": "tools@loveforpixels.com","email_type": "private","email_is_receiving": true,"email_notification_time": "12"}]', 1, '2017-05-22T17:00:00+02:00', '2017-05-22T17:00:00+02:00')
;
