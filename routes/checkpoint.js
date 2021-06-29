const Route = require(__base + 'routes/master/route');
const CheckpointQueries = require(__base + 'api/services/checkpoint/checkpoint_queries');
const CheckpointHal = require(__base + 'api/services/checkpoint/checkpoint_hal');
const CheckpointValidationSchema = require(__base + 'api/services/checkpoint/checkpoint_validation_schema');

module.exports = (db)=>{
	return new Route('checkpoints', new CheckpointQueries(db, 'checkpoint', 'chpo_id', 'chpo_fulltext', 'chpo'), new CheckpointHal(), new CheckpointValidationSchema()).getRoutes();
}