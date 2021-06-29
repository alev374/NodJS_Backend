const ValidationSchema = require(__base + 'api/service_utils/validation_schema');

class ElevatorValidationSchema extends ValidationSchema {
	constructor() {
		super();

		this.postSchema = {
			"elev_serial_number": this.joi.string().required(),
			"elev_barcode": this.joi.string().required(),
			"elev_manufacturer": this.joi.string().required(),
			"elev_build_year": this.joi.string().required(),
			"elev_location": this.joi.string().required(),
			"elev_type": this.joi.string().required(),
			"elev_is_active": this.joi.boolean().required(),
			"elev_emergency_information": this.joi.object({
				"emergency_company": this.joi.string(),
				"emergency_company_phone_number": this.joi.string(),
				"emergency_exit_instructions": this.joi.string().allow(''),
				"emergency_phone_number": this.joi.string()
			}).required(),
			"elev_inspection_days": this.joi.array().items(
				this.joi.string()
			).required(),
			"pers_inspector_id": this.joi.string().required(),
			"pers_substitute_id": this.joi.alternatives().try(this.joi.string(), this.joi.allow(null)),
			"esta_id": this.joi.string().required(),
			// "chli_id": this.joi.alternatives().try(this.joi.string(), this.joi.allow(null)).required(),
			"elev_chpoints": this.joi.alternatives().try(
				this.joi.array().items(
					this.joi.object({
						"chpo_id": this.joi.string()
					})
				),
				this.joi.allow(null)
			).required(),
			"elev_last_inspection": [this.joi.alternatives().try(this.joi.date().timestamp(), this.joi.string().isoDate())]
		};

		this.putSchema = Object.assign({}, this.postSchema);

		this.patchSchema = {
			"elev_serial_number": [this.joi.string()],
			"elev_barcode": [this.joi.string()],
			"elev_manufacturer": [this.joi.string()],
			"elev_build_year": [this.joi.string()],
			"elev_location": [this.joi.string()],
			"elev_type": [this.joi.string()],
			"elev_is_active": [this.joi.boolean()],
			"elev_emergency_information": [this.joi.object({
				"emergency_company": this.joi.string(),
				"emergency_company_phone_number": this.joi.string(),
				"emergency_exit_instructions": this.joi.string().allow(''),
				"emergency_phone_number": this.joi.string()
			})],
			"elev_inspection_days": [this.joi.array().items(
				this.joi.string()
			)],
			"pers_inspector_id": [this.joi.string()],
			"pers_substitute_id": [this.joi.alternatives().try(this.joi.string(), this.joi.allow(null))],
			"esta_id": [this.joi.string()],
			// "chli_id": [this.joi.string(), this.joi.allow(null)],
			"elev_chpoints": [this.joi.alternatives().try(
				this.joi.array().items(
					this.joi.object({
						"chpo_id": this.joi.string()
					})
				),
				this.joi.allow(null)
			)],
			"elev_last_inspection": [this.joi.alternatives().try(this.joi.date().timestamp(), this.joi.string().isoDate())]
		};
	}

	post(){
		return super.post(this.postSchema);
	}

	put(){
		let putSchema = Object.assign({}, this.putSchema);
		putSchema['elev_id'] = this.joi.string().min(1).max(100).required();
		return super.put(putSchema);
	}

	putById(){
		return super.putById(this.putSchema)
	}

	patch(){
		let patchSchema = Object.assign({}, this.patchSchema);
		patchSchema['elev_id'] = this.joi.string().min(1).max(100).required();
		return super.patch(patchSchema);
	}

	patchById(){
		return super.patchById(this.patchSchema);
	}
}


module.exports = ElevatorValidationSchema;