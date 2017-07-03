select p.username as username, s.name as site
from person p, auth_for_testing_mot aftm, organisation o,
  organisation_site_map osm, site s, auth_for_testing_mot_at_site afts,
  site_business_role_map sbrm, auth_for_ae afa, security_card sc,
  person_security_card_map pscm, security_card_drift scd
where aftm.person_id = p.id
and aftm.vehicle_class_id = 3 -- only class 3 vehicles
and aftm.status_id = 9 -- only qualified testing authorisations
and p.is_account_claim_required = 0
and p.is_password_change_required = 0
and o.id = osm.organisation_id
and s.id = osm.site_id
and s.id = afts.site_id
and afts.vehicle_class_id = 3 -- only class 3 vehicles
and afts.status_id = 2 -- only valid site authorisations
and sbrm.site_id = s.id
and sbrm.person_id = p.id
and sbrm.site_business_role_id = 1 -- only testers
and afa.organisation_id = o.id
and afa.status_id = 2 -- only valid ae authorisations
and o.slots_balance > 0 -- ae's with slots available
and p.id = pscm.person_id
and sc.id = pscm.security_card_id
and sc.security_card_status_lookup_id = 1 -- only assigned cards
and sc.id = scd.security_card_id
and scd.last_observed_drift <= 60 -- no cards drifted forward
and scd.last_observed_drift >= -60 -- or back beyond 1 hour
and p.id not in (
  select last_updated_by from mot_test_current
  where status_id = 4 -- exclude any testers with active tests
)
and p.username is not null -- exclude dodgy test data
limit 50