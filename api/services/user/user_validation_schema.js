const ValidationSchema = require(__base + 'api/service_utils/validation_schema');

class UserValidationSchema extends ValidationSchema {
	constructor() {
		super();

		this.postSchema = {
			"pers_firstname": this.joi.string().required(),
			"pers_lastname": this.joi.string().required(),
			"pers_is_active":  this.joi.boolean(),
			"pers_username": this.joi.string().min(4).required(),
			"pers_password": this.joi.string().min(8).required(),
			"pers_addresses": this.joi.array().items(
				this.joi.object({
					"address_street_name": this.joi.string().required(),
					"address_street_number": this.joi.string().required(),
					"address_zipcode": this.joi.string().required(),
					"address_city": this.joi.string().required(),
					"address_country": this.joi.string().required(),
					"address_type": this.joi.string().required(),
				})
			),
			"pers_email_addresses": this.joi.array().items(
				this.joi.object({
					"email_address": this.joi.string().required(),
					"email_type": this.joi.string().required(),
					"email_notification_time": this.joi.string().required()
				})
			),
			"pers_phone_numbers": this.joi.array().items(
				this.joi.object({
					"phone_number": this.joi.string().required(),
					"phone_type": this.joi.string().required()
				})
			),
			"pers_scope": this.joi.string().required(),
			"pese_elevator_limit": this.joi.number().integer(),
			"pese_estate_limit": this.joi.number().integer(),
			"pese_user_limit": this.joi.number().integer(),

		};

		this.putSchema = Object.assign({}, this.postSchema);

		this.patchSchema = {
			"pers_firstname": [this.joi.string().min(1)],
			"pers_lastname": [this.joi.string().min(1)],
			"pers_is_active":  [this.joi.boolean()],
			"pers_username": [this.joi.string().min(1)],
			"pers_password": [this.joi.string().min(8)],
			"pers_addresses": [this.joi.array().items(
				this.joi.object({
					"address_street_name": this.joi.string().min(1),
					"address_street_number": this.joi.string().min(1),
					"address_street_zipcode": this.joi.string().min(1),
					"address_city": this.joi.string().min(1),
					"address_country": this.joi.string().min(1),
					"address_type": this.joi.string().min(1),
				})
			)],
			"pers_email_addresses": [this.joi.array().items(
				this.joi.object({
					"email_address": this.joi.string().min(1),
					"email_type": this.joi.string().min(1),
					"email_notification_time": [this.joi.string().allow('')]
				})
			)],
			"pers_phone_numbers": [this.joi.array().items(
				this.joi.object({
					"phone_number": this.joi.string().min(1),
					"phone_type": this.joi.string().min(1)
				})
			)],
			"pers_scope": [this.joi.string()],
			"pese_elevator_limit": this.joi.number().integer(),
			"pese_estate_limit": this.joi.number().integer(),
			"pese_user_limit": this.joi.number().integer(),
		};
	}

	post(){
		// console.log("User add Validation Schema === ");
		return super.post(this.postSchema);
	}

	put(){
		let putSchema = Object.assign({}, this.putSchema);
		putSchema['pers_id'] = this.joi.string().min(1).max(100).required();
		return super.put(putSchema);
	}

	putById(){
		return super.putById(this.putSchema)
	}

	patch(){
		let patchSchema = Object.assign({}, this.patchSchema);
		patchSchema['pers_id'] = this.joi.string().min(1).max(100).required();
		return super.patch(patchSchema);
	}

	patchById(){
		return super.patchById(this.patchSchema);
	}
}


module.exports = UserValidationSchema;