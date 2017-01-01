/**
 * Copyright 2008-2017 | Fabrice Creuzot (luigifab) <code~luigifab~info>
 * Created D/15/12/2013, updated M/08/11/2016
 * https://redmine.luigifab.info/projects/redmine/wiki/apijs
 *
 * This program is free software, you can redistribute it or modify
 * it under the terms of the GNU General Public License (GPL).
 */

// traductions
function apijsInitTranslations() {

	var de = apijs.i18n.data.de, en = apijs.i18n.data.en, es = apijs.i18n.data.es, fr = apijs.i18n.data.fr,
	    it = apijs.i18n.data.it, pt = apijs.i18n.data.pt, ru = apijs.i18n.data.ru;

	de.deleteTitle = "Eine Datei löschen";
	en.deleteTitle = "Delete a file";
	es.deleteTitle = "Borrar un archivo";
	fr.deleteTitle = "Supprimer un fichier";
	it.deleteTitle = "Eliminare un file";
	pt.deleteTitle = "Suprimir um ficheiro";
	ru.deleteTitle = "Удалить файл";

	de.deleteText = "Sind Sie sicher, dass Sie diese Datei löschen möchten?[br]Achtung, diese Aktion ist unrückgängig.";
	en.deleteText = "Are you sure you want to delete this file?[br]Be careful, you can't cancel this operation.";
	es.deleteText = "¿Está usted seguro-a de que desea eliminar este archivo?[br]Atención, pues no podrá cancelar esta operación.";
	fr.deleteText = "Êtes-vous certain(e) de vouloir supprimer ce fichier ?[br]Attention, cette opération n'est pas annulable.";
	it.deleteText = "Sicuri di voler eliminare il file?[br]Attenzione, questa operazione non puo' essere annullata.";
	pt.deleteText = "Tem certeza de que quer suprimir este ficheiro?[br]Atenção, não pode cancelar esta operação.";
	ru.deleteText = "Вы уверены, что хотите удалить этот файл?[br]Осторожно, вы не сможете отменить эту операцию.";

	de.errorTitle = "Fehler";
	en.errorTitle = "Error";
	es.errorTitle = "Error";
	fr.errorTitle = "Erreur";
	it.errorTitle = "Errore";
	pt.errorTitle = "Erro";
	ru.errorTitle = "Ошибка";

	de.error403 = "Sie verfügen nicht über die notwendigen Rechte um diese Operation durchzuführen, bitte [a §]aktualisieren Sie die Seite[/a].";
	en.error403 = "You are not authorized to perform this operation, please [a §]refresh the page[/a].";
	es.error403 = "No está autorizado-a para llevar a cabo esta operación, por favor [a §]actualice la página[/a].";
	fr.error403 = "Vous n'êtes pas autorisé(e) à effectuer cette opération, veuillez [a §]actualiser la page[/a].";
	it.error403 = "Non siete autorizzati a eseguire questa operazione, vi preghiamo di [a §]ricaricare la pagina[/a].";
	pt.error403 = "Não é autorizado(a) para efetuar esta operação, por favor [a §]atualize a página[/a].";
	ru.error403 = "Вы не авторизованы для выполнения этой операции, пожалуйста [a §]обновите страницу[/a].";

	de.error404 = "Es tut uns leid, diese Datei existiert nicht mehr, bitte [a §]aktualisieren Sie die Seite[/a].";
	en.error404 = "Sorry, the file no longer exists, please [a §]refresh the page[/a].";
	es.error404 = "Lo sentimos, pero el archivo ya no existe, por favor [a §]actualice la página[/a].";
	fr.error404 = "Désolé, le fichier n'existe plus, veuillez [a §]actualiser la page[/a].";
	it.error404 = "Spiacenti, il file non esiste più, vi preghiamo di [a §]ricaricare la pagina[/a].";
	pt.error404 = "Lamento, o ficheiro já não existe, por favor [a §]atualize a página[/a].";
	ru.error404 = "Извините, но файл не существует, пожалуйста [a §]обновите страницу[/a].";

	de.sendTitle = "Mehrere Dateien versenden";
	en.sendTitle = "Send multiple files";
	es.sendTitle = "Enviar varios archivos";
	fr.sendTitle = "Envoyer plusieurs fichiers";
	it.sendTitle = "Inviare più file";
	pt.sendTitle = "Enviar vários ficheiros";
	ru.sendTitle = "Отправить несколько файлов";

	de.sendText = "§ Dateien gespeichert. Beenden Sie Ihre Veränderungen bevor Sie das Formular speichern oder die Seite [a §]neu laden[/a].";
	en.sendText = "§ files saved. Finish your changes before saving the form or simply [a §]reload[/a] the page.";
	es.sendText = "§ archivos grabados. Termine sus modificaciones antes de grabar el formulario o [a §]recargue[/a] simplemente la página.";
	fr.sendText = "§ fichiers enregistrés. Terminez vos modifications avant d'enregistrer le formulaire ou [a §]rechargez[/a] simplement la page.";
	it.sendText = "§ file salvati. Terminate le vostre modifiche prima di salvare il formulario o [a §]ricaricate[/a] semplicemente la pagina.";
	pt.sendText = "§ ficheiros registados. Termine as suas alterações antes de registar o formulário ou [a §]recarregue[/a] simplesmente a página.";
	ru.sendText = "§ файлы сохранены. Завершите изменения перед тем как сохранить форму или просто [a §]перезагрузите[/a] страницу.";

	de.editTitle = "Eine Beschreibung bearbeiten";
	en.editTitle = "Edit a description";
	es.editTitle = "Editar una descripción";
	fr.editTitle = "Modifier une description";
	it.editTitle = "Modificare una descrizione";
	pt.editTitle = "Modificar uma descrição";
	ru.editTitle = "Редактировать описание";

	de.editText = "Bitte geben Sie weiter unten die neue Beschreibung für diese Datei an. Um die Beschreibung zu löschen lassen Sie das Feld leer.";
	en.editText = "Enter below the new description for the file. To remove the description, leave the field empty.";
	es.editText = "Introduzca a continuación la nueva descripción para el archivo. Para eliminar la descripción, deje el campo en blanco.";
	fr.editText = "Saisissez ci-dessous la nouvelle description pour ce fichier. Pour supprimer la description, laissez le champ vide.";
	it.editText = "Inserire qui sotto la nuova descrizione del file. Per cancellare la descrizione, lasciate lo spazio vuoto.";
	pt.editText = "Digite abaixo a nova descrição para este ficheiro. Para suprimir a descrição, deixe o campo vazio.";
	ru.editText = "Ниже введите новое описание файла. Оставьте поле пустым, чтобы удалить описание.";
}

// en cas d'erreur
function apijsShowError(data) {

	if ((typeof data === 'number') || (data.indexOf('<!DOCTYPE') < 0)) {
		apijs.dialog.dialogInformation(
			apijs.i18n.translate('errorTitle'),
			(typeof data === 'number') ? apijs.i18n.translate('error' + data, "href='javascript:location.reload();'") : data,
			'error');
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


// #### Modification d'une description d'un fichier ######################### //
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
	apijs.dialog.dialogFormOptions(apijs.i18n.translate('editTitle'), text, action, apijsActionEditAttachment,
		[action, id, token], 'editattachment');
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
// = révision : 30
// » Attention il est admis qu'un code différent de 200/403/404 n'est pas possible
// » Affiche une demande de confirmation de suppression avec le dialogue de confirmation
// » Demande la suppression en Ajax (../apijs/delete[get=id;post=token])
function apijsDeleteAttachment(id, action, token) {

	if (typeof apijs.i18n.data.en.deleteTitle !== 'string')
		apijsInitTranslations();

	apijs.dialog.dialogConfirmation(apijs.i18n.translate('deleteTitle'), apijs.i18n.translate('deleteText'),
		apijsActionDeleteAttachment, [action, id, token]);
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
					for (elem in elems) if (elems.hasOwnProperty(elem) && !isNaN(elem)) {
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