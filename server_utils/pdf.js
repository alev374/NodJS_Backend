const PdfPrinter = require('pdfmake/src/printer');
const fs = require('fs');

class PDF {
	constructor() {
		this.basePath = `files/reports`;
		this.fonts = {
			SourceSansPro: {
				normal: `fonts/source_sans_pro/SourceSansPro-Regular.ttf`
			}
		}
		this.defaultStyle = {
			font: 'SourceSansPro'
		}
	}

	buildPDF(data = null){
		return {
			content: [],
			defaultStyle: this.defaultStyle
		};
	}

	createPDF(path = '', filename = '', data = ''){
		return new Promise((resolve, reject) => {
			try {
			 	let pdf = this.buildPDF(data);
				const printer = new PdfPrinter(this.fonts);
				let pdfDoc = printer.createPdfKitDocument(pdf);
				pdfDoc.pipe(fs.createWriteStream(`${this.basePath}/${path}/${filename}.pdf`)).on('finish', ()=>{
					resolve();
				});
				pdfDoc.end();				
			} catch(err) {
				console.log(err);
				reject(err)
			}           
		});
	}
}

module.exports = PDF;