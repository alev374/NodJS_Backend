const Queries = require(__base + 'api/service_utils/queries');

class CheckpointQueries extends Queries{
	constructor(db, table, table_id, table_fulltext, table_alias) {
		super(db, table, table_id, table_fulltext, table_alias);
	}
	
	post(auth = {}, data = {}){
		console.log("Checkpoint Post Data === ", data);
		let checklists = data.chpo_checklists;
		delete data.chpo_checklists;
		let id = null;
		return new Promise((resolve, reject) => {
			return this.db.select(this.db.raw(`max(chpo_sort) as maxvalue`)).from('checkpoint').then(result => {
				resolve(result[0].maxvalue);
			})
			.catch(error => {
				reject(error)
			})
		})
		.then((maxvalue) => {
			data = {
				...data,
				'chpo_sort': parseInt(maxvalue) + 1,
				'chpo_default': data.chpo_default ? data.chpo_default : false
			}
			return super.post(auth, data, this.table, this.table_id, true);
		})
		.then((chpo_id)=>{
			id = chpo_id;
			try {
				checklists.forEach((checkpoint)=>{
					checkpoint['chpo_id'] = id
				})
				return this._upsert(checklists, 'checklist_checkpoint_relation', 'chpo_id')
			} catch(e) {
				return null;
			}
		})
		.then(()=>{
			return id
		})
	}

	put(auth = {}, data = {}){
		console.log("Checkpoint Put Data === ", data);
		if (data.oldIndex != undefined && data.newIndex != undefined) { // Only sort change case
			let oldValue = parseInt(data.oldIndex);
			let newValue = parseInt(data.newIndex);
			let moveItemId = '';
			return this.db.select('chpo_id').from('checkpoint').whereRaw(`chpo_sort = ${oldValue}`).then(result => {
				moveItemId = result[0].chpo_id;
				let proms = [];
				if (oldValue < newValue) {
					for (let i = oldValue + 1; i < newValue + 1; i++) {
						let updateData = {
							'chpo_sort': i - 1
						}
						let updatePromise = this._update(updateData, 'checkpoint', 'chpo_id', `chpo_sort = ${i}`);
						proms.push(updatePromise);
					}
				} else if (oldValue > newValue) {
					for (let i = oldValue - 1; i > newValue - 1; i--) {
						let updateData = {
							'chpo_sort': i + 1
						}
						let updatePromise = this._update(updateData, 'checkpoint', 'chpo_id', `chpo_sort = ${i}`);
						proms.push(updatePromise);
					}
				}
				
				return Promise.all(proms).then(() => {
					let mainUpdateData = {
						'chpo_sort': newValue
					}
					return this._update(mainUpdateData, 'checkpoint', 'chpo_id', `chpo_id = '${moveItemId}'`).then((chpo_id) =>{
						return chpo_id;
					}).catch(error => {
						console.log("Checkpoint Update Error == ", error);
					})
				}).catch(error => {
					console.log("Checkpoint Update Error == ", error);
				})
			})
			
		} else {
			let checklists = data.chpo_checklists;
			delete data.chpo_checklists;
			let id = null;
			return super.put(auth, data, this.table, this.table_id)
			.then((chpo_id)=>{
				id = chpo_id;
				return this.db.select('checklist_checkpoint_relation.*').from('checklist_checkpoint_relation')
				.where('checklist_checkpoint_relation.chpo_id', chpo_id)
			})
			.then((result)=>{
				try {
					checklists.forEach((checkpoint)=>{
						checkpoint['chpo_id'] = id
					})
					return this._upsert(checklists, 'checklist_checkpoint_relation', 'chpo_id')
				} catch(e) {
					return null;
				}			
			})
			.then(()=>{
				return id
			}).catch(error => {
				console.log("Checkpoint Update Error == ", error);
			})
		}
	}
}

module.exports = CheckpointQueries;