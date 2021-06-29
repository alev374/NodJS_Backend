const Queries = require(__base + 'api/service_utils/queries');
const password = require(__base + 'server_utils/auth');
const passwordRecoveryEmail = require(__base + 'email/pw_recovery_email');


class UsersQueries extends Queries{
	constructor(db, table, table_id, table_fulltext, table_alias) {
		super(db, table, table_id, table_fulltext, table_alias);
		this.password = password;
	}

	get(auth = {}, select = '', limit = this.limit, offset = this.offset, search = null){
		if(select == ''){
			select = `${this.table}_view.*`;
		}
		return super.get(auth, select, limit, offset, search)
	}

	getById(auth = {}, id = '', table_id= `${this.table}_view.${this.table_id}`){
		return this.get(auth, `${this.table}_view.*`).where(table_id, id);
	}

	search(auth = {}, search = '', limit = this.limit, offset = this.offset, table_fulltext = this.table_fulltext, select = `${this.table}_view.*`){
		select = `${this.table}_view.*`;
		return super.search(auth, search, limit, offset, table_fulltext, select);
	}
	
	check(auth = {}, check){
		return super.check(auth, check, `pers_username = '${check}'`)
	}

	post(auth = {}, data = {}){
		console.log("User Post ===== ", data);
		let newData = {...data};
		let pers_creator = ''; //pers_id when creator is owner_selfmanaged
		if (data.hasOwnProperty('pers_scope')) {
			if (auth.pers_scope === 'owner_selfmanaged' && (data.pers_scope != 'inspector')) {
				throw new Error('Not allowed to create person of scope owner, manager or admin')
			} 
			if (auth.pers_scope !== 'admin' && (data.pers_scope == 'admin' || data.pers_scope == 'manager')) {
				throw new Error('Not allowed to create person of scope admin or manager')
			}

			if (auth.pers_scope === 'owner_selfmanaged' && data.pers_scope === 'inspector') {
				pers_creator = auth.pers_id;
				newData = {
					...newData,
					'pers_created_by': pers_creator
				}
			}
		}

		let pers_id = null;	
		let inputData = Object.assign({}, newData);
		return this.db.select('pero_id').from('person_role_config').where('pero_scope', newData.pers_scope)
		.then((result)=>{		
			newData.pers_scope = result[0].pero_id;
			return newData;
		})
		.catch(()=>{
			newData.pers_scope = 3;
			return newData;
		})
		.then((data) => {
			if (auth.pers_scope === 'owner_selfmanaged' && data.pers_scope === 3) { // When owner_selfmanaged user add inspector users
				return new Promise((resolve, reject) => {
					this.db.select('person_selfmanaged_limit.*').from('person_selfmanaged_limit').whereRaw(`pers_id = '${auth.pers_id}'`)
					.then(result => {
						console.log("Limit check result === ", result);
						if (
							parseInt(result[0].pese_user_limit ? result[0].pese_user_limit : 0) == 0 ||
							parseInt(result[0].pese_user_limit ? result[0].pese_user_limit : 0) > parseInt(result[0].pese_user_created ? result[0].pese_user_created : 0)
							) {
								console.log("User can be added!!!!");
								resolve(newData);
							}
						else {
							reject('User creation is limited!');
							// throw new Error('User creation is limited')
						}
					})
					.catch(error => {
						reject(error)
					})
				});
			} else {
				return newData;
			}
		})
		.then((newData)=>{
			console.log("User add newData Before generateHash === ", newData);
			return this.password.generateHash(newData.pers_password);
		})
		.then((hash)=>{
			newData.pers_password = hash;
			if (newData.pese_elevator_limit || newData.pese_estate_limit || newData.pese_user_limit) {
				const { pese_elevator_limit, pese_estate_limit, pese_user_limit, ...otherData} = newData;
				return super.post(auth, otherData, this.table, this.table_id, true);
			} else {
				return super.post(auth, newData, this.table, this.table_id, true);
			}
			
		}).
		then((id) => {
			return new Promise((resolve, reject) => {
				if (inputData.pese_elevator_limit || inputData.pese_estate_limit || inputData.pese_user_limit) {
					//When self_usermanaged user is added!
					let limitData = {
						'pers_id': id,
						'pese_elevator_limit': inputData.pese_elevator_limit,
						'pese_estate_limit': inputData.pese_estate_limit,
						'pese_user_limit': inputData.pese_user_limit
					}
					this._insert(limitData, 'person_selfmanaged_limit', 'pers_id').then(() => {
						this.db.raw('REFRESH MATERIALIZED VIEW person_view').then(() => {
							resolve(id);
						})
					});
				} else if (pers_creator != '') { 
					// Add 1 to the user created number at person_selfmanaged_limit table if self_usermanaged created a inspector user
					this.db.select('person_selfmanaged_limit.*').from('person_selfmanaged_limit').whereRaw(`pers_id = '${pers_creator}'`)
					.then(result => {
						let updateData = {
							'pese_user_created': result[0].pese_user_created ? parseInt(result[0].pese_user_created) + 1 : 1
						};
						console.log("User add result preparing 1111 , ", result, updateData);
						
						this._update(updateData, 'person_selfmanaged_limit', 'pers_id', `pers_id = '${pers_creator}'`).then(() =>{
							this.db.raw('REFRESH MATERIALIZED VIEW person_view').then(() => {
								resolve(id);
							})
						}).catch(error => {
							reject()
						})
					})
				} else if (inputData.pers_scope == 'owner_selfmanaged') {
					//When self_usermanaged user is added!
					let limitData = {
						'pers_id': id,
						'pese_elevator_limit': 0,
						'pese_estate_limit': 0,
						'pese_user_limit': 0
					}
					this._insert(limitData, 'person_selfmanaged_limit', 'pers_id').then(() => {
						this.db.raw('REFRESH MATERIALIZED VIEW person_view').then(() => {
							resolve(id);
						})
					});
				} else {
					resolve(id);
				}
			})
		})
		.then((id)=>{
			pers_id = id;
			return this.db.select('pers_username', 'pers_email_addresses').from('person_view').where('pers_id', pers_id);
		})
		.then((response)=>{
			let emailPromises = [];
			if(response){
				const emailContent = passwordRecoveryEmail.buildEmail(response[0].pers_username, password);
				response[0].pers_email_addresses.forEach((email)=>{
					emailPromises.push(passwordRecoveryEmail.send(email.email_address, emailContent));
				});
			}
			if(emailPromises.length > 0){
				return Promise.all(emailPromises);
			}
			return null;
		})
		.then(() => {
			return this.setInactive(data, pers_id);
		})
		.then((response)=>{
			return pers_id;
		})
		.catch((e)=>{
			console.log(e);
		})
	}

	put(auth = {}, data = {}){
		// console.log("User Put ===== ", data);
		let pers_id = null;
		let inputData = Object.assign({}, data);
		return Promise.resolve(data)
		.then(data => {
			if (data.hasOwnProperty('pers_scope')) {
				if (auth.pers_scope !== 'admin' && (data.pers_scope == 'admin' || data.pers_scope == 'manager')) {
					throw new Error('Not allowed to change scope of person to admin or manager')
				}
				return this.db.select('pero_id').from('person_role_config').where('pero_scope', data.pers_scope)
				.then((result) => {
					data.pers_scope = result[0].pero_id;
					return data;
				})
			}
			return data
		})
		.then(data => {
			if (data.hasOwnProperty('pers_password')) {
				console.log('pers_password');
				return this.password.generateHash(data.pers_password)
				.then(hash => {
					data.pers_password = hash;
					return data; 
				})
			}
			return data
		})
		.then(data => {
			if (data.pese_elevator_limit || data.pese_estate_limit || data.pese_user_limit) {
				const { pese_elevator_limit, pese_estate_limit, pese_user_limit, ...otherData} = data;
				return super.put(auth, otherData, this.table, this.table_id)
			} else {
				return super.put(auth, data, this.table, this.table_id);
			}
		})
		.then((id) => {
			return new Promise((resolve, reject) => {
				if (inputData.pese_elevator_limit || inputData.pese_estate_limit || inputData.pese_user_limit) {
					let limitData = {
						'pers_id': id,
						'pese_elevator_limit': inputData.pese_elevator_limit,
						'pese_estate_limit': inputData.pese_estate_limit,
						'pese_user_limit': inputData.pese_user_limit
					}
					this.checkDuplicate(`pers_id = '${id}'`, 'person_selfmanaged_limit', 'pers_id')
					.then(result => {
						 console.log("Check Result  === ", result);
						if (result.length == 0) {
							this._insert(limitData, 'person_selfmanaged_limit', 'pers_id').then(() => {
								this.db.raw('REFRESH MATERIALIZED VIEW person_view').then(() => {
									resolve(id);
								})
							}).catch(error => {
								reject()
							})
						} else {
							this._update(limitData, 'person_selfmanaged_limit', 'pers_id', `pers_id = '${id}'`).then(() =>{
								this.db.raw('REFRESH MATERIALIZED VIEW person_view').then(() => {
									resolve(id);
								})
							}).catch(error => {
								reject()
							})
						}
					})
				} else if (inputData.pers_scope == 'owner_selfmanaged') {
					//When self_usermanaged user is added!
					let limitData = {
						'pers_id': id,
						'pese_elevator_limit': 0,
						'pese_estate_limit': 0,
						'pese_user_limit': 0
					}
					this._insert(limitData, 'person_selfmanaged_limit', 'pers_id').then(() => {
						this.db.raw('REFRESH MATERIALIZED VIEW person_view').then(() => {
							resolve(id);
						})
					});
				} else {
					resolve(id)
				}
			})
		})
		.then(id => {
			pers_id = id;
			if (data.hasOwnProperty('pers_password')) {
				return this.db.select('pers_username', 'pers_email_addresses').from('person_view').where('pers_id', pers_id)
				.then((response) => {
					let emailPromises = [];
					if (response) {
						const emailContent = passwordRecoveryEmail.buildEmail(response[0].pers_username, password);
						response[0].pers_email_addresses.forEach((email) => {
							emailPromises.push(passwordRecoveryEmail.send(email.email_address, emailContent));
						});
					}
					if (emailPromises.length > 0) {
						return Promise.all(emailPromises);
					}
					return null;
				})
			}
			return null;
		})
		.then(mail => {
			return this.setInactive(data, pers_id);
		})
		.then(response => {
			return pers_id;
		})
		.catch((e) => {
			console.log(e);
		})
	}

	setInactive(data, pers_id) {
		if (data.hasOwnProperty('pers_is_active') && data.pers_is_active === false) {
			return this._update({ pers_inspector_id: null }, 'elevator', 'elev_id', `pers_inspector_id = '${pers_id}'`)
			.then(()=>{
				return this._update({ pers_substitute_id: null }, 'elevator', 'elev_id', `pers_substitute_id = '${pers_id}'`);
			})
			.then(()=>{
				return this._delete('estate_stakeholder', 'pers_id', `pers_id = '${pers_id}'`);
			})
			.then(() => {
				return this._delete('access_log', 'aclo_owner', `aclo_owner = '${pers_id}' and aclo_content_table != 'person'`);
			})
			.then(()=>{
				return this.db.raw('REFRESH MATERIALIZED VIEW elevator_view; REFRESH MATERIALIZED VIEW estate_view;')
			})
		}
	}

	deleteConnection(auth={}, data={}) {
		console.log("deleteConnection input data === ", auth, data);
		let deleter = auth.pers_id;
		if (!data.id) {
			return;
		}
		return this.db.select('person_selfmanaged_limit.*').from('person_selfmanaged_limit').whereRaw(`pers_id = '${deleter}'`)
		.then(result => {
			this.db.raw('REFRESH MATERIALIZED VIEW person_view').then(() => {
			})
		})
	}
}

module.exports = UsersQueries;