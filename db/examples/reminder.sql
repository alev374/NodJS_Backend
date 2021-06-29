-- today inspector

select elev_inspector ->> 'pers_id' elev_inspector, jsonb_agg(today_elevators) inspector_today_elevators
from
(
	select *
	from
	(
		select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from elevator_view
	
	) elevator
	where elev_inspection_day ~ '\d+'
	and EXTRACT(day FROM '2018-10-12 08:00:00'::timestamp)::text = elev_inspection_day
) today_elevators
group by elev_inspector ->> 'pers_id'
union
select elev_inspector ->> 'pers_id' elev_inspector, jsonb_agg(today_elevators) inspector_today_elevators
from
(
	select *
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
		EXTRACT(dow FROM '2018-10-30 08:00:00'::timestamp) today_dow,
		EXTRACT(dow FROM ('2018-10-30 08:00:00'::timestamp - INTERVAL '1 DAY')) yesterday_dow
		from
		(
			select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from elevator_view
		) elevator
	) elevator
	where elev_inspection_day ~ '\D+' and elev_last_inspection is not null
	and elev_inspection_day_dow = today_dow
) today_elevators
group by elev_inspector ->> 'pers_id'
;

-- today substitute

select elev_substitute ->> 'pers_id' elev_substitute, jsonb_agg(today_elevators) substitute_today_elevators
from
(
	select *
	from
	(
		select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from elevator_view
	
	) elevator
	where elev_inspection_day ~ '\d+'
	and EXTRACT(day FROM '2018-10-12 08:00:00'::timestamp)::text = elev_inspection_day
) today_elevators
group by elev_substitute ->> 'pers_id'
union
select elev_substitute ->> 'pers_id' elev_substitute, jsonb_agg(today_elevators) substitute_today_elevators
from
(
	select *
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
		EXTRACT(dow FROM '2018-10-30 08:00:00'::timestamp) today_dow,
		EXTRACT(dow FROM ('2018-10-30 08:00:00'::timestamp - INTERVAL '1 DAY')) yesterday_dow
		from
		(
			select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from elevator_view
		) elevator
	) elevator
	where elev_inspection_day ~ '\D+' and elev_last_inspection is not null
	and elev_inspection_day_dow = today_dow
) today_elevators
group by elev_substitute ->> 'pers_id'
;

-- past date inspector
select elev_inspector ->> 'pers_id' elev_inspector, jsonb_agg(past_date_elevators) inspector_past_date_elevators
from
(
	select *,
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
) past_date_elevators
group by elev_inspector ->> 'pers_id'
;

-- past day inspector
select elev_inspector ->> 'pers_id' elev_inspector, jsonb_agg(past_date_elevators) inspector_past_date_elevators
from
(
    select *
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
) past_date_elevators
group by elev_inspector ->> 'pers_id'
;

-- past date substitute
select elev_substitute ->> 'pers_id' elev_substitute, jsonb_agg(past_date_elevators) substitute_past_date_elevators
from
(
	select *,
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
) past_date_elevators
group by elev_substitute ->> 'pers_id'
;

-- past day substitute
select elev_substitute ->> 'pers_id' elev_substitute, jsonb_agg(past_date_elevators) substitute_past_date_elevators
from
(
    select *
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
) past_date_elevators
group by elev_substitute ->> 'pers_id'
;

-- past date stakeholder
select esta_stakeholder ->> 'pers_id' elev_stakeholder, jsonb_agg(past_date_elevators) stakeholder_past_date_elevators
from
(
	select *,
	DATE_PART('day', ('2018-10-20 08:00:00'::timestamp - INTERVAL '11 DAY') - elev_last_inspection) days_since_last_inspection
	from
	(
		select *,
		(regexp_replace(('2018-10-20 08:00:00'::timestamp - INTERVAL '8 DAY')::Text, '(?<=\d{4}-\d{2}-)\d{2}', elev_inspection_day))::timestamp inspection_date
		from
		(
			select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from 
			(
				select elevator_view.*, json_array_elements(elev_estate -> 'esta_stakeholders') esta_stakeholder
				from elevator_view
			) elevator_view		
		) elevator
		where elev_inspection_day ~ '\d+' and elev_last_inspection is not null
	) elevator
	where DATE_PART('day', '2018-10-20 08:00:00'::timestamp - inspection_date) = 8
	and DATE_PART('day', ('2018-10-20 08:00:00'::timestamp - INTERVAL '11 DAY') - elev_last_inspection) > 11
	and DATE_PART('day', ('2018-10-20 08:00:00'::timestamp - INTERVAL '11 DAY') - elev_last_inspection) < 28
) past_date_elevators
group by esta_stakeholder ->> 'pers_id'
;

-- past day stakeholder
select esta_stakeholder ->> 'pers_id' elev_stakeholder, jsonb_agg(past_date_elevators) stakeholder_past_date_elevators
from
(
    select *
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
            select elevator_view.*, jsonb_array_elements_text(elevator_view.elev_inspection_days) elev_inspection_day from (
				select elevator_view.*, json_array_elements(elev_estate -> 'esta_stakeholders') esta_stakeholder
				from elevator_view
			) elevator_view	
        ) elevator
    ) elevator
    where elev_inspection_day ~ '\D+' and elev_last_inspection is not null
    and elev_inspection_day_dow = yesterday_dow
    and last_inspection_dow != yesterday_dow
) past_date_elevators
group by esta_stakeholder ->> 'pers_id'
;