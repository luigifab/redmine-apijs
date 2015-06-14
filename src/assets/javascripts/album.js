/**
 * Copyright 2008-2015 | Fabrice Creuzot (luigifab) <code~luigifab~info>
 * Created D/15/12/2013, updated V/01/05/2015, version 27
 * https://redmine.luigifab.info/projects/redmine/wiki/apijs
 *
 * This program is free software, you can redistribute it or modify
 * it under the terms of the GNU General Public License (GPL).
 */

// traductions
function apijsInitTranslations() {

	apijs.i18n.data.en.deleteTitle = "Delete a file";
	apijs.i18n.data.es.deleteTitle = "Borrar un archivo";
	apijs.i18n.data.fr.deleteTitle = "Supprimer un fichier";
	apijs.i18n.data.ru.deleteTitle = "Удалить файл";
	apijs.i18n.data.en.deleteText = "Are you sure you want to delete this file?[br]Be careful, you can't cancel this operation.";
	apijs.i18n.data.es.deleteText = "Está usted seguro-a de que desea eliminar este archivo?[br]Tenga cuidado, pues no podrá cancelar esta operación.";
	apijs.i18n.data.fr.deleteText = "Êtes-vous certain de vouloir supprimer ce fichier ?[br]Attention, cette opération n'est pas annulable.";
	apijs.i18n.data.ru.deleteText = "Вы уверены, что хотите удалить этот файл?[br]Осторожно, вы не сможете отменить эту операцию.";

	apijs.i18n.data.en.errorTitle = "Error";
	apijs.i18n.data.fr.errorTitle = "Erreur";
	apijs.i18n.data.ru.errorTitle = "Ошибка";
	apijs.i18n.data.en.error403 = "You are not authorized to perform this operation, please [a §]refresh the page[/a].";
	apijs.i18n.data.es.error403 = "No está autorizado-a para llevar a cabo esta operación, por favor [a §]actualice la página[/a].";
	apijs.i18n.data.fr.error403 = "Vous n'êtes pas autorisé(e) à effectuer cette opération, veuillez [a §]actualiser la page[/a].";;
	apijs.i18n.data.ru.error403 = "Вы не авторизованы для выполнения этой операции, пожалуйста [a §]обновите страницу[/a].";
	apijs.i18n.data.en.error404 = "Sorry, the file no longer exists, please [a §]refresh the page[/a].";
	apijs.i18n.data.es.error404 = "Lo sentimos, pero el archivo ya no existe, por favor [a §]actualice la página[/a].";
	apijs.i18n.data.fr.error404 = "Désolé, le fichier n'existe plus, veuillez [a §]actualiser la page[/a].";
	apijs.i18n.data.ru.error404 = "Извините, но файл не существует, пожалуйста [a §]обновите страницу[/a].";

	apijs.i18n.data.en.sendTitle = "Send multiple files";
	apijs.i18n.data.es.sendTitle = "Enviar varios archivos";
	apijs.i18n.data.fr.sendTitle = "Envoyer plusieurs fichiers";
	apijs.i18n.data.ru.sendTitle = "Отправить несколько файлов";
	apijs.i18n.data.en.sendText = "§ files saved. Finish your changes before save the form or simply [a §]reload[/a] the page.";
	apijs.i18n.data.fr.sendText = "§ fichiers enregistrés. Terminez vos modifications avant d'enregistrer le formulaire ou [a §]rechargez[/a] simplement la page.";
	apijs.i18n.data.ru.sendText = "§ файлы сохранены. Завершите изменения перед тем как сохранить форму или просто [a §]перезагрузите[/a] страницу.";

	apijs.i18n.data.en.editTitle = "Edit a description";
	apijs.i18n.data.es.editTitle = "Editar una descripción";
	apijs.i18n.data.fr.editTitle = "Modifier une description";
	apijs.i18n.data.ru.editTitle = "Редактировать описание";
	apijs.i18n.data.en.editText = "Enter below the new description for the file. To remove the description, leave the field empty.";
	apijs.i18n.data.es.editText = "Introducir a continuación la nueva descripción para el archivo. Para eliminar la descripción, deje el campo en blanco.";
	apijs.i18n.data.fr.editText = "Saisissez ci-dessous la nouvelle description pour ce fichier. Pour supprimer la description, laissez le champ vide.";
	apijs.i18n.data.ru.editText = "Ниже введите новое описание файла. Оставьте поле пустым, чтобы удалить описание.";
}

// en cas d'erreur
function apijsShowError(data) {

	if ((typeof data === 'number') || (data.indexOf('<!DOCTYPE') < 0)) {
		apijs.dialog.dialogInformation(apijs.i18n.translate('errorTitle'), (typeof data === 'number') ? apijs.i18n.translate('error' + data, "href='javascript:location.reload();'") : data, 'error');
	}
	else {
		apijs.dialog.styles.remove('lock'); // obligatoire sinon demande de confirmation de quitter la page
		location.reload();
	}
}


// #### Envoi d'un fichier ZIP ############################################## //
// = révision : 13
// » Affiche un formulaire d'upload avec le dialogue d'upload
// » Envoi un fichier en Ajax (../apijs/uploadzip[get=type,id;post=token,mybigzip])
function apijsSendZip(url, token, maxsize) {

	if (typeof apijs.i18n.data.en.sendTitle !== 'string')
		apijsInitTranslations();

	apijs.config.upload.tokenValue = token;
	apijs.upload.sendFile(apijs.i18n.translate('sendTitle'), url, 'mybigzip', maxsize, 'zip', apijsFinalZip);
}

function apijsFinalZip(total) {
	apijs.dialog.dialogInformation(apijs.i18n.translate('sendTitle'), apijs.i18n.translate('sendText', total, "href='javascript:location.reload();'"));
}


// #### Modification d'une description ###################################### //
// = révision : 30
// » Attention il est admis qu'un code différent de 200/403/404 n'est pas possible
// » Affiche un formulaire à remplir avec un simple champ texte avec le dialogue d'options
// » Demande la modification en Ajax (../apijs/edit[get=id;post=token,description])
function apijsEditAttachment(id, action, token) {

	// gestion des traductions
	if (typeof apijs.i18n.data.en.editTitle !== 'string')
		apijsInitTranslations();

	// création du formulaire et affichage de celui-ci dans un dialogue
	var text, desc;

	if (document.getElementById('attachmentId' + id).querySelector('span.description')) {
		desc = document.getElementById('attachmentId' + id).querySelector('span.description').firstChild.nodeValue.trim();
	}
	else {
		desc = document.createElement('span');
		desc.setAttribute('class', 'description');
		desc.appendChild(document.createTextNode(''));
		document.getElementById('attachmentId' + id).querySelector('dd').appendChild(desc);
		desc = '';
	}

	text  = '[p][label for="apijsRedText"]' + apijs.i18n.translate('editText') + '[/label][/p]';
	text += '[input type="text" name="description" value="' + desc + '" spellcheck="true" id="apijsRedText"]';

	// affichage du dialogue
	apijs.dialog.dialogFormOptions(apijs.i18n.translate('editTitle'), text, action, apijsActionEditAttachment, [action, id, token], 'editattachment');
	apijs.dialog.tDialog.querySelector('input').select();
}

function apijsActionEditAttachment(action, args) {

	// vérification de la nouvelle description
	if (typeof action === 'boolean') {
		return true;
	}
	// sauvegarde de la nouvelle description
	else if (typeof action === 'string') {

		// args = [action, id, token]
		var xhr = new XMLHttpRequest();
		xhr.open('POST', args[0] + '?id=' + args[1] + '&isAjax=true', true);
		xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
		xhr.setRequestHeader('X-CSRF-Token', args[2]);

		xhr.onreadystatechange = function () {

			if ((xhr.readyState === 4) && (xhr.status === 200)) {

				// le traitement est un succès
				// extraction de l'id et la description du fichier enregistré
				// mise à jour de la légende plus éventuellement de l'input type hidden et de l'image
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
					apijsShowError(xhr.responseText);
				}
			}
			else if ((xhr.readyState === 4) && (xhr.status === 403)) {
				apijsShowError(403);
			}
			else if ((xhr.readyState === 4) && (xhr.status === 404)) {
				apijsShowError(404);
			}
		};

		xhr.send('description=' + encodeURIComponent(document.getElementById('apijsRedText').value));
	}
}


// #### Suppression d'un fichier ############################################ //
// = révision : 29
// » Attention il est admis qu'un code différent de 200/403/404 n'est pas possible
// » Affiche une demande de confirmation de suppression avec le dialogue de confirmation
// » Demande la suppression en Ajax (../apijs/delete[get=id;post=token])
function apijsDeleteAttachment(id, action, token) {

	if (typeof apijs.i18n.data.en.deleteTitle !== 'string')
		apijsInitTranslations();

	apijs.dialog.dialogConfirmation(apijs.i18n.translate('deleteTitle'), apijs.i18n.translate('deleteText'), apijsActionDeleteAttachment, [action, id, token]);
}

function apijsActionDeleteAttachment(args) {

	// args = [action, id, token]
	var xhr = new XMLHttpRequest();
	xhr.open('GET', args[0] + '?id=' + args[1] + '&isAjax=true', true);
	xhr.setRequestHeader('X-CSRF-Token', args[2]);

	xhr.onreadystatechange = function () {

		if ((xhr.readyState === 4) && (xhr.status === 200)) {

			// le traitement est un succès
			// suppression du fichier de la page grâce à son id
			// éventuellement cache la liste des fichiers (s'il n'y en a plus aucun)
			// éventuellement réattribue les ids du diaporama (pas de réinitialisation, on remet juste les ids en place)
			if (xhr.responseText.indexOf('attachmentId') === 0) {

				var attachment = document.getElementById(xhr.responseText), album = attachment.parentNode,
				    elems, elem, id, i = 0;

				album.removeChild(attachment);
				elems = album.querySelectorAll('a[id][type]');

				if (album.querySelectorAll('dl,li').length < 1) {
					album.style.display = 'none';
				}
				else if (elems.length > 0) {
					for (elem in elems) if (elems.hasOwnProperty(elem) && (elem !== 'length')) {
						id = elems[elem].getAttribute('id');
						elems[elem].setAttribute('id', id.slice(0, id.lastIndexOf('.') + 1) + i++);
					}
				}

				apijs.dialog.actionClose();
			}
			// le traitement est un échec
			// rechargement de la page ou affichage du contenu de la réponse
			else {
				apijsShowError(xhr.responseText);
			}
		}
		else if ((xhr.readyState === 4) && (xhr.status === 403)) {
			apijsShowError(403);
		}
		else if ((xhr.readyState === 4) && (xhr.status === 404)) {
			apijsShowError(404);
		}
	};

	xhr.send();
}