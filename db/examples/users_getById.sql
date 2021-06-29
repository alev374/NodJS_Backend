SELECT * from person
LEFT JOIN
(
	SELECT per.pers_id, json_agg(phone.phon_id) as phon_id, json_agg(phone.phon_number) as phon_number, json_agg(phone.phon_type) as phon_type
	FROM person_phone_relation per
	LEFT JOIN phone
	ON per.phon_id = phone.phon_id
	GROUP BY pers_id
) phon
on person.pers_id = phon.pers_id
LEFT JOIN
(
	SELECT per.pers_id, json_agg(email.emai_id) as emai_id, json_agg(email.emai_address) as emai_address, json_agg(email.emai_is_receiving) as emai_is_receiving
	FROM person_email_relation per
	LEFT JOIN email
	ON per.emai_id = email.emai_id
	GROUP BY pers_id
) emai
on person.pers_id = emai.pers_id
WHERE person.pers_id = ''