-- get stakeholer reports that have not been sent

select * from 
(
select pers_id, jsonb_array_elements(pers_email_addresses) as email, jsonb_array_elements(stakeholder_reports) as report from person_view
where pers_scope = 'owner'
) stakeholder
where
stakeholder.email ->> 'email_notification_time' = '15'
and
stakeholder.report ->> 'repo_report' is not null
and
(
	select not exists(
		select 1 from report_delivery_log
		where
		repo_id = stakeholder.report ->> 'repo_id'
		and 
		pers_id = stakeholder.pers_id
	)
)