const Route = require(__base + 'routes/master/route');
const ElevatorQueries = require(__base + 'api/services/elevator/elevator_queries');
const ElevatorHal = require(__base + 'api/services/elevator/elevator_hal');
const ElevatorValidationSchema = require(__base + 'api/services/elevator/elevator_validation_schema');

module.exports = (db)=>{
	return new Route('elevators', new ElevatorQueries(db, 'elevator', 'elev_id', 'elev_fulltext', 'elev'), new ElevatorHal(), new ElevatorValidationSchema()).getRoutes();
}