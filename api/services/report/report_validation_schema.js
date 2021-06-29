const ValidationSchema = require(__base + 'api/service_utils/validation_schema');

class ReportValidationSchema extends ValidationSchema {
	constructor() {
		super();

		this.multipartFormSchema = {
			"image": this.joi.any(),
			"json": this.joi.string().required()
		}

		this.postSchema = {
			"repo_checkpoints": this.joi.array().items(
				this.joi.object({
					"chpo_id": this.joi.string().required(),
					"chpo_headline": this.joi.string().required(),
					"chpo_description": this.joi.string().required(),
					"chpo_long_description": this.joi.string().required(),
					"chpo_emergency_description": this.joi.alternatives().try(this.joi.string(), this.joi.allow(null)).required(),
					"chpo_priority": this.joi.string().required(),
					"chpo_is_ok": this.joi.boolean().required(), 
					"chpo_annotation": [this.joi.string().allow('')],
					"chpo_images": this.joi.array().items(
						[this.joi.object({
							"image_filename": this.joi.string().required(),
							"image_base64": this.joi.string().required(),
						})]
					).required()
				})
			),
			"repo_inspector": this.joi.object({
				"pers_id": this.joi.string().required(),
				"pers_firstname": this.joi.string().required(),
				"pers_lastname": this.joi.string().required(),
				"pers_addresses": this.joi.array().items(
					this.joi.object({
						"address_street_name": this.joi.string().required(),
						"address_street_number": this.joi.string().required(),
						"address_zipcode": this.joi.string().required(),
						"address_city": this.joi.string().required(),
						"address_country": this.joi.string().required(),
						"address_type": [this.joi.string()],
					})
				),
				"pers_email_addresses": this.joi.array().items(
					this.joi.object({
						"email_address": this.joi.string().required(),
						"email_type": this.joi.string().required(),
						"email_notification_time": this.joi.string().allow(''),
						"email_is_receiving": this.joi.boolean()
					})
				),
				"pers_phone_numbers": this.joi.array().items(
					this.joi.object({
						"phone_number": this.joi.string().required(),
						"phone_type": this.joi.string().required()
					})
				),
				"pers_is_substitute": this.joi.boolean().required()
			}),
			"repo_elevator": this.joi.object({
				"elev_id": this.joi.string().required(),
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
				).required()
			}),
			"repo_estate": this.joi.object({
				"esta_id": this.joi.string(),
				"esta_approach": this.joi.string().allow(''),
				"esta_facility_manager": this.joi.object({
					"facility_manager_name": this.joi.string().required(),
					"facility_manager_phone_number": this.joi.string().required()
				}),
				"esta_address": this.joi.object({
					"address_street_name": this.joi.string().required(),
					"address_street_number": this.joi.string().required(),
					"address_zipcode": this.joi.string().required(),
					"address_city": this.joi.string().required(),
					"address_country": this.joi.string().required(),
					"address_type": [this.joi.string()]
				}),
				"esta_stakeholders": [this.joi.array().items(
					this.joi.object()
				)]
			})
		};

		this.putSchema = Object.assign({}, this.postSchema);

		
	}

	postMultipartForm(val, options, next){
		return {
			payload: (val, options, next)=>{
				let isFormDataValid = this.joi.validate(val, this.multipartFormSchema);
				if(isFormDataValid.error){
					next(isFormDataValid.error, val);
				}
				else{
					try {
						let isJsonDataVaild = this.joi.validate(JSON.parse(val.json), this.postSchema);
						if(isJsonDataVaild.error){
							next(isJsonDataVaild.error, val);
						}
						else{
							next(null, val);
						}
					} catch(err) {
						next(err, val);
					}
					
				}				
			}
		}
				
	}

	post(){		
		return super.post(this.postSchema);
	}

	put(){
		let putSchema = Object.assign({}, this.putSchema);
		putSchema['repo_id'] = this.joi.string().min(1).max(100).required();
		return super.put(putSchema);
	}

	putById(){
		return super.putById(this.putSchema)
	}

	patch(){
		let putSchema = Object.assign({}, this.putSchema);
		putSchema['repo_id'] = this.joi.string().min(1).max(100).required();
		return super.patch(putSchema);
	}

	patchById(){
		return super.patchById(this.putSchema);
	}
}


module.exports = ReportValidationSchema;