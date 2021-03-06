select veh.registration, ma.name, mo.name
from vehicle veh, model_detail md, model mo, make ma
where veh.id < 10000000
and veh.registration is not null
and veh.model_detail_id = md.id
and veh.registration not like "%-%"
and veh.registration not like "%@%"
and md.model_id = mo.id
and mo.make_id = ma.id
and md.vehicle_class_id = 4 -- cars only
and length(ma.name) > 0
and length(mo.name) > 0
and ma.name = 'PEUGEOT' -- show results where the manufacture is PEUGEOT as this is set to return a timeout from the fake SMMT service
and length(veh.vin) > 5 -- the VIN number needs to be at least 5 chars long
limit 10