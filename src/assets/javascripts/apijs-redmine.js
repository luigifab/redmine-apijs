/**
 * Created D/15/12/2013
 * Updated L/28/07/2025
 *
 * Copyright 2008-2025 | Fabrice Creuzot (luigifab) <code~luigifab~fr>
 * https://github.com/luigifab/redmine-apijs
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

	this.init = function () {

		var d = apijs.i18n.data;
		if (!d.frca) d.frca = {};
		// @see https://docs.google.com/spreadsheets/d/1UUpKZ-YAAlcfvGHYwt6aUM9io390j0-fIL0vMRh1pW0/edit?usp=sharing
		// auto start
		d.cs[250] = "Smazat soubor";
		d.cs[251] = "Opravdu chcete tento soubor smazat?[br]Pozor, tuto operaci nelze vrátit zpět.";
		d.cs[252] = "Chyba";
		d.de[250] = "Eine Datei löschen";
		d.de[251] = "Sind Sie sicher, dass Sie diese Datei löschen möchten?[br]Achtung, diese Aktion ist unrückgängig.";
		d.de[252] = "Fehler";
		d.de[253] = "Sie verfügen nicht über die notwendigen Rechte um diese Operation durchzuführen, bitte [a §]aktualisieren Sie die Seite[/a].";
		d.de[254] = "Es tut uns leid, diese Datei existiert nicht mehr, bitte [a §]aktualisieren Sie die Seite[/a].";
		d.de[255] = "Eine Beschreibung bearbeiten";
		d.de[256] = "Bitte geben Sie weiter unten die neue Beschreibung für diese Datei an. Um die Beschreibung zu löschen lassen Sie das Feld leer.";
		d.el[252] = "Σφάλμα";
		d.en[250] = "Remove file";
		d.en[251] = "Are you sure you want to remove this file?[br]Be careful, you can't cancel this operation.";
		d.en[252] = "Error";
		d.en[253] = "You are not authorized to perform this operation, please [a §]refresh the page[/a].";
		d.en[254] = "Sorry, the file no longer exists, please [a §]refresh the page[/a].";
		d.en[255] = "Edit description";
		d.en[256] = "Enter below the new description for the file. To remove the description, leave the field empty.";
		d.en[257] = "Rename file";
		d.en[258] = "Enter below the new name for the file.";
		d.en[259] = "Clear cache";
		d.en[260] = "Are you sure you want to clear the cache?[br]Be careful, you can't cancel this operation.";
		d.es[250] = "Borrar un archivo";
		d.es[251] = "¿Está usted seguro(a) de que desea eliminar este archivo?[br]Atención, pues no podrá cancelar esta operación.";
		d.es[253] = "No está autorizado-a para llevar a cabo esta operación, por favor [a §]actualice la página[/a].";
		d.es[254] = "Disculpe, pero el archivo ya no existe, por favor [a §]actualice la página[/a].";
		d.es[255] = "Editar una descripción";
		d.es[256] = "Introduzca a continuación la nueva descripción para el archivo. Para eliminar la descripción, deje el campo en blanco.";
		d.es[259] = "Vaciar la caché";
		d.es[260] = "¿Está usted seguro(a) de querer vaciar la caché?[br]Cuidado, esta operación no puede ser cancelada.";
		d.fr[250] = "Supprimer le fichier";
		d.fr[251] = "Êtes-vous sûr(e) de vouloir supprimer ce fichier ?[br]Attention, cette opération n'est pas annulable.";
		d.fr[252] = "Erreur";
		d.fr[253] = "Vous n'êtes pas autorisé(e) à effectuer cette opération, veuillez [a §]actualiser la page[/a].";
		d.fr[254] = "Désolé, le fichier n'existe plus, veuillez [a §]actualiser la page[/a].";
		d.fr[255] = "Modifier la description";
		d.fr[256] = "Saisissez ci-dessous la nouvelle description pour ce fichier. Pour supprimer la description, laissez le champ vide.";
		d.fr[257] = "Renommer le fichier";
		d.fr[258] = "Saisissez ci-dessous le nouveau nom pour ce fichier.";
		d.fr[259] = "Vider le cache";
		d.fr[260] = "Êtes-vous certain(e) de vouloir vider le cache ?[br]Attention, cette opération n'est pas annulable.";
		d.hu[252] = "Hiba";
		d.it[250] = "Cancella i file";
		d.it[251] = "Sei sicura di voler eliminare il file?[br]Attenzione, questa operazione non può essere annullata.";
		d.it[252] = "Errore";
		d.it[253] = "Non siete autorizzati a eseguire questa operazione, vi preghiamo di [a §]ricaricare la pagina[/a].";
		d.it[254] = "Spiacenti, il file non esiste più, vi preghiamo di [a §]ricaricare la pagina[/a].";
		d.it[255] = "Modificare una descrizione";
		d.it[256] = "Inserire qui sotto la nuova descrizione del file. Per cancellare la descrizione, lasciate lo spazio vuoto.";
		d.ja[250] = "ファイルを削除";
		d.ja[252] = "エラー";
		d.nl[252] = "Fout";
		d.pl[250] = "Usuń plik";
		d.pl[251] = "Jesteś pewny, że chcesz usunąć ten plik?[br]Uwaga! Nie ma odwrotu od tej operacji.";
		d.pl[252] = "Błąd";
		d.pt[250] = "Suprimir um ficheiro";
		d.pt[251] = "Tem certeza de que quer suprimir este ficheiro?[br]Cuidado, não pode cancelar esta operação.";
		d.pt[252] = "Erro";
		d.pt[253] = "Não é autorizado(a) para efetuar esta operação, por favor [a §]atualize a página[/a].";
		d.pt[254] = "Lamento, o ficheiro já não existe, por favor [a §]atualize a página[/a].";
		d.pt[255] = "Modificar uma descrição";
		d.pt[256] = "Digite abaixo a nova descrição para este ficheiro. Para suprimir a descrição, deixe o campo vazio.";
		d.ro[252] = "Eroare";
		d.ru[250] = "Удалить файл";
		d.ru[251] = "Вы уверены, что хотите удалить этот файл?[br]Осторожно, вы не сможете отменить эту операцию.";
		d.ru[252] = "Ошибка";
		d.ru[253] = "Вы не авторизованы для выполнения этой операции, пожалуйста [a §]обновите страницу[/a].";
		d.ru[254] = "Извините, но файл не существует, пожалуйста [a §]обновите страницу[/a].";
		d.ru[255] = "Редактировать описание";
		d.ru[256] = "Ниже введите новое описание файла. Оставьте поле пустым, чтобы удалить описание.";
		d.sk[252] = "Chyba";
		d.tr[252] = "Hata";
		d.tr[259] = "Önbelleği temizle";
		d.uk[252] = "Помилка";
		d.zh[252] = "错误信息";
		// auto end
	};

	this.error = function (data) {

		if ((typeof data == 'string') && (data.indexOf('<!DOCTYPE') < 0)) {
			apijs.dialog.dialogInformation(apijs.i18n.translate(252), data, 'error');
		}
		else {
			apijs.dialog.remove('lock');
			self.location.reload();
		}
	};

	this.editAttachment = function (elem, id, action, token) {

		var desc, text, title = apijs.i18n.translate(255);

		desc = elem.parentNode.parentNode.querySelector('.description').textContent.trim();
		text = '[p][label for="apijsinput"]' + apijs.i18n.translate(256) + '[/label][/p]' +
				'[input type="text" name="description" value="' + desc + '" spellcheck="true" id="apijsinput"]';

		apijs.dialog.dialogFormOptions(title, text, action, apijsRedmine.actionEditAttachment, [id, action, token], 'editattach');
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

							// description
							elem = document.getElementById(id);
							elem.querySelector('.description').textContent = text;

							// input type hidden
							elem = elem.querySelector('input');
							if (elem)
								elem.value = elem.value.slice(0, elem.value.lastIndexOf('|') + 1) + text;

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

			xhr.send('desc=' + encodeURIComponent(document.getElementById('apijsinput').value));
		}
	};

	this.renameAttachment = function (elem, id, action, token) {

		var name, text, title = apijs.i18n.translate(257);

		name = elem.parentNode.parentNode.querySelector('.filename').textContent.trim();
		text = '[p][label for="apijsinput"]' + apijs.i18n.translate(258) + '[/label][/p]' +
				'[input type="text" name="name" value="' + name + '" spellcheck="false" id="apijsinput"]';

		apijs.dialog.dialogFormOptions(title, text, action, apijsRedmine.actionRenameAttachment, [id, action, token], 'editattach');
	};

	this.actionRenameAttachment = function (action, args) {

		// vérification du nouveau nom
		if (typeof action == 'boolean') {
			return true;
		}
		// sauvegarde du nouveau nom
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

							// extrait l'id et le nom du fichier enregistré
							var elem, id, name, subelem, text;
							id   = xhr.responseText.slice(0, xhr.responseText.indexOf(':'));
							name = xhr.responseText.slice(xhr.responseText.indexOf(':') + 1);

							// nom
							elem = document.getElementById(id);
							elem.querySelector('.filename').textContent = name;

							// URLs sur a/href et input/value et button.download/onclick et button.show/onclick
							// pas de maj de src et srcset sur img pour éviter un appel réseau inutile
							subelem = elem.querySelector('input');
							if (subelem) {
								text = subelem.getAttribute('value');
								subelem.setAttribute('value', name + text.substring(text.indexOf('|')));
							}

							subelem = elem.querySelector('a');
							if (subelem) {
								text = subelem.getAttribute('href');
								subelem.setAttribute('href', text.substring(0, text.lastIndexOf('/') + 1) + name);
							}

							subelem = elem.querySelector('button.download');
							if (subelem) {
								text = subelem.getAttribute('onclick');
								subelem.setAttribute('onclick', text.substring(0, text.lastIndexOf('/') + 1) + name + "';");
							}

							subelem = elem.querySelector('button.show');
							if (subelem) {
								text = subelem.getAttribute('onclick');
								subelem.setAttribute('onclick', text.substring(0, text.lastIndexOf('/') + 1) + name + "';");
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

			xhr.send('name=' + encodeURIComponent(document.getElementById('apijsinput').value));
		}
	};

	this.removeAttachment = function (elem, id, action, token) {
		apijs.dialog.dialogConfirmation(apijs.i18n.translate(250), apijs.i18n.translate(251), apijsRedmine.actionRemoveAttachment, [id, action, token]);
	};

	this.actionRemoveAttachment = function (args) {

		// args = [id, action, token]
		var xhr = new XMLHttpRequest();
		xhr.open('POST', args[1] + '?id=' + args[0] + '&isAjax=true', true);
		xhr.setRequestHeader('X-CSRF-Token', args[2]);

		xhr.onreadystatechange = function () {

			if (xhr.readyState === 4) {
				if ([0, 200].has(xhr.status)) {
					if (xhr.responseText.indexOf('attachmentId') === 0) {

						// supprime le fichier de la page grâce à son id
						var attachment = document.getElementById(xhr.responseText), elems = attachment.parentNode, idx = 0;
						attachment.remove();

						// supprime la liste des fichiers
						if (elems.querySelectorAll('dl, li').length < 1) {
							elems.remove();
						}
						// ou réattribue les ids du diaporama (pas de réinitialisation, on remet juste les ids en place)
						else {
							elems.querySelectorAll('a[id][type]').forEach(function (elem) {
								elem.setAttribute('id', elem.getAttribute('id').slice(0, elem.getAttribute('id').lastIndexOf('.') + 1) + idx++);
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

	this.clearCache = function (action) {
		apijs.dialog.dialogConfirmation(apijs.i18n.translate(259), apijs.i18n.translate(260), apijsRedmine.actionClearCache, action);
	};

	this.actionClearCache = function (args) {
		apijs.dialog.remove('waiting', 'lock');
		self.location.href = args;
	};

})();

if (typeof self.addEventListener == 'function')
	self.addEventListener('apijsload', apijsRedmine.init.bind(apijsRedmine));