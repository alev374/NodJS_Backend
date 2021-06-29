const fs = require('fs');
const mkdirp = require('mkdirp');

class FileUpload {
	constructor() {
		this.allowedContentTypes = [
			'image/jpeg',
			'image/png'
		],
		this.base64Prefix = 'data:image/jpeg;base64,';
	}

	saveFiles(files, path){
		let promises = [];
		files.forEach((file)=>{
			let promise = this.saveBase64File(file, path);
			if(promise){
				promises.push(promise);
			}			
		})
		return Promise.all(promises);
	}

	saveBase64File(file, path){
		path = `${__base}files/reports/${path}/${file.image_filename}.jpg`;
		if(file.image_base64.includes(this.base64Prefix)){
			file.image_base64 = file.image_base64.replace(/^data:image\/\w+;base64,/, '');
			return new Promise((resolve, reject) => {
				let buffer = new Buffer(file.image_base64, 'base64');
				fs.writeFile(path, buffer, (err) => {
					if(err){
						console.log(err);
						reject(err)
					}
					else{
						resolve(path);
					}
				});
			});
		}
	}

	saveFile(file, path){
		if(this.allowedContentTypes.indexOf(file.hapi.headers['content-type']) == -1){
			return null;
		}
		return new Promise((resolve, reject) => {
			const name = file.hapi.filename;
			path = `${__base}files/reports/${path}/${name}`
			let writeStream = fs.createWriteStream(path);

			writeStream.on('error', function (err) {
				reject(err);
			});

			file.pipe(writeStream);

			file.on('end', function (err) {
				if(err){
					reject(err);
				}
				resolve({
					filename: file.hapi.filename,
					headers: file.hapi.headers
				});
			})
		});		
	}
}

module.exports = new FileUpload();