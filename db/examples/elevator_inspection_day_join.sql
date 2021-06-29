select person_view.pers_id, person_view.pers_firstname, person_view.pers_lastname, person_view.pers_email_addresses,
inspector_today_elevators.elevators as inspector_today_elevators,
inspector_past_date_elevators.elevators as inspector_past_date_elevators,
inspector_past_day_elevators.elevators as inspector_past_day_elevators,
substitute_today_elevators.elevators as substitute_today_elevators,
substitute_past_date_elevators.elevators as substitute_past_date_elevators,
substitute_past_day_elevators.elevators as substitute_past_day_elevators,
stakeholder_past_date_elevators.elevators as stakeholder_past_date_elevators,
stakeholder_past_day_elevators.elevators as stakeholder_past_day_elevators
from person_view
-- inspector today
left join
(
	select person_view.pers_id, jsonb_agg(inspector_elevators.elevator) as elevators from person_view
	left join
	(
		select 
		pers_id,
		jsonb_array_elements(pers_inspector_elevators) -> 'elev_inspection_days' as elev_inspection_days,
		jsonb_array_elements(pers_inspector_elevators) as elevator
		from person_view
	) inspector_elevators
	on inspector_elevators.pers_id = person_view.pers_id
	where inspector_elevators.elev_inspection_days @> '["1"]'
	group by person_view.pers_id
) inspector_today_elevators
on inspector_today_elevators.pers_id = person_view.pers_id
-- inspector past date
left join
(
	select person_view.pers_id, jsonb_agg(inspector_elevators.elevator) as elevators from person_view
	left join
	(
		select 
		pers_id,
		jsonb_array_elements(pers_inspector_elevators) -> 'elev_inspection_days' as elev_inspection_days,
		jsonb_array_elements(pers_inspector_elevators) as elevator
		from person_view
	) inspector_elevators
	on inspector_elevators.pers_id = person_view.pers_id
	where inspector_elevators.elev_inspection_days @> '["1"]'
	group by person_view.pers_id
) inspector_past_date_elevators
on inspector_past_date_elevators.pers_id = person_view.pers_id
-- inspector past day
left join
(
	select person_view.pers_id, jsonb_agg(inspector_elevators.elevator) as elevators from person_view
	left join
	(
		select 
		pers_id,
		jsonb_array_elements(pers_inspector_elevators) -> 'elev_inspection_days' as elev_inspection_days,
		jsonb_array_elements(pers_inspector_elevators) as elevator
		from person_view
	) inspector_elevators
	on inspector_elevators.pers_id = person_view.pers_id
	where inspector_elevators.elev_inspection_days @> '["1"]'
	group by person_view.pers_id
) inspector_past_day_elevators
on inspector_past_day_elevators.pers_id = person_view.pers_id
-- substitute today
left join
(
	select person_view.pers_id, jsonb_agg(substitute_elevators.elevator) as elevators from person_view
	left join
	(
		select 
		pers_id,
		jsonb_array_elements(pers_substitute_elevators) -> 'elev_inspection_days' as elev_inspection_days,
		jsonb_array_elements(pers_substitute_elevators) as elevator
		from person_view
	) substitute_elevators
	on substitute_elevators.pers_id = person_view.pers_id
	where substitute_elevators.elev_inspection_days @> '["1"]'
	group by person_view.pers_id
) substitute_today_elevators
on substitute_today_elevators.pers_id = person_view.pers_id
-- substitute past date
left join
(
	select person_view.pers_id, jsonb_agg(substitute_elevators.elevator) as elevators from person_view
	left join
	(
		select 
		pers_id,
		jsonb_array_elements(pers_substitute_elevators) -> 'elev_inspection_days' as elev_inspection_days,
		jsonb_array_elements(pers_substitute_elevators) as elevator
		from person_view
	) substitute_elevators
	on substitute_elevators.pers_id = person_view.pers_id
	where substitute_elevators.elev_inspection_days @> '["1"]'
	group by person_view.pers_id
) substitute_past_date_elevators
on substitute_past_date_elevators.pers_id = person_view.pers_id
-- substitute past day
left join
(
	select person_view.pers_id, jsonb_agg(substitute_elevators.elevator) as elevators from person_view
	left join
	(
		select 
		pers_id,
		jsonb_array_elements(pers_substitute_elevators) -> 'elev_inspection_days' as elev_inspection_days,
		jsonb_array_elements(pers_substitute_elevators) as elevator
		from person_view
	) substitute_elevators
	on substitute_elevators.pers_id = person_view.pers_id
	where substitute_elevators.elev_inspection_days @> '["1"]'
	group by person_view.pers_id
) substitute_past_day_elevators
on substitute_past_day_elevators.pers_id = person_view.pers_id
-- stakeholder past date
left join
(
	select person_view.pers_id, jsonb_agg(stakeholder_elevators.elevator) as elevators from person_view
	left join
	(
		select 
		pers_id,
		jsonb_array_elements(pers_stakeholder_elevators) -> 'elev_inspection_days' as elev_inspection_days,
		jsonb_array_elements(pers_stakeholder_elevators) as elevator
		from person_view
	) stakeholder_elevators
	on stakeholder_elevators.pers_id = person_view.pers_id
	where stakeholder_elevators.elev_inspection_days @> '["1"]'
	group by person_view.pers_id
) stakeholder_past_date_elevators
on stakeholder_past_date_elevators.pers_id = person_view.pers_id
-- stakeholder past day
left join
(
	select person_view.pers_id, jsonb_agg(stakeholder_elevators.elevator) as elevators from person_view
	left join
	(
		select 
		pers_id,
		jsonb_array_elements(pers_stakeholder_elevators) -> 'elev_inspection_days' as elev_inspection_days,
		jsonb_array_elements(pers_stakeholder_elevators) as elevator
		from person_view
	) stakeholder_elevators
	on stakeholder_elevators.pers_id = person_view.pers_id
	where stakeholder_elevators.elev_inspection_days @> '["1"]'
	group by person_view.pers_id
) stakeholder_past_day_elevators
on stakeholder_past_day_elevators.pers_id = person_view.pers_id