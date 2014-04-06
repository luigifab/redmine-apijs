"use strict";
/**
 * Copyright 2013-2014 | Fabrice Creuzot (luigifab) <code~luigifab~info>
 * https://redmine.luigifab.info/projects/redmine/wiki/apijs
 *
 * This program is free software, you can redistribute it or modify
 * it under the terms of the GNU General Public License (GPL).
 */

// en cas d'erreur
function showDialogError(data) {

	apijs.dialog.dialogInformation(
		apijs.i18n.translate('errorTitle'),
		(typeof data === 'number') ? apijs.i18n.translate('error' + data) : data,
		'error'
	);
}


// #### Modification d'une description ########################### public ### //
// = révision : 11
// » Affiche un formulaire à remplir (un champ texte) avec le dialogue d'options de [TheDialog]
// » Demande la modification en Ajax (sur apijs/edit[post=id,authenticity_token,description])
// » Attention il est admis qu'un code différent de 200/403/404 ne peut pas arriver
function editAttachment(id, action, key) {

	// gestion des traductions
	if (typeof apijs.i18n.data.en.editTitle !== 'string') {

		apijs.i18n.data.en.editTitle = "Edit a description";
		apijs.i18n.data.fr.editTitle = "Modifier une description";
		apijs.i18n.data.en.editText = "Enter below the new description for the file. To remove the description, leave the field empty.";
		apijs.i18n.data.fr.editText = "Saisissez ci-dessous la nouvelle description pour ce fichier. Pour supprimer la description, laissez le champ vide.";

		apijs.i18n.data.en.errorTitle = "Error";
		apijs.i18n.data.fr.errorTitle = "Erreur";
		apijs.i18n.data.en.error403 = "You are not authorized to perform this operation.";
		apijs.i18n.data.fr.error403 = "Vous n'êtes pas autorisé(e) à effectuer cette opération.";
		apijs.i18n.data.en.error404 = "Sorry, the file no longer exists, please [a href='javascript:location.reload();']refresh the page[/a].";
		apijs.i18n.data.fr.error404 = "Désolé, le fichier n'existe plus, veuillez [a href='javascript:location.reload();']actualiser la page[/a].";
	}

	// création du formulaire et affichage de celui-ci dans un dialogue
	// attention, l'ordre des champs input à son importance !
	var text, desc = document.getElementById('attachmentId' + id).querySelector('span.description').firstChild.nodeValue.trim();

	text  = '[p][label for="text"]' + apijs.i18n.translate('editText') + '[/label][/p]';
	text += '[input type="text" name="description" value="' + desc + '" id="text"]';
	text += '[input type="hidden" name="authenticity_token" value="' + key + '"]';
	text += '[input type="hidden" name="id" value="' + id + '"]';

	// affichage du dialogue
	apijs.dialog.dialogFormOptions(apijs.i18n.translate('editTitle'), text, action, actionEditAttachment, key, 'editattachment');
}

function actionEditAttachment(action, args) {

	// vérification de la nouvelle description
	if (typeof action === 'boolean') {
		return true;
	}
	// sauvegarde de la nouvelle description
	else if (typeof action === 'string') {

		// args = key
		var xhr = new XMLHttpRequest();
		xhr.open('POST', action, true);
		xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
		xhr.setRequestHeader('X-CSRF-Token', args);

		xhr.onreadystatechange = function () {

			if ((xhr.readyState === 4) && (xhr.status === 200)) {

				// le traitement est un succès
				// extraction de l'id et la description du fichier enregistré
				// mise à jour de la légende, de l'input type hidden et de l'image
				if (xhr.responseText.indexOf('attachmentId') === 0) {

					var elem, id, text;
					id   = xhr.responseText.slice(0, xhr.responseText.indexOf(':'));
					text = xhr.responseText.slice(xhr.responseText.indexOf(':') + 1);

					// légende
					elem = document.getElementById(id).querySelector('span.description').firstChild;
					elem.replaceData(0, elem.length, text);

					// input type hidden (si disponible)
					elem = document.getElementById(id).querySelector('input');
					if (elem)
						elem.value = elem.value.slice(0, elem.value.lastIndexOf('|') + 1) + text;

					// image (si disponible)
					elem = document.getElementById(id).querySelector('img');
					if (elem)
						elem.setAttribute('alt', text);

					apijs.dialog.actionClose();
				}
				// le traitement est un échec
				// rechargement de la page ou affichage du contenu de la réponse
				else {
					if (xhr.responseText.indexOf('<!DOCTYPE') === 0) {
						apijs.dialog.styles.remove('lock');
						location.reload();
					}
					else {
						showDialogError(xhr.responseText);
					}
				}
			}
			else if ((xhr.readyState === 4) && (xhr.status === 403)) {
				showDialogError(403);
			}
			else if ((xhr.readyState === 4) && (xhr.status === 404)) {
				showDialogError(404);
			}
		};

		xhr.send(apijs.serialize(document.getElementById('apijsBox')));
	}
}


// #### Suppression d'un fichier ################################# public ### //
// = révision : 11
// » Affiche une demande de confirmation de suppression avec le dialogue de confirmation de [TheDialog]
// » Demande la suppression en Ajax (sur apijs/delete[post=id,authenticity_token])
// » Attention il est admis qu'un code différent de 200/403/404 ne peut pas arriver
function deleteAttachment(id, action, key) {

	// gestion des traductions
	if (typeof apijs.i18n.data.en.deleteTitle !== 'string') {

		apijs.i18n.data.en.deleteTitle = "Delete a file";
		apijs.i18n.data.fr.deleteTitle = "Supprimer un fichier";
		apijs.i18n.data.en.deleteText = "Are you sure you want to delete this file?[br]Be careful, you can't cancel this operation.";
		apijs.i18n.data.fr.deleteText = "Êtes-vous certain de vouloir supprimer ce fichier ?[br]Attention, cette opération n'est pas annulable.";

		apijs.i18n.data.en.errorTitle = "Error";
		apijs.i18n.data.fr.errorTitle = "Erreur";
		apijs.i18n.data.en.error403 = "You are not authorized to perform this operation.";
		apijs.i18n.data.fr.error403 = "Vous n'êtes pas autorisé(e) à effectuer cette opération.";
		apijs.i18n.data.en.error404 = "Sorry, the file no longer exists, please [a href='javascript:location.reload();']refresh the page[/a].";
		apijs.i18n.data.fr.error404 = "Désolé, le fichier n'existe plus, veuillez [a href='javascript:location.reload();']actualiser la page[/a].";
	}

	// affichage du dialogue
	apijs.dialog.dialogConfirmation(apijs.i18n.translate('deleteTitle'), apijs.i18n.translate('deleteText'), actionDeleteAttachment, [action, id, key]);
}

function actionDeleteAttachment(args) {

	// args = [action, id, key]
	var xhr = new XMLHttpRequest();
	xhr.open('POST', args[0], true);
	xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
	xhr.setRequestHeader('X-CSRF-Token', args[2]);

	xhr.onreadystatechange = function () {

		if ((xhr.readyState === 4) && (xhr.status === 200)) {

			// le traitement est un succès
			// extraction de l'id du fichier supprimé
			// suppression du fichier de la page
			if (xhr.responseText.indexOf('attachmentId') === 0) {
				document.getElementById(xhr.responseText).parentNode.removeChild(document.getElementById(xhr.responseText));
				apijs.dialog.actionClose();
			}
			// le traitement est un échec
			// rechargement de la page ou affichage du contenu de la réponse
			else {
				if (xhr.responseText.indexOf('<!DOCTYPE') === 0) {
					apijs.dialog.styles.remove('lock');
					location.reload();
				}
				else {
					showDialogError(xhr.responseText);
				}
			}
		}
		else if ((xhr.readyState === 4) && (xhr.status === 403)) {
			showDialogError(403);
		}
		else if ((xhr.readyState === 4) && (xhr.status === 404)) {
			showDialogError(404);
		}
	};

	xhr.send('id=' + encodeURIComponent(args[1]) + '&authenticity_token=' + encodeURIComponent(args[2]));
}