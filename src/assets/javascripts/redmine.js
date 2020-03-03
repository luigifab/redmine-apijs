/**
 * Created D/15/12/2013
 * Updated J/06/02/2020
 *
 * Copyright 2008-2020 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
 * https://www.luigifab.fr/redmine/apijs
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

var apijsRedmine = new (function () {

	"use strict";

	this.start = function () {

		var d = apijs.i18n.data;
		// https://docs.google.com/spreadsheets/d/1UUpKZ-YAAlcfvGHYwt6aUM9io390j0-fIL0vMRh1pW0/edit?usp=sharing
		// auto start
		d.cs[252] = "Chyba";
		d.de[250] = "Eine Datei löschen";
		d.de[251] = "Sind Sie sicher, dass Sie diese Datei löschen möchten?[br]Achtung, diese Aktion ist unrückgängig.";
		d.de[252] = "Fehler";
		d.de[253] = "Sie verfügen nicht über die notwendigen Rechte um diese Operation durchzuführen, bitte [a §]aktualisieren Sie die Seite[/a].";
		d.de[254] = "Es tut uns leid, diese Datei existiert nicht mehr, bitte [a §]aktualisieren Sie die Seite[/a].";
		d.de[255] = "Eine Beschreibung bearbeiten";
		d.de[256] = "Bitte geben Sie weiter unten die neue Beschreibung für diese Datei an. Um die Beschreibung zu löschen lassen Sie das Feld leer.";
		d.en[250] = "Delete a file";
		d.en[251] = "Are you sure you want to delete this file?[br]Be careful, you can't cancel this operation.";
		d.en[252] = "Error";
		d.en[253] = "You are not authorized to perform this operation, please [a §]refresh the page[/a].";
		d.en[254] = "Sorry, the file no longer exists, please [a §]refresh the page[/a].";
		d.en[255] = "Edit a description";
		d.en[256] = "Enter below the new description for the file. To remove the description, leave the field empty.";
		d.es[250] = "Borrar un archivo";
		d.es[251] = "¿Está usted seguro-a de que desea eliminar este archivo?[br]Atención, pues no podrá cancelar esta operación.";
		d.es[253] = "No está autorizado-a para llevar a cabo esta operación, por favor [a §]actualice la página[/a].";
		d.es[254] = "Disculpe, pero el archivo ya no existe, por favor [a §]actualice la página[/a].";
		d.es[255] = "Editar una descripción";
		d.es[256] = "Introduzca a continuación la nueva descripción para el archivo. Para eliminar la descripción, deje el campo en blanco.";
		d.fr[250] = "Supprimer un fichier";
		d.fr[251] = "Êtes-vous certain(e) de vouloir supprimer ce fichier ?[br]Attention, cette opération n'est pas annulable.";
		d.fr[252] = "Erreur";
		d.fr[253] = "Vous n'êtes pas autorisé(e) à effectuer cette opération, veuillez [a §]actualiser la page[/a].";
		d.fr[254] = "Désolé, le fichier n'existe plus, veuillez [a §]actualiser la page[/a].";
		d.fr[255] = "Modifier une description";
		d.fr[256] = "Saisissez ci-dessous la nouvelle description pour ce fichier. Pour supprimer la description, laissez le champ vide.";
		d.it[250] = "Eliminare un file";
		d.it[251] = "Sicuri di voler eliminare il file?[br]Attenzione, questa operazione non può essere annullata.";
		d.it[252] = "Errore";
		d.it[253] = "Non siete autorizzati a eseguire questa operazione, vi preghiamo di [a §]ricaricare la pagina[/a].";
		d.it[254] = "Spiacenti, il file non esiste più, vi preghiamo di [a §]ricaricare la pagina[/a].";
		d.it[255] = "Modificare una descrizione";
		d.it[256] = "Inserire qui sotto la nuova descrizione del file. Per cancellare la descrizione, lasciate lo spazio vuoto.";
		d.ja[250] = "ファイルを削除";
		d.ja[252] = "エラー";
		d.nl[252] = "Fout";
		d.pl[252] = "Błąd";
		d.pt[250] = "Suprimir um ficheiro";
		d.pt[251] = "Tem certeza de que quer suprimir este ficheiro?[br]Atenção, não pode cancelar esta operação.";
		d.pt[252] = "Erro";
		d.pt[253] = "Não é autorizado(a) para efetuar esta operação, por favor [a §]atualize a página[/a].";
		d.pt[254] = "Lamento, o ficheiro já não existe, por favor [a §]atualize a página[/a].";
		d.pt[255] = "Modificar uma descrição";
		d.pt[256] = "Digite abaixo a nova descrição para este ficheiro. Para suprimir a descrição, deixe o campo vazio.";
		d.ptBR[252] = "Erro";
		d.ru[250] = "Удалить файл";
		d.ru[251] = "Вы уверены, что хотите удалить этот файл?[br]Осторожно, вы не сможете отменить эту операцию.";
		d.ru[252] = "Ошибка";
		d.ru[253] = "Вы не авторизованы для выполнения этой операции, пожалуйста [a §]обновите страницу[/a].";
		d.ru[254] = "Извините, но файл не существует, пожалуйста [a §]обновите страницу[/a].";
		d.ru[255] = "Редактировать описание";
		d.ru[256] = "Ниже введите новое описание файла. Оставьте поле пустым, чтобы удалить описание.";
		d.tr[252] = "Hata";
		d.zh[252] = "错误信息";
	// auto end
	};

	this.error = function (data) {

		if ((typeof data == 'string') || (data.indexOf('<!DOCTYPE') < 0)) {
			apijs.dialog.dialogInformation(apijs.i18n.translate(252), data, 'error');
		}
		else {
			apijs.dialog.remove('lock'); // obligatoire sinon demande de confirmation de quitter la page
			self.location.reload();
		}
	};

	this.editAttachment = function (id, action, token) {

		var desc, text, title = apijs.i18n.translate(255);
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

		text = '[p][label for="apijsRedText"]' + apijs.i18n.translate(256) + '[/label][/p]' +
				'[input type="text" name="description" value="' + desc + '" spellcheck="true" id="apijsRedText"]';

		apijs.dialog.dialogFormOptions(title, text, action, apijsRedmine.actionEditAttachment, [id, action, token], 'editattachment');
		apijs.dialog.t1.querySelector('input').select();
	};

	this.actionEditAttachment = function (action, args) {

		// vérification de la nouvelle description
		if (typeof action == 'boolean') {
			return true;
		}
		// sauvegarde de la nouvelle description
		else if (typeof action == 'string') {

			// args = [id, action, token]
			var xhr = new XMLHttpRequest();
			xhr.open('POST', args[1] + '?id=' + args[0] + '&isAjax=true', true);
			xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
			xhr.setRequestHeader('X-CSRF-Token', args[2]);

			xhr.onreadystatechange = function () {

				if (xhr.readyState === 4) {
					if ([0, 200].has(xhr.status)) {
						if (xhr.responseText.indexOf('attachmentId') === 0) {

							// extrait l'id et la description du fichier enregistré
							var elem, id, text;
							id   = xhr.responseText.slice(0, xhr.responseText.indexOf(':'));
							text = xhr.responseText.slice(xhr.responseText.indexOf(':') + 1);

							// légende
							elem = document.getElementById(id).querySelector('span.description').firstChild;
							elem.replaceData(0, elem.length, text);

							// input type hidden
							elem = document.getElementById(id).querySelector('input');
							if (elem)
								elem.value = elem.value.slice(0, elem.value.lastIndexOf('|') + 1) + text;

							// image
							elem = document.getElementById(id).querySelector('img');
							if (elem)
								elem.setAttribute('alt', text);

							apijs.dialog.actionClose();
						}
						else {
							apijsRedmine.error(xhr.responseText);
						}
					}
					else {
						apijsRedmine.error(xhr.status);
					}
				}
			};

			xhr.send('description=' + encodeURIComponent(document.getElementById('apijsRedText').value));
		}
	};

	this.deleteAttachment = function (id, action, token) {
		apijs.dialog.dialogConfirmation(apijs.i18n.translate(250), apijs.i18n.translate(251), apijsRedmine.actionDeleteAttachment, [id, action, token]);
	};

	this.actionDeleteAttachment = function (args) {

		// args = [id, action, token]
		var xhr = new XMLHttpRequest();
		xhr.open('GET', args[1] + '?id=' + args[0] + '&isAjax=true', true);
		xhr.setRequestHeader('X-CSRF-Token', args[2]);

		xhr.onreadystatechange = function () {

			if (xhr.readyState === 4) {
				if ([0, 200].has(xhr.status)) {
					if (xhr.responseText.indexOf('attachmentId') === 0) {

						// supprime le fichier de la page grâce à son id
						var attachment = document.getElementById(xhr.responseText), album = attachment.parentNode, i = 0;
						album.removeChild(attachment);

						if (album.querySelectorAll('dl, li').length < 1) {
							// supprime la liste des fichiers
							album.parentNode.removeChild(album);
						}
						else {
							// réattribue les ids du diaporama (pas de réinitialisation, on remet juste les ids en place)
							album.querySelectorAll('a[id][type]').forEach(function (elem) {
								elem.setAttribute('id', elem.getAttribute('id').slice(0, elem.getAttribute('id').lastIndexOf('.') + 1) + i++);
							});
						}

						apijs.dialog.actionClose();
					}
					else {
						apijsRedmine.error(xhr.responseText);
					}
				}
				else {
					apijsRedmine.error(xhr.status);
				}
			}
		};

		xhr.send();
	};

})();

if (typeof self.addEventListener == 'function')
	self.addEventListener('apijsload', apijsRedmine.start.bind(apijsRedmine));