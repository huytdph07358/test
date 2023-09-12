import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workcake/common/utils.dart';
import 'package:http/http.dart' as http;

class Boards extends ChangeNotifier {
  List _data = [];
  Map _selectedBoard = {};
  Map _archivedCards ={};
  Map _archivedLists ={};

  List get data => _data; 
  Map get selectedBoard => _selectedBoard;
  Map get archivedCards => _archivedCards;
  Map get archivedLists => _archivedLists;
  
  onChangeBoard(board) async {
    _selectedBoard = board;
    archivedLists["${board["id"]}"] = (archivedLists["${board["id"]}"] ?? []) + (board["list_cards"] ?? []).where((e) => e["is_archived"] == true).toList();
    _selectedBoard["list_cards"] = (_selectedBoard["list_cards"] ?? []).where((e) => e["is_archived"] == false).toList();

    for (var i = 0; i < _selectedBoard["list_cards"].length; i++) {
      final listCard = _selectedBoard["list_cards"][i];

      archivedCards["${board["id"]}"] = (archivedCards["${board["id"]}"] ?? []) + listCard["cards"].where((e) => e["is_archived"] == true).toList();
      listCard["cards"] = listCard["cards"].where((e) => e["is_archived"] == false).toList();
    }

    if (!board.isEmpty) {
      var box = await Hive.openBox("lastSelectedBoard");
      box.put(board["channel_id"].toString(), board);
    }
    notifyListeners();
  }

  getListBoards(token, workspaceId, channelId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards?token=$token');

    try {
      final box = await Hive.openBox("lastSelectedBoard");
      final lastSelectedBoard = box.get(channelId.toString());
      final response = await http.get(url);
      final responseData = json.decode(response.body);

      _archivedLists = {};
      _archivedCards = {};

      if (responseData["success"]) {
        _data = responseData["boards"];
      
        if (lastSelectedBoard != null) {
          final index = _data.indexWhere((e) => e["id"] == lastSelectedBoard["id"]);
          if (index != -1) {
            onChangeBoard(_data[index]);
          } else {
            onChangeBoard(_data.length > 0 ? _data[0] : {});
          }
        } else {
          onChangeBoard(_data.length > 0 ? _data[0] : {});
        }
       
        notifyListeners();
      } else {
        print("getListBoards error");
      }
    } catch (e) {
      print("getListBoards error");
      print(e.toString());
    }
  }

  createNewBoard(token, workspaceId, channelId, title) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/create?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "title": title        
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        await getListBoards(token, workspaceId, channelId);
        if (_data.length > 0) {
          _selectedBoard = _data[0];
        }
      } else {
        print("create new board error");
      }
    } catch (e) {
      print("create new board error");
      print(e.toString());
    }
  }

  createNewCardList(token, workspaceId, channelId, boardId, title) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/create?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "title": title
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        getListBoards(token, workspaceId, channelId);
      } else {
        print("createNewCardList error");
      }
    } catch (e) {
      print("createNewCardList error");
      print(e.toString());
    }
  }

  createNewCard(token, workspaceId, channelId, boardId, listCardId, card) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/create?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "card": card
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        getListBoards(token, workspaceId, channelId);
      } else {
        print("createNewCard error");
      }
    } catch (e) {
      print("createNewCard error");
      print(e.toString());
    }
  }

  arrangeCard(token, workspaceId, channelId, boardId, listCardId, updateListCard, Map card) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/arrange_cards?token=$token');

    try {
      final listCardIndex = selectedBoard["list_cards"].indexWhere((e) => e["id"] == updateListCard["id"]);
      if (listCardIndex == -1) return;
      selectedBoard["list_cards"][listCardIndex]["order"] = updateListCard["order"];
      var body = {
        "card": card,
        "updateListCard": updateListCard
      };

      final response = await http.post(url, headers: Utils.headers, body: json.encode(body));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {} else {
        print("arrangeCard error");
      }
    } catch (e, t) {
      print("arrangeCard error $e, $t");
    }
  }

  arrangeCardList(token, workspaceId, channelId, boardId, listOrder) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/arrange_cards_list?token=$token');

    try {
      selectedBoard["order"] = listOrder;
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "list_order": listOrder
      }));
      final responseData = json.decode(response.body);
      if (responseData["success"]) {} else {
        print("arrangeCardList error");
      }
    } catch (e) {
      print("arrangeCardList error");
      print(e.toString());
    }
  }

  updateCardDescription(token, workspaceId, channelId, boardId, listCardId, cardId, description) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/update_card_description?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "description": description
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        getListBoards(token, workspaceId, channelId);
      } else {
        print("updateCardDescription error");
      }
    } catch (e) {
      print("updateCardDescription error");
      print(e.toString());
    }
  }
  
  updateChecklist(token, workspaceId, channelId, boardId, listCardId, cardId, checklistId, value) async { 
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/change_checklist?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "checklist_id": checklistId,
        "title": value
      }));
      final responseData = json.decode(response.body);
      if (responseData["success"]) {
      } else {
        print("updateChecklist error");
      }
    } catch (e) {
      print("updateChecklist error ${e.toString()}");
    }
  }

  sendCommentCard(token, workspaceId, channelId, boardId, listCardId, cardId, comment) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/send_comment_card?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "comment": comment
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {} else {
        print("sendCommentCard error");
      }
    } catch (e) {
      print("sendCommentCard error");
      print(e.toString());
    }
  }

  deleteComment(token, workspaceId, channelId, boardId, listCardId, cardId, commentId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/delete_comment?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "comment_id": commentId
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {} else {
        print("deleteComment error");
      }
    } catch (e) {
      print("deleteComment error");
      print(e.toString());
    }
  }

  getActivity(token, workspaceId, channelId, boardId, listCardId, cardId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/get_comments_and_attributes?token=$token');

    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        return responseData;
      } else {
        print("getActivity error");
      }
    } catch (e) {
      print("getActivity error");
      print(e.toString());
    }
  }

  addOrRemoveAttribute(token, workspaceId, channelId, boardId, listCardId, cardId, attributeId, type) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/add_or_remove_attribute?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "attribute_id": attributeId,
        "type": type
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        return responseData["card"];
      } else {
        print("addOrRemoveAttribute error");
      }
    } catch (e) {
      print("addOrRemoveAttribute error");
      print(e.toString());
    }
  }

  createLabel(token, workspaceId, channelId, boardId, title, colorHex) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/create_label?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "title": title,
        "color_hex": colorHex
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        selectedBoard["labels"].add(responseData["label"]);
        notifyListeners();
      } else {
        print("createLabel error");
      }
    } catch (e) {
      print("createLabel error");
      print(e.toString());
    }
  }

  createChecklist(token, workspaceId, channelId, boardId, listCardId, cardId, title) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/create_checklist?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "title": title
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        return responseData;
      } else {
        print("createChecklist error");
      }
    } catch (e) {
      print("createChecklist error");
      print(e.toString());
    }
  }

  createOrChangeTask(token, workspaceId, channelId, boardId, listCardId, cardId, checklistId, title, checked, taskId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/create_or_change_task?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "title": title,
        "checklist_id": checklistId,
        "task_id": taskId,
        "checked": checked
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        return responseData;
      } else {
        print("createOrChangeTask error");
      }
    } catch (e) {
      print("createOrChangeTask error");
      print(e.toString());
    }
  }

  deleteChecklistOrTask(token, workspaceId, channelId, boardId, listCardId, cardId, checklistId, taskId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/delete_checklist_or_task?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "checklist_id": checklistId,
        "task_id": taskId
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        return responseData;
      } else {
        print("deleteChecklistOrTask error");
      }
    } catch (e) {
      print("deleteChecklistOrTask error");
      print(e.toString());
    }
  }

  addAttachment(token, workspaceId, channelId, boardId, listCardId, cardId, contentUrl, type, fileName) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/add_attachment?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "content_url": contentUrl,
        "type": type,
        "file_name": fileName
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        return responseData;
      } else {
        print("addAttachment error");
        return null;
      }
    } catch (e) {
      print("addAttachment error");
      print(e.toString());
      return null;
    }
  }

  deleteAttachment(token, workspaceId, channelId, boardId, listCardId, cardId, attachmentId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/delete_attachment?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "card_attachment_id": attachmentId,
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        return responseData;
      } else {
        print("deleteAttachment error");
      }
    } catch (e) {
      print("deleteAttachment error");
      print(e.toString());
    }
  }

 updateCardTitleOrDescription(token, workspaceId, channelId, boardId, listCardId, card) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/${card['id']}/update_card?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "card": card,
        "description": card["description"],
        "title": card["title"],
        "priority": card["priority"],
        "due_date": card["dueDate"]
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        updateCard(workspaceId, channelId, boardId, listCardId, card["id"], "updateCard", card);
        getListBoards(token, workspaceId, channelId);
      } else {
        print("updateCardDescription error");
      }
    } catch (e) {
      print("updateCardDescription error");
      print(e.toString());
    }
  }

  changeListCardTitle(token, workspaceId, channelId, boardId, listCardId, title, isArchived) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/update_listcard_title?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "title": title,
        "is_archived": isArchived
      }));
      final responseData = json.decode(response.body);
      final indexBoard = _data.indexWhere((e) => e["id"] == boardId);
      final selectedBoard = _data[indexBoard];

      if (responseData["success"]) {
        final listCardIndex = selectedBoard["list_cards"].indexWhere((e) => e["id"] == listCardId);
        if (listCardIndex != -1) {
          selectedBoard["list_cards"][listCardIndex]["title"] = title;
          selectedBoard["list_cards"][listCardIndex]["is_archived"] = isArchived;
          if (isArchived) {
            _archivedLists["$boardId"] += [selectedBoard["list_cards"][listCardIndex]];
            selectedBoard["list_cards"].removeAt(listCardIndex);
          }
        } else {
          if (!isArchived) {
            final index = _archivedLists["$boardId"].indexWhere((e) => e["id"] == listCardId);
            if (index != -1) {
              selectedBoard["list_cards"].add(_archivedLists["$boardId"][index]);
              _archivedLists["$boardId"].removeAt(index);
            }
          }
        }
        notifyListeners();
        return true;
      } else {
        print("changeListCardTitle error");
        return false;
      }
    } catch (e) {
      print("changeListCardTitle error ${e.toString()}");
      return false;
    }
  }

  addTaskAttachment(token, workspaceId, channelId, boardId, listCardId, cardId, taskId, content) async { 
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/add_task_attachment?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "content": content,
        "task_id": taskId
      }));
      final responseData = json.decode(response.body);
      if (responseData["success"]) {
      } else {
        print("addTaskAttachment error");
      }
    } catch (e) {
      print("addTaskAttachment error ${e.toString()}");
    }
  }

  removeTaskAttachment(token, workspaceId, channelId, boardId, listCardId, cardId, taskId, contentId) async { 
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/remove_task_attachment?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "content_id": contentId,
        "task_id": taskId
      }));
      final responseData = json.decode(response.body);
      if (responseData["success"]) {
      } else {
        print("removeTaskAttachment error");
      }
    } catch (e) {
      print("removeTaskAttachment error ${e.toString()}");
    }
  }

  addOrRemoveTaskAssignee(token, workspaceId, channelId, boardId, listCardId, cardId, taskId, userId) async { 
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/add_or_remove_task_assignee?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "user_id": userId,
        "task_id": taskId
      }));
      final responseData = json.decode(response.body);
      if (responseData["success"]) {
      } else {
        print("addOrRemoveTaskAssignee error");
      }
    } catch (e) {
      print("addOrRemoveTaskAssignee error ${e.toString()}");
    }
  }

  checkAllTask(token, workspaceId, channelId, boardId, listCardId, cardId, checklistId, value) async { 
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/check_all_task?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "checklist_id": checklistId,
        "value": value
      }));
      final responseData = json.decode(response.body);
      if (responseData["success"]) {
      } else {
        print("checkAllTask error");
      }
    } catch (e) {
      print("checkAllTask error ${e.toString()}");
    }
  }

  changeBoardInfo(token, workspaceId, channelId, board) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/${board["id"]}/change_info?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "board": board,
      }));
      final responseData = json.decode(response.body);
      if (responseData["success"]) {
      } else {
        print("changeBoardInfo error");
      }
    } catch (e) {
      print("changeBoardInfo error ${e.toString()}");
    }
  }

  updateCard(workspaceId, channelId, boardId, listCardId, cardId, type, payload) {
    try {
      final listCardIndex = selectedBoard["list_cards"].indexWhere((e) => e["id"] == listCardId);
      if (listCardIndex == -1) return;
      final cards = selectedBoard["list_cards"][listCardIndex]["cards"];
      final indexCard = cards.indexWhere((e) => e["id"].toString() == cardId.toString());
      if (indexCard == -1) return;
      final card = cards[indexCard];

      if (type == "sendCommentCard") {
        card["comments_count"] +=1;
      } else if (type == "createOrChangeTask") {
        final tasks = card["tasks"];
        final indexTask = tasks.indexWhere((e) => e["id"].toString() == payload["taskId"].toString());

        if (indexTask == -1) {
          tasks.add(payload["task"]);
        }
      } else if (type == "deleteComment") {
        card["comments_count"] -=1;
      } else if (type == "deleteChecklistOrTask") {
        if (payload["taskId"] != null) {
          final indexTask = card["tasks"].indexWhere((e) => e["id"] == payload["taskId"]);
          if (indexTask != -1) card["tasks"].removeAt(indexTask);
        } else {
          card["tasks"] = card["tasks"].where((e) => e["checklist_id"] != payload["checklistId"]).toList();
        }
      } else if (type == "updateCard") {
        card["description"] = payload["description"];
        card["title"] = payload["title"];
        card["priority"] = payload["priority"];
        card["due_date"] = payload["dueDate"];
      }
      notifyListeners();
    } catch (e, trace) {
      print("updateCard error: $e $trace");
    }
  }

  editCommentCard(token, workspaceId, channelId, boardId, listCardId, cardId, comment, commentId, addFiles, removeFiles) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/boards/$boardId/$listCardId/$cardId/edit_comment_card?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({
        "comment": comment,
        "comment_id": commentId,
        "add_files": addFiles,
        "remove_files": removeFiles
      }));
      final responseData = json.decode(response.body);

      if (responseData["success"]) {
        updateCard(workspaceId, channelId, boardId, listCardId, cardId, "editCommentCard", {"comment": comment, 'comment_id': commentId});
      } else {
        print("editCommentCard error");
      }
    } catch (e, trace) {
      print("editCommentCard error");
      print(trace);
      print(e.toString());
    }
  }
}
