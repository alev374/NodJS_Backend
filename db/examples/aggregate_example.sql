select p.*, pp.phones, pe.emails
from person p left join
     (select pers_id, json_agg(ppr.phon_id) as phones
      from person_phone_realtion ppr 
      group by pers_id
     ) pp
     on p.pers_id = pp.pers_id left join
     (select pers_id, json_agg(per.email_id) as emails
      from person_email_realtion per 
      group by pers_id
     ) pe
     on p.pers_id = pe.pers_id;