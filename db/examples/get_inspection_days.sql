select * from
(
	select pers_id, pers_scope, pers_email_addresses, pers_inspector_elevators, pers_substitute_elevators, jsonb_array_elements(pers_inspector_elevators) -> 'elev_inspection_days' as inspection_days
	from person_view
) inspection_days
where
inspection_days ? '25'
and
pers_scope = 'inspector'
or
pers_scope = 'substitute'