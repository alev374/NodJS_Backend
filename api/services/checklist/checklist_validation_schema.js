const ValidationSchema = require(__base + 'api/service_utils/validation_schema');

class ChecklistValidationSchema extends ValidationSchema {
	constructor() {
		super();

		this.postSchema = {
			"chli_name": this.joi.string().required(),
			"chli_checkpoints": this.joi.alternatives().try(
				this.joi.array().items(
					this.joi.object({
						"chpo_id": this.joi.string()
					})
				),
				this.joi.allow(null)
			).required()
		};

		this.putSchema = Object.assign({}, this.postSchema);

		this.patchSchema = {
			"chli_name": [this.joi.string()],
			"chli_checkpoints": [this.joi.alternatives().try(
				this.joi.array().items(
					this.joi.object({
						"chpo_id": this.joi.string()
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
		putSchema['chli_id'] = this.joi.string().min(1).max(100).required();
		return super.put(putSchema);
	}

	putById(){
		return super.putById(this.putSchema)
	}

	patch(){
		let patchSchema = Object.assign({}, this.patchSchema);
		patchSchema['chli_id'] = this.joi.string().min(1).max(100).required();
		return super.patch(patchSchema);
	}

	patchById(){
		return super.patchById(this.patchSchema);
	}
}


module.exports = ChecklistValidationSchema;