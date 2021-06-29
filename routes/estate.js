const Route = require(__base + 'routes/master/route');
const EstateQueries = require(__base + 'api/services/estate/estate_queries');
const EstateHal = require(__base + 'api/services/estate/estate_hal');
const EstateValidationSchema = require(__base + 'api/services/estate/estate_validation_schema');

module.exports = (db)=>{
	return new Route('estates', new EstateQueries(db, 'estate', 'esta_id', 'esta_fulltext', 'esta'), new EstateHal(), new EstateValidationSchema()).getRoutes();
}