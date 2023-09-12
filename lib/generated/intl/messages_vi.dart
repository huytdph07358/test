// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
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
  String get localeName => 'vi';

  static String m0(fullName) => "${fullName} đã chỉ định bạn trong một issue";

  static String m1(time) => "  lúc ${time}";

  static String m2(name) => "Bạn không thể thực hiện thao tác với ${name}.";

  static String m3(name) => "${name} đã thay đổi avatar nhóm này";

  static String m4(assignUser, issueauthor, channelName) =>
      "${assignUser} đã đóng issue mà ${issueauthor} tạo trong kênh ${channelName}";

  static String m5(assignUser, channelName) =>
      "${assignUser} đã đóng issue mà bạn đã được chỉ định trong kênh ${channelName}";

  static String m6(count) => "${count} Đóng";

  static String m7(time) => "đã bình luận ${time}";

  static String m8(count) => " ${count} bình luận";

  static String m9(count) => "${count} ngày trước";

  static String m10(count) => "${count} giờ trước";

  static String m11(count) => "${count} nhãn";

  static String m12(count) => "${count} phút trước";

  static String m13(count) => "${count} tháng trước";

  static String m14(count) => "${count} năm trước";

  static String m15(name) => "Bạn có chắc chắn muốn lưu trữ ${name}?";

  static String m16(name) =>
      "Tìm kiếm tất cả liên hệ và tin nhắn trong ${name}";

  static String m17(name) => "Tìm kiếm tin nhắn trong ${name}";

  static String m18(time) => "•  chỉnh sửa lúc ${time}";

  static String m19(statusCode) => "${statusCode} Lỗi với trạng thái:";

  static String m20(user, invitedUser) => " ${user} đã mời ${invitedUser}";

  static String m21(fullName, channelName) =>
      "${fullName} đã mời bạn vào kênh ${channelName}";

  static String m22(fullName, workspaceName) =>
      "${fullName} đã mời bạn vào phòng ${workspaceName}.";

  static String m23(name) => "Mời đến kênh ${name}";

  static String m24(count) => "${count} Mở";

  static String m25(count) => "${count} mốc";

  static String m26(time) => "đã mở issue lúc ${time}.";

  static String m27(name) => "Tuỳ chọn: ${name}";

  static String m28(type) => "BẠN NHẬN ĐƯỢC LỜI MỜI THAM GIA ${type}";

  static String m29(assignUser, issueauthor, channelName) =>
      "${assignUser} đã mở lại issue ${issueauthor} đã tạo trong kênh ${channelName}";

  static String m30(assignUser, channelName) =>
      "${assignUser} đã mở lại issue mà bạn đã được chỉ định trong kênh ${channelName}";

  static String m31(hotkey) =>
      "Tìm kiếm (${hotkey} + F) / Bất kỳ (${hotkey} + T)";

  static String m32(type) => "Tìm kiếm ${type}";

  static String m33(count) => "đã gửi ${count} files.";

  static String m34(count) => "đã gửi ${count} ảnh.";

  static String m35(count) => "đã gửi ${count} video.";

  static String m36(count) => "Xem thêm ${count} bình luận";

  static String m37(character) => "${character} Nhãn dán";

  static String m38(fullName) =>
      "${fullName} đã bỏ gán cho bạn trong một issue";

  static String m39(hotkey) =>
      "Mẹo: Sử dụng phím tắt ${hotkey}-T để tìm kiếm nhanh";

  static String m40(hotkey) =>
      "Mẹo: Sử dụng phím tắt ${hotkey}-T để tìm kiếm bất kỳ";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Closed": MessageLookupByLibrary.simpleMessage("Đã đóng"),
        "Commented": MessageLookupByLibrary.simpleMessage("đã nhận xét"),
        "CreateANewPassword":
            MessageLookupByLibrary.simpleMessage("Tạo mật khẩu mới"),
        "MediaAutoDownload": MessageLookupByLibrary.simpleMessage(
            "Tự động tải xuống phương tiện"),
        "NewPassword": MessageLookupByLibrary.simpleMessage("Mật khẩu mới"),
        "Notification": MessageLookupByLibrary.simpleMessage("Thông báo"),
        "SearchDiscussionsDirectories": MessageLookupByLibrary.simpleMessage(
            "Tìm kiếm các cuộc thảo luận, thư mục, dữ liệu và hơn thế nữa"),
        "StorageDirectDessage":
            MessageLookupByLibrary.simpleMessage("Cài đặt tự động tải xuống"),
        "aNewDevice": MessageLookupByLibrary.simpleMessage("Thiết bị mới"),
        "about": MessageLookupByLibrary.simpleMessage("Giới thiệu"),
        "accept": MessageLookupByLibrary.simpleMessage("Chấp nhận"),
        "acceptInvite": MessageLookupByLibrary.simpleMessage("Đã chấp nhận"),
        "accepted": MessageLookupByLibrary.simpleMessage("Chấp nhận"),
        "active": MessageLookupByLibrary.simpleMessage("Hoạt động"),
        "add": MessageLookupByLibrary.simpleMessage("Thêm"),
        "addANewAtt":
            MessageLookupByLibrary.simpleMessage("Thêm tệp đính kèm mới"),
        "addAnOption":
            MessageLookupByLibrary.simpleMessage("Thêm một tùy chọn"),
        "addAppToChannel":
            MessageLookupByLibrary.simpleMessage("Thêm ứng dụng vào kênh"),
        "addApps": MessageLookupByLibrary.simpleMessage("Thêm ứng dụng"),
        "addCommands": MessageLookupByLibrary.simpleMessage("Thêm lệnh"),
        "addComment": MessageLookupByLibrary.simpleMessage("Thêm nhận xét"),
        "addDescription": MessageLookupByLibrary.simpleMessage("Thêm mô tả"),
        "addDetail": MessageLookupByLibrary.simpleMessage("Thêm mô tả..."),
        "addFriend": MessageLookupByLibrary.simpleMessage("Thêm bạn"),
        "addFriendUsingEmail": MessageLookupByLibrary.simpleMessage(
            "Hãy thử thêm một người bạn bằng tên người dùng hoặc địa chỉ email của họ"),
        "addList": MessageLookupByLibrary.simpleMessage("Thêm danh danh sách"),
        "addMoreDetailed":
            MessageLookupByLibrary.simpleMessage("Thêm chi tiết"),
        "addName": MessageLookupByLibrary.simpleMessage("Thêm tên"),
        "addNewApp": MessageLookupByLibrary.simpleMessage("Thêm ứng dụng mới"),
        "addNewList":
            MessageLookupByLibrary.simpleMessage("Thêm danh sách mới"),
        "addNewOption": MessageLookupByLibrary.simpleMessage("Thêm tuỳ chọn"),
        "addParamsCommands":
            MessageLookupByLibrary.simpleMessage("Thêm tham số "),
        "addShortcut": MessageLookupByLibrary.simpleMessage("/ Thêm lối tắt"),
        "addText": MessageLookupByLibrary.simpleMessage("Thêm văn bản"),
        "addTitle": MessageLookupByLibrary.simpleMessage("Thêm tiêu đề"),
        "addUrl":
            MessageLookupByLibrary.simpleMessage("https:// Thêm đường dẫn"),
        "addYourFriendPancake": MessageLookupByLibrary.simpleMessage(
            "Thêm bạn bè của bạn trên Pancake"),
        "added": MessageLookupByLibrary.simpleMessage("Đã thêm"),
        "admins": MessageLookupByLibrary.simpleMessage("Quản trị viên"),
        "after": MessageLookupByLibrary.simpleMessage("Sau nữa"),
        "ago": MessageLookupByLibrary.simpleMessage("trước"),
        "alert": MessageLookupByLibrary.simpleMessage("cảnh báo"),
        "all": MessageLookupByLibrary.simpleMessage("Tất cả"),
        "allFriends": MessageLookupByLibrary.simpleMessage("Tất cả bạn bè"),
        "allowToSyncFromThisDevice": MessageLookupByLibrary.simpleMessage(
            "Cho phép đồng bộ hóa từ thiết bị này?"),
        "alreadyHaveAnAccount":
            MessageLookupByLibrary.simpleMessage(" Đã có tài khoản "),
        "alsoSendToChannel":
            MessageLookupByLibrary.simpleMessage("Đồng thời gửi đến kênh"),
        "anIssue": MessageLookupByLibrary.simpleMessage("một issue"),
        "anIssueYouHasBeenAssignIn": MessageLookupByLibrary.simpleMessage(
            "một issue bạn đã được chỉ định trong"),
        "anMessageHasBeenSend": MessageLookupByLibrary.simpleMessage(
            "Một tin nhắn đã được gửi kèm theo mã tới"),
        "and": MessageLookupByLibrary.simpleMessage("và"),
        "appAvailable":
            MessageLookupByLibrary.simpleMessage("Các ứng dụng có sẵn"),
        "appDefault": MessageLookupByLibrary.simpleMessage("Ứng dụng mặc định"),
        "appLists": MessageLookupByLibrary.simpleMessage("Danh sách ứng dụng"),
        "appName": MessageLookupByLibrary.simpleMessage("Tên ứng dụng"),
        "appear": MessageLookupByLibrary.simpleMessage("Hiện"),
        "apps": MessageLookupByLibrary.simpleMessage("Ứng dụng"),
        "archive": MessageLookupByLibrary.simpleMessage("Lưu trữ"),
        "archiveCard": MessageLookupByLibrary.simpleMessage("Lưu trữ thẻ"),
        "archiveChannel": MessageLookupByLibrary.simpleMessage("Lưu trữ kênh"),
        "archived": MessageLookupByLibrary.simpleMessage("đã lưu trữ"),
        "archivedItems":
            MessageLookupByLibrary.simpleMessage("Các mục đã lưu trữ"),
        "areYouWantTo": MessageLookupByLibrary.simpleMessage("Bạn có muốn"),
        "askDeleteMember": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn xóa thành viên này không?"),
        "askLeaveWorkspace": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn rời khỏi không gian làm việc này không?"),
        "assign": MessageLookupByLibrary.simpleMessage("chỉ định"),
        "assignIssue": m0,
        "assignedNobody":
            MessageLookupByLibrary.simpleMessage("Không giao cho ai"),
        "assignees": MessageLookupByLibrary.simpleMessage("Người làm"),
        "at": m1,
        "ats": MessageLookupByLibrary.simpleMessage("lúc"),
        "attachImageToComment":
            MessageLookupByLibrary.simpleMessage("Đính kèm hình ảnh"),
        "attachments": MessageLookupByLibrary.simpleMessage("Tập đính kèm"),
        "attendance": MessageLookupByLibrary.simpleMessage("Chấm Công"),
        "author": MessageLookupByLibrary.simpleMessage("Người tạo"),
        "auto": MessageLookupByLibrary.simpleMessage("Tự động"),
        "autoRefeshIn":
            MessageLookupByLibrary.simpleMessage("Tự động làm mới trong"),
        "back": MessageLookupByLibrary.simpleMessage("Trở về"),
        "backup": MessageLookupByLibrary.simpleMessage("Sao lưu"),
        "backupDM": MessageLookupByLibrary.simpleMessage("DM dự phòng"),
        "basicInfo": MessageLookupByLibrary.simpleMessage("Thông tin cơ bản"),
        "before": MessageLookupByLibrary.simpleMessage("Trước đây"),
        "block": MessageLookupByLibrary.simpleMessage("Chặn"),
        "blocked": MessageLookupByLibrary.simpleMessage("Đã chặn"),
        "boards": MessageLookupByLibrary.simpleMessage("BẢNG"),
        "by": MessageLookupByLibrary.simpleMessage("bởi"),
        "call": MessageLookupByLibrary.simpleMessage("Gọi thoại"),
        "cancel": MessageLookupByLibrary.simpleMessage("Huỷ"),
        "cantActionsForYou": m2,
        "changeAvatar":
            MessageLookupByLibrary.simpleMessage("Đổi ảnh đại diện"),
        "changeAvatarDm": m3,
        "changeFile": MessageLookupByLibrary.simpleMessage("Thay đổi tệp"),
        "changeNickname":
            MessageLookupByLibrary.simpleMessage("Thay đổi biệt danh"),
        "changePassword": MessageLookupByLibrary.simpleMessage("Đổi mật khẩu"),
        "changeWorkflow":
            MessageLookupByLibrary.simpleMessage("Đổi quy trình làm việc"),
        "channel": MessageLookupByLibrary.simpleMessage("kênh"),
        "channelInstalled":
            MessageLookupByLibrary.simpleMessage("Kênh đã được cài đặt"),
        "channelName": MessageLookupByLibrary.simpleMessage("TÊN KÊNH"),
        "channelNameExisted":
            MessageLookupByLibrary.simpleMessage("Tên kênh đã tồn tại"),
        "channelSettings": MessageLookupByLibrary.simpleMessage("Cài đặt kênh"),
        "channelTopic": MessageLookupByLibrary.simpleMessage("chủ đề kênh"),
        "channelType": MessageLookupByLibrary.simpleMessage("Kiểu kênh"),
        "channels": MessageLookupByLibrary.simpleMessage("Các kênh"),
        "channelsList": MessageLookupByLibrary.simpleMessage("Danh sách kênh"),
        "checkList": MessageLookupByLibrary.simpleMessage("Danh mục"),
        "chooseALabel": MessageLookupByLibrary.simpleMessage("Chọn một nhãn"),
        "chooseAMember":
            MessageLookupByLibrary.simpleMessage("Chọn một thành viên"),
        "closeIssue": MessageLookupByLibrary.simpleMessage("Đóng issue"),
        "closeIssues": m4,
        "closeIssues1": m5,
        "closeWithComment":
            MessageLookupByLibrary.simpleMessage("Đóng sau khi bình luận"),
        "closed": m6,
        "closedThis": MessageLookupByLibrary.simpleMessage("đã đóng"),
        "codeInvite": MessageLookupByLibrary.simpleMessage("Mã lời mời"),
        "collapse": MessageLookupByLibrary.simpleMessage("gập lại"),
        "color": MessageLookupByLibrary.simpleMessage("Màu"),
        "colorPicker": MessageLookupByLibrary.simpleMessage("Bộ chọn màu"),
        "commands": MessageLookupByLibrary.simpleMessage("Các lệnh"),
        "comment": MessageLookupByLibrary.simpleMessage("Bình luận"),
        "commented": m7,
        "communityGuide":
            MessageLookupByLibrary.simpleMessage("Hướng dẫn cộng đồng"),
        "complete": MessageLookupByLibrary.simpleMessage("hoàn thành"),
        "confirm": MessageLookupByLibrary.simpleMessage("Xác nhận"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Xác nhận mật khẩu"),
        "connectGoogleDrive":
            MessageLookupByLibrary.simpleMessage("Kết nối Google Drive"),
        "connectPOSApp": MessageLookupByLibrary.simpleMessage(
            "Kế nối ứng dụng POS đến kênh này."),
        "connected": MessageLookupByLibrary.simpleMessage("Đã kết nối"),
        "connecting": MessageLookupByLibrary.simpleMessage("đang kết nối"),
        "contactInfo":
            MessageLookupByLibrary.simpleMessage("Thông tin liên hệ"),
        "contactSupport":
            MessageLookupByLibrary.simpleMessage("Liên hệ hỗ trợ"),
        "contacts": MessageLookupByLibrary.simpleMessage("Danh bạ"),
        "conversationName":
            MessageLookupByLibrary.simpleMessage("Tên hội thoại"),
        "copyText": MessageLookupByLibrary.simpleMessage("Sao chép văn bản"),
        "copyToClipboard": MessageLookupByLibrary.simpleMessage("Sao chép"),
        "countComments": m8,
        "countDayAgo": m9,
        "countHourAgo": m10,
        "countLabels": m11,
        "countMinuteAgo": m12,
        "countMonthAgo": m13,
        "countYearAgo": m14,
        "create": MessageLookupByLibrary.simpleMessage("Tạo"),
        "createANewIssue":
            MessageLookupByLibrary.simpleMessage("Tạo issue mới"),
        "createAWorkspace":
            MessageLookupByLibrary.simpleMessage("Tạo một phòng"),
        "createAccount": MessageLookupByLibrary.simpleMessage("Tạo tài khoản"),
        "createAnAccount":
            MessageLookupByLibrary.simpleMessage("Tạo tài khoản"),
        "createApp": MessageLookupByLibrary.simpleMessage("Tạo ứng dụng"),
        "createBoard": MessageLookupByLibrary.simpleMessage("Tạo bảng"),
        "createBy": MessageLookupByLibrary.simpleMessage("Tạo bởi"),
        "createChannel": MessageLookupByLibrary.simpleMessage("Tạo kênh"),
        "createCommand": MessageLookupByLibrary.simpleMessage("Tạo lệnh"),
        "createCommands": MessageLookupByLibrary.simpleMessage("Tạo lệnh"),
        "createCustomApp":
            MessageLookupByLibrary.simpleMessage("Taọ ứng dụng tuỳ chỉnh"),
        "createGroup": MessageLookupByLibrary.simpleMessage("Tạo nhóm"),
        "createIssue": MessageLookupByLibrary.simpleMessage("Tạo issue"),
        "createLabels": MessageLookupByLibrary.simpleMessage("Tạo nhãn"),
        "createMilestone": MessageLookupByLibrary.simpleMessage("Tạo mốc"),
        "createNewBoard": MessageLookupByLibrary.simpleMessage("Tạo bảng mới"),
        "createNewLabel": MessageLookupByLibrary.simpleMessage("Tạo nhãn mới"),
        "createNewList":
            MessageLookupByLibrary.simpleMessage("Tạo danh sách mới"),
        "createNewMilestone":
            MessageLookupByLibrary.simpleMessage("Tạo cột mốc mới"),
        "createPoll": MessageLookupByLibrary.simpleMessage("Tạo cuộc thăm dò"),
        "createWorkspace": MessageLookupByLibrary.simpleMessage("Tạo  phòng"),
        "created": MessageLookupByLibrary.simpleMessage("Đã tạo"),
        "createdByMessage":
            MessageLookupByLibrary.simpleMessage("Được tạo bởi tin nhắn"),
        "createdIn": MessageLookupByLibrary.simpleMessage("được tạo trong"),
        "currentPassword":
            MessageLookupByLibrary.simpleMessage("Mật khẩu hiện tại"),
        "customApp": MessageLookupByLibrary.simpleMessage("Tạo app tuỳ biến"),
        "dark": MessageLookupByLibrary.simpleMessage("Tối"),
        "darkMode": MessageLookupByLibrary.simpleMessage("Chế độ tối"),
        "dataIsBeingTransmitted":
            MessageLookupByLibrary.simpleMessage("Dữ liệu đang được truyền"),
        "dataProcessing": MessageLookupByLibrary.simpleMessage("Xử lý dữ liệu"),
        "date": MessageLookupByLibrary.simpleMessage("Ngày"),
        "dateOfBirth": MessageLookupByLibrary.simpleMessage("Ngày sinh"),
        "day": MessageLookupByLibrary.simpleMessage("ngày"),
        "days": MessageLookupByLibrary.simpleMessage("ngày"),
        "delete": MessageLookupByLibrary.simpleMessage("Xoá"),
        "deleteAccount": MessageLookupByLibrary.simpleMessage("Xóa tài khoản"),
        "deleteChannel": MessageLookupByLibrary.simpleMessage("Xoá kênh"),
        "deleteChat": MessageLookupByLibrary.simpleMessage("Xoá nhóm"),
        "deleteComment":
            MessageLookupByLibrary.simpleMessage("Xoá bình luận này?"),
        "deleteDirectMessage":
            MessageLookupByLibrary.simpleMessage("Xóa tin nhắn"),
        "deleteForEveryone":
            MessageLookupByLibrary.simpleMessage("Xóa tất cả mọi người"),
        "deleteForMe": MessageLookupByLibrary.simpleMessage("Xoá mình tôi"),
        "deleteLabel": MessageLookupByLibrary.simpleMessage("Xoá nhãn"),
        "deleteMembers":
            MessageLookupByLibrary.simpleMessage("Xoá thành viên?"),
        "deleteMessages": MessageLookupByLibrary.simpleMessage("Xóa tin nhắn"),
        "deleteMilestone": MessageLookupByLibrary.simpleMessage("Xoá mốc"),
        "deleteThisMessages": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn xóa tin nhắn này?"),
        "deleteWorkspace": MessageLookupByLibrary.simpleMessage("Xoá phòng"),
        "desAddFriend": MessageLookupByLibrary.simpleMessage(
            "Nhập tên bạn bè của bạn với thẻ của họ. Ví dụ: JohnDoe#1234."),
        "desApp": MessageLookupByLibrary.simpleMessage(
            "Sau khi tạo và cài đặt ứng dụng, bạn có thể cấu hình trong các kênh cụ thể."),
        "desBankApp": MessageLookupByLibrary.simpleMessage(
            "Thông báo biến động tài khoản ngân hàng."),
        "desDeleteChannel": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn xóa thành viên này khỏi kênh không? \n NKhông thể hoàn tác hành động này."),
        "desMentionMode": MessageLookupByLibrary.simpleMessage(
            "Làm mờ kênh, chỉ đánh dấu chưa đọc và thông báo khi @mentions hoặc @all."),
        "desNormalMode": MessageLookupByLibrary.simpleMessage(
            "Tất cả các tin nhắn đề có thông báo và đánh dấu chưa đọc"),
        "desOffMode": MessageLookupByLibrary.simpleMessage("Không có gì."),
        "desPOSApp": MessageLookupByLibrary.simpleMessage(
            "Đồng bộ tin nhắn từ những trạng thái cấu hình POS."),
        "desSearch": MessageLookupByLibrary.simpleMessage(
            "Tìm kiếm danh bạ và tin nhắn riêng của bạn."),
        "desSearchAnything": MessageLookupByLibrary.simpleMessage(
            "Tìm kiếm tất cả danh bạ và tin nhắn của bạn."),
        "desSilentMode":
            MessageLookupByLibrary.simpleMessage("Chỉ tắt thông báo"),
        "descArchiveChannel": m15,
        "descCreateWorkspace": MessageLookupByLibrary.simpleMessage(
            "Không gian làm việc của bạn là nơi bạn và bạn bè của bạn làm việc. Tạo và bắt đầu trò chuyện."),
        "descDeleteChannel": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn xóa kênh này không? Hành động này không thể được hoàn tác."),
        "descDeleteLabel": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn xóa nhãn này không? \n Không thể hoàn tác hành động này."),
        "descDeleteMilestone": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn xóa mốc này không? \n Không thể hoàn tác hành động này."),
        "descDeleteNewsroom": MessageLookupByLibrary.simpleMessage(
            "Đây là kênh tin tức của phòng, nếu bạn xóa người dùng này khỏi kênh thì người dùng đó sẽ bị xóa khỏi không gian làm việc"),
        "descDeleteWorkspace": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn xóa không gian làm việc không? Hành động này không thể được hoàn tác."),
        "descFileterAuthor":
            MessageLookupByLibrary.simpleMessage("Nhập hoặc chọn tên"),
        "descInvite": MessageLookupByLibrary.simpleMessage(
            "Mời bạn bè hoặc thêm những người mới."),
        "descJoinWs": MessageLookupByLibrary.simpleMessage(
            "Nhập lời mời bên dưới để tham gia không gian làm việc hiện có"),
        "descLeaveChannel": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn rời khỏi kênh không? Không thể hoàn tác hành động này."),
        "descLeaveGroup": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn rời khỏi cuộc trò chuyện này không?"),
        "descLeaveWorkspace": MessageLookupByLibrary.simpleMessage(
            "Bạn có chắc chắn muốn rời khỏi phòng?\n Hành động này không thể được hoàn tác."),
        "descNothingTurnedUp": MessageLookupByLibrary.simpleMessage(
            "Bạn có thể muốn thử sử dụng các từ khóa khác nhau hoặc kiểm tra lỗi chính tả"),
        "descResetDeviceKey": MessageLookupByLibrary.simpleMessage(
            "**Nhấn vào đặt lại khóa thiết bị để xóa dữ liệu khỏi các thiết bị khác. Panchat sẽ gửi mã xác minh đến email/số điện thoại của bạn"),
        "descSearchAll": MessageLookupByLibrary.simpleMessage(
            "Tìm kiếm tất cả tin nhắn riêng và workspace"),
        "descSearchContact":
            MessageLookupByLibrary.simpleMessage("Tìm kiếm tất cả liên hệ"),
        "descSearchDms": MessageLookupByLibrary.simpleMessage(
            "Tìm kiếm tin nhắn trong tin nhắn riêng"),
        "descSearchInCtWs": m16,
        "descSearchInWs": m17,
        "descSyncPanchat": MessageLookupByLibrary.simpleMessage(
            "*Mở ứng dụng Panchat trên thiết bị của bạn và nhấn vào đồng bộ hóa dữ liệu để nhận mã OTP"),
        "descWatchActivity": MessageLookupByLibrary.simpleMessage(
            "Thông báo từ tất cả hoạt động."),
        "descWatchMention": MessageLookupByLibrary.simpleMessage(
            "Chỉ nhận thông báo từ issue bạn tạo hoặc được assign."),
        "description": MessageLookupByLibrary.simpleMessage("Mô tả"),
        "details": MessageLookupByLibrary.simpleMessage("Chi tiết"),
        "devMode": MessageLookupByLibrary.simpleMessage("chế độ dev"),
        "deviceId": MessageLookupByLibrary.simpleMessage("Id thiết bị"),
        "devices": MessageLookupByLibrary.simpleMessage("Thiết bị"),
        "directMessageDetails":
            MessageLookupByLibrary.simpleMessage("Chi tiết tin nhắn"),
        "directMessages":
            MessageLookupByLibrary.simpleMessage("Tin nhắn riêng"),
        "directSettings":
            MessageLookupByLibrary.simpleMessage("Cài đặt tin nhắn riêng"),
        "discard": MessageLookupByLibrary.simpleMessage("Loại bỏ"),
        "discarded": MessageLookupByLibrary.simpleMessage("Bị loại bỏ"),
        "displayName": MessageLookupByLibrary.simpleMessage("Tên hiển thị"),
        "doNotSync": MessageLookupByLibrary.simpleMessage("Không đồng bộ"),
        "doYouWantToArchiveThisList": MessageLookupByLibrary.simpleMessage(
            "Bạn có muốn lưu trữ danh sách này không."),
        "doYouWantToDeleteYourAccount": MessageLookupByLibrary.simpleMessage(
            "Bạn có muốn xóa tài khoản của mình không?"),
        "doYouWantToDownload":
            MessageLookupByLibrary.simpleMessage("Bạn có muốn tải xuống"),
        "done": MessageLookupByLibrary.simpleMessage("Xong"),
        "download": MessageLookupByLibrary.simpleMessage("Tải xuống"),
        "downloadAttachment":
            MessageLookupByLibrary.simpleMessage("Tải xuống tệp đính kèm"),
        "downloadFile": MessageLookupByLibrary.simpleMessage("Tải tập tin"),
        "dueBy": MessageLookupByLibrary.simpleMessage("Hạn đến "),
        "dueDate": MessageLookupByLibrary.simpleMessage("Quá hạn (Opt)"),
        "dueDates": MessageLookupByLibrary.simpleMessage("Ngày đến hạn"),
        "edit": MessageLookupByLibrary.simpleMessage("Sửa"),
        "editBasicInfo":
            MessageLookupByLibrary.simpleMessage("Chỉnh sửa thông tin cơ bản"),
        "editChannelDesc":
            MessageLookupByLibrary.simpleMessage("Sửa mô tả kênh"),
        "editChannelTopic":
            MessageLookupByLibrary.simpleMessage("Sửa chủ đề kênh"),
        "editComment":
            MessageLookupByLibrary.simpleMessage("Chỉnh sửa bình luận"),
        "editImage": MessageLookupByLibrary.simpleMessage("Sửa ảnh"),
        "editMessage":
            MessageLookupByLibrary.simpleMessage("Chỉnh sửa tin nhắn"),
        "editName": MessageLookupByLibrary.simpleMessage("Chỉnh sửa tên"),
        "editWorkspaceName": MessageLookupByLibrary.simpleMessage(
            "Chỉnh sửa tên phòng làm việc"),
        "edited": MessageLookupByLibrary.simpleMessage("đã chỉnh sửa"),
        "editedBy": MessageLookupByLibrary.simpleMessage("•  đã chỉnh sửa bởi"),
        "editedTime": m18,
        "editors": MessageLookupByLibrary.simpleMessage("Biên tập viên"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "emailAddress": MessageLookupByLibrary.simpleMessage("Địa chỉ email"),
        "enjoyToSearch": MessageLookupByLibrary.simpleMessage("Tìm kiếm"),
        "enterANewPassword":
            MessageLookupByLibrary.simpleMessage("Nhập lại mật khẩu mới"),
        "enterCardTitle":
            MessageLookupByLibrary.simpleMessage("Nhập tiêu đề thẻ"),
        "enterListTitle":
            MessageLookupByLibrary.simpleMessage("Nhập danh sách tiêu đề"),
        "enterPassToTransfer": MessageLookupByLibrary.simpleMessage(
            "Nhập mật khẩu để chuyển giao"),
        "enterUsername":
            MessageLookupByLibrary.simpleMessage("nhập tên người sử dụng#0000"),
        "enterYourCode":
            MessageLookupByLibrary.simpleMessage(" NHẬP MÃ CỦA BẠN "),
        "enterYourCodeOnOtherDevices": MessageLookupByLibrary.simpleMessage(
            "Bạn sẽ nhận được mã gồm 4 chữ số để xác minh"),
        "enterYourInformationsBelow": MessageLookupByLibrary.simpleMessage(
            "Nhập thông tin của bạn bên dưới"),
        "errorWithStatus": m19,
        "exact": MessageLookupByLibrary.simpleMessage("Chính xác"),
        "exactMatch": MessageLookupByLibrary.simpleMessage("Kết hợp chuẩn xác"),
        "example": MessageLookupByLibrary.simpleMessage("Ví dụ"),
        "expand": MessageLookupByLibrary.simpleMessage("Mở rộng"),
        "female": MessageLookupByLibrary.simpleMessage("Nữ"),
        "fileDownloading":
            MessageLookupByLibrary.simpleMessage("File đang tải xuống"),
        "fileManager": MessageLookupByLibrary.simpleMessage("Quản lý tập tin"),
        "files": MessageLookupByLibrary.simpleMessage("Tập tin"),
        "filterLabels": MessageLookupByLibrary.simpleMessage("Lọc nhãn"),
        "filterMilestone":
            MessageLookupByLibrary.simpleMessage("Lọc mốc hoàn thành"),
        "filterNoMilestone": MessageLookupByLibrary.simpleMessage(
            "issue không có mốc hoàn thành"),
        "findAll": MessageLookupByLibrary.simpleMessage(
            "Tìm kiếm workspace, tin nhắn, liên hệ..."),
        "findEverything":
            MessageLookupByLibrary.simpleMessage("Tìm mọi thứ cho bạn."),
        "firstName": MessageLookupByLibrary.simpleMessage("Tên"),
        "forgotPassword": MessageLookupByLibrary.simpleMessage("Quên mật khẩu"),
        "forwardMessage": MessageLookupByLibrary.simpleMessage("Chuyển tiếp"),
        "forwardThisMessage":
            MessageLookupByLibrary.simpleMessage("Chuyển tiếp tin nhắn"),
        "friends": MessageLookupByLibrary.simpleMessage("Bạn bè"),
        "from": MessageLookupByLibrary.simpleMessage("Từ"),
        "fullName": MessageLookupByLibrary.simpleMessage("Tên"),
        "gender": MessageLookupByLibrary.simpleMessage("Giới tính"),
        "gettingData": MessageLookupByLibrary.simpleMessage("Lấy dữ liệu"),
        "groupName": MessageLookupByLibrary.simpleMessage("Tên nhóm"),
        "hasChanged": MessageLookupByLibrary.simpleMessage("đã thay đổi"),
        "hasChangedChannel":
            MessageLookupByLibrary.simpleMessage("đã thay đổi kênh"),
        "hasChangedChannelNameTo":
            MessageLookupByLibrary.simpleMessage("đã đổi tên kênh thành"),
        "hasChangedChannelTopicTo":
            MessageLookupByLibrary.simpleMessage("đã thay đổi"),
        "hasChangedChannelWorkflowTo": MessageLookupByLibrary.simpleMessage(
            "đã thay đổi quy trình làm việc của kênh thành"),
        "hasChangedDMNameTo":
            MessageLookupByLibrary.simpleMessage("đã đổi tên nhóm thành"),
        "hasInviteYouTo": MessageLookupByLibrary.simpleMessage(" đã mời bạn "),
        "hasInvited": MessageLookupByLibrary.simpleMessage("đã mời"),
        "hasJoinedTheChannelByCode": MessageLookupByLibrary.simpleMessage(
            "đã tham gia kênh bằng mã mời"),
        "hasLeft": MessageLookupByLibrary.simpleMessage("đã rời khỏi"),
        "hasLeftTheChannel":
            MessageLookupByLibrary.simpleMessage("đã rời khỏi kênh"),
        "hass": MessageLookupByLibrary.simpleMessage("đã"),
        "haveAnInviteAlready":
            MessageLookupByLibrary.simpleMessage("Đã có một lời mời rồi?"),
        "hide": MessageLookupByLibrary.simpleMessage("Ẩn"),
        "hideDirectMessage":
            MessageLookupByLibrary.simpleMessage("Ẩn tin nhắn"),
        "hight": MessageLookupByLibrary.simpleMessage("Cao"),
        "home": MessageLookupByLibrary.simpleMessage("Trang chủ"),
        "hour": MessageLookupByLibrary.simpleMessage("giờ"),
        "hours": MessageLookupByLibrary.simpleMessage("giờ"),
        "iAgreeToTheTerms": MessageLookupByLibrary.simpleMessage(
            "Tôi đồng ý với Điều khoản dịch vụ và chính sách Bảo mật"),
        "ifYouDontMakeThatRequest": MessageLookupByLibrary.simpleMessage(
            "Nếu bạn không đưa ra yêu cầu đó, vui lòng chọn"),
        "images": MessageLookupByLibrary.simpleMessage("Ảnh"),
        "inAnIssueYouHadFollowed": MessageLookupByLibrary.simpleMessage(
            "trong một issue bạn đã theo dõi."),
        "inThread": MessageLookupByLibrary.simpleMessage("Từ thread"),
        "incomingFriendRequest":
            MessageLookupByLibrary.simpleMessage("Yêu cầu kết bạn gửi đến"),
        "index": MessageLookupByLibrary.simpleMessage("STT:"),
        "inputCannotEmpty":
            MessageLookupByLibrary.simpleMessage("Đầu vào không được để trống"),
        "insertKeyCodeChannel":
            MessageLookupByLibrary.simpleMessage("Vui lòng chèn mã khóa kênh"),
        "install": MessageLookupByLibrary.simpleMessage("Cài đặt"),
        "invied": m20,
        "inviedChannel": m21,
        "inviedChannels":
            MessageLookupByLibrary.simpleMessage("Đã mời bạn vào kênh"),
        "inviedWorkSpace": m22,
        "invitationHistory":
            MessageLookupByLibrary.simpleMessage("Lịch sử lời mời:"),
        "invite": MessageLookupByLibrary.simpleMessage("Mời"),
        "inviteCodeWs":
            MessageLookupByLibrary.simpleMessage("Hoặc lời mời bằng mã: "),
        "inviteLookLike":
            MessageLookupByLibrary.simpleMessage("Ví dụ về liên kết mời"),
        "inviteMember": MessageLookupByLibrary.simpleMessage("Mời thành viên"),
        "inviteOnly": MessageLookupByLibrary.simpleMessage("Chỉ mời"),
        "invitePeople": MessageLookupByLibrary.simpleMessage("Mời mọi người"),
        "inviteTo": m23,
        "inviteToChannel":
            MessageLookupByLibrary.simpleMessage("Mời người mới đến kênh này"),
        "inviteToGroup": MessageLookupByLibrary.simpleMessage("Mời vào nhóm"),
        "inviteToWorkspace":
            MessageLookupByLibrary.simpleMessage("Mời đến phòng làm việc"),
        "inviteWsCode":
            MessageLookupByLibrary.simpleMessage("LIÊN KẾT HOẶC MÃ MỜI"),
        "inviteYourFriend":
            MessageLookupByLibrary.simpleMessage("Mời bạn của bạn"),
        "invited": MessageLookupByLibrary.simpleMessage("Đã mời"),
        "issue": MessageLookupByLibrary.simpleMessage("Issue"),
        "issueCreateSuccess":
            MessageLookupByLibrary.simpleMessage("Issue được tạo thành công"),
        "issueDetails": MessageLookupByLibrary.simpleMessage("Chi tiết issue"),
        "issues": MessageLookupByLibrary.simpleMessage("Issues"),
        "issuesWithNoMilestone":
            MessageLookupByLibrary.simpleMessage("issue không có cột mốc"),
        "join": MessageLookupByLibrary.simpleMessage("Tham gia"),
        "joinChannel": MessageLookupByLibrary.simpleMessage("Tham gia kênh"),
        "joinChannelFail": MessageLookupByLibrary.simpleMessage(
            "Tham gia kênh thất bại. Vui lòng thử lại.."),
        "joinChannelSuccess":
            MessageLookupByLibrary.simpleMessage("Tham gia kênh thành công."),
        "joinWorkspace": MessageLookupByLibrary.simpleMessage("Tham gia phòng"),
        "joinWorkspaceFail": MessageLookupByLibrary.simpleMessage(
            "Tham gia phòng thất bại. Vui lòng thử lại.."),
        "joinWorkspaceSuccess":
            MessageLookupByLibrary.simpleMessage("Tham gia phòng thành công"),
        "justLoggeInAndRequested": MessageLookupByLibrary.simpleMessage(
            " vừa đăng nhập và yêu cầu đồng bộ hóa dữ liệu từ thiết bị này."),
        "justMention": MessageLookupByLibrary.simpleMessage("Chỉ @mention"),
        "kanbanMode": MessageLookupByLibrary.simpleMessage("chế độ kanban"),
        "labelSelected": MessageLookupByLibrary.simpleMessage("nhãn đã chọn"),
        "labels": MessageLookupByLibrary.simpleMessage("Nhãn"),
        "language": MessageLookupByLibrary.simpleMessage("Ngôn ngữ và khu vực"),
        "languages": MessageLookupByLibrary.simpleMessage("Ngôn ngữ"),
        "lastName": MessageLookupByLibrary.simpleMessage("Họ"),
        "lastReplyAt":
            MessageLookupByLibrary.simpleMessage("Trả lời cuối cùng lúc"),
        "leastRecentlyUpdated":
            MessageLookupByLibrary.simpleMessage("Cập nhật ít nhất gần đây"),
        "leaveAComment":
            MessageLookupByLibrary.simpleMessage("Để lại nhận xét"),
        "leaveChannel": MessageLookupByLibrary.simpleMessage("Rời kênh"),
        "leaveConversation":
            MessageLookupByLibrary.simpleMessage("Rời cuộc hội thoại"),
        "leaveDirect": MessageLookupByLibrary.simpleMessage(
            "Đã rời khỏi cuộc trò chuyện này"),
        "leaveGroup": MessageLookupByLibrary.simpleMessage("Rời nhóm"),
        "leaveWorkspace":
            MessageLookupByLibrary.simpleMessage("Rời khỏi phòng"),
        "light": MessageLookupByLibrary.simpleMessage("Sáng"),
        "lightMode": MessageLookupByLibrary.simpleMessage("Chế độ sáng"),
        "listArchive":
            MessageLookupByLibrary.simpleMessage("Danh sách lưu trữ"),
        "listChannel": MessageLookupByLibrary.simpleMessage("Danh sách kênh"),
        "listWorkspaceMember":
            MessageLookupByLibrary.simpleMessage("Danh sách người trong phòng"),
        "loggedIntoGoogleDrive": MessageLookupByLibrary.simpleMessage(
            "Đã đăng nhập vào Google Drive"),
        "loginWithQRCode":
            MessageLookupByLibrary.simpleMessage("Đăng nhập bằng mã QR"),
        "logout": MessageLookupByLibrary.simpleMessage("Đăng xuất"),
        "logoutThisDevice":
            MessageLookupByLibrary.simpleMessage("Đăng xuất thiết bị này"),
        "lookingFor":
            MessageLookupByLibrary.simpleMessage("Hoặc tôi đang tìm kiếm ..."),
        "low": MessageLookupByLibrary.simpleMessage("Thấp"),
        "male": MessageLookupByLibrary.simpleMessage("Nam"),
        "markAsUnread":
            MessageLookupByLibrary.simpleMessage("Đánh dấu chưa đọc"),
        "matchAnyLabelAnd": MessageLookupByLibrary.simpleMessage(
            "Phù hợp với bất kỳ nhãn và bất kỳ thành viên nào."),
        "medium": MessageLookupByLibrary.simpleMessage("Vừa phải"),
        "members": MessageLookupByLibrary.simpleMessage("Thành viên"),
        "mentionMode": MessageLookupByLibrary.simpleMessage("CHẾ ĐỘ MENTION"),
        "mentions": MessageLookupByLibrary.simpleMessage("Nhắc tới"),
        "messageName": MessageLookupByLibrary.simpleMessage("TÊN TIN NHẮN"),
        "messages": MessageLookupByLibrary.simpleMessage("Tin nhắn"),
        "messagesAndCallsInThisChatWill": MessageLookupByLibrary.simpleMessage(
            "Tin nhắn và cuộc gọi trong cuộc trò chuyện này sẽ được mã hóa từ đầu đến cuối. Chỉ những người tham gia mới có thể đọc hoặc nghe chúng."),
        "milestones": MessageLookupByLibrary.simpleMessage("Thời hạn"),
        "minute": MessageLookupByLibrary.simpleMessage("phút"),
        "minutes": MessageLookupByLibrary.simpleMessage("phút"),
        "minutesAgo": MessageLookupByLibrary.simpleMessage("phút trước"),
        "mobile": MessageLookupByLibrary.simpleMessage("điện thoại di động"),
        "mobileData": MessageLookupByLibrary.simpleMessage("dữ liệu di động"),
        "momentAgo": MessageLookupByLibrary.simpleMessage("vài giây trước"),
        "month": MessageLookupByLibrary.simpleMessage("tháng"),
        "months": MessageLookupByLibrary.simpleMessage("tháng"),
        "moreUnread": MessageLookupByLibrary.simpleMessage("More unreads"),
        "name": MessageLookupByLibrary.simpleMessage("Tên"),
        "nameBoard": MessageLookupByLibrary.simpleMessage("Tên bảng"),
        "nameFile": MessageLookupByLibrary.simpleMessage("Tên tệp: "),
        "nameList": MessageLookupByLibrary.simpleMessage("Tên danh sách"),
        "nearbyScan": MessageLookupByLibrary.simpleMessage("Quét gần đây"),
        "newBoards": MessageLookupByLibrary.simpleMessage("Bảng mới"),
        "newCard": MessageLookupByLibrary.simpleMessage("Thẻ mới"),
        "newChecklist": MessageLookupByLibrary.simpleMessage("Danh sách mới"),
        "newIssue": MessageLookupByLibrary.simpleMessage("Issue mới"),
        "newLabel": MessageLookupByLibrary.simpleMessage("Nhãn mới"),
        "newList": MessageLookupByLibrary.simpleMessage("Danh sách mới"),
        "newMessage": MessageLookupByLibrary.simpleMessage("Tin nhắn mới"),
        "newMilestone": MessageLookupByLibrary.simpleMessage("Mốc mới"),
        "newPasswordDoesMatch": MessageLookupByLibrary.simpleMessage(
            "Mật khẩu mới chưa trùng khớp"),
        "newest": MessageLookupByLibrary.simpleMessage("Mới nhất"),
        "news": MessageLookupByLibrary.simpleMessage("MỚI"),
        "newworkspace": MessageLookupByLibrary.simpleMessage("Thêm phòng"),
        "next": MessageLookupByLibrary.simpleMessage("Sau"),
        "noAttachment":
            MessageLookupByLibrary.simpleMessage("Không có tập tin đính kèm"),
        "noCheckList":
            MessageLookupByLibrary.simpleMessage("Không có danh sách"),
        "noDescriptionProvided": MessageLookupByLibrary.simpleMessage(
            "_Không có mô tả được cung cấp._"),
        "noDueDate":
            MessageLookupByLibrary.simpleMessage("Không có ngày đến hạn"),
        "noFriendToAdd":
            MessageLookupByLibrary.simpleMessage("Không có bạn bè để thêm"),
        "noItems":
            MessageLookupByLibrary.simpleMessage("Chưa có mục nào được ghim!"),
        "noLabel": MessageLookupByLibrary.simpleMessage("Không nhãn"),
        "noMembers":
            MessageLookupByLibrary.simpleMessage("Không có thành viên"),
        "noMilestone": MessageLookupByLibrary.simpleMessage("Không có cột mốc"),
        "noOneAssignYourself": MessageLookupByLibrary.simpleMessage("Không ai"),
        "noSelected": MessageLookupByLibrary.simpleMessage("Không được chọn"),
        "none": MessageLookupByLibrary.simpleMessage("Không có"),
        "noneYet": MessageLookupByLibrary.simpleMessage("Chưa có"),
        "normal": MessageLookupByLibrary.simpleMessage("Thường"),
        "normalMode":
            MessageLookupByLibrary.simpleMessage("CHẾ ĐỘ BÌNH THƯỜNG"),
        "notRegisteredYet":
            MessageLookupByLibrary.simpleMessage("Chưa đăng ký"),
        "notSet": MessageLookupByLibrary.simpleMessage("Chưa đặt"),
        "noteCreateWs": MessageLookupByLibrary.simpleMessage(
            "Bằng cách tạo không gian làm việc, bạn đồng ý với"),
        "noteNewPassword": MessageLookupByLibrary.simpleMessage(
            "Lưu ý: Mật khẩu mới tối thiểu 6 ký tự trở lên & tối đa 32 ký tự."),
        "nothing": MessageLookupByLibrary.simpleMessage("Không có gì"),
        "nothingTurnedUp":
            MessageLookupByLibrary.simpleMessage("Không có gì xuất hiện"),
        "notificationSound":
            MessageLookupByLibrary.simpleMessage("Thông báo & Âm thanh"),
        "notifySetting":
            MessageLookupByLibrary.simpleMessage("Cài đặt thông báo"),
        "now": MessageLookupByLibrary.simpleMessage("bây giờ"),
        "off": MessageLookupByLibrary.simpleMessage("Tắt"),
        "offMode": MessageLookupByLibrary.simpleMessage("CHẾ ĐỘ TẮT"),
        "offline": MessageLookupByLibrary.simpleMessage("Ngoại tuyến"),
        "oldest": MessageLookupByLibrary.simpleMessage("Cũ nhất"),
        "on": MessageLookupByLibrary.simpleMessage("vào"),
        "online": MessageLookupByLibrary.simpleMessage("Trực tuyến"),
        "open": m24,
        "openMilestones": m25,
        "openThisIssue": m26,
        "opened": MessageLookupByLibrary.simpleMessage("đã mở"),
        "openedThisIssue": MessageLookupByLibrary.simpleMessage("đã mở issue"),
        "option": MessageLookupByLibrary.simpleMessage("Tuỳ chỉnh"),
        "optionName": m27,
        "or": MessageLookupByLibrary.simpleMessage("hoặc"),
        "other": MessageLookupByLibrary.simpleMessage("khác"),
        "outgoingFriendRequest":
            MessageLookupByLibrary.simpleMessage("Yêu cầu kết bạn gửi đi"),
        "overdue": MessageLookupByLibrary.simpleMessage("Quá hạn"),
        "owner": MessageLookupByLibrary.simpleMessage(" Chủ phòng"),
        "params": MessageLookupByLibrary.simpleMessage("Tham số:"),
        "paramsCommand":
            MessageLookupByLibrary.simpleMessage("Tham số của lệnh:"),
        "password": MessageLookupByLibrary.simpleMessage("Mật khẩu"),
        "pastDueBy": MessageLookupByLibrary.simpleMessage("Quá hạn"),
        "pendingRequest":
            MessageLookupByLibrary.simpleMessage("YÊU CẦU ĐANG CHỜ XỬ LÝ"),
        "phoneNumber": MessageLookupByLibrary.simpleMessage("SĐT"),
        "photo": MessageLookupByLibrary.simpleMessage("Ảnh"),
        "pinMessage": MessageLookupByLibrary.simpleMessage("Ghim tin nhắn"),
        "pinMessages": MessageLookupByLibrary.simpleMessage("Ghim tin nhắn"),
        "pinThisChannel":
            MessageLookupByLibrary.simpleMessage("Ghim kênh này."),
        "pinned": MessageLookupByLibrary.simpleMessage("Kênh đã ghim"),
        "pleaseChoose": MessageLookupByLibrary.simpleMessage("vui lòng chọn"),
        "pleaseSelectChannel":
            MessageLookupByLibrary.simpleMessage("Vui lòng chọn kênh"),
        "pleaseUpdateVersion": MessageLookupByLibrary.simpleMessage(
            "Vui lòng cập nhật phiên bản mới"),
        "pollIsDisabled": MessageLookupByLibrary.simpleMessage(
            "Cuộc thăm dò ý kiến ​​này đã bị vô hiệu hóa"),
        "postedIn": MessageLookupByLibrary.simpleMessage("Đã đăng trong"),
        "preview": MessageLookupByLibrary.simpleMessage("Xem trước"),
        "previewComment":
            MessageLookupByLibrary.simpleMessage("Xem trước bình luận"),
        "previewText":
            MessageLookupByLibrary.simpleMessage("Xem trước văn bản"),
        "previous": MessageLookupByLibrary.simpleMessage("Trước"),
        "priority": MessageLookupByLibrary.simpleMessage("quyền ưu tiên"),
        "private": MessageLookupByLibrary.simpleMessage("Riêng tư"),
        "privateChannel": MessageLookupByLibrary.simpleMessage("Kênh riêng"),
        "privates": MessageLookupByLibrary.simpleMessage("riêng tư"),
        "processingData": MessageLookupByLibrary.simpleMessage("Xử lý dữ liệu"),
        "profile": MessageLookupByLibrary.simpleMessage("Hồ sơ"),
        "profileEdit": MessageLookupByLibrary.simpleMessage("Chỉnh sửa hồ sơ"),
        "public": MessageLookupByLibrary.simpleMessage("công khai"),
        "publicChannel": MessageLookupByLibrary.simpleMessage("Kênh công cộng"),
        "receiveJoinChannel": m28,
        "recentChannel": MessageLookupByLibrary.simpleMessage("Kênh gần đây"),
        "recentSearches":
            MessageLookupByLibrary.simpleMessage("Tìm kiếm Gần đây"),
        "recentlyUpdated":
            MessageLookupByLibrary.simpleMessage("Cập nhật gần đây"),
        "regular": MessageLookupByLibrary.simpleMessage("Kênh thường"),
        "reject": MessageLookupByLibrary.simpleMessage("Từ chối"),
        "rememberMe": MessageLookupByLibrary.simpleMessage("Nhớ mật khẩu"),
        "remove": MessageLookupByLibrary.simpleMessage("Loại bỏ"),
        "removeFriend": MessageLookupByLibrary.simpleMessage("Xoá bạn"),
        "removeFromSavedItems":
            MessageLookupByLibrary.simpleMessage("Xoá khỏi mục đã lưu"),
        "removed": MessageLookupByLibrary.simpleMessage("đã loại bỏ"),
        "reopen": MessageLookupByLibrary.simpleMessage("Mở lại"),
        "reopenIssue": MessageLookupByLibrary.simpleMessage("Mở lại issue"),
        "reopened": m29,
        "reopened1": m30,
        "reopenedThis": MessageLookupByLibrary.simpleMessage("đã mở lại"),
        "repliedToThread":
            MessageLookupByLibrary.simpleMessage("trả lời chủ đề"),
        "replies": MessageLookupByLibrary.simpleMessage("phản hồi"),
        "reply": MessageLookupByLibrary.simpleMessage("Đã trả lời tin nhắn"),
        "replyInThread":
            MessageLookupByLibrary.simpleMessage("Trả lời threads"),
        "replyThisMessage":
            MessageLookupByLibrary.simpleMessage("Trả lời tin nhắn"),
        "replyThread": MessageLookupByLibrary.simpleMessage("trả lời"),
        "replys": MessageLookupByLibrary.simpleMessage("phản hồi"),
        "reportDirectMessage":
            MessageLookupByLibrary.simpleMessage("Báo cáo tin nhắn"),
        "request": MessageLookupByLibrary.simpleMessage("Lời yêu cầu"),
        "requestSyncData":
            MessageLookupByLibrary.simpleMessage("yêu cầu đồng bộ hóa dữ liệu"),
        "requestTime":
            MessageLookupByLibrary.simpleMessage("Thời gian yêu cầu"),
        "requestUrl": MessageLookupByLibrary.simpleMessage("Yêu cầu URL:"),
        "resetDeviceKey":
            MessageLookupByLibrary.simpleMessage("Đặt lại khoá thiết bị "),
        "response": MessageLookupByLibrary.simpleMessage("Phản hồi"),
        "restore": MessageLookupByLibrary.simpleMessage("Khôi phục"),
        "restoreDM": MessageLookupByLibrary.simpleMessage("Khôi phục DM"),
        "results": MessageLookupByLibrary.simpleMessage("Các kết quả"),
        "reviewIssue": MessageLookupByLibrary.simpleMessage("Xem lại"),
        "roles": MessageLookupByLibrary.simpleMessage("Vai trò"),
        "save": MessageLookupByLibrary.simpleMessage("Lưu"),
        "saveChanges": MessageLookupByLibrary.simpleMessage("Lưu thay đổi"),
        "saveMessage": MessageLookupByLibrary.simpleMessage("Lưu tin nhắn"),
        "savedMessages":
            MessageLookupByLibrary.simpleMessage("Tin nhắn đã lưu"),
        "search": MessageLookupByLibrary.simpleMessage("Tìm kiếm"),
        "searchAnything": m31,
        "searchArchive":
            MessageLookupByLibrary.simpleMessage("Tìm kiếm kho lưu trữ"),
        "searchChannel": MessageLookupByLibrary.simpleMessage("Tìm kênh"),
        "searchLabel": MessageLookupByLibrary.simpleMessage("Tìm kiếm nhãn"),
        "searchMember":
            MessageLookupByLibrary.simpleMessage("Tìm kiếm thành viên"),
        "searchType": m32,
        "second": MessageLookupByLibrary.simpleMessage("giây"),
        "selectChannel": MessageLookupByLibrary.simpleMessage("Chọn kênh"),
        "selectMember": MessageLookupByLibrary.simpleMessage("Chọn thành viên"),
        "selected": MessageLookupByLibrary.simpleMessage("Đã chọn"),
        "sendFriendRequest":
            MessageLookupByLibrary.simpleMessage("Gửi lời mời kết bạn"),
        "sendToBoard": MessageLookupByLibrary.simpleMessage("Gửi tới bảng"),
        "sent": MessageLookupByLibrary.simpleMessage("Đã gửi"),
        "sentAFile": MessageLookupByLibrary.simpleMessage("đã gửi một file."),
        "sentAVideo": MessageLookupByLibrary.simpleMessage("đã gửi một video."),
        "sentAnImage": MessageLookupByLibrary.simpleMessage("đã gửi một ảnh."),
        "sentAttachments":
            MessageLookupByLibrary.simpleMessage("đã gửi tập tin đính kèm."),
        "sentFiles": m33,
        "sentImages": m34,
        "sentVideos": m35,
        "setAdmin": MessageLookupByLibrary.simpleMessage("Quản trị viên"),
        "setDesc": MessageLookupByLibrary.simpleMessage("Đặt mô tả"),
        "setEditor": MessageLookupByLibrary.simpleMessage("Biên tập viên"),
        "setMember": MessageLookupByLibrary.simpleMessage("Thành viên"),
        "setTopic": MessageLookupByLibrary.simpleMessage("Đặt chủ đề"),
        "setrole": MessageLookupByLibrary.simpleMessage("Đặt vai trò"),
        "settings": MessageLookupByLibrary.simpleMessage("Cài đặt"),
        "share":
            MessageLookupByLibrary.simpleMessage("Đã chia sẻ một tin nhắn"),
        "shareMessage":
            MessageLookupByLibrary.simpleMessage("Chia sẻ tin nhắn:"),
        "shareMessages":
            MessageLookupByLibrary.simpleMessage("Chia sẻ tin nhắn"),
        "shortcut": MessageLookupByLibrary.simpleMessage("Rút gọn:"),
        "showMoreComments": m36,
        "signIn": MessageLookupByLibrary.simpleMessage("Đăng nhập"),
        "signUp": MessageLookupByLibrary.simpleMessage("Đăng ký"),
        "silent": MessageLookupByLibrary.simpleMessage("Im lặng"),
        "silentMode": MessageLookupByLibrary.simpleMessage("CHẾ ĐỘ IM LẶNG"),
        "sort": MessageLookupByLibrary.simpleMessage("Sắp xếp"),
        "sortBy": MessageLookupByLibrary.simpleMessage("Sắp xếp theo"),
        "startDownloading":
            MessageLookupByLibrary.simpleMessage("Bắt đầu tải xuống"),
        "startingUp": MessageLookupByLibrary.simpleMessage("Khởi động"),
        "sticker": m37,
        "sticker1": MessageLookupByLibrary.simpleMessage("Đã gửi một nhãn dán"),
        "submit": MessageLookupByLibrary.simpleMessage("Gửi đi"),
        "submitNewIssue": MessageLookupByLibrary.simpleMessage("Tạo issue mới"),
        "success": MessageLookupByLibrary.simpleMessage("Thành công"),
        "switchToCards": MessageLookupByLibrary.simpleMessage("Sang thẻ"),
        "switchToLists": MessageLookupByLibrary.simpleMessage("Sang danh sách"),
        "sync": MessageLookupByLibrary.simpleMessage("Đồng bộ"),
        "syncData": MessageLookupByLibrary.simpleMessage("Đồng bộ hóa dữ liệu"),
        "syncPanchatApp":
            MessageLookupByLibrary.simpleMessage("Đồng bộ bằng Panchat *"),
        "synchronizationwilltake": MessageLookupByLibrary.simpleMessage(
            "Đồng bộ hóa sẽ diễn ra theo yêu cầu của thiết bị"),
        "syntaxError": MessageLookupByLibrary.simpleMessage(
            "Mã cú pháp không đúng, hãy thử lại!"),
        "tClose": MessageLookupByLibrary.simpleMessage("Đóng"),
        "tClosed": MessageLookupByLibrary.simpleMessage("Đóng"),
        "tOpen": MessageLookupByLibrary.simpleMessage("Mở"),
        "tagName": MessageLookupByLibrary.simpleMessage("Thẻ"),
        "theVideoCallEnded":
            MessageLookupByLibrary.simpleMessage("Cuộc gọi video đã kết thúc."),
        "theme": MessageLookupByLibrary.simpleMessage("Chủ đề nền"),
        "thereWasAnErrorInUpdating": MessageLookupByLibrary.simpleMessage(
            "Đã xảy ra lỗi khi cập nhật thông tin, đã xảy ra lỗi khi cập nhật thông tin của bạn, vui lòng thử lại sau!"),
        "thereWasAnErrorWhile": MessageLookupByLibrary.simpleMessage(
            "Đã xảy ra lỗi khi tải hình đại diện lên, vui lòng thử lại sau!"),
        "thisChannel": MessageLookupByLibrary.simpleMessage("kênh này"),
        "thisConversation":
            MessageLookupByLibrary.simpleMessage("cuộc trò chuyện này"),
        "thisGroup": MessageLookupByLibrary.simpleMessage("nhóm này"),
        "thisIsTheStartOf":
            MessageLookupByLibrary.simpleMessage("Đây là phần bắt đầu của"),
        "thisMessageDeleted":
            MessageLookupByLibrary.simpleMessage("[Tin nhắn này đã bị xoá.]"),
        "thisMessageWasDeleted":
            MessageLookupByLibrary.simpleMessage("[Tin nhắn này đã bị xóa.]"),
        "threads": MessageLookupByLibrary.simpleMessage("Chủ đề"),
        "timeCreate": MessageLookupByLibrary.simpleMessage("Thời gian tạo"),
        "timeCreated": MessageLookupByLibrary.simpleMessage("Thời gian tạo"),
        "tipFilter":
            MessageLookupByLibrary.simpleMessage("Dùng ↑ ↓ ↵ để điều hướng"),
        "tipSearch": MessageLookupByLibrary.simpleMessage(
            "Mẹo: Sử dụng bảng phím bắn CMD + T để tìm kiếm bất cứ thứ gì."),
        "title": MessageLookupByLibrary.simpleMessage("Tiêu đề"),
        "titleCannotBeEmpty":
            MessageLookupByLibrary.simpleMessage("Tiêu đề không được để trống"),
        "to": MessageLookupByLibrary.simpleMessage("thành"),
        "toChannel": MessageLookupByLibrary.simpleMessage("tới kênh"),
        "toResetYourDevice":
            MessageLookupByLibrary.simpleMessage("để đặt lại thiết bị của bạn"),
        "toThisConversation":
            MessageLookupByLibrary.simpleMessage("tới cuộc trò chuyện này"),
        "today": MessageLookupByLibrary.simpleMessage("Hôm nay"),
        "topic": MessageLookupByLibrary.simpleMessage("Chủ đề"),
        "transfer": MessageLookupByLibrary.simpleMessage("Chuyển giao"),
        "transferIssue":
            MessageLookupByLibrary.simpleMessage("Chuyển giao issue"),
        "transferOwner":
            MessageLookupByLibrary.simpleMessage("Chuyển quyền sở hữu"),
        "transferTo": MessageLookupByLibrary.simpleMessage("Chuyển giao cho"),
        "trong": MessageLookupByLibrary.simpleMessage("Trong"),
        "typeAMessage": MessageLookupByLibrary.simpleMessage("Nhập tin nhắn"),
        "typeEmailOrPhoneToInvite": MessageLookupByLibrary.simpleMessage(
            "Nhập email hoặc số điện thoại để mời"),
        "typeMessage": MessageLookupByLibrary.simpleMessage("Nhập tin nhắn..."),
        "unPinThisChannel":
            MessageLookupByLibrary.simpleMessage("Bỏ ghim kênh này."),
        "unarchiveCard":
            MessageLookupByLibrary.simpleMessage("Hủy lưu trữ thẻ"),
        "unarchiveChannel":
            MessageLookupByLibrary.simpleMessage("Hủy lưu trữ kênh"),
        "unarchived": MessageLookupByLibrary.simpleMessage("chưa được lưu trữ"),
        "unassign": MessageLookupByLibrary.simpleMessage("bỏ chỉ định"),
        "unassignIssue": m38,
        "unpinMessage":
            MessageLookupByLibrary.simpleMessage("Bỏ ghim tin nhắn"),
        "unreadOnly": MessageLookupByLibrary.simpleMessage("Chưa đọc"),
        "unsaveMessages":
            MessageLookupByLibrary.simpleMessage("Xóa tin nhắn đã lưu"),
        "unwatch": MessageLookupByLibrary.simpleMessage("Bỏ theo dõi"),
        "update": MessageLookupByLibrary.simpleMessage("Cập nhật"),
        "updateCommand": MessageLookupByLibrary.simpleMessage("Cập nhật lệnh"),
        "updateComment":
            MessageLookupByLibrary.simpleMessage("Cập nhật bình luận"),
        "upload": MessageLookupByLibrary.simpleMessage("Tải lên"),
        "urgent": MessageLookupByLibrary.simpleMessage("Khẩn cấp"),
        "useShotKeyboardQuickSearch": m39,
        "useShotKeyboardSearchAnything": m40,
        "userManagement":
            MessageLookupByLibrary.simpleMessage("QUẢN LÝ NGƯỜI DÙNG"),
        "userName": MessageLookupByLibrary.simpleMessage("Tên người dùng"),
        "userProfile":
            MessageLookupByLibrary.simpleMessage("Thông tin người dùng"),
        "verificationHasFailed":
            MessageLookupByLibrary.simpleMessage("Xác minh không thành công"),
        "video": MessageLookupByLibrary.simpleMessage("Video"),
        "videoCall": MessageLookupByLibrary.simpleMessage("Gọi video"),
        "viewAll": MessageLookupByLibrary.simpleMessage("Xem tất cả"),
        "viewMessage": MessageLookupByLibrary.simpleMessage("Xem tin nhắn"),
        "viewProfile": MessageLookupByLibrary.simpleMessage("Xem hồ sơ"),
        "viewWholeFile":
            MessageLookupByLibrary.simpleMessage("Xem toàn bộ tệp"),
        "waitingForVerification":
            MessageLookupByLibrary.simpleMessage("Đang chờ xác minh"),
        "wasKickedFromThisChannel":
            MessageLookupByLibrary.simpleMessage("đã bị loại khỏi kênh này"),
        "watch": MessageLookupByLibrary.simpleMessage("Theo dõi"),
        "watchActivity":
            MessageLookupByLibrary.simpleMessage("Tất cả hoạt động"),
        "watchAllComment": MessageLookupByLibrary.simpleMessage(
            "Thêm tất cả nhận xét từ các issue đã đăng ký vào thread."),
        "watchMention":
            MessageLookupByLibrary.simpleMessage("Tham gia và @mentions"),
        "weSoExcitedToSeeYou": MessageLookupByLibrary.simpleMessage(
            "Chúng tôi rất vui mừng được gặp bạn"),
        "welcome": MessageLookupByLibrary.simpleMessage("Chào mừng!"),
        "welcomeTo": MessageLookupByLibrary.simpleMessage("Chào mừng bạn đến"),
        "whatForDiscussion":
            MessageLookupByLibrary.simpleMessage("Có gì để thảo luận?"),
        "whatUpForDiscussion":
            MessageLookupByLibrary.simpleMessage("Có gì để thảo luận?"),
        "whatYourPollAbout": MessageLookupByLibrary.simpleMessage(
            "Cuộc thăm dò ý kiến của bạn là gì?"),
        "whenUsing": MessageLookupByLibrary.simpleMessage("khi sử dụng"),
        "workspace": MessageLookupByLibrary.simpleMessage("Workspace"),
        "workspaceCannotBlank": MessageLookupByLibrary.simpleMessage(
            "Tên không gian làm việc không được để trống"),
        "workspaceDetails":
            MessageLookupByLibrary.simpleMessage("Chi tiết phòng làm việc"),
        "workspaceName": MessageLookupByLibrary.simpleMessage("Tên phòng"),
        "wrongCodePleaseTryAgain": MessageLookupByLibrary.simpleMessage(
            "Không đúng mã số, vui lòng thử lại"),
        "year": MessageLookupByLibrary.simpleMessage("năm"),
        "years": MessageLookupByLibrary.simpleMessage("năm"),
        "yesterday": MessageLookupByLibrary.simpleMessage("Hôm qua"),
        "youCanUndoThisAction": MessageLookupByLibrary.simpleMessage(
            "Bạn không thể hoàn tác hành động này"),
        "youDoNotHaveSufficient": MessageLookupByLibrary.simpleMessage(
            "Bạn không có đủ quyền để thực hiện thao tác"),
        "youInAnIssueIn":
            MessageLookupByLibrary.simpleMessage("bạn trong một issue trong"),
        "youWillNeedBoth": MessageLookupByLibrary.simpleMessage(
            "Bạn sẽ cần cả tên người dùng và thẻ của họ. Hãy nhớ rằng tên người dùng có phân biệt chữ hoa chữ thường."),
        "yourEmailPhone":
            MessageLookupByLibrary.simpleMessage("Email / Số điện thoại"),
        "yourFriend": MessageLookupByLibrary.simpleMessage("Bạn bè của bạn"),
        "yourName": MessageLookupByLibrary.simpleMessage("Tên của bạn"),
        "yourRoleCannotAction": MessageLookupByLibrary.simpleMessage(
            "Vai trò của bạn không thể thực hiện hành động."),
        "yourUsernameAndTag": MessageLookupByLibrary.simpleMessage(
            "* Tên người dùng và thẻ của bạn là ")
      };
}
