const ValidationSchema = require(__base + 'api/service_utils/validation_schema');

class CheckpointValidationSchema extends ValidationSchema {
	constructor() {
		super();

		this.postSchema = {
			"chpo_headline": this.joi.string().required(),
			"chpo_description": this.joi.string().required(),
			"chpo_long_description": this.joi.string().required(),
			"chpo_emergency_description": this.joi.alternatives().try(this.joi.string().allow(''), this.joi.allow(null)).required(),
			"chpo_priority": this.joi.number().integer().required(),
			"chpo_default": this.joi.boolean()
		};

		this.putSchema = Object.assign({}, this.postSchema);

		this.patchSchema = {
			"chpo_headline": [this.joi.string()],
			"chpo_description": [this.joi.string()],
			"chpo_long_description": [this.joi.string()],
			"chpo_emergency_description": [this.joi.alternatives().try(this.joi.string().allow(''), this.joi.allow(null)).required()],
			"chpo_priority": [this.joi.number().integer()],
			"newIndex": [this.joi.number().integer()],
			"oldIndex": [this.joi.number().integer()],
			"chpo_default": this.joi.boolean()
		};
	}

	post(){
		return super.post(this.postSchema);
	}

	put(){
		let putSchema = Object.assign({}, this.putSchema);
		putSchema['chpo_id'] = this.joi.string().min(1).max(100).required();
		return super.put(putSchema);
	}

	putById(){
		return super.putById(this.putSchema)
	}

	patch(){
		let patchSchema = Object.assign({}, this.patchSchema);
		patchSchema['chpo_id'] = this.joi.string().min(1).max(100).required();
		return super.patch(patchSchema);
	}

	patchById(){
		return super.patchById(this.patchSchema);
	}
}


module.exports = CheckpointValidationSchema;