const Route = require(__base + 'routes/master/route');
const ChecklistQueries = require(__base + 'api/services/checklist/checklist_queries');
const ChecklistHal = require(__base + 'api/services/checklist/checklist_hal');
const ChecklistValidationSchema = require(__base + 'api/services/checklist/checklist_validation_schema');

module.exports = (db)=>{
	return new Route('checklists', new ChecklistQueries(db, 'checklist', 'chli_id', 'chli_fulltext', 'chli'), new ChecklistHal(), new ChecklistValidationSchema()).getRoutes();
}