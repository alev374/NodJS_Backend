const ValidationSchema = require(__base + 'api/service_utils/validation_schema');

class EstateValidationSchema extends ValidationSchema {
	constructor() {
		super();

		this.postSchema = {
			"esta_approach": this.joi.string().allow(''),
			"esta_facility_manager": [this.joi.object({
				"facility_manager_name": this.joi.string().allow(''),
				"facility_manager_phone_number": this.joi.string().allow('')
			})],
			"esta_address": this.joi.object({
				"address_street_name": this.joi.string().required(),
				"address_street_number": this.joi.string().required(),
				"address_zipcode": this.joi.string().required(),
				"address_city": this.joi.string().required(),
				"address_country": this.joi.string().required()
			}),
			"esta_stakeholders": this.joi.alternatives().try(
				this.joi.array().items(
					this.joi.object({
						"pers_id": this.joi.string(),
					})
				),
				this.joi.allow(null)
			).required()
		};

		this.putSchema = Object.assign({}, this.postSchema);

		this.patchSchema = {
			"esta_approach": [this.joi.string().allow('')],
			"esta_facility_manager": [this.joi.object({
				"facility_manager_name": this.joi.string().required(),
				"facility_manager_phone_number": this.joi.string().required()
			})],
			"esta_address": [this.joi.object({
				"address_street_name": this.joi.string().required(),
				"address_street_number": this.joi.string().required(),
				"address_zipcode": this.joi.string().required(),
				"address_city": this.joi.string().required(),
				"address_country": this.joi.string().required()
			})],
			"esta_stakeholders": [this.joi.alternatives().try(
				this.joi.array().items(
					this.joi.object({
						"esta_id": [this.joi.string()],
						"pers_id": this.joi.string()
					})
				),
				this.joi.allow(null)
			)]
		};
	}

	post(){
		return super.post(this.postSchema);
	}

	put(){
		let putSchema = Object.assign({}, this.putSchema);
		putSchema['esta_id'] = this.joi.string().min(1).max(100).required();
		return super.put(putSchema);
	}

	putById(){
		return super.putById(this.putSchema)
	}

	patch(){
		let patchSchema = Object.assign({}, this.patchSchema);
		patchSchema['esta_id'] = this.joi.string().min(1).max(100).required();
		return super.patch(patchSchema);
	}

	patchById(){
		return super.patchById(this.patchSchema);
	}
}


module.exports = EstateValidationSchema;