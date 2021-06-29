const Joi = require('joi');

class ValidationSchema {
	constructor() {
		this.joi = Joi;
	}

	get(){
		return {
			query: {
				limit: [this.joi.number().integer().min(0)],
				offset: [this.joi.number().integer().min(0)],
				search: this.joi.string(),
				check: this.joi.string()
			}
		}
	}

	post(schema){
		return {
			payload: schema
		}
	}

	put(schema){
		return {
			payload: schema
		}
	}

	putById(schema){
		return {
			payload: schema
		}
	}

	patch(schema){
		return {
			payload: schema
		}
	}

	patchById(schema){
		return {
			payload: schema
		}
	}

	delete(){
		return {
			params: {
				id: this.joi.string().required()
			}
		}
	}
	
}

module.exports = ValidationSchema;