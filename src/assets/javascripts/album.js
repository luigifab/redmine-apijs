/**
 * Created D/15/12/2013
 * Updated S/29/09/2018
 *
 * Copyright 2008-2018 | Fabrice Creuzot (luigifab) <code~luigifab~info>
 * https://www.luigifab.info/redmine/apijs
 *
 * This program is free software, you can redistribute it or modify
 * it under the terms of the GNU General Public License (GPL) as published
 * by the free software foundation, either version 2 of the license, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but without any warranty, without even the implied warranty of
 * merchantability or fitness for a particular purpose. See the
 * GNU General Public License (GPL) for more details.
 */

function apijsInitTranslations() {

	var de = apijs.i18n.data.de, en = apijs.i18n.data.en, es = apijs.i18n.data.es, fr = apijs.i18n.data.fr,
	    it = apijs.i18n.data.it, pt = apijs.i18n.data.pt, ru = apijs.i18n.data.ru;

	de.a250 = "Eine Datei löschen";
	en.a250 = "Delete a file";
	es.a250 = "Borrar un archivo";
	fr.a250 = "Supprimer un fichier";
	it.a250 = "Eliminare un file";
	pt.a250 = "Suprimir um ficheiro";
	ru.a250 = "Удалить файл";

	de.a251 = "Sind Sie sicher, dass Sie diese Datei löschen möchten?[br]Achtung, diese Aktion ist unrückgängig.";
	en.a251 = "Are you sure you want to delete this file?[br]Be careful, you can't cancel this operation.";
	es.a251 = "¿Está usted seguro-a de que desea eliminar este archivo?[br]Atención, pues no podrá cancelar esta operación.";
	fr.a251 = "Êtes-vous certain(e) de vouloir supprimer ce fichier ?[br]Attention, cette opération n'est pas annulable.";
	it.a251 = "Sicuri di voler eliminare il file?[br]Attenzione, questa operazione non puo' essere annullata.";
	pt.a251 = "Tem certeza de que quer suprimir este ficheiro?[br]Atenção, não pode cancelar esta operação.";
	ru.a251 = "Вы уверены, что хотите удалить этот файл?[br]Осторожно, вы не сможете отменить эту операцию.";

	de.a252 = "Fehler";
	en.a252 = "Error";
	es.a252 = "Error";
	fr.a252 = "Erreur";
	it.a252 = "Errore";
	pt.a252 = "Erro";
	ru.a252 = "Ошибка";

	de.a253 = "Sie verfügen nicht über die notwendigen Rechte um diese Operation durchzuführen, bitte [a §]aktualisieren Sie die Seite[/a].";
	en.a253 = "You are not authorized to perform this operation, please [a §]refresh the page[/a].";
	es.a253 = "No está autorizado-a para llevar a cabo esta operación, por favor [a §]actualice la página[/a].";
	fr.a253 = "Vous n'êtes pas autorisé(e) à effectuer cette opération, veuillez [a §]actualiser la page[/a].";
	it.a253 = "Non siete autorizzati a eseguire questa operazione, vi preghiamo di [a §]ricaricare la pagina[/a].";
	pt.a253 = "Não é autorizado(a) para efetuar esta operação, por favor [a §]atualize a página[/a].";
	ru.a253 = "Вы не авторизованы для выполнения этой операции, пожалуйста [a §]обновите страницу[/a].";

	de.a254 = "Es tut uns leid, diese Datei existiert nicht mehr, bitte [a §]aktualisieren Sie die Seite[/a].";
	en.a254 = "Sorry, the file no longer exists, please [a §]refresh the page[/a].";
	es.a254 = "Lo sentimos, pero el archivo ya no existe, por favor [a §]actualice la página[/a].";
	fr.a254 = "Désolé, le fichier n'existe plus, veuillez [a §]actualiser la page[/a].";
	it.a254 = "Spiacenti, il file non esiste più, vi preghiamo di [a §]ricaricare la pagina[/a].";
	pt.a254 = "Lamento, o ficheiro já não existe, por favor [a §]atualize a página[/a].";
	ru.a254 = "Извините, но файл не существует, пожалуйста [a §]обновите страницу[/a].";

	de.a255 = "Eine Beschreibung bearbeiten";
	en.a255 = "Edit a description";
	es.a255 = "Editar una descripción";
	fr.a255 = "Modifier une description";
	it.a255 = "Modificare una descrizione";
	pt.a255 = "Modificar uma descrição";
	ru.a255 = "Редактировать описание";

	de.a256 = "Bitte geben Sie weiter unten die neue Beschreibung für diese Datei an. Um die Beschreibung zu löschen lassen Sie das Feld leer.";
	en.a256 = "Enter below the new description for the file. To remove the description, leave the field empty.";
	es.a256 = "Introduzca a continuación la nueva descripción para el archivo. Para eliminar la descripción, deje el campo en blanco.";
	fr.a256 = "Saisissez ci-dessous la nouvelle description pour ce fichier. Pour supprimer la description, laissez le champ vide.";
	it.a256 = "Inserire qui sotto la nuova descrizione del file. Per cancellare la descrizione, lasciate lo spazio vuoto.";
	pt.a256 = "Digite abaixo a nova descrição para este ficheiro. Para suprimir a descrição, deixe o campo vazio.";
	ru.a256 = "Ниже введите новое описание файла. Оставьте поле пустым, чтобы удалить описание.";
}

function apijsShowError(data) {

	if ((typeof data === 'number') || (data.indexOf('<!DOCTYPE') < 0)) {
		apijs.dialog.dialogInformation(
			apijs.i18n.translate('a252'),
			(typeof data === 'number') ? apijs.i18n.translate('error' + data, "href='javascript:location.reload();'") : data,
			'error');
	}
	else {
		apijs.dialog.styles.remove('lock'); // obligatoire sinon demande de confirmation de quitter la page
		location.reload();
	}
}


function apijsEditAttachment(id, action, token) {

	// gestion des traductions
	if (typeof apijs.i18n.data.en.a255 !== 'string')
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

	text  = '[p][label for="apijsRedText"]' + apijs.i18n.translate('a257') + '[/label][/p]';
	text += '[input type="text" name="description" value="' + desc + '" spellcheck="true" id="apijsRedText"]';

	// affichage du dialogue
	apijs.dialog.dialogFormOptions(apijs.i18n.translate('a256'), text, action, apijsActionEditAttachment,
		[action, id, token], 'editattachment');
	apijs.dialog.t1.querySelector('input').select();
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


function apijsDeleteAttachment(id, action, token) {

	if (typeof apijs.i18n.data.en.a250 !== 'string')
		apijsInitTranslations();

	apijs.dialog.dialogConfirmation(apijs.i18n.translate('a250'), apijs.i18n.translate('a251'),
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