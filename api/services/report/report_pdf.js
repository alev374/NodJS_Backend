const PDF = require(__base + 'server_utils/pdf');
const moment = require('moment');
const fs = require('fs');

class ReportPDF extends PDF {
	constructor() {
		super();
	}

	buildPDF(data = null){
		let pdf = super.buildPDF(data);
		pdf.header = (currentPage, pageCount) => {
			return {
				'text': (currentPage > 1) ? `Prüfprotokoll für Aufzug ${data.repo_elevator.elev_serial_number} vom ${moment(data.repo_creation).format('DD.MM.YYYY')}` : '',
				alignment: 'left',
				margin: [40, 20, 0, 0],
				fontSize: 9
			}
		}
		pdf.footer = (currentPage, pageCount) => {
			return {
				columns: [
				{
					'text': `Erstellt mit der App der Aufzugwärter GmbH – aufzugwaerter.info`,
					alignment: 'left',
					margin: [40, 0, 0, 20],
					fontSize: 9
				},
				{
					text: `${currentPage.toString()} / ${pageCount}`,
					alignment: 'right',
					margin: [0, 0, 40, 20],
					fontSize: 9
				}
				]
			}
		}
		pdf.styles = {
			intro: {
				fontSize: 14,
				lineHeight: 2
			},
			paragraph: {
				fontSize: 12,
				lineHeight: 1.25
			},
			spacer:{
				margin: [0, 0, 0, 10]
			},
			checkpointHeadline:{
				fontSize: 12,
				lineHeight: 1.25
			},
			checkpointDescription:{
				fontSize: 10,
				lineHeight: 1.25
			},
			checkpointLongDescriptionIntro:{
				margin: [0, 0, 0, 10]
			},
			checkpointLongDescription:{
				fontSize: 9,
				lineHeight: 1.25
			},
			checkpointAnnotation:{
				lineHeight: 1.25
			},
			checkpointAnnotationNegative:{
				color:'red'
			},
			checkpointAnnotationPositive:{
				color:'green'
			},
			checkpointImageReference:{
				fontSize: 9				
			}
		};
		pdf.content.push({
			text: `Prüfprotokoll für Aufzug ${data.repo_elevator.elev_serial_number} vom ${moment(data.repo_creation).format('DD.MM.YYYY')}`,
			style: 	'intro'
		});
		pdf.content.push({
			text: `Adresse: ${data.repo_estate.esta_address.address_street_name} ${data.repo_estate.esta_address.address_street_number}, ${data.repo_estate.esta_address.address_zipcode} ${data.repo_estate.esta_address.address_city}, ${data.repo_estate.esta_address.address_country}`,
			style: 'paragraph'
		});
		if(data.repo_elevator.elev_location != ''){
			pdf.content.push({
				text: `Standort: ${data.repo_elevator.elev_location}`,
				style: 'paragraph'
			});
		}
		pdf.content.push({
			text: `Aufzugwärter: ${data.repo_inspector.pers_firstname} ${data.repo_inspector.pers_lastname}`
		});
		pdf.content.push({
			text: `Seriennummer: ${data.repo_elevator.elev_serial_number} | Baujahr: ${data.repo_elevator.elev_build_year} | Hersteller: ${data.repo_elevator.elev_manufacturer}`,
			style: ['paragraph','spacer']
		});
		pdf.content.push({
			text: `Prüfpunkte:`,
			style: ['paragraph','spacer']
		});

		// add checkpoints
		data.repo_checkpoints.forEach((checkpoint, index) => {
			pdf.content.push({
				text: `${index + 1}. ${checkpoint.chpo_headline}:`,
				style: ['checkpointHeadline']
			});
			if(checkpoint.chpo_is_ok === false){
				const priority = (checkpoint.chpo_priority != 'normal') ? ` (${checkpoint.chpo_priority})` : ``; 
				const annotation = (checkpoint.chpo_annotation != '') ? `: ${checkpoint.chpo_annotation}` : ``;
				pdf.content.push({
					text: `Mangel${priority}${annotation}`,
					style: ['checkpointAnnotation','checkpointAnnotationNegative']
				})
				if(checkpoint.chpo_images.length > 0){
					pdf.content.push({
						text: `(siehe Bilder im Anhang)`,
						style: ['checkpointAnnotation','checkpointImageReference']
					})
				}
			}
			else{
				pdf.content.push({
					text: `Kein Mangel`,
					style: ['checkpointAnnotation','checkpointAnnotationPositive']
				})
			}
		});	

		// add image attachment
		let isFirstAttachment = true;
		data.repo_checkpoints.forEach((checkpoint, index) => {
			if(checkpoint.chpo_images.length > 0){
				if(isFirstAttachment){
					pdf.content.push({
						text: `Anhang:`,
						style: 'intro',
						pageBreak: 'before'
					});
					pdf.content.push({
						text: `${index + 1}. ${checkpoint.chpo_headline}:`,
						style: ['checkpointHeadline']
					});
					isFirstAttachment = false;
				}
				else{
					pdf.content.push({
						text: `${index + 1}. ${checkpoint.chpo_headline}:`,
						style: ['checkpointHeadline'],
						pageBreak: 'before'
					});
				}
				// add images
				let contentColumn = {
					alignment: 'justify',
					columns: []
				};
				let imageIndex = 0;
				let imageFilePath = '';
				for (let image of checkpoint.chpo_images){
					imageFilePath= `${this.basePath}/${data.repo_elevator.elev_id}/${data.repo_id}/${image.image_filename}.jpg`;
						if(fs.existsSync(imageFilePath)){
							contentColumn.columns.push({
								image: imageFilePath,
								fit: [250, 250],
								margin: [0, 5, 5, 5]
							});
						}
						else{
							contentColumn.columns.push({
								text: 'Bild konnte nicht geladen werden.',
								fit: [250, 250],
								margin: [0, 5, 5, 5]
							});
						}
						if(imageIndex == checkpoint.chpo_images.length - 1){
							pdf.content.push(contentColumn);
							break;
						}
						if(imageIndex != 0 && imageIndex % 2 == 1){
							pdf.content.push(contentColumn);				
							contentColumn = {
								alignment: 'justify',
								columns: []
							}
							
						}
						if(imageIndex != 0 && imageIndex % 4 == 0){
							contentColumn.pageBreak = 'before'
						}
						imageIndex++;	

				}
			}
		});
		
		return pdf;
	}
}

module.exports = new ReportPDF();