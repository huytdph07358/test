// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(fullName) => "${fullName} has assign you in an issue";

  static String m1(time) => "  at ${time}";

  static String m2(name) =>
      "There aren\'t any actions for you to take on ${name}.";

  static String m3(name) => "${name} has changed avatar this group";

  static String m4(assignUser, issueauthor, channelName) =>
      "${assignUser} has closed an issue ${issueauthor} created in ${channelName} channel";

  static String m5(assignUser, channelName) =>
      "${assignUser} has closed an issue you has been assign in ${channelName} channel";

  static String m6(count) => "${count} Closed";

  static String m7(time) => "commented ${time}";

  static String m8(count) =>
      "${Intl.plural(count, one: ' 1 comment', other: ' ${count} comments')}";

  static String m9(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m10(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m11(count) => "${count} labels";

  static String m12(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m13(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m14(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  static String m15(name) => "Are you sure you want to archive ${name}?";

  static String m16(name) => "Search your contacts and message in ${name}";

  static String m17(name) => "Search messages in ${name}";

  static String m18(time) => "•  edited ${time}";

  static String m19(statusCode) => "${statusCode} Error with status:";

  static String m20(user, invitedUser) => " ${user} has invited ${invitedUser}";

  static String m21(fullName, channelName) =>
      "${fullName} has invite you to ${channelName} channel";

  static String m22(fullName, workspaceName) =>
      "${fullName} has invite you to ${workspaceName} workspace";

  static String m23(name) => "Invite to ${name}";

  static String m24(count) => "${count} Open";

  static String m25(count) => "${count} Milestones";

  static String m26(time) => "opened this issue ${time}.";

  static String m27(name) => "Option: ${name}";

  static String m28(type) => "YOU RECEIVE AN INVITE TO JOIN A ${type}";

  static String m29(assignUser, issueauthor, channelName) =>
      "${assignUser} has reopened an issue ${issueauthor} created in ${channelName} channel";

  static String m30(assignUser, channelName) =>
      "${assignUser} has reopened an issue you has been assign in ${channelName} channel";

  static String m31(hotkey) =>
      "Search (${hotkey} + F) / Anything (${hotkey} + T)";

  static String m32(type) => "Search ${type}";

  static String m33(count) => "sent ${count} files.";

  static String m34(count) => "sent ${count} images.";

  static String m35(count) => "sent ${count} videos.";

  static String m36(count) => "Show ${count} more comments";

  static String m37(character) => "${character} Sticker";

  static String m38(fullName) => "${fullName} has unassign you in an issue";

  static String m39(hotkey) =>
      "Tip: Use shotkeyboard ${hotkey}-T to quick search";

  static String m40(hotkey) =>
      "Tip: Use shotkeyboard ${hotkey}-T to search anything";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Closed": MessageLookupByLibrary.simpleMessage("Closed"),
        "Commented": MessageLookupByLibrary.simpleMessage("commented"),
        "CreateANewPassword":
            MessageLookupByLibrary.simpleMessage("Create a new password"),
        "MediaAutoDownload":
            MessageLookupByLibrary.simpleMessage("Media auto-download"),
        "NewPassword": MessageLookupByLibrary.simpleMessage("New Password"),
        "Notification": MessageLookupByLibrary.simpleMessage("Notification"),
        "SearchDiscussionsDirectories": MessageLookupByLibrary.simpleMessage(
            "Search discussions, directories, data, and more"),
        "StorageDirectDessage":
            MessageLookupByLibrary.simpleMessage("Storage direct message"),
        "aNewDevice": MessageLookupByLibrary.simpleMessage("A new device"),
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "accept": MessageLookupByLibrary.simpleMessage("Accept"),
        "acceptInvite": MessageLookupByLibrary.simpleMessage("Accepted"),
        "accepted": MessageLookupByLibrary.simpleMessage("Accepted"),
        "active": MessageLookupByLibrary.simpleMessage("Active"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addANewAtt":
            MessageLookupByLibrary.simpleMessage("Add a new attachment"),
        "addAnOption": MessageLookupByLibrary.simpleMessage("Add an option"),
        "addAppToChannel":
            MessageLookupByLibrary.simpleMessage("Add app to channel"),
        "addApps": MessageLookupByLibrary.simpleMessage("Add apps"),
        "addCommands": MessageLookupByLibrary.simpleMessage("Add commands"),
        "addComment": MessageLookupByLibrary.simpleMessage("Add Comment"),
        "addDescription":
            MessageLookupByLibrary.simpleMessage("Add description"),
        "addDetail":
            MessageLookupByLibrary.simpleMessage("Add a more detailed..."),
        "addFriend": MessageLookupByLibrary.simpleMessage("Add friend"),
        "addFriendUsingEmail": MessageLookupByLibrary.simpleMessage(
            "Try adding a friend using their username or email address"),
        "addList": MessageLookupByLibrary.simpleMessage("Add list"),
        "addMoreDetailed":
            MessageLookupByLibrary.simpleMessage("Add more detailed"),
        "addName": MessageLookupByLibrary.simpleMessage("Add name"),
        "addNewApp": MessageLookupByLibrary.simpleMessage("Add new apps"),
        "addNewList": MessageLookupByLibrary.simpleMessage("Add new list"),
        "addNewOption": MessageLookupByLibrary.simpleMessage("Add new option"),
        "addParamsCommands":
            MessageLookupByLibrary.simpleMessage("Add Params Commands"),
        "addShortcut": MessageLookupByLibrary.simpleMessage("/ Add shortcut"),
        "addText": MessageLookupByLibrary.simpleMessage("Add text"),
        "addTitle": MessageLookupByLibrary.simpleMessage("Add title"),
        "addUrl": MessageLookupByLibrary.simpleMessage("https:// Add url"),
        "addYourFriendPancake":
            MessageLookupByLibrary.simpleMessage("Add your friend on Pancake"),
        "added": MessageLookupByLibrary.simpleMessage("Added"),
        "admins": MessageLookupByLibrary.simpleMessage("Admins"),
        "after": MessageLookupByLibrary.simpleMessage("After"),
        "ago": MessageLookupByLibrary.simpleMessage("ago"),
        "alert": MessageLookupByLibrary.simpleMessage("alert"),
        "all": MessageLookupByLibrary.simpleMessage("All"),
        "allFriends": MessageLookupByLibrary.simpleMessage("All friends"),
        "allowToSyncFromThisDevice": MessageLookupByLibrary.simpleMessage(
            "Allow to sync from this device?"),
        "alreadyHaveAnAccount":
            MessageLookupByLibrary.simpleMessage("Already have an account"),
        "alsoSendToChannel":
            MessageLookupByLibrary.simpleMessage("Also send to channel"),
        "anIssue": MessageLookupByLibrary.simpleMessage("an issue "),
        "anIssueYouHasBeenAssignIn": MessageLookupByLibrary.simpleMessage(
            "an issue you has been assign in"),
        "anMessageHasBeenSend": MessageLookupByLibrary.simpleMessage(
            "An message has been send with a code to"),
        "and": MessageLookupByLibrary.simpleMessage("and"),
        "anyMatch": MessageLookupByLibrary.simpleMessage("Any match"),
        "appAvailable":
            MessageLookupByLibrary.simpleMessage("Applications are available"),
        "appDefault": MessageLookupByLibrary.simpleMessage("App default"),
        "appLists": MessageLookupByLibrary.simpleMessage("App lists"),
        "appName": MessageLookupByLibrary.simpleMessage("App Name"),
        "appear": MessageLookupByLibrary.simpleMessage("Appear"),
        "apps": MessageLookupByLibrary.simpleMessage("Apps"),
        "archive": MessageLookupByLibrary.simpleMessage("Archive"),
        "archiveCard": MessageLookupByLibrary.simpleMessage("Archive Card"),
        "archiveChannel":
            MessageLookupByLibrary.simpleMessage("Archive Channel"),
        "archived": MessageLookupByLibrary.simpleMessage("archived"),
        "archivedItems": MessageLookupByLibrary.simpleMessage("Archived items"),
        "areYouWantTo": MessageLookupByLibrary.simpleMessage("Are you want to"),
        "askDeleteMember": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this member?"),
        "askLeaveWorkspace": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to leave this workspace?"),
        "assign": MessageLookupByLibrary.simpleMessage("assign"),
        "assignIssue": m0,
        "assignedNobody":
            MessageLookupByLibrary.simpleMessage("Assigned to nobody"),
        "assignees": MessageLookupByLibrary.simpleMessage("Assignees"),
        "at": m1,
        "ats": MessageLookupByLibrary.simpleMessage("at"),
        "attachImageToComment":
            MessageLookupByLibrary.simpleMessage("Attach image to comment"),
        "attachments": MessageLookupByLibrary.simpleMessage("Attachments"),
        "attendance": MessageLookupByLibrary.simpleMessage("Attendance"),
        "author": MessageLookupByLibrary.simpleMessage("Author"),
        "auto": MessageLookupByLibrary.simpleMessage("Auto"),
        "autoRefeshIn": MessageLookupByLibrary.simpleMessage("Auto refesh in"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "backup": MessageLookupByLibrary.simpleMessage("Backup"),
        "backupDM": MessageLookupByLibrary.simpleMessage("Backup DM"),
        "basicInfo": MessageLookupByLibrary.simpleMessage("Basic info"),
        "before": MessageLookupByLibrary.simpleMessage("Before "),
        "block": MessageLookupByLibrary.simpleMessage("Block"),
        "blocked": MessageLookupByLibrary.simpleMessage("Blocked"),
        "boards": MessageLookupByLibrary.simpleMessage("BOARDS"),
        "by": MessageLookupByLibrary.simpleMessage("by"),
        "call": MessageLookupByLibrary.simpleMessage("Call"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cantActionsForYou": m2,
        "changeAvatar": MessageLookupByLibrary.simpleMessage("Change Avatar"),
        "changeAvatarDm": m3,
        "changeFile": MessageLookupByLibrary.simpleMessage("Change File"),
        "changeNickname":
            MessageLookupByLibrary.simpleMessage("Change Nickname"),
        "changePassword":
            MessageLookupByLibrary.simpleMessage("Change Password"),
        "changeWorkflow":
            MessageLookupByLibrary.simpleMessage("Change workflow"),
        "channel": MessageLookupByLibrary.simpleMessage("channel"),
        "channelInstalled":
            MessageLookupByLibrary.simpleMessage("Channel Installed"),
        "channelName": MessageLookupByLibrary.simpleMessage("CHANNEL NAME"),
        "channelNameExisted":
            MessageLookupByLibrary.simpleMessage("Channel name already exists"),
        "channelSettings":
            MessageLookupByLibrary.simpleMessage("Channel Settings"),
        "channelTopic": MessageLookupByLibrary.simpleMessage("channel topic"),
        "channelType": MessageLookupByLibrary.simpleMessage("Channel Type"),
        "channels": MessageLookupByLibrary.simpleMessage("Channels"),
        "channelsList": MessageLookupByLibrary.simpleMessage("Channels list"),
        "checkList": MessageLookupByLibrary.simpleMessage("Checklists"),
        "chooseALabel": MessageLookupByLibrary.simpleMessage("Choose a label"),
        "chooseAMember":
            MessageLookupByLibrary.simpleMessage("Choose a member"),
        "closeIssue": MessageLookupByLibrary.simpleMessage("Close issue"),
        "closeIssues": m4,
        "closeIssues1": m5,
        "closeWithComment":
            MessageLookupByLibrary.simpleMessage("Close with comment"),
        "closed": m6,
        "closedThis": MessageLookupByLibrary.simpleMessage(" closed this"),
        "codeInvite": MessageLookupByLibrary.simpleMessage("Code invite"),
        "collapse": MessageLookupByLibrary.simpleMessage("Collapse"),
        "color": MessageLookupByLibrary.simpleMessage("Color"),
        "colorPicker": MessageLookupByLibrary.simpleMessage("Color Picker"),
        "commands": MessageLookupByLibrary.simpleMessage("Commands"),
        "comment": MessageLookupByLibrary.simpleMessage("Comment"),
        "commented": m7,
        "communityGuide":
            MessageLookupByLibrary.simpleMessage("Community Guidelines"),
        "complete": MessageLookupByLibrary.simpleMessage("complete"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirm password"),
        "connectGoogleDrive":
            MessageLookupByLibrary.simpleMessage("Connect Google Drive"),
        "connectPOSApp": MessageLookupByLibrary.simpleMessage(
            "Connect the POS app to this channel"),
        "connected": MessageLookupByLibrary.simpleMessage("Connected"),
        "connecting": MessageLookupByLibrary.simpleMessage("connecting"),
        "contactInfo": MessageLookupByLibrary.simpleMessage("Contact info"),
        "contactSupport":
            MessageLookupByLibrary.simpleMessage("Contact support"),
        "contacts": MessageLookupByLibrary.simpleMessage("Contacts"),
        "conversationName":
            MessageLookupByLibrary.simpleMessage("Conversation name"),
        "copyText": MessageLookupByLibrary.simpleMessage("Copy text"),
        "copyToClipboard":
            MessageLookupByLibrary.simpleMessage("Copy to clipboard"),
        "countComments": m8,
        "countDayAgo": m9,
        "countHourAgo": m10,
        "countLabels": m11,
        "countMinuteAgo": m12,
        "countMonthAgo": m13,
        "countYearAgo": m14,
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createANewIssue":
            MessageLookupByLibrary.simpleMessage("Create a new issue"),
        "createAWorkspace":
            MessageLookupByLibrary.simpleMessage("Create a workspace"),
        "createAccount": MessageLookupByLibrary.simpleMessage("Create Account"),
        "createAnAccount":
            MessageLookupByLibrary.simpleMessage("Create an Account"),
        "createApp": MessageLookupByLibrary.simpleMessage("Create app"),
        "createBoard": MessageLookupByLibrary.simpleMessage("Create board"),
        "createBy": MessageLookupByLibrary.simpleMessage("Create by"),
        "createChannel": MessageLookupByLibrary.simpleMessage("Create Channel"),
        "createCommand": MessageLookupByLibrary.simpleMessage("Create command"),
        "createCommands":
            MessageLookupByLibrary.simpleMessage("Create commands"),
        "createCustomApp":
            MessageLookupByLibrary.simpleMessage("Create custom app"),
        "createGroup": MessageLookupByLibrary.simpleMessage("Create group"),
        "createIssue": MessageLookupByLibrary.simpleMessage("Create issue"),
        "createLabels": MessageLookupByLibrary.simpleMessage("Create label"),
        "createMilestone":
            MessageLookupByLibrary.simpleMessage("Create milestone"),
        "createNewBoard":
            MessageLookupByLibrary.simpleMessage("Create new board"),
        "createNewLabel":
            MessageLookupByLibrary.simpleMessage("Create new label"),
        "createNewList":
            MessageLookupByLibrary.simpleMessage("Create new list"),
        "createNewMilestone":
            MessageLookupByLibrary.simpleMessage("Create new Milestone"),
        "createPoll": MessageLookupByLibrary.simpleMessage("Create Poll"),
        "createWorkspace":
            MessageLookupByLibrary.simpleMessage("Create workspace"),
        "created": MessageLookupByLibrary.simpleMessage("Created"),
        "createdByMessage":
            MessageLookupByLibrary.simpleMessage("Created by message"),
        "createdIn": MessageLookupByLibrary.simpleMessage("created in"),
        "currentPassword":
            MessageLookupByLibrary.simpleMessage("Current Password"),
        "customApp": MessageLookupByLibrary.simpleMessage("Create custom apps"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Dark mode"),
        "dataIsBeingTransmitted":
            MessageLookupByLibrary.simpleMessage("Data is being transmitted"),
        "dataProcessing":
            MessageLookupByLibrary.simpleMessage("Data processing"),
        "date": MessageLookupByLibrary.simpleMessage("Date"),
        "dateOfBirth": MessageLookupByLibrary.simpleMessage("Date of birth"),
        "day": MessageLookupByLibrary.simpleMessage("day"),
        "days": MessageLookupByLibrary.simpleMessage("days"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete account"),
        "deleteChannel": MessageLookupByLibrary.simpleMessage("Delete Channel"),
        "deleteChat": MessageLookupByLibrary.simpleMessage("Delete chat"),
        "deleteComment":
            MessageLookupByLibrary.simpleMessage("Delete this comment?"),
        "deleteDirectMessage":
            MessageLookupByLibrary.simpleMessage("Delete direct message"),
        "deleteForEveryone":
            MessageLookupByLibrary.simpleMessage("Delete for everyone"),
        "deleteForMe": MessageLookupByLibrary.simpleMessage("Delete for me"),
        "deleteLabel": MessageLookupByLibrary.simpleMessage("Delete Label"),
        "deleteMembers": MessageLookupByLibrary.simpleMessage("Delete member?"),
        "deleteMessages":
            MessageLookupByLibrary.simpleMessage("Delete Message"),
        "deleteMilestone":
            MessageLookupByLibrary.simpleMessage("Delete Milestone"),
        "deleteThisMessages": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this message?"),
        "deleteWorkspace":
            MessageLookupByLibrary.simpleMessage("Delete workspace"),
        "desAddFriend": MessageLookupByLibrary.simpleMessage(
            "Enter your friend\'s name with their tag. Ex: JohnDoe#1234"),
        "desApp": MessageLookupByLibrary.simpleMessage(
            "After creating and installing the application, you can configure to stay in specific channels."),
        "desBankApp": MessageLookupByLibrary.simpleMessage(
            "Notice of bank account fluctuations."),
        "desDeleteChannel": MessageLookupByLibrary.simpleMessage(
            "Are you sure want to delete this member from channel?\nThis action cannot be undone."),
        "desMentionMode": MessageLookupByLibrary.simpleMessage(
            "Channel dimming, highlighting and notification only when @mentions or @all."),
        "desNormalMode": MessageLookupByLibrary.simpleMessage(
            "All messages have notifications and highlights."),
        "desOffMode": MessageLookupByLibrary.simpleMessage("Nothing."),
        "desPOSApp": MessageLookupByLibrary.simpleMessage(
            "Synchronize messages from the left side configuration POS."),
        "desSearch": MessageLookupByLibrary.simpleMessage(
            "Search your contacts and messages in direct"),
        "desSearchAnything": MessageLookupByLibrary.simpleMessage(
            "Search all your contacts and messages."),
        "desSilentMode": MessageLookupByLibrary.simpleMessage(
            "Turn off notifications only."),
        "descArchiveChannel": m15,
        "descCreateWorkspace": MessageLookupByLibrary.simpleMessage(
            "Your workspace is where you and your friends hang out. Make your and start talking."),
        "descDeleteChannel": MessageLookupByLibrary.simpleMessage(
            "Are you sure want to delete channel ? This action cannot be undone"),
        "descDeleteLabel": MessageLookupByLibrary.simpleMessage(
            "Are you sure want to delete miletsone?\nThis action cannot be undone."),
        "descDeleteMilestone": MessageLookupByLibrary.simpleMessage(
            "Are you sure want to delete miletsone?\nThis action cannot be undone."),
        "descDeleteNewsroom": MessageLookupByLibrary.simpleMessage(
            "This is channel newsroom, if you remove this user from the channel it will be removed from the workspace"),
        "descDeleteWorkspace": MessageLookupByLibrary.simpleMessage(
            "Are you sure want to delete workspace ? This action cannot be undone"),
        "descFileterAuthor":
            MessageLookupByLibrary.simpleMessage("Type or choose a name"),
        "descInvite": MessageLookupByLibrary.simpleMessage(
            "Invite existing team member or add new ones."),
        "descJoinWs": MessageLookupByLibrary.simpleMessage(
            "Enter an invite below to join an existing workspace"),
        "descLeaveChannel": MessageLookupByLibrary.simpleMessage(
            "Are you sure want to leave channel?\nThis action cannot be undone."),
        "descLeaveGroup": MessageLookupByLibrary.simpleMessage(
            "Are you sure want to leave this conversation?"),
        "descLeaveWorkspace": MessageLookupByLibrary.simpleMessage(
            "Are you sure want to leave workspace?\nThis action cannot be undone."),
        "descNothingTurnedUp": MessageLookupByLibrary.simpleMessage(
            "You may want to try using different keywords or checking for typos"),
        "descResetDeviceKey": MessageLookupByLibrary.simpleMessage(
            "**Tap Reset Device Key to remove data from other devices. Panchat will send a Verify Code to your email/phone number"),
        "descSearchAll": MessageLookupByLibrary.simpleMessage(
            "Search all your directs and all workspaces"),
        "descSearchContact":
            MessageLookupByLibrary.simpleMessage("Search all your contacts"),
        "descSearchDms": MessageLookupByLibrary.simpleMessage(
            "Search messages in your direct"),
        "descSearchInCtWs": m16,
        "descSearchInWs": m17,
        "descSyncPanchat": MessageLookupByLibrary.simpleMessage(
            "*Tap Sync Data and open Panchat app on your devices to get OTP code"),
        "descWatchActivity": MessageLookupByLibrary.simpleMessage(
            "Notified of all notifications on this channel."),
        "descWatchMention": MessageLookupByLibrary.simpleMessage(
            "Only receive notifications from this channel when participating or @mentioned."),
        "description": MessageLookupByLibrary.simpleMessage("Description"),
        "details": MessageLookupByLibrary.simpleMessage("Details"),
        "devMode": MessageLookupByLibrary.simpleMessage("Dev mode"),
        "deviceId": MessageLookupByLibrary.simpleMessage("Device id"),
        "devices": MessageLookupByLibrary.simpleMessage("Devices"),
        "directMessageDetails":
            MessageLookupByLibrary.simpleMessage("Direct message details"),
        "directMessages":
            MessageLookupByLibrary.simpleMessage("Direct Messages"),
        "directSettings":
            MessageLookupByLibrary.simpleMessage("Direct settings"),
        "discard": MessageLookupByLibrary.simpleMessage("Discard"),
        "discarded": MessageLookupByLibrary.simpleMessage("Discarded"),
        "displayName": MessageLookupByLibrary.simpleMessage("Display name"),
        "doNotSync": MessageLookupByLibrary.simpleMessage("Do not sync"),
        "doYouWantToArchiveThisList": MessageLookupByLibrary.simpleMessage(
            "Do you want to archive this list."),
        "doYouWantToDeleteYourAccount": MessageLookupByLibrary.simpleMessage(
            "Do you want to delete your account?"),
        "doYouWantToDownload":
            MessageLookupByLibrary.simpleMessage("Do you want  to download"),
        "done": MessageLookupByLibrary.simpleMessage("Done"),
        "download": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadAttachment":
            MessageLookupByLibrary.simpleMessage("Download attachment"),
        "downloadFile": MessageLookupByLibrary.simpleMessage("Download file"),
        "downloadingData":
            MessageLookupByLibrary.simpleMessage("Downloading data"),
        "dueBy": MessageLookupByLibrary.simpleMessage("Due by "),
        "dueDate": MessageLookupByLibrary.simpleMessage("Due date (Opt)"),
        "dueDates": MessageLookupByLibrary.simpleMessage("Due date"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editBasicInfo":
            MessageLookupByLibrary.simpleMessage("Edit Basic info"),
        "editChannelDesc":
            MessageLookupByLibrary.simpleMessage("Edit channel description"),
        "editChannelTopic":
            MessageLookupByLibrary.simpleMessage("Edit channel topic"),
        "editComment": MessageLookupByLibrary.simpleMessage("Edit comment"),
        "editImage": MessageLookupByLibrary.simpleMessage("Edit Image"),
        "editMessage": MessageLookupByLibrary.simpleMessage("Edit message"),
        "editName": MessageLookupByLibrary.simpleMessage("Edit name"),
        "editWorkspaceName":
            MessageLookupByLibrary.simpleMessage("Edit workspace name"),
        "edited": MessageLookupByLibrary.simpleMessage("edited"),
        "editedBy": MessageLookupByLibrary.simpleMessage("•  edited by"),
        "editedTime": m18,
        "editors": MessageLookupByLibrary.simpleMessage("Editor"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "emailAddress": MessageLookupByLibrary.simpleMessage("Email address"),
        "enjoyToSearch":
            MessageLookupByLibrary.simpleMessage("Enjoy to search"),
        "enterANewPassword":
            MessageLookupByLibrary.simpleMessage("Re-type new"),
        "enterCardTitle":
            MessageLookupByLibrary.simpleMessage("Enter card title"),
        "enterListTitle":
            MessageLookupByLibrary.simpleMessage("Enter list title"),
        "enterPassToTransfer":
            MessageLookupByLibrary.simpleMessage("Enter password to transfer"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("Enter a Username#0000"),
        "enterYourCode":
            MessageLookupByLibrary.simpleMessage("ENTER YOUR CODE"),
        "enterYourCodeOnOtherDevices": MessageLookupByLibrary.simpleMessage(
            "You\'ll receive a 4 digit code to verify"),
        "enterYourInformationsBelow": MessageLookupByLibrary.simpleMessage(
            "Enter your informations below"),
        "errorWithStatus": m19,
        "exact": MessageLookupByLibrary.simpleMessage("exact"),
        "exactMatch": MessageLookupByLibrary.simpleMessage("Exact match"),
        "example": MessageLookupByLibrary.simpleMessage("Examples"),
        "expand": MessageLookupByLibrary.simpleMessage("Expand"),
        "failedToLoadImage":
            MessageLookupByLibrary.simpleMessage("Failed to load image"),
        "female": MessageLookupByLibrary.simpleMessage("Female"),
        "fileDownloading":
            MessageLookupByLibrary.simpleMessage("File downloading"),
        "fileManager": MessageLookupByLibrary.simpleMessage("File manager"),
        "files": MessageLookupByLibrary.simpleMessage("Files"),
        "filterLabels": MessageLookupByLibrary.simpleMessage("Filter labels"),
        "filterMilestone":
            MessageLookupByLibrary.simpleMessage("Filter milestones"),
        "filterNoMilestone":
            MessageLookupByLibrary.simpleMessage("Issues with no milestone"),
        "findAll": MessageLookupByLibrary.simpleMessage(
            "Find workspace, message, contacts ..."),
        "findEverything":
            MessageLookupByLibrary.simpleMessage("Find everything for you."),
        "firstName": MessageLookupByLibrary.simpleMessage("First name"),
        "forgotPassword":
            MessageLookupByLibrary.simpleMessage("Forgot Password"),
        "forwardMessage":
            MessageLookupByLibrary.simpleMessage("Forward message"),
        "forwardThisMessage":
            MessageLookupByLibrary.simpleMessage("Share this message"),
        "friends": MessageLookupByLibrary.simpleMessage("Friends"),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "fullName": MessageLookupByLibrary.simpleMessage("Full Name"),
        "gender": MessageLookupByLibrary.simpleMessage("Gender"),
        "gettingData": MessageLookupByLibrary.simpleMessage("Getting data"),
        "groupName": MessageLookupByLibrary.simpleMessage("Group name"),
        "hasChanged": MessageLookupByLibrary.simpleMessage("has changed"),
        "hasChangedChannel":
            MessageLookupByLibrary.simpleMessage("has changed channel"),
        "hasChangedChannelNameTo": MessageLookupByLibrary.simpleMessage(
            "has changed channel name to "),
        "hasChangedChannelTopicTo":
            MessageLookupByLibrary.simpleMessage("has changed"),
        "hasChangedChannelWorkflowTo": MessageLookupByLibrary.simpleMessage(
            "has changed channel workflow to "),
        "hasChangedDMNameTo":
            MessageLookupByLibrary.simpleMessage("has changed group name to "),
        "hasInviteYouTo":
            MessageLookupByLibrary.simpleMessage("has invite you to"),
        "hasInvited": MessageLookupByLibrary.simpleMessage(" has invited "),
        "hasJoinedTheChannelByCode": MessageLookupByLibrary.simpleMessage(
            " has joined the channel by invitation code"),
        "hasLeft": MessageLookupByLibrary.simpleMessage("has left "),
        "hasLeftTheChannel":
            MessageLookupByLibrary.simpleMessage("has left the channel"),
        "hass": MessageLookupByLibrary.simpleMessage("has"),
        "haveAnInviteAlready":
            MessageLookupByLibrary.simpleMessage("Have an invite already?"),
        "hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "hideDirectMessage":
            MessageLookupByLibrary.simpleMessage("Hide direct message"),
        "hight": MessageLookupByLibrary.simpleMessage("Hight"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "hour": MessageLookupByLibrary.simpleMessage("hour"),
        "hours": MessageLookupByLibrary.simpleMessage("hours"),
        "iAgreeToTheTerms": MessageLookupByLibrary.simpleMessage(
            "I agree to the Terms of service and Privacy policy"),
        "ifYouDontMakeThatRequest": MessageLookupByLibrary.simpleMessage(
            "If you don\'t make that request, please choose"),
        "images": MessageLookupByLibrary.simpleMessage("Images"),
        "inAnIssueYouHadFollowed": MessageLookupByLibrary.simpleMessage(
            "in an issue you had followed."),
        "inThread": MessageLookupByLibrary.simpleMessage("In thread"),
        "incomingFriendRequest":
            MessageLookupByLibrary.simpleMessage("Incoming Friend Request"),
        "index": MessageLookupByLibrary.simpleMessage("Index:"),
        "inputCannotEmpty":
            MessageLookupByLibrary.simpleMessage("Input cannot be empty"),
        "insertKeyCodeChannel": MessageLookupByLibrary.simpleMessage(
            "Please Insert KeyCode Channel"),
        "install": MessageLookupByLibrary.simpleMessage("Install"),
        "invied": m20,
        "inviedChannel": m21,
        "inviedChannels":
            MessageLookupByLibrary.simpleMessage(" Has invite you to channel"),
        "inviedWorkSpace": m22,
        "invitationHistory":
            MessageLookupByLibrary.simpleMessage("Invitation history:"),
        "invite": MessageLookupByLibrary.simpleMessage("Invite"),
        "inviteCodeWs": MessageLookupByLibrary.simpleMessage(
            "Or Invite by Code Workspace: "),
        "inviteLookLike":
            MessageLookupByLibrary.simpleMessage("Invites should look like"),
        "inviteMember": MessageLookupByLibrary.simpleMessage("Invite member"),
        "inviteOnly": MessageLookupByLibrary.simpleMessage("Invite Only"),
        "invitePeople": MessageLookupByLibrary.simpleMessage("Invite People"),
        "inviteTo": m23,
        "inviteToChannel": MessageLookupByLibrary.simpleMessage(
            "Invite new people to this channel."),
        "inviteToGroup":
            MessageLookupByLibrary.simpleMessage("Invite to group"),
        "inviteToWorkspace":
            MessageLookupByLibrary.simpleMessage("Invite to workspace"),
        "inviteWsCode":
            MessageLookupByLibrary.simpleMessage("INVITE LINK OR CODE INVITE"),
        "inviteYourFriend":
            MessageLookupByLibrary.simpleMessage("Invite your friend"),
        "invited": MessageLookupByLibrary.simpleMessage("Invited"),
        "issue": MessageLookupByLibrary.simpleMessage("Issue"),
        "issueCreateSuccess":
            MessageLookupByLibrary.simpleMessage("Issue created successfully"),
        "issueDetails": MessageLookupByLibrary.simpleMessage("issue Details"),
        "issues": MessageLookupByLibrary.simpleMessage("Issues"),
        "issuesWithNoMilestone":
            MessageLookupByLibrary.simpleMessage("Issues with no milestone"),
        "join": MessageLookupByLibrary.simpleMessage("Join"),
        "joinChannel": MessageLookupByLibrary.simpleMessage("Join Channel"),
        "joinChannelFail": MessageLookupByLibrary.simpleMessage(
            "Join the error channel. Please try again.."),
        "joinChannelSuccess": MessageLookupByLibrary.simpleMessage(
            "Join channel was successful."),
        "joinWorkspace":
            MessageLookupByLibrary.simpleMessage("Join a workspace"),
        "joinWorkspaceFail": MessageLookupByLibrary.simpleMessage(
            "Join the error workspace. Please try again.."),
        "joinWorkspaceSuccess": MessageLookupByLibrary.simpleMessage(
            "Join workspace was successful"),
        "justLoggeInAndRequested": MessageLookupByLibrary.simpleMessage(
            "just logged in and requested to sync data from this device."),
        "justMention": MessageLookupByLibrary.simpleMessage("Just @mention"),
        "kanbanMode": MessageLookupByLibrary.simpleMessage("Kanban mode"),
        "labelSelected": MessageLookupByLibrary.simpleMessage("label selected"),
        "labels": MessageLookupByLibrary.simpleMessage("Labels"),
        "labelsName": MessageLookupByLibrary.simpleMessage("labels Name"),
        "language": MessageLookupByLibrary.simpleMessage("Language & Region"),
        "languages": MessageLookupByLibrary.simpleMessage("Languages"),
        "lastName": MessageLookupByLibrary.simpleMessage("Last name"),
        "lastReplyAt": MessageLookupByLibrary.simpleMessage("Last reply at"),
        "leastRecentlyUpdated":
            MessageLookupByLibrary.simpleMessage("Least Recently Updated"),
        "leaveAComment":
            MessageLookupByLibrary.simpleMessage("Leave a comment"),
        "leaveADescription":
            MessageLookupByLibrary.simpleMessage("Leave a description"),
        "leaveChannel": MessageLookupByLibrary.simpleMessage("Leave Channel"),
        "leaveConversation":
            MessageLookupByLibrary.simpleMessage("Leave conversation"),
        "leaveDirect":
            MessageLookupByLibrary.simpleMessage("Has left this conversation"),
        "leaveGroup": MessageLookupByLibrary.simpleMessage("Leave group"),
        "leaveWorkspace":
            MessageLookupByLibrary.simpleMessage("Leave workspace"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Light mode"),
        "listArchive": MessageLookupByLibrary.simpleMessage("List Archived"),
        "listChannel": MessageLookupByLibrary.simpleMessage("List channel"),
        "listWorkspaceMember": MessageLookupByLibrary.simpleMessage(
            "List of people in the workspace"),
        "loggedIntoGoogleDrive":
            MessageLookupByLibrary.simpleMessage("Logged into Google Drive"),
        "loginWithQRCode":
            MessageLookupByLibrary.simpleMessage("Login with QR code"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "logoutThisDevice":
            MessageLookupByLibrary.simpleMessage("Logout this device"),
        "lookingFor":
            MessageLookupByLibrary.simpleMessage("Or I\'m looking for..."),
        "low": MessageLookupByLibrary.simpleMessage("Low"),
        "male": MessageLookupByLibrary.simpleMessage("Male"),
        "markAsUnread": MessageLookupByLibrary.simpleMessage("Mark as unread"),
        "matchAnyLabelAnd": MessageLookupByLibrary.simpleMessage(
            "Match any label and any member."),
        "medium": MessageLookupByLibrary.simpleMessage("Medium"),
        "members": MessageLookupByLibrary.simpleMessage("Members"),
        "mentionMode": MessageLookupByLibrary.simpleMessage("MENTION MODE"),
        "mentions": MessageLookupByLibrary.simpleMessage("Mentions"),
        "messageName": MessageLookupByLibrary.simpleMessage("MESSAGE NAME"),
        "messages": MessageLookupByLibrary.simpleMessage("Messages"),
        "messagesAndCallsInThisChatWill": MessageLookupByLibrary.simpleMessage(
            "Messages and calls in this chat will be encrypted end-to-end. Only participants could read or listen to them."),
        "milestoneTitle":
            MessageLookupByLibrary.simpleMessage("Milestone title"),
        "milestones": MessageLookupByLibrary.simpleMessage("Milestones"),
        "minute": MessageLookupByLibrary.simpleMessage("minute"),
        "minutes": MessageLookupByLibrary.simpleMessage("minutes"),
        "minutesAgo": MessageLookupByLibrary.simpleMessage("minutes ago"),
        "mobile": MessageLookupByLibrary.simpleMessage("mobile"),
        "mobileData": MessageLookupByLibrary.simpleMessage("mobile data"),
        "momentAgo": MessageLookupByLibrary.simpleMessage("moment ago"),
        "month": MessageLookupByLibrary.simpleMessage("month"),
        "months": MessageLookupByLibrary.simpleMessage("months"),
        "moreUnread": MessageLookupByLibrary.simpleMessage("More unreads"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "nameBoard": MessageLookupByLibrary.simpleMessage("Name Board"),
        "nameFile": MessageLookupByLibrary.simpleMessage("Name file: "),
        "nameList": MessageLookupByLibrary.simpleMessage("Name List"),
        "nearbyScan": MessageLookupByLibrary.simpleMessage("Nearby Scan"),
        "newBoards": MessageLookupByLibrary.simpleMessage("New boards"),
        "newCard": MessageLookupByLibrary.simpleMessage("New Card"),
        "newChecklist": MessageLookupByLibrary.simpleMessage("New checklist"),
        "newIssue": MessageLookupByLibrary.simpleMessage("New issue"),
        "newLabel": MessageLookupByLibrary.simpleMessage("New label"),
        "newList": MessageLookupByLibrary.simpleMessage("New List"),
        "newMessage": MessageLookupByLibrary.simpleMessage("New message"),
        "newMilestone": MessageLookupByLibrary.simpleMessage("New milestone"),
        "newPasswordDoesMatch":
            MessageLookupByLibrary.simpleMessage("New password doesn\'t match"),
        "newest": MessageLookupByLibrary.simpleMessage("Newest"),
        "news": MessageLookupByLibrary.simpleMessage("NEW"),
        "newworkspace": MessageLookupByLibrary.simpleMessage("Add a workspace"),
        "next": MessageLookupByLibrary.simpleMessage("Next"),
        "noAttachment": MessageLookupByLibrary.simpleMessage("No attachment"),
        "noCheckList": MessageLookupByLibrary.simpleMessage("No checkList"),
        "noDescriptionProvided":
            MessageLookupByLibrary.simpleMessage("_No description provided._"),
        "noDueDate": MessageLookupByLibrary.simpleMessage("No due date"),
        "noFriendToAdd":
            MessageLookupByLibrary.simpleMessage("No friends to add"),
        "noItems": MessageLookupByLibrary.simpleMessage(
            "No items have been pinned yet!"),
        "noLabel": MessageLookupByLibrary.simpleMessage("No label"),
        "noMembers": MessageLookupByLibrary.simpleMessage("No members"),
        "noMilestone": MessageLookupByLibrary.simpleMessage("No milestone"),
        "noOneAssignYourself":
            MessageLookupByLibrary.simpleMessage("No one-assign yourself"),
        "noSelected": MessageLookupByLibrary.simpleMessage("No selected"),
        "none": MessageLookupByLibrary.simpleMessage("None"),
        "noneYet": MessageLookupByLibrary.simpleMessage("None yet"),
        "normal": MessageLookupByLibrary.simpleMessage("Normal"),
        "normalMode": MessageLookupByLibrary.simpleMessage("NORMAL MODE"),
        "notRegisteredYet":
            MessageLookupByLibrary.simpleMessage("Not registered yet"),
        "notSet": MessageLookupByLibrary.simpleMessage("Not set"),
        "noteCreateWs": MessageLookupByLibrary.simpleMessage(
            "By create a workspace, you agree to Pancake\'s"),
        "noteNewPassword": MessageLookupByLibrary.simpleMessage(
            "Note: New password must be at least 6 characters or more & up to 32 characters."),
        "nothing": MessageLookupByLibrary.simpleMessage("Nothing"),
        "nothingTurnedUp":
            MessageLookupByLibrary.simpleMessage("Nothing turned up"),
        "notificationSound":
            MessageLookupByLibrary.simpleMessage("Notification & Sound"),
        "notifySetting":
            MessageLookupByLibrary.simpleMessage("Notification setting"),
        "now": MessageLookupByLibrary.simpleMessage("now"),
        "off": MessageLookupByLibrary.simpleMessage("Off"),
        "offMode": MessageLookupByLibrary.simpleMessage("OFF MODE"),
        "offline": MessageLookupByLibrary.simpleMessage("Offline"),
        "oldest": MessageLookupByLibrary.simpleMessage("Oldest"),
        "on": MessageLookupByLibrary.simpleMessage("on"),
        "online": MessageLookupByLibrary.simpleMessage("Online"),
        "open": m24,
        "openMilestones": m25,
        "openThisIssue": m26,
        "opened": MessageLookupByLibrary.simpleMessage("opened"),
        "openedThisIssue":
            MessageLookupByLibrary.simpleMessage("opened this issue"),
        "option": MessageLookupByLibrary.simpleMessage("Option"),
        "optionName": m27,
        "or": MessageLookupByLibrary.simpleMessage("or"),
        "other": MessageLookupByLibrary.simpleMessage("other"),
        "outgoingFriendRequest":
            MessageLookupByLibrary.simpleMessage("Outgoing Friend Request"),
        "overdue": MessageLookupByLibrary.simpleMessage("Overdue"),
        "owner": MessageLookupByLibrary.simpleMessage("Owner"),
        "params": MessageLookupByLibrary.simpleMessage("Params:"),
        "paramsCommand":
            MessageLookupByLibrary.simpleMessage("Params Commands:"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "pastDueBy": MessageLookupByLibrary.simpleMessage("Past due by"),
        "pendingRequest":
            MessageLookupByLibrary.simpleMessage("PENDING REQUEST"),
        "phoneNumber": MessageLookupByLibrary.simpleMessage("Phone number"),
        "photo": MessageLookupByLibrary.simpleMessage("Photo"),
        "pinMessage": MessageLookupByLibrary.simpleMessage("Pin message"),
        "pinMessages": MessageLookupByLibrary.simpleMessage("Pin message"),
        "pinThisChannel":
            MessageLookupByLibrary.simpleMessage("Pin this channel."),
        "pinned": MessageLookupByLibrary.simpleMessage("Pinned"),
        "pleaseChoose": MessageLookupByLibrary.simpleMessage("please choose"),
        "pleaseSelectChannel":
            MessageLookupByLibrary.simpleMessage("Please select channel"),
        "pleaseUpdateVersion":
            MessageLookupByLibrary.simpleMessage("Please update version"),
        "pollIsDisabled":
            MessageLookupByLibrary.simpleMessage("This poll is disabled"),
        "postedIn": MessageLookupByLibrary.simpleMessage("Posted in"),
        "preview": MessageLookupByLibrary.simpleMessage("Preview"),
        "previewComment":
            MessageLookupByLibrary.simpleMessage("Preview Comment"),
        "previewText": MessageLookupByLibrary.simpleMessage("Preview text"),
        "previous": MessageLookupByLibrary.simpleMessage("Previous"),
        "priority": MessageLookupByLibrary.simpleMessage("Priority"),
        "private": MessageLookupByLibrary.simpleMessage("Private"),
        "privateChannel":
            MessageLookupByLibrary.simpleMessage("Private Channel"),
        "privates": MessageLookupByLibrary.simpleMessage("private"),
        "processingData":
            MessageLookupByLibrary.simpleMessage("Processing data"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "profileEdit": MessageLookupByLibrary.simpleMessage("Profile Edit"),
        "public": MessageLookupByLibrary.simpleMessage("public"),
        "publicChannel": MessageLookupByLibrary.simpleMessage("Public Channel"),
        "receiveJoinChannel": m28,
        "recentChannel": MessageLookupByLibrary.simpleMessage("Recent channel"),
        "recentSearches":
            MessageLookupByLibrary.simpleMessage("Recent Searches"),
        "recentlyUpdated":
            MessageLookupByLibrary.simpleMessage("Recently Updated"),
        "regular": MessageLookupByLibrary.simpleMessage("Regular"),
        "reject": MessageLookupByLibrary.simpleMessage("Reject"),
        "rememberMe": MessageLookupByLibrary.simpleMessage("Remember me"),
        "remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "removeFriend": MessageLookupByLibrary.simpleMessage("Remove Friend"),
        "removeFromSavedItems":
            MessageLookupByLibrary.simpleMessage("Remove from saved items"),
        "removed": MessageLookupByLibrary.simpleMessage("removed"),
        "reopen": MessageLookupByLibrary.simpleMessage("Reopen"),
        "reopenIssue": MessageLookupByLibrary.simpleMessage("Reopen issue"),
        "reopened": m29,
        "reopened1": m30,
        "reopenedThis": MessageLookupByLibrary.simpleMessage(" reopened this"),
        "repliedTo": MessageLookupByLibrary.simpleMessage("Replied to"),
        "repliedToAThread":
            MessageLookupByLibrary.simpleMessage("replied to a thread : "),
        "repliedToThread":
            MessageLookupByLibrary.simpleMessage("Replied to thread"),
        "replies": MessageLookupByLibrary.simpleMessage("replies"),
        "reply": MessageLookupByLibrary.simpleMessage("Replied to a message"),
        "replyInThread":
            MessageLookupByLibrary.simpleMessage("Reply in thread"),
        "replyThisMessage":
            MessageLookupByLibrary.simpleMessage("Reply message"),
        "replyThread": MessageLookupByLibrary.simpleMessage("Reply"),
        "replys": MessageLookupByLibrary.simpleMessage("reply"),
        "reportDirectMessage":
            MessageLookupByLibrary.simpleMessage("Report direct message"),
        "request": MessageLookupByLibrary.simpleMessage("Request"),
        "requestSyncData":
            MessageLookupByLibrary.simpleMessage("request sync data"),
        "requestTime": MessageLookupByLibrary.simpleMessage("Request time"),
        "requestUrl": MessageLookupByLibrary.simpleMessage("Request URL:"),
        "resetDeviceKey":
            MessageLookupByLibrary.simpleMessage("Reset device key"),
        "response": MessageLookupByLibrary.simpleMessage("Response"),
        "restore": MessageLookupByLibrary.simpleMessage("Restore"),
        "restoreDM": MessageLookupByLibrary.simpleMessage("Restore DM"),
        "results": MessageLookupByLibrary.simpleMessage("Results"),
        "reviewIssue": MessageLookupByLibrary.simpleMessage("Review Issue"),
        "roles": MessageLookupByLibrary.simpleMessage("Roles"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Save change"),
        "saveMessage": MessageLookupByLibrary.simpleMessage("Save message"),
        "savedMessages": MessageLookupByLibrary.simpleMessage("Saved Messages"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "searchAnything": m31,
        "searchArchive": MessageLookupByLibrary.simpleMessage("Search archive"),
        "searchChannel": MessageLookupByLibrary.simpleMessage("Search Channel"),
        "searchLabel": MessageLookupByLibrary.simpleMessage("Search label"),
        "searchMember": MessageLookupByLibrary.simpleMessage("Search member"),
        "searchType": m32,
        "second": MessageLookupByLibrary.simpleMessage("second"),
        "selectChannel": MessageLookupByLibrary.simpleMessage("Select Channel"),
        "selectMember": MessageLookupByLibrary.simpleMessage("Select member"),
        "selected": MessageLookupByLibrary.simpleMessage("Selected"),
        "sendFriendRequest":
            MessageLookupByLibrary.simpleMessage("Send Friend Request"),
        "sendToBoard": MessageLookupByLibrary.simpleMessage("Send to board"),
        "sent": MessageLookupByLibrary.simpleMessage("Sent"),
        "sentAFile": MessageLookupByLibrary.simpleMessage("sent a file."),
        "sentAVideo": MessageLookupByLibrary.simpleMessage("sent a video."),
        "sentAnImage": MessageLookupByLibrary.simpleMessage("sent an image."),
        "sentAttachments":
            MessageLookupByLibrary.simpleMessage("sent attachments."),
        "sentFiles": m33,
        "sentImages": m34,
        "sentVideos": m35,
        "setAdmin": MessageLookupByLibrary.simpleMessage("Set Admin"),
        "setDesc": MessageLookupByLibrary.simpleMessage("Set Description"),
        "setEditor": MessageLookupByLibrary.simpleMessage("Set Editor"),
        "setMember": MessageLookupByLibrary.simpleMessage("Set Member"),
        "setTopic": MessageLookupByLibrary.simpleMessage("Set Topic"),
        "setrole": MessageLookupByLibrary.simpleMessage("Set Roles"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Sent a shared message"),
        "shareMessage":
            MessageLookupByLibrary.simpleMessage("Sharing this message:"),
        "shareMessages": MessageLookupByLibrary.simpleMessage("Share message"),
        "shortcut": MessageLookupByLibrary.simpleMessage("Shortcut:"),
        "showMoreComments": m36,
        "signIn": MessageLookupByLibrary.simpleMessage("Sign in"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign up"),
        "silent": MessageLookupByLibrary.simpleMessage("Silent"),
        "silentMode": MessageLookupByLibrary.simpleMessage("SILENT MODE"),
        "sort": MessageLookupByLibrary.simpleMessage("Sort"),
        "sortBy": MessageLookupByLibrary.simpleMessage("Sort by"),
        "startDownloading":
            MessageLookupByLibrary.simpleMessage("Start downloading"),
        "startingUp": MessageLookupByLibrary.simpleMessage("Starting up"),
        "sticker": m37,
        "sticker1": MessageLookupByLibrary.simpleMessage("Sent a sticker"),
        "submit": MessageLookupByLibrary.simpleMessage("Submit"),
        "submitNewIssue":
            MessageLookupByLibrary.simpleMessage("Submit new issue"),
        "success": MessageLookupByLibrary.simpleMessage("Success"),
        "switchToCards":
            MessageLookupByLibrary.simpleMessage("Switch to cards"),
        "switchToLists":
            MessageLookupByLibrary.simpleMessage("Switch to lists"),
        "sync": MessageLookupByLibrary.simpleMessage("Sync"),
        "syncData": MessageLookupByLibrary.simpleMessage(" Sync data"),
        "syncPanchatApp":
            MessageLookupByLibrary.simpleMessage("Sync by Panchat app *"),
        "synchronizationwilltake": MessageLookupByLibrary.simpleMessage(
            "Synchronization will take place as required by the device"),
        "syntaxError": MessageLookupByLibrary.simpleMessage(
            "Syntax code was wrong, try again!"),
        "tClose": MessageLookupByLibrary.simpleMessage("Close"),
        "tClosed": MessageLookupByLibrary.simpleMessage("Closed"),
        "tOpen": MessageLookupByLibrary.simpleMessage("Open"),
        "tagName": MessageLookupByLibrary.simpleMessage("Tag name"),
        "theVideoCallEnded":
            MessageLookupByLibrary.simpleMessage("The video call ended."),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "thereWasAnErrorInUpdating": MessageLookupByLibrary.simpleMessage(
            "There was an error in updating information there was an error in updating your information, please try again later!"),
        "thereWasAnErrorWhile": MessageLookupByLibrary.simpleMessage(
            "There was an error while uploading the avatar, please try again later!"),
        "thisChannel": MessageLookupByLibrary.simpleMessage("this channel"),
        "thisConversation":
            MessageLookupByLibrary.simpleMessage("this conversation"),
        "thisGroup": MessageLookupByLibrary.simpleMessage("this group "),
        "thisIsTheStartOf":
            MessageLookupByLibrary.simpleMessage("This is the start of"),
        "thisMessageDeleted":
            MessageLookupByLibrary.simpleMessage("[This message was deleted.]"),
        "thisMessageWasDeleted":
            MessageLookupByLibrary.simpleMessage("[This message was deleted.]"),
        "threads": MessageLookupByLibrary.simpleMessage("Threads"),
        "timeCreate": MessageLookupByLibrary.simpleMessage("Time create"),
        "timeCreated": MessageLookupByLibrary.simpleMessage("Time Created"),
        "tipFilter":
            MessageLookupByLibrary.simpleMessage("Use ↑ ↓ ↵ to navigate"),
        "tipSearch": MessageLookupByLibrary.simpleMessage(
            "Tips: Use shotkeyboard CMD + T to search anything."),
        "title": MessageLookupByLibrary.simpleMessage("Title"),
        "titleCannotBeEmpty":
            MessageLookupByLibrary.simpleMessage("Title cannot be empty"),
        "to": MessageLookupByLibrary.simpleMessage("to"),
        "toChannel": MessageLookupByLibrary.simpleMessage(" to channel"),
        "toResetYourDevice":
            MessageLookupByLibrary.simpleMessage("to reset your device"),
        "toThisConversation":
            MessageLookupByLibrary.simpleMessage("to this conversation"),
        "today": MessageLookupByLibrary.simpleMessage("Today"),
        "topic": MessageLookupByLibrary.simpleMessage("Topic"),
        "transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
        "transferIssue": MessageLookupByLibrary.simpleMessage("Transfer issue"),
        "transferOwner":
            MessageLookupByLibrary.simpleMessage("Transfer ownership"),
        "transferTo": MessageLookupByLibrary.simpleMessage("Transfer to"),
        "trong": MessageLookupByLibrary.simpleMessage("In"),
        "typeAMessage": MessageLookupByLibrary.simpleMessage("Type a message"),
        "typeEmailOrPhoneToInvite": MessageLookupByLibrary.simpleMessage(
            "Type an email or phone number to invite"),
        "typeMessage":
            MessageLookupByLibrary.simpleMessage("Type a message..."),
        "unPinThisChannel":
            MessageLookupByLibrary.simpleMessage("Unpin this channel."),
        "unarchiveCard": MessageLookupByLibrary.simpleMessage("Unarchive card"),
        "unarchiveChannel":
            MessageLookupByLibrary.simpleMessage("Unarchive Channel"),
        "unarchived": MessageLookupByLibrary.simpleMessage("unarchived"),
        "unassign": MessageLookupByLibrary.simpleMessage("unassign"),
        "unassignIssue": m38,
        "unpinMessage": MessageLookupByLibrary.simpleMessage("Unpin message"),
        "unreadOnly": MessageLookupByLibrary.simpleMessage("Unread only"),
        "unsaveMessages": MessageLookupByLibrary.simpleMessage("Remove saved"),
        "unwatch": MessageLookupByLibrary.simpleMessage("Unwatch"),
        "update": MessageLookupByLibrary.simpleMessage("Update"),
        "updateCommand": MessageLookupByLibrary.simpleMessage("Update command"),
        "updateComment": MessageLookupByLibrary.simpleMessage("Update comment"),
        "upload": MessageLookupByLibrary.simpleMessage("Upload"),
        "urgent": MessageLookupByLibrary.simpleMessage("Urgent"),
        "useShotKeyboardQuickSearch": m39,
        "useShotKeyboardSearchAnything": m40,
        "userManagement":
            MessageLookupByLibrary.simpleMessage("USER MANAGEMENT"),
        "userName": MessageLookupByLibrary.simpleMessage("User name"),
        "userProfile": MessageLookupByLibrary.simpleMessage("User profile"),
        "verificationHasFailed":
            MessageLookupByLibrary.simpleMessage("Verification has failed"),
        "video": MessageLookupByLibrary.simpleMessage("Video"),
        "videoCall": MessageLookupByLibrary.simpleMessage("Video"),
        "viewAll": MessageLookupByLibrary.simpleMessage("View all"),
        "viewMessage": MessageLookupByLibrary.simpleMessage("View message"),
        "viewProfile": MessageLookupByLibrary.simpleMessage("View profile"),
        "viewWholeFile":
            MessageLookupByLibrary.simpleMessage("View whole file"),
        "waitingForVerification":
            MessageLookupByLibrary.simpleMessage("Waiting for verification"),
        "wasKickedFromThisChannel": MessageLookupByLibrary.simpleMessage(
            " was kicked from this channel"),
        "watch": MessageLookupByLibrary.simpleMessage("Watch"),
        "watchActivity": MessageLookupByLibrary.simpleMessage("All Activity"),
        "watchAllComment": MessageLookupByLibrary.simpleMessage(
            "Add all comments from the subcribed issues to the thread."),
        "watchMention":
            MessageLookupByLibrary.simpleMessage("Participating and @mentions"),
        "weSoExcitedToSeeYou": MessageLookupByLibrary.simpleMessage(
            "We\'re so excited to see you"),
        "welcome": MessageLookupByLibrary.simpleMessage("Welcome!"),
        "welcomeTo": MessageLookupByLibrary.simpleMessage("Welcome to"),
        "whatForDiscussion":
            MessageLookupByLibrary.simpleMessage("What’s up for discussion?"),
        "whatUpForDiscussion":
            MessageLookupByLibrary.simpleMessage("What\'s up for discussion?"),
        "whatYourPollAbout":
            MessageLookupByLibrary.simpleMessage("What\'s your poll about?"),
        "whenUsing": MessageLookupByLibrary.simpleMessage("When using"),
        "workspace": MessageLookupByLibrary.simpleMessage("Workspace"),
        "workspaceCannotBlank": MessageLookupByLibrary.simpleMessage(
            "Workspaces\'s name cannot be blank"),
        "workspaceDetails":
            MessageLookupByLibrary.simpleMessage("Workspace details"),
        "workspaceName":
            MessageLookupByLibrary.simpleMessage("Workspace\'s name"),
        "wrongCodePleaseTryAgain": MessageLookupByLibrary.simpleMessage(
            "Wrong code, please try again"),
        "year": MessageLookupByLibrary.simpleMessage("year"),
        "years": MessageLookupByLibrary.simpleMessage("years"),
        "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
        "youCanUndoThisAction":
            MessageLookupByLibrary.simpleMessage("You can’t undo this action"),
        "youDoNotHaveSufficient": MessageLookupByLibrary.simpleMessage(
            "You do not have sufficient permissions to perform the operation"),
        "youInAnIssueIn":
            MessageLookupByLibrary.simpleMessage("you in an issue in"),
        "youWillNeedBoth": MessageLookupByLibrary.simpleMessage(
            "You will need both their username and a tag. Keep in mind that username is case sensitive."),
        "yourEmailPhone":
            MessageLookupByLibrary.simpleMessage("Your email/phone"),
        "yourFriend": MessageLookupByLibrary.simpleMessage("Your friends"),
        "yourName": MessageLookupByLibrary.simpleMessage("Your name"),
        "yourRoleCannotAction": MessageLookupByLibrary.simpleMessage(
            "Your role cannot take action."),
        "yourUsernameAndTag":
            MessageLookupByLibrary.simpleMessage("* Your username and tag is ")
      };
}
