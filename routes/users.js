const Route = require(__base + 'routes/master/route');
const UserQueries = require(__base + 'api/services/user/user_queries');
const UserHal = require(__base + 'api/services/user/user_hal');
const UserValidationSchema = require(__base + 'api/services/user/user_validation_schema');

module.exports = (db)=>{
	return new Route('users', new UserQueries(db, 'person', 'pers_id', 'pers_fulltext', 'pers'), new UserHal(), new UserValidationSchema()).getRoutes();
}