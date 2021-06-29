'use strict';

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const boom = require('boom');
const recoveryEmail = require(__base + 'email/pw_recovery_email');
const IdGenerator = require(__base + 'api/service_utils/id_generator');

class Auth{
	constructor() {	
		this.salt = 10;
		this.secret = 'SYP9Aa2ROdIxzsptHX7qgNMx3dUrWtsv2l5';
		this.expirationTime = '12h'
	}

	_loginValidation(db, username, password){
		let error = boom.forbidden(`Invalid username: ${username}`);
		return db.select('pers_id', 'pers_username', 'pers_password', 'pers_scope').from('person').where('pers_username', username)
		.then((data)=>{
			data = data[0]
			return db.select('pero_scope').from('person_role_config').where('pero_id', data.pers_scope)
			.then((result)=>{			
				data.pers_scope = result[0].pero_scope;
				data.scope = result[0].pero_scope;
				return data;
			})
		})
		.then((data)=>{
			error = boom.forbidden('Invalid password');
			return this.checkPassword(password, data.pers_password)
			.then((result)=>{
				// if(result){
				// 	return {data: data, error: error};
				// }
				// else{
				// 	return {data: null, error: error};
				// }
				return {data: data, error: error};
			})
		})
		.catch((err)=>{
			// return {data: null, error: error};
			return {data: data, error: error};
		})
	}

	validateLogin(db, username, password, callback){
		let error = boom.forbidden(`Invalid username: ${username}`);
		return this._loginValidation(db, username, password)
		.then((result)=>{
			if(result.data){
				delete result.data.pers_password;
				result.data.pers_token = jwt.sign(result.data, this.secret, { expiresIn: this.expirationTime });
				return callback(null, true, result.data)
			}
			else{
				return callback(result.error, false, result.error)
			}
		})
		.catch((err)=>{
			return callback(error, false, error)
		})
	}

	validateToken(db, decoded, request, callback){
		
		return db.select('pers_scope').from('person').where('pers_id', decoded.pers_id).andWhere('pers_username', decoded.pers_username)
		.then((result)=>{
			if(result.length > 0){
				return db.select('pero_id').from('person_role_config').where('pero_id', result[0].pers_scope).andWhere('pero_scope', decoded.pers_scope)
			}
			else{
				throw new Error('token username or id are not valid');
			}
		})
		.then((result)=>{
			if(result.length > 0){
				return callback(null, true);
			}
			else{
				throw new Error('token scope is not valid');
			}
		})
		.catch((err)=>{
			console.log(err);
			return callback(null, false);
		})
	}

	generateHash(password, salt = this.salt){
		return bcrypt.hash(password, salt)
	}

	checkPassword(password, hash){
		bcrypt.hash(password, this.salt).then(result => {
			console.log("Password Hash ==== ", result);
		})
		
		console.log("Database Hash ==== ", hash);
		return bcrypt.compare(password, hash)
	}

	resetPassword(db, pers_username, pers_password = null){
		let pers_id = null;
		let pers_email_addresses = null;
		let password = pers_password;
		let passwordHash = null;
	 	return db.select('pers_id', 'pers_email_addresses').from('person_view').where('pers_username', pers_username)
		.then((result)=>{
			if(Array.isArray(result) && result.length == 0){
				return Promise.reject( boom.forbidden(`Invalid username: ${pers_username}`));
			}
			pers_id = result[0].pers_id;
			pers_email_addresses = result[0].pers_email_addresses;
			password = (password) ? password : new IdGenerator(db).buildId(8);
			return this.generateHash(password);			
		})
		.then((hash)=>{
			passwordHash = hash;

			let emailPromises = [];
			const emailContent = recoveryEmail.buildEmail(pers_username, password);
			pers_email_addresses.forEach((email)=>{
				emailPromises.push(recoveryEmail.send(email.email_address, emailContent))
			})
			return Promise.all(emailPromises)
		})
		.then((result)=>{
			return db.transaction((trx)=>{
				return db('person')
				.where('pers_id', pers_id)
				.transacting(trx)
				.update({pers_password: passwordHash})
				.returning('pers_id')
				.then((response)=>{
					trx.commit;
					return {pers_id:response[0]};
				})
				.catch(trx.rollback)
			});
		})
	}

	changePassword(db, pers_username, pers_password, pers_new_password){
		return this._loginValidation(db, pers_username, pers_password)
		.then((result)=>{
			if(result.data){
				return this.resetPassword(db, pers_username, pers_new_password);
			}
			else{
				return result.error;
			}
		})
	}
}

// new Auth().generateHash('', 15).then((hash)=>{
// 	console.log(hash);
// })

module.exports = new Auth();
