const Queries = require(__base + 'api/service_utils/queries');

class ChecklistQueries extends Queries{
	constructor(db, table, table_id, table_fulltext, table_alias) {
		super(db, table, table_id, table_fulltext, table_alias);
	}

	check(auth = {}, check){
		return super.check(auth, check, `chli_name = '${check}'`)
	}

	post(auth = {}, data = {}){

		let checkpoints = data.chli_checkpoints;
		// delete data.chli_checkpoints;
		let id = null;
		console.log("CheckList Post Data === ", data);
		return super.post(auth, data, this.table, this.table_id, true)
		.then((chli_id)=>{
			id = chli_id;
			try {
				checkpoints.forEach((checkpoint, index)=>{
					checkpoint['chli_id'] = id
				})
				return this._upsert(checkpoints, 'checklist_checkpoint_relation', 'chli_id')
			} catch(e) {
				return null;
			}
		})
		.then(()=>{
			return id
		})
	}

	put(auth = {}, data = {}){
		let checkpoints = data.chli_checkpoints;
		let id = null;
		return super.put(auth, data, this.table, this.table_id)
		.then((chli_id)=>{
			id = chli_id;
			return this.db.select('checklist_checkpoint_relation.*').from('checklist_checkpoint_relation')
			.where('checklist_checkpoint_relation.chli_id', chli_id)
		})
		.then((result)=>{
			try {
				checkpoints.forEach((checkpoint)=>{
					checkpoint['chli_id'] = id
				})
				return this._upsert(checkpoints, 'checklist_checkpoint_relation', 'chli_id')
			} catch(e) {
				return null;
			}			
		})
		.then(()=>{
			return id
		})
	}
}

module.exports = ChecklistQueries;