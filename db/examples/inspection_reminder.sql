-- inspection reminder date of month
--past

select *,
json_array_elements(elev_estate -> 'esta_stakeholders') esta_stakeholder,
DATE_PART('day', ('2018-10-20 08:00:00'::timestamp - INTERVAL '11 DAY') - elev_last_inspection) days_since_last_inspection
from
(
    select *,
    (regexp_replace(('2018-10-20 08:00:00'::timestamp - INTERVAL '8 DAY')::Text, '(?<=\d{4}-\d{2}-)\d{2}', elev_inspection_day))::timestamp inspection_date
    from
    (
        select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from elevator_view
    
    ) elevator
    where elev_inspection_day ~ '\d+' and elev_last_inspection is not null
) elevator
where DATE_PART('day', '2018-10-20 08:00:00'::timestamp - inspection_date) = 8
and DATE_PART('day', ('2018-10-20 08:00:00'::timestamp - INTERVAL '11 DAY') - elev_last_inspection) > 11
and DATE_PART('day', ('2018-10-20 08:00:00'::timestamp - INTERVAL '11 DAY') - elev_last_inspection) < 28
;

--present
select *,
json_array_elements(elev_estate -> 'esta_stakeholders') esta_stakeholder
from
(
	select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from elevator_view

) elevator
where elev_inspection_day ~ '\d+'
and EXTRACT(day FROM '2018-10-12 08:00:00'::timestamp)::text = elev_inspection_day
;


-- inspection reminder day of week
-- yesterday

select *,
json_array_elements(elev_estate -> 'esta_stakeholders') esta_stakeholder
from
(
	select elevator.*,
	CASE elev_inspection_day
		WHEN 'So' THEN 0
		WHEN 'Mo' THEN 1
		WHEN 'Di' THEN 2
		WHEN 'Mi' THEN 3
		WHEN 'Do' THEN 4
		WHEN 'Fr' THEN 5
		ELSE 6
	END as elev_inspection_day_dow,
	EXTRACT(dow FROM elev_last_inspection) last_inspection_dow,
	EXTRACT(dow FROM '2018-10-31 08:00:00'::timestamp) today_dow,
	EXTRACT(dow FROM ('2018-10-31 08:00:00'::timestamp - INTERVAL '1 DAY')) yesterday_dow
	from
	(
		select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from elevator_view
	) elevator
) elevator
where elev_inspection_day ~ '\D+' and elev_last_inspection is not null
and elev_inspection_day_dow = yesterday_dow
and last_inspection_dow != yesterday_dow
;

-- today

select *,
json_array_elements(elev_estate -> 'esta_stakeholders') esta_stakeholder
from
(
	select *,
	CASE elev_inspection_day
		WHEN 'So' THEN 0
		WHEN 'Mo' THEN 1
		WHEN 'Di' THEN 2
		WHEN 'Mi' THEN 3
		WHEN 'Do' THEN 4
		WHEN 'Fr' THEN 5
		ELSE 6
	END as elev_inspection_day_dow,
	EXTRACT(dow FROM elev_last_inspection) last_inspection_dow,
	EXTRACT(dow FROM '2018-10-30 08:00:00'::timestamp) today_dow
	from
	(
		select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from elevator_view
	) elevator
) elevator
where elev_inspection_day ~ '\D+' and elev_last_inspection is not null
and elev_inspection_day_dow = today_dow
;







select elevator.elev_id, jsonb_agg(jsonb_build_object(
'elev_id', elevator.elev_id,
'elev_type', elevator.elev_type,
'elev_estate', elevator.elev_estate,
'elev_barcode', elevator.elev_barcode,
'elev_location', elevator.elev_location,
'elev_creation', elevator.elev_creation,
'elev_inspector', elevator.elev_inspector,
'elev_is_active', elevator.elev_is_active,
'elev_build_year', elevator.elev_build_year,
'elev_substitute', elevator.elev_substitute,
'elev_last_updated', elevator.elev_last_updated,
'elev_manufacturer', elevator.elev_manufacturer,
'elev_serial_number', elevator.elev_serial_number,
'elev_inspection_days', elevator.elev_inspection_days,
'elev_last_inspection', elevator.elev_last_inspection,
'elev_emergency_information', elevator.elev_emergency_information
))
from
(
	select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from elevator_view

) elevator
where elev_inspection_day ~ '\d+'
and EXTRACT(day FROM '2018-10-12 08:00:00'::timestamp)::text = elev_inspection_day
group by elevator.elev_id
;