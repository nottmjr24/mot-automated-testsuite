SELECT  distinct(p.username) as username, s.name as site
from person p, auth_for_testing_mot aftm, organisation o,
 organisation_site_map osm, site s, auth_for_testing_mot_at_site afts,
 site_business_role_map sbrm, auth_for_ae afa, security_card sc,
 person_security_card_map pscm, mot_test_current mtc, special_notice sn
where aftm.person_id = p.id
and aftm.vehicle_class_id = 4 -- only cars
and aftm.status_id = 9 -- only qualified testing authorisations
and p.is_account_claim_required = 0
and p.is_password_change_required = 0
and o.id = osm.organisation_id
and s.id = osm.site_id
and s.id = afts.site_id
and afts.vehicle_class_id = 4 -- only cars
and afts.status_id = 2 -- only valid site authorisations
and sbrm.site_id = s.id
and sbrm.person_id = p.id
and sbrm.site_business_role_id = 1 -- only testers
and sbrm.status_id = 1 -- Only Active tester roles
and afa.organisation_id = o.id
and afa.status_id = 2 -- only valid ae authorisations
and o.slots_balance > 15 -- ae's with slots available
and p.id = pscm.person_id
and sc.id = pscm.security_card_id
and sc.security_card_status_lookup_id = 1 -- only assigned cards
and mtc.site_id <> s.id
and mtc.status_id = 6 -- Passed tests only
and mtc.mot_test_type_id = 1  -- Normal tests only
and mtc.document_id IS NOT NULL  -- exclude where there are no MOT certificates
--  and p.username = sn2.username
and not exists ( -- not all security_card have a corresponding security_card_drift
 select 1 from security_card_drift scd
 where sc.id = scd.security_card_id
 and (scd.last_observed_drift > 60 or scd.last_observed_drift < -60) -- no drift beyond +/-2
)
and not exists (
 select 1 from mot_test_current mtc
 where p.id = mtc.last_updated_by
 and mtc.status_id = 4 -- exclude any testers with active tests
)
and not exists (
    select 1 from site_business_role_map sbrm
    where p.id = sbrm.person_id
    group by sbrm.person_id
    having count(*)>1)
and p.username not in (
	Select sn2.username from (select max(sn.id) as id, sn.username
        from special_notice sn
        where sn.is_acknowledged = 0
        Group by sn.username) sn2)  -- removes users with special notice block
and p.username is not null -- exclude dodgy test data
limit 100
