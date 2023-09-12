// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `{count, plural, one{1 year ago} other{{count} years ago}}`
  String countYearAgo(num count) {
    return Intl.plural(
      count,
      one: '1 year ago',
      other: '$count years ago',
      name: 'countYearAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 month ago} other{{count} months ago}}`
  String countMonthAgo(num count) {
    return Intl.plural(
      count,
      one: '1 month ago',
      other: '$count months ago',
      name: 'countMonthAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 day ago} other{{count} days ago}}`
  String countDayAgo(num count) {
    return Intl.plural(
      count,
      one: '1 day ago',
      other: '$count days ago',
      name: 'countDayAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 hour ago} other{{count} hours ago}}`
  String countHourAgo(num count) {
    return Intl.plural(
      count,
      one: '1 hour ago',
      other: '$count hours ago',
      name: 'countHourAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 minute ago} other{{count} minutes ago}}`
  String countMinuteAgo(num count) {
    return Intl.plural(
      count,
      one: '1 minute ago',
      other: '$count minutes ago',
      name: 'countMinuteAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{ 1 comment} other{ {count} comments}}`
  String countComments(num count) {
    return Intl.plural(
      count,
      one: ' 1 comment',
      other: ' $count comments',
      name: 'countComments',
      desc: '',
      args: [count],
    );
  }

  /// `moment ago`
  String get momentAgo {
    return Intl.message(
      'moment ago',
      name: 'momentAgo',
      desc: '',
      args: [],
    );
  }

  /// `Language & Region`
  String get language {
    return Intl.message(
      'Language & Region',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `User profile`
  String get userProfile {
    return Intl.message(
      'User profile',
      name: 'userProfile',
      desc: '',
      args: [],
    );
  }

  /// `Pinned`
  String get pinned {
    return Intl.message(
      'Pinned',
      name: 'pinned',
      desc: '',
      args: [],
    );
  }

  /// `Channels`
  String get channels {
    return Intl.message(
      'Channels',
      name: 'channels',
      desc: '',
      args: [],
    );
  }

  /// `Direct Messages`
  String get directMessages {
    return Intl.message(
      'Direct Messages',
      name: 'directMessages',
      desc: '',
      args: [],
    );
  }

  /// `Invite People`
  String get invitePeople {
    return Intl.message(
      'Invite People',
      name: 'invitePeople',
      desc: '',
      args: [],
    );
  }

  /// `Create Channel`
  String get createChannel {
    return Intl.message(
      'Create Channel',
      name: 'createChannel',
      desc: '',
      args: [],
    );
  }

  /// `Join Channel`
  String get joinChannel {
    return Intl.message(
      'Join Channel',
      name: 'joinChannel',
      desc: '',
      args: [],
    );
  }

  /// `Change Nickname`
  String get changeNickname {
    return Intl.message(
      'Change Nickname',
      name: 'changeNickname',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Change Avatar`
  String get changeAvatar {
    return Intl.message(
      'Change Avatar',
      name: 'changeAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Leave workspace`
  String get leaveWorkspace {
    return Intl.message(
      'Leave workspace',
      name: 'leaveWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Transfer ownership`
  String get transferOwner {
    return Intl.message(
      'Transfer ownership',
      name: 'transferOwner',
      desc: '',
      args: [],
    );
  }

  /// `Delete workspace`
  String get deleteWorkspace {
    return Intl.message(
      'Delete workspace',
      name: 'deleteWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to delete workspace ? This action cannot be undone`
  String get descDeleteWorkspace {
    return Intl.message(
      'Are you sure want to delete workspace ? This action cannot be undone',
      name: 'descDeleteWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to delete channel ? This action cannot be undone`
  String get descDeleteChannel {
    return Intl.message(
      'Are you sure want to delete channel ? This action cannot be undone',
      name: 'descDeleteChannel',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to leave workspace?\nThis action cannot be undone.`
  String get descLeaveWorkspace {
    return Intl.message(
      'Are you sure want to leave workspace?\nThis action cannot be undone.',
      name: 'descLeaveWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Mentions`
  String get mentions {
    return Intl.message(
      'Mentions',
      name: 'mentions',
      desc: '',
      args: [],
    );
  }

  /// `Threads`
  String get threads {
    return Intl.message(
      'Threads',
      name: 'threads',
      desc: '',
      args: [],
    );
  }

  /// `Pin this channel.`
  String get pinThisChannel {
    return Intl.message(
      'Pin this channel.',
      name: 'pinThisChannel',
      desc: '',
      args: [],
    );
  }

  /// `Unpin this channel.`
  String get unPinThisChannel {
    return Intl.message(
      'Unpin this channel.',
      name: 'unPinThisChannel',
      desc: '',
      args: [],
    );
  }

  /// `Create a workspace`
  String get createAWorkspace {
    return Intl.message(
      'Create a workspace',
      name: 'createAWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Create workspace`
  String get createWorkspace {
    return Intl.message(
      'Create workspace',
      name: 'createWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Your workspace is where you and your friends hang out. Make your and start talking.`
  String get descCreateWorkspace {
    return Intl.message(
      'Your workspace is where you and your friends hang out. Make your and start talking.',
      name: 'descCreateWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `By create a workspace, you agree to Pancake's`
  String get noteCreateWs {
    return Intl.message(
      'By create a workspace, you agree to Pancake\'s',
      name: 'noteCreateWs',
      desc: '',
      args: [],
    );
  }

  /// `Community Guidelines`
  String get communityGuide {
    return Intl.message(
      'Community Guidelines',
      name: 'communityGuide',
      desc: '',
      args: [],
    );
  }

  /// `Have an invite already?`
  String get haveAnInviteAlready {
    return Intl.message(
      'Have an invite already?',
      name: 'haveAnInviteAlready',
      desc: '',
      args: [],
    );
  }

  /// `Join a workspace`
  String get joinWorkspace {
    return Intl.message(
      'Join a workspace',
      name: 'joinWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Enter an invite below to join an existing workspace`
  String get descJoinWs {
    return Intl.message(
      'Enter an invite below to join an existing workspace',
      name: 'descJoinWs',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get friends {
    return Intl.message(
      'Friends',
      name: 'friends',
      desc: '',
      args: [],
    );
  }

  /// `Direct settings`
  String get directSettings {
    return Intl.message(
      'Direct settings',
      name: 'directSettings',
      desc: '',
      args: [],
    );
  }

  /// `Create group`
  String get createGroup {
    return Intl.message(
      'Create group',
      name: 'createGroup',
      desc: '',
      args: [],
    );
  }

  /// `Invite to group`
  String get inviteToGroup {
    return Intl.message(
      'Invite to group',
      name: 'inviteToGroup',
      desc: '',
      args: [],
    );
  }

  /// `Delete chat`
  String get deleteChat {
    return Intl.message(
      'Delete chat',
      name: 'deleteChat',
      desc: '',
      args: [],
    );
  }

  /// `Leave group`
  String get leaveGroup {
    return Intl.message(
      'Leave group',
      name: 'leaveGroup',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to leave this conversation?`
  String get descLeaveGroup {
    return Intl.message(
      'Are you sure want to leave this conversation?',
      name: 'descLeaveGroup',
      desc: '',
      args: [],
    );
  }

  /// `Call`
  String get call {
    return Intl.message(
      'Call',
      name: 'call',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get videoCall {
    return Intl.message(
      'Video',
      name: 'videoCall',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get accepted {
    return Intl.message(
      'Accepted',
      name: 'accepted',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Added`
  String get added {
    return Intl.message(
      'Added',
      name: 'added',
      desc: '',
      args: [],
    );
  }

  /// `Add apps`
  String get addApps {
    return Intl.message(
      'Add apps',
      name: 'addApps',
      desc: '',
      args: [],
    );
  }

  /// `Accepted`
  String get acceptInvite {
    return Intl.message(
      'Accepted',
      name: 'acceptInvite',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Response`
  String get response {
    return Intl.message(
      'Response',
      name: 'response',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get reject {
    return Intl.message(
      'Reject',
      name: 'reject',
      desc: '',
      args: [],
    );
  }

  /// `Block`
  String get block {
    return Intl.message(
      'Block',
      name: 'block',
      desc: '',
      args: [],
    );
  }

  /// `Remove Friend`
  String get removeFriend {
    return Intl.message(
      'Remove Friend',
      name: 'removeFriend',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message(
      'Full Name',
      name: 'fullName',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Display name`
  String get displayName {
    return Intl.message(
      'Display name',
      name: 'displayName',
      desc: '',
      args: [],
    );
  }

  /// `Email address`
  String get emailAddress {
    return Intl.message(
      'Email address',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Conversation name`
  String get conversationName {
    return Intl.message(
      'Conversation name',
      name: 'conversationName',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get members {
    return Intl.message(
      'Members',
      name: 'members',
      desc: '',
      args: [],
    );
  }

  /// `Files`
  String get files {
    return Intl.message(
      'Files',
      name: 'files',
      desc: '',
      args: [],
    );
  }

  /// `Images`
  String get images {
    return Intl.message(
      'Images',
      name: 'images',
      desc: '',
      args: [],
    );
  }

  /// `Photo`
  String get photo {
    return Intl.message(
      'Photo',
      name: 'photo',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// `Saved Messages`
  String get savedMessages {
    return Intl.message(
      'Saved Messages',
      name: 'savedMessages',
      desc: '',
      args: [],
    );
  }

  /// `Remove from saved items`
  String get removeFromSavedItems {
    return Intl.message(
      'Remove from saved items',
      name: 'removeFromSavedItems',
      desc: '',
      args: [],
    );
  }

  /// `Search ({hotkey} + F) / Anything ({hotkey} + T)`
  String searchAnything(Object hotkey) {
    return Intl.message(
      'Search ($hotkey + F) / Anything ($hotkey + T)',
      name: 'searchAnything',
      desc: '',
      args: [hotkey],
    );
  }

  /// `Search your contacts and messages in direct`
  String get desSearch {
    return Intl.message(
      'Search your contacts and messages in direct',
      name: 'desSearch',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get messages {
    return Intl.message(
      'Messages',
      name: 'messages',
      desc: '',
      args: [],
    );
  }

  /// `Contacts`
  String get contacts {
    return Intl.message(
      'Contacts',
      name: 'contacts',
      desc: '',
      args: [],
    );
  }

  /// `Or I'm looking for...`
  String get lookingFor {
    return Intl.message(
      'Or I\'m looking for...',
      name: 'lookingFor',
      desc: '',
      args: [],
    );
  }

  /// `In thread`
  String get inThread {
    return Intl.message(
      'In thread',
      name: 'inThread',
      desc: '',
      args: [],
    );
  }

  /// `Tips: Use shotkeyboard CMD + T to search anything.`
  String get tipSearch {
    return Intl.message(
      'Tips: Use shotkeyboard CMD + T to search anything.',
      name: 'tipSearch',
      desc: '',
      args: [],
    );
  }

  /// `Search all your contacts and messages.`
  String get desSearchAnything {
    return Intl.message(
      'Search all your contacts and messages.',
      name: 'desSearchAnything',
      desc: '',
      args: [],
    );
  }

  /// `Search all your directs and all workspaces`
  String get descSearchAll {
    return Intl.message(
      'Search all your directs and all workspaces',
      name: 'descSearchAll',
      desc: '',
      args: [],
    );
  }

  /// `Search all your contacts`
  String get descSearchContact {
    return Intl.message(
      'Search all your contacts',
      name: 'descSearchContact',
      desc: '',
      args: [],
    );
  }

  /// `Search your contacts and message in {name}`
  String descSearchInCtWs(Object name) {
    return Intl.message(
      'Search your contacts and message in $name',
      name: 'descSearchInCtWs',
      desc: '',
      args: [name],
    );
  }

  /// `Search messages in your direct`
  String get descSearchDms {
    return Intl.message(
      'Search messages in your direct',
      name: 'descSearchDms',
      desc: '',
      args: [],
    );
  }

  /// `Search messages in {name}`
  String descSearchInWs(Object name) {
    return Intl.message(
      'Search messages in $name',
      name: 'descSearchInWs',
      desc: '',
      args: [name],
    );
  }

  /// `Find everything for you.`
  String get findEverything {
    return Intl.message(
      'Find everything for you.',
      name: 'findEverything',
      desc: '',
      args: [],
    );
  }

  /// `Enjoy to search`
  String get enjoyToSearch {
    return Intl.message(
      'Enjoy to search',
      name: 'enjoyToSearch',
      desc: '',
      args: [],
    );
  }

  /// `Find workspace, message, contacts ...`
  String get findAll {
    return Intl.message(
      'Find workspace, message, contacts ...',
      name: 'findAll',
      desc: '',
      args: [],
    );
  }

  /// `Tip: Use shotkeyboard {hotkey}-T to search anything`
  String useShotKeyboardSearchAnything(Object hotkey) {
    return Intl.message(
      'Tip: Use shotkeyboard $hotkey-T to search anything',
      name: 'useShotKeyboardSearchAnything',
      desc: '',
      args: [hotkey],
    );
  }

  /// `Tip: Use shotkeyboard {hotkey}-T to quick search`
  String useShotKeyboardQuickSearch(Object hotkey) {
    return Intl.message(
      'Tip: Use shotkeyboard $hotkey-T to quick search',
      name: 'useShotKeyboardQuickSearch',
      desc: '',
      args: [hotkey],
    );
  }

  /// `Color Picker`
  String get colorPicker {
    return Intl.message(
      'Color Picker',
      name: 'colorPicker',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Languages`
  String get languages {
    return Intl.message(
      'Languages',
      name: 'languages',
      desc: '',
      args: [],
    );
  }

  /// `Your name`
  String get yourName {
    return Intl.message(
      'Your name',
      name: 'yourName',
      desc: '',
      args: [],
    );
  }

  /// `Tag name`
  String get tagName {
    return Intl.message(
      'Tag name',
      name: 'tagName',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get phoneNumber {
    return Intl.message(
      'Phone number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Date of birth`
  String get dateOfBirth {
    return Intl.message(
      'Date of birth',
      name: 'dateOfBirth',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message(
      'Male',
      name: 'male',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message(
      'Female',
      name: 'female',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Online`
  String get online {
    return Intl.message(
      'Online',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get offline {
    return Intl.message(
      'Offline',
      name: 'offline',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Blocked`
  String get blocked {
    return Intl.message(
      'Blocked',
      name: 'blocked',
      desc: '',
      args: [],
    );
  }

  /// `Add friend`
  String get addFriend {
    return Intl.message(
      'Add friend',
      name: 'addFriend',
      desc: '',
      args: [],
    );
  }

  /// `Enter your friend's name with their tag. Ex: JohnDoe#1234`
  String get desAddFriend {
    return Intl.message(
      'Enter your friend\'s name with their tag. Ex: JohnDoe#1234',
      name: 'desAddFriend',
      desc: '',
      args: [],
    );
  }

  /// `Enter a Username#0000`
  String get enterUsername {
    return Intl.message(
      'Enter a Username#0000',
      name: 'enterUsername',
      desc: '',
      args: [],
    );
  }

  /// `Outgoing Friend Request`
  String get outgoingFriendRequest {
    return Intl.message(
      'Outgoing Friend Request',
      name: 'outgoingFriendRequest',
      desc: '',
      args: [],
    );
  }

  /// `Incoming Friend Request`
  String get incomingFriendRequest {
    return Intl.message(
      'Incoming Friend Request',
      name: 'incomingFriendRequest',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message(
      'Active',
      name: 'active',
      desc: '',
      args: [],
    );
  }

  /// `Devices`
  String get devices {
    return Intl.message(
      'Devices',
      name: 'devices',
      desc: '',
      args: [],
    );
  }

  /// `Sync`
  String get sync {
    return Intl.message(
      'Sync',
      name: 'sync',
      desc: '',
      args: [],
    );
  }

  /// `File manager`
  String get fileManager {
    return Intl.message(
      'File manager',
      name: 'fileManager',
      desc: '',
      args: [],
    );
  }

  /// `File downloading`
  String get fileDownloading {
    return Intl.message(
      'File downloading',
      name: 'fileDownloading',
      desc: '',
      args: [],
    );
  }

  /// `Apps`
  String get apps {
    return Intl.message(
      'Apps',
      name: 'apps',
      desc: '',
      args: [],
    );
  }

  /// `Create app`
  String get createApp {
    return Intl.message(
      'Create app',
      name: 'createApp',
      desc: '',
      args: [],
    );
  }

  /// `After creating and installing the application, you can configure to stay in specific channels.`
  String get desApp {
    return Intl.message(
      'After creating and installing the application, you can configure to stay in specific channels.',
      name: 'desApp',
      desc: '',
      args: [],
    );
  }

  /// `App default`
  String get appDefault {
    return Intl.message(
      'App default',
      name: 'appDefault',
      desc: '',
      args: [],
    );
  }

  /// `Applications are available`
  String get appAvailable {
    return Intl.message(
      'Applications are available',
      name: 'appAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Synchronize messages from the left side configuration POS.`
  String get desPOSApp {
    return Intl.message(
      'Synchronize messages from the left side configuration POS.',
      name: 'desPOSApp',
      desc: '',
      args: [],
    );
  }

  /// `Notice of bank account fluctuations.`
  String get desBankApp {
    return Intl.message(
      'Notice of bank account fluctuations.',
      name: 'desBankApp',
      desc: '',
      args: [],
    );
  }

  /// `Create custom apps`
  String get customApp {
    return Intl.message(
      'Create custom apps',
      name: 'customApp',
      desc: '',
      args: [],
    );
  }

  /// `Install`
  String get install {
    return Intl.message(
      'Install',
      name: 'install',
      desc: '',
      args: [],
    );
  }

  /// `Type a message...`
  String get typeMessage {
    return Intl.message(
      'Type a message...',
      name: 'typeMessage',
      desc: '',
      args: [],
    );
  }

  /// `Pin message`
  String get pinMessages {
    return Intl.message(
      'Pin message',
      name: 'pinMessages',
      desc: '',
      args: [],
    );
  }

  /// `Notification setting`
  String get notifySetting {
    return Intl.message(
      'Notification setting',
      name: 'notifySetting',
      desc: '',
      args: [],
    );
  }

  /// `NORMAL MODE`
  String get normalMode {
    return Intl.message(
      'NORMAL MODE',
      name: 'normalMode',
      desc: '',
      args: [],
    );
  }

  /// `All messages have notifications and highlights.`
  String get desNormalMode {
    return Intl.message(
      'All messages have notifications and highlights.',
      name: 'desNormalMode',
      desc: '',
      args: [],
    );
  }

  /// `MENTION MODE`
  String get mentionMode {
    return Intl.message(
      'MENTION MODE',
      name: 'mentionMode',
      desc: '',
      args: [],
    );
  }

  /// `Channel dimming, highlighting and notification only when @mentions or @all.`
  String get desMentionMode {
    return Intl.message(
      'Channel dimming, highlighting and notification only when @mentions or @all.',
      name: 'desMentionMode',
      desc: '',
      args: [],
    );
  }

  /// `SILENT MODE`
  String get silentMode {
    return Intl.message(
      'SILENT MODE',
      name: 'silentMode',
      desc: '',
      args: [],
    );
  }

  /// `Turn off notifications only.`
  String get desSilentMode {
    return Intl.message(
      'Turn off notifications only.',
      name: 'desSilentMode',
      desc: '',
      args: [],
    );
  }

  /// `OFF MODE`
  String get offMode {
    return Intl.message(
      'OFF MODE',
      name: 'offMode',
      desc: '',
      args: [],
    );
  }

  /// `Nothing.`
  String get desOffMode {
    return Intl.message(
      'Nothing.',
      name: 'desOffMode',
      desc: '',
      args: [],
    );
  }

  /// `Invite`
  String get invite {
    return Intl.message(
      'Invite',
      name: 'invite',
      desc: '',
      args: [],
    );
  }

  /// `Invite to workspace`
  String get inviteToWorkspace {
    return Intl.message(
      'Invite to workspace',
      name: 'inviteToWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Invite to {name}`
  String inviteTo(Object name) {
    return Intl.message(
      'Invite to $name',
      name: 'inviteTo',
      desc: '',
      args: [name],
    );
  }

  /// `Invite existing team member or add new ones.`
  String get descInvite {
    return Intl.message(
      'Invite existing team member or add new ones.',
      name: 'descInvite',
      desc: '',
      args: [],
    );
  }

  /// `Search member`
  String get searchMember {
    return Intl.message(
      'Search member',
      name: 'searchMember',
      desc: '',
      args: [],
    );
  }

  /// `Your friends`
  String get yourFriend {
    return Intl.message(
      'Your friends',
      name: 'yourFriend',
      desc: '',
      args: [],
    );
  }

  /// `Code invite`
  String get codeInvite {
    return Intl.message(
      'Code invite',
      name: 'codeInvite',
      desc: '',
      args: [],
    );
  }

  /// `Invite new people to this channel.`
  String get inviteToChannel {
    return Intl.message(
      'Invite new people to this channel.',
      name: 'inviteToChannel',
      desc: '',
      args: [],
    );
  }

  /// `Topic`
  String get topic {
    return Intl.message(
      'Topic',
      name: 'topic',
      desc: '',
      args: [],
    );
  }

  /// `Edit channel topic`
  String get editChannelTopic {
    return Intl.message(
      'Edit channel topic',
      name: 'editChannelTopic',
      desc: '',
      args: [],
    );
  }

  /// `Edit channel description`
  String get editChannelDesc {
    return Intl.message(
      'Edit channel description',
      name: 'editChannelDesc',
      desc: '',
      args: [],
    );
  }

  /// `Set Topic`
  String get setTopic {
    return Intl.message(
      'Set Topic',
      name: 'setTopic',
      desc: '',
      args: [],
    );
  }

  /// `Set Description`
  String get setDesc {
    return Intl.message(
      'Set Description',
      name: 'setDesc',
      desc: '',
      args: [],
    );
  }

  /// `Channel name already exists`
  String get channelNameExisted {
    return Intl.message(
      'Channel name already exists',
      name: 'channelNameExisted',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to archive {name}?`
  String descArchiveChannel(Object name) {
    return Intl.message(
      'Are you sure you want to archive $name?',
      name: 'descArchiveChannel',
      desc: '',
      args: [name],
    );
  }

  /// `Create by`
  String get createBy {
    return Intl.message(
      'Create by',
      name: 'createBy',
      desc: '',
      args: [],
    );
  }

  /// `on`
  String get on {
    return Intl.message(
      'on',
      name: 'on',
      desc: '',
      args: [],
    );
  }

  /// `ago`
  String get ago {
    return Intl.message(
      'ago',
      name: 'ago',
      desc: '',
      args: [],
    );
  }

  /// `CHANNEL NAME`
  String get channelName {
    return Intl.message(
      'CHANNEL NAME',
      name: 'channelName',
      desc: '',
      args: [],
    );
  }

  /// `Channel Type`
  String get channelType {
    return Intl.message(
      'Channel Type',
      name: 'channelType',
      desc: '',
      args: [],
    );
  }

  /// `Change workflow`
  String get changeWorkflow {
    return Intl.message(
      'Change workflow',
      name: 'changeWorkflow',
      desc: '',
      args: [],
    );
  }

  /// `Archive Channel`
  String get archiveChannel {
    return Intl.message(
      'Archive Channel',
      name: 'archiveChannel',
      desc: '',
      args: [],
    );
  }

  /// `Leave Channel`
  String get leaveChannel {
    return Intl.message(
      'Leave Channel',
      name: 'leaveChannel',
      desc: '',
      args: [],
    );
  }

  /// `Delete Channel`
  String get deleteChannel {
    return Intl.message(
      'Delete Channel',
      name: 'deleteChannel',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get private {
    return Intl.message(
      'Private',
      name: 'private',
      desc: '',
      args: [],
    );
  }

  /// `Regular`
  String get regular {
    return Intl.message(
      'Regular',
      name: 'regular',
      desc: '',
      args: [],
    );
  }

  /// `Add new apps`
  String get addNewApp {
    return Intl.message(
      'Add new apps',
      name: 'addNewApp',
      desc: '',
      args: [],
    );
  }

  /// `Connect the POS app to this channel`
  String get connectPOSApp {
    return Intl.message(
      'Connect the POS app to this channel',
      name: 'connectPOSApp',
      desc: '',
      args: [],
    );
  }

  /// `Issue`
  String get issue {
    return Intl.message(
      'Issue',
      name: 'issue',
      desc: '',
      args: [],
    );
  }

  /// `Watch`
  String get watch {
    return Intl.message(
      'Watch',
      name: 'watch',
      desc: '',
      args: [],
    );
  }

  /// `Unwatch`
  String get unwatch {
    return Intl.message(
      'Unwatch',
      name: 'unwatch',
      desc: '',
      args: [],
    );
  }

  /// `Participating and @mentions`
  String get watchMention {
    return Intl.message(
      'Participating and @mentions',
      name: 'watchMention',
      desc: '',
      args: [],
    );
  }

  /// `Only receive notifications from this channel when participating or @mentioned.`
  String get descWatchMention {
    return Intl.message(
      'Only receive notifications from this channel when participating or @mentioned.',
      name: 'descWatchMention',
      desc: '',
      args: [],
    );
  }

  /// `All Activity`
  String get watchActivity {
    return Intl.message(
      'All Activity',
      name: 'watchActivity',
      desc: '',
      args: [],
    );
  }

  /// `Notified of all notifications on this channel.`
  String get descWatchActivity {
    return Intl.message(
      'Notified of all notifications on this channel.',
      name: 'descWatchActivity',
      desc: '',
      args: [],
    );
  }

  /// `Add all comments from the subcribed issues to the thread.`
  String get watchAllComment {
    return Intl.message(
      'Add all comments from the subcribed issues to the thread.',
      name: 'watchAllComment',
      desc: '',
      args: [],
    );
  }

  /// `New issue`
  String get newIssue {
    return Intl.message(
      'New issue',
      name: 'newIssue',
      desc: '',
      args: [],
    );
  }

  /// `Labels`
  String get labels {
    return Intl.message(
      'Labels',
      name: 'labels',
      desc: '',
      args: [],
    );
  }

  /// `Milestones`
  String get milestones {
    return Intl.message(
      'Milestones',
      name: 'milestones',
      desc: '',
      args: [],
    );
  }

  /// `{count} Open`
  String open(Object count) {
    return Intl.message(
      '$count Open',
      name: 'open',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Closed`
  String closed(Object count) {
    return Intl.message(
      '$count Closed',
      name: 'closed',
      desc: '',
      args: [count],
    );
  }

  /// `{count} labels`
  String countLabels(Object count) {
    return Intl.message(
      '$count labels',
      name: 'countLabels',
      desc: '',
      args: [count],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Add name`
  String get addName {
    return Intl.message(
      'Add name',
      name: 'addName',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get color {
    return Intl.message(
      'Color',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  /// `Create label`
  String get createLabels {
    return Intl.message(
      'Create label',
      name: 'createLabels',
      desc: '',
      args: [],
    );
  }

  /// `{count} Milestones`
  String openMilestones(Object count) {
    return Intl.message(
      '$count Milestones',
      name: 'openMilestones',
      desc: '',
      args: [count],
    );
  }

  /// `Sort`
  String get sort {
    return Intl.message(
      'Sort',
      name: 'sort',
      desc: '',
      args: [],
    );
  }

  /// `Unread only`
  String get unreadOnly {
    return Intl.message(
      'Unread only',
      name: 'unreadOnly',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message(
      'Author',
      name: 'author',
      desc: '',
      args: [],
    );
  }

  /// `Issues`
  String get issues {
    return Intl.message(
      'Issues',
      name: 'issues',
      desc: '',
      args: [],
    );
  }

  /// `Type or choose a name`
  String get descFileterAuthor {
    return Intl.message(
      'Type or choose a name',
      name: 'descFileterAuthor',
      desc: '',
      args: [],
    );
  }

  /// `Use ↑ ↓ ↵ to navigate`
  String get tipFilter {
    return Intl.message(
      'Use ↑ ↓ ↵ to navigate',
      name: 'tipFilter',
      desc: '',
      args: [],
    );
  }

  /// `Issues with no milestone`
  String get filterNoMilestone {
    return Intl.message(
      'Issues with no milestone',
      name: 'filterNoMilestone',
      desc: '',
      args: [],
    );
  }

  /// `Assigned to nobody`
  String get assignedNobody {
    return Intl.message(
      'Assigned to nobody',
      name: 'assignedNobody',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get sortBy {
    return Intl.message(
      'Sort by',
      name: 'sortBy',
      desc: '',
      args: [],
    );
  }

  /// `Newest`
  String get newest {
    return Intl.message(
      'Newest',
      name: 'newest',
      desc: '',
      args: [],
    );
  }

  /// `Oldest`
  String get oldest {
    return Intl.message(
      'Oldest',
      name: 'oldest',
      desc: '',
      args: [],
    );
  }

  /// `Recently Updated`
  String get recentlyUpdated {
    return Intl.message(
      'Recently Updated',
      name: 'recentlyUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Least Recently Updated`
  String get leastRecentlyUpdated {
    return Intl.message(
      'Least Recently Updated',
      name: 'leastRecentlyUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get previous {
    return Intl.message(
      'Previous',
      name: 'previous',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Copy to clipboard`
  String get copyToClipboard {
    return Intl.message(
      'Copy to clipboard',
      name: 'copyToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Assignees`
  String get assignees {
    return Intl.message(
      'Assignees',
      name: 'assignees',
      desc: '',
      args: [],
    );
  }

  /// `Transfer issue`
  String get transferIssue {
    return Intl.message(
      'Transfer issue',
      name: 'transferIssue',
      desc: '',
      args: [],
    );
  }

  /// `Edit comment`
  String get editComment {
    return Intl.message(
      'Edit comment',
      name: 'editComment',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message(
      'Preview',
      name: 'preview',
      desc: '',
      args: [],
    );
  }

  /// `Preview Comment`
  String get previewComment {
    return Intl.message(
      'Preview Comment',
      name: 'previewComment',
      desc: '',
      args: [],
    );
  }

  /// `Add a more detailed...`
  String get addDetail {
    return Intl.message(
      'Add a more detailed...',
      name: 'addDetail',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `Attach image to comment`
  String get attachImageToComment {
    return Intl.message(
      'Attach image to comment',
      name: 'attachImageToComment',
      desc: '',
      args: [],
    );
  }

  /// `Close issue`
  String get closeIssue {
    return Intl.message(
      'Close issue',
      name: 'closeIssue',
      desc: '',
      args: [],
    );
  }

  /// `Close with comment`
  String get closeWithComment {
    return Intl.message(
      'Close with comment',
      name: 'closeWithComment',
      desc: '',
      args: [],
    );
  }

  /// `Reopen issue`
  String get reopenIssue {
    return Intl.message(
      'Reopen issue',
      name: 'reopenIssue',
      desc: '',
      args: [],
    );
  }

  /// `Update comment`
  String get updateComment {
    return Intl.message(
      'Update comment',
      name: 'updateComment',
      desc: '',
      args: [],
    );
  }

  /// `Submit new issue`
  String get submitNewIssue {
    return Intl.message(
      'Submit new issue',
      name: 'submitNewIssue',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Add title`
  String get addTitle {
    return Intl.message(
      'Add title',
      name: 'addTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add description`
  String get addDescription {
    return Intl.message(
      'Add description',
      name: 'addDescription',
      desc: '',
      args: [],
    );
  }

  /// `Create milestone`
  String get createMilestone {
    return Intl.message(
      'Create milestone',
      name: 'createMilestone',
      desc: '',
      args: [],
    );
  }

  /// `Save change`
  String get saveChanges {
    return Intl.message(
      'Save change',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Due date (Opt)`
  String get dueDate {
    return Intl.message(
      'Due date (Opt)',
      name: 'dueDate',
      desc: '',
      args: [],
    );
  }

  /// `Comment`
  String get comment {
    return Intl.message(
      'Comment',
      name: 'comment',
      desc: '',
      args: [],
    );
  }

  /// `Filter labels`
  String get filterLabels {
    return Intl.message(
      'Filter labels',
      name: 'filterLabels',
      desc: '',
      args: [],
    );
  }

  /// `Filter milestones`
  String get filterMilestone {
    return Intl.message(
      'Filter milestones',
      name: 'filterMilestone',
      desc: '',
      args: [],
    );
  }

  /// `Join channel was successful.`
  String get joinChannelSuccess {
    return Intl.message(
      'Join channel was successful.',
      name: 'joinChannelSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Join the error channel. Please try again..`
  String get joinChannelFail {
    return Intl.message(
      'Join the error channel. Please try again..',
      name: 'joinChannelFail',
      desc: '',
      args: [],
    );
  }

  /// `Join workspace was successful`
  String get joinWorkspaceSuccess {
    return Intl.message(
      'Join workspace was successful',
      name: 'joinWorkspaceSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Join the error workspace. Please try again..`
  String get joinWorkspaceFail {
    return Intl.message(
      'Join the error workspace. Please try again..',
      name: 'joinWorkspaceFail',
      desc: '',
      args: [],
    );
  }

  /// `Examples`
  String get example {
    return Intl.message(
      'Examples',
      name: 'example',
      desc: '',
      args: [],
    );
  }

  /// `Workspace's name`
  String get workspaceName {
    return Intl.message(
      'Workspace\'s name',
      name: 'workspaceName',
      desc: '',
      args: [],
    );
  }

  /// `INVITE LINK OR CODE INVITE`
  String get inviteWsCode {
    return Intl.message(
      'INVITE LINK OR CODE INVITE',
      name: 'inviteWsCode',
      desc: '',
      args: [],
    );
  }

  /// `Invites should look like`
  String get inviteLookLike {
    return Intl.message(
      'Invites should look like',
      name: 'inviteLookLike',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message(
      'or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Or Invite by Code Workspace: `
  String get inviteCodeWs {
    return Intl.message(
      'Or Invite by Code Workspace: ',
      name: 'inviteCodeWs',
      desc: '',
      args: [],
    );
  }

  /// `Workspaces's name cannot be blank`
  String get workspaceCannotBlank {
    return Intl.message(
      'Workspaces\'s name cannot be blank',
      name: 'workspaceCannotBlank',
      desc: '',
      args: [],
    );
  }

  /// `Input cannot be empty`
  String get inputCannotEmpty {
    return Intl.message(
      'Input cannot be empty',
      name: 'inputCannotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Syntax code was wrong, try again!`
  String get syntaxError {
    return Intl.message(
      'Syntax code was wrong, try again!',
      name: 'syntaxError',
      desc: '',
      args: [],
    );
  }

  /// `More unreads`
  String get moreUnread {
    return Intl.message(
      'More unreads',
      name: 'moreUnread',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `Issue created successfully`
  String get issueCreateSuccess {
    return Intl.message(
      'Issue created successfully',
      name: 'issueCreateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `sent a video.`
  String get sentAVideo {
    return Intl.message(
      'sent a video.',
      name: 'sentAVideo',
      desc: '',
      args: [],
    );
  }

  /// `sent {count} videos.`
  String sentVideos(Object count) {
    return Intl.message(
      'sent $count videos.',
      name: 'sentVideos',
      desc: '',
      args: [count],
    );
  }

  /// `sent a file.`
  String get sentAFile {
    return Intl.message(
      'sent a file.',
      name: 'sentAFile',
      desc: '',
      args: [],
    );
  }

  /// `sent {count} files.`
  String sentFiles(Object count) {
    return Intl.message(
      'sent $count files.',
      name: 'sentFiles',
      desc: '',
      args: [count],
    );
  }

  /// `sent an image.`
  String get sentAnImage {
    return Intl.message(
      'sent an image.',
      name: 'sentAnImage',
      desc: '',
      args: [],
    );
  }

  /// `sent {count} images.`
  String sentImages(Object count) {
    return Intl.message(
      'sent $count images.',
      name: 'sentImages',
      desc: '',
      args: [count],
    );
  }

  /// `sent attachments.`
  String get sentAttachments {
    return Intl.message(
      'sent attachments.',
      name: 'sentAttachments',
      desc: '',
      args: [],
    );
  }

  /// `Attachments`
  String get attachments {
    return Intl.message(
      'Attachments',
      name: 'attachments',
      desc: '',
      args: [],
    );
  }

  /// `The video call ended.`
  String get theVideoCallEnded {
    return Intl.message(
      'The video call ended.',
      name: 'theVideoCallEnded',
      desc: '',
      args: [],
    );
  }

  /// `Logged into Google Drive`
  String get loggedIntoGoogleDrive {
    return Intl.message(
      'Logged into Google Drive',
      name: 'loggedIntoGoogleDrive',
      desc: '',
      args: [],
    );
  }

  /// `Connect Google Drive`
  String get connectGoogleDrive {
    return Intl.message(
      'Connect Google Drive',
      name: 'connectGoogleDrive',
      desc: '',
      args: [],
    );
  }

  /// `Backup`
  String get backup {
    return Intl.message(
      'Backup',
      name: 'backup',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
      desc: '',
      args: [],
    );
  }

  /// `Sync by Panchat app *`
  String get syncPanchatApp {
    return Intl.message(
      'Sync by Panchat app *',
      name: 'syncPanchatApp',
      desc: '',
      args: [],
    );
  }

  /// `*Tap Sync Data and open Panchat app on your devices to get OTP code`
  String get descSyncPanchat {
    return Intl.message(
      '*Tap Sync Data and open Panchat app on your devices to get OTP code',
      name: 'descSyncPanchat',
      desc: '',
      args: [],
    );
  }

  /// `Reset device key`
  String get resetDeviceKey {
    return Intl.message(
      'Reset device key',
      name: 'resetDeviceKey',
      desc: '',
      args: [],
    );
  }

  /// `**Tap Reset Device Key to remove data from other devices. Panchat will send a Verify Code to your email/phone number`
  String get descResetDeviceKey {
    return Intl.message(
      '**Tap Reset Device Key to remove data from other devices. Panchat will send a Verify Code to your email/phone number',
      name: 'descResetDeviceKey',
      desc: '',
      args: [],
    );
  }

  /// `Please update version`
  String get pleaseUpdateVersion {
    return Intl.message(
      'Please update version',
      name: 'pleaseUpdateVersion',
      desc: '',
      args: [],
    );
  }

  /// `{statusCode} Error with status:`
  String errorWithStatus(Object statusCode) {
    return Intl.message(
      '$statusCode Error with status:',
      name: 'errorWithStatus',
      desc: '',
      args: [statusCode],
    );
  }

  /// `Mark as unread`
  String get markAsUnread {
    return Intl.message(
      'Mark as unread',
      name: 'markAsUnread',
      desc: '',
      args: [],
    );
  }

  /// `Starting up`
  String get startingUp {
    return Intl.message(
      'Starting up',
      name: 'startingUp',
      desc: '',
      args: [],
    );
  }

  /// `Nothing turned up`
  String get nothingTurnedUp {
    return Intl.message(
      'Nothing turned up',
      name: 'nothingTurnedUp',
      desc: '',
      args: [],
    );
  }

  /// `You may want to try using different keywords or checking for typos`
  String get descNothingTurnedUp {
    return Intl.message(
      'You may want to try using different keywords or checking for typos',
      name: 'descNothingTurnedUp',
      desc: '',
      args: [],
    );
  }

  /// `Type an email or phone number to invite`
  String get typeEmailOrPhoneToInvite {
    return Intl.message(
      'Type an email or phone number to invite',
      name: 'typeEmailOrPhoneToInvite',
      desc: '',
      args: [],
    );
  }

  /// `Invitation history:`
  String get invitationHistory {
    return Intl.message(
      'Invitation history:',
      name: 'invitationHistory',
      desc: '',
      args: [],
    );
  }

  /// `Sent`
  String get sent {
    return Intl.message(
      'Sent',
      name: 'sent',
      desc: '',
      args: [],
    );
  }

  /// `Please Insert KeyCode Channel`
  String get insertKeyCodeChannel {
    return Intl.message(
      'Please Insert KeyCode Channel',
      name: 'insertKeyCodeChannel',
      desc: '',
      args: [],
    );
  }

  /// `Join`
  String get join {
    return Intl.message(
      'Join',
      name: 'join',
      desc: '',
      args: [],
    );
  }

  /// `Results`
  String get results {
    return Intl.message(
      'Results',
      name: 'results',
      desc: '',
      args: [],
    );
  }

  /// `No friends to add`
  String get noFriendToAdd {
    return Intl.message(
      'No friends to add',
      name: 'noFriendToAdd',
      desc: '',
      args: [],
    );
  }

  /// `Try adding a friend using their username or email address`
  String get addFriendUsingEmail {
    return Intl.message(
      'Try adding a friend using their username or email address',
      name: 'addFriendUsingEmail',
      desc: '',
      args: [],
    );
  }

  /// `Invited`
  String get invited {
    return Intl.message(
      'Invited',
      name: 'invited',
      desc: '',
      args: [],
    );
  }

  /// `What’s up for discussion?`
  String get whatForDiscussion {
    return Intl.message(
      'What’s up for discussion?',
      name: 'whatForDiscussion',
      desc: '',
      args: [],
    );
  }

  /// `Delete member?`
  String get deleteMembers {
    return Intl.message(
      'Delete member?',
      name: 'deleteMembers',
      desc: '',
      args: [],
    );
  }

  /// `This is channel newsroom, if you remove this user from the channel it will be removed from the workspace`
  String get descDeleteNewsroom {
    return Intl.message(
      'This is channel newsroom, if you remove this user from the channel it will be removed from the workspace',
      name: 'descDeleteNewsroom',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to delete this member from channel?\nThis action cannot be undone.`
  String get desDeleteChannel {
    return Intl.message(
      'Are you sure want to delete this member from channel?\nThis action cannot be undone.',
      name: 'desDeleteChannel',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to leave channel?\nThis action cannot be undone.`
  String get descLeaveChannel {
    return Intl.message(
      'Are you sure want to leave channel?\nThis action cannot be undone.',
      name: 'descLeaveChannel',
      desc: '',
      args: [],
    );
  }

  /// `YOU RECEIVE AN INVITE TO JOIN A {type}`
  String receiveJoinChannel(Object type) {
    return Intl.message(
      'YOU RECEIVE AN INVITE TO JOIN A $type',
      name: 'receiveJoinChannel',
      desc: '',
      args: [type],
    );
  }

  /// `Create commands`
  String get createCommands {
    return Intl.message(
      'Create commands',
      name: 'createCommands',
      desc: '',
      args: [],
    );
  }

  /// `Shortcut:`
  String get shortcut {
    return Intl.message(
      'Shortcut:',
      name: 'shortcut',
      desc: '',
      args: [],
    );
  }

  /// `Request URL:`
  String get requestUrl {
    return Intl.message(
      'Request URL:',
      name: 'requestUrl',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Params Commands:`
  String get paramsCommand {
    return Intl.message(
      'Params Commands:',
      name: 'paramsCommand',
      desc: '',
      args: [],
    );
  }

  /// `Index:`
  String get index {
    return Intl.message(
      'Index:',
      name: 'index',
      desc: '',
      args: [],
    );
  }

  /// `Params:`
  String get params {
    return Intl.message(
      'Params:',
      name: 'params',
      desc: '',
      args: [],
    );
  }

  /// `Update command`
  String get updateCommand {
    return Intl.message(
      'Update command',
      name: 'updateCommand',
      desc: '',
      args: [],
    );
  }

  /// `Create command`
  String get createCommand {
    return Intl.message(
      'Create command',
      name: 'createCommand',
      desc: '',
      args: [],
    );
  }

  /// `Edit Image`
  String get editImage {
    return Intl.message(
      'Edit Image',
      name: 'editImage',
      desc: '',
      args: [],
    );
  }

  /// `Change File`
  String get changeFile {
    return Intl.message(
      'Change File',
      name: 'changeFile',
      desc: '',
      args: [],
    );
  }

  /// `Name file: `
  String get nameFile {
    return Intl.message(
      'Name file: ',
      name: 'nameFile',
      desc: '',
      args: [],
    );
  }

  /// `Preview text`
  String get previewText {
    return Intl.message(
      'Preview text',
      name: 'previewText',
      desc: '',
      args: [],
    );
  }

  /// `Sharing this message:`
  String get shareMessage {
    return Intl.message(
      'Sharing this message:',
      name: 'shareMessage',
      desc: '',
      args: [],
    );
  }

  /// `[This message was deleted.]`
  String get thisMessageDeleted {
    return Intl.message(
      '[This message was deleted.]',
      name: 'thisMessageDeleted',
      desc: '',
      args: [],
    );
  }

  /// `commented {time}`
  String commented(Object time) {
    return Intl.message(
      'commented $time',
      name: 'commented',
      desc: '',
      args: [time],
    );
  }

  /// `•  edited by`
  String get editedBy {
    return Intl.message(
      '•  edited by',
      name: 'editedBy',
      desc: '',
      args: [],
    );
  }

  /// `edited`
  String get edited {
    return Intl.message(
      'edited',
      name: 'edited',
      desc: '',
      args: [],
    );
  }

  /// `•  edited {time}`
  String editedTime(Object time) {
    return Intl.message(
      '•  edited $time',
      name: 'editedTime',
      desc: '',
      args: [time],
    );
  }

  /// `  at {time}`
  String at(Object time) {
    return Intl.message(
      '  at $time',
      name: 'at',
      desc: '',
      args: [time],
    );
  }

  /// `Show {count} more comments`
  String showMoreComments(Object count) {
    return Intl.message(
      'Show $count more comments',
      name: 'showMoreComments',
      desc: '',
      args: [count],
    );
  }

  /// `Delete this comment?`
  String get deleteComment {
    return Intl.message(
      'Delete this comment?',
      name: 'deleteComment',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Transfer`
  String get transfer {
    return Intl.message(
      'Transfer',
      name: 'transfer',
      desc: '',
      args: [],
    );
  }

  /// `There aren't any actions for you to take on {name}.`
  String cantActionsForYou(Object name) {
    return Intl.message(
      'There aren\'t any actions for you to take on $name.',
      name: 'cantActionsForYou',
      desc: '',
      args: [name],
    );
  }

  /// `Your role cannot take action.`
  String get yourRoleCannotAction {
    return Intl.message(
      'Your role cannot take action.',
      name: 'yourRoleCannotAction',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this member?`
  String get askDeleteMember {
    return Intl.message(
      'Are you sure you want to delete this member?',
      name: 'askDeleteMember',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave this workspace?`
  String get askLeaveWorkspace {
    return Intl.message(
      'Are you sure you want to leave this workspace?',
      name: 'askLeaveWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `Transfer to`
  String get transferTo {
    return Intl.message(
      'Transfer to',
      name: 'transferTo',
      desc: '',
      args: [],
    );
  }

  /// `Select member`
  String get selectMember {
    return Intl.message(
      'Select member',
      name: 'selectMember',
      desc: '',
      args: [],
    );
  }

  /// `Enter password to transfer`
  String get enterPassToTransfer {
    return Intl.message(
      'Enter password to transfer',
      name: 'enterPassToTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Roles`
  String get roles {
    return Intl.message(
      'Roles',
      name: 'roles',
      desc: '',
      args: [],
    );
  }

  /// `Set Admin`
  String get setAdmin {
    return Intl.message(
      'Set Admin',
      name: 'setAdmin',
      desc: '',
      args: [],
    );
  }

  /// `Set Editor`
  String get setEditor {
    return Intl.message(
      'Set Editor',
      name: 'setEditor',
      desc: '',
      args: [],
    );
  }

  /// `Set Member`
  String get setMember {
    return Intl.message(
      'Set Member',
      name: 'setMember',
      desc: '',
      args: [],
    );
  }

  /// `Channel Installed`
  String get channelInstalled {
    return Intl.message(
      'Channel Installed',
      name: 'channelInstalled',
      desc: '',
      args: [],
    );
  }

  /// `Commands`
  String get commands {
    return Intl.message(
      'Commands',
      name: 'commands',
      desc: '',
      args: [],
    );
  }

  /// `Time Created`
  String get timeCreated {
    return Intl.message(
      'Time Created',
      name: 'timeCreated',
      desc: '',
      args: [],
    );
  }

  /// `Add commands`
  String get addCommands {
    return Intl.message(
      'Add commands',
      name: 'addCommands',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Create custom app`
  String get createCustomApp {
    return Intl.message(
      'Create custom app',
      name: 'createCustomApp',
      desc: '',
      args: [],
    );
  }

  /// `App Name`
  String get appName {
    return Intl.message(
      'App Name',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Option`
  String get option {
    return Intl.message(
      'Option',
      name: 'option',
      desc: '',
      args: [],
    );
  }

  /// `Workspace`
  String get workspace {
    return Intl.message(
      'Workspace',
      name: 'workspace',
      desc: '',
      args: [],
    );
  }

  /// `channel`
  String get channel {
    return Intl.message(
      'channel',
      name: 'channel',
      desc: '',
      args: [],
    );
  }

  /// `Enter list title`
  String get enterListTitle {
    return Intl.message(
      'Enter list title',
      name: 'enterListTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add new list`
  String get addNewList {
    return Intl.message(
      'Add new list',
      name: 'addNewList',
      desc: '',
      args: [],
    );
  }

  /// `Add list`
  String get addList {
    return Intl.message(
      'Add list',
      name: 'addList',
      desc: '',
      args: [],
    );
  }

  /// `Create new board`
  String get createNewBoard {
    return Intl.message(
      'Create new board',
      name: 'createNewBoard',
      desc: '',
      args: [],
    );
  }

  /// `Share this message`
  String get forwardThisMessage {
    return Intl.message(
      'Share this message',
      name: 'forwardThisMessage',
      desc: '',
      args: [],
    );
  }

  /// `List channel`
  String get listChannel {
    return Intl.message(
      'List channel',
      name: 'listChannel',
      desc: '',
      args: [],
    );
  }

  /// `Search {type}`
  String searchType(Object type) {
    return Intl.message(
      'Search $type',
      name: 'searchType',
      desc: '',
      args: [type],
    );
  }

  /// `Forward message`
  String get forwardMessage {
    return Intl.message(
      'Forward message',
      name: 'forwardMessage',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Add new option`
  String get addNewOption {
    return Intl.message(
      'Add new option',
      name: 'addNewOption',
      desc: '',
      args: [],
    );
  }

  /// `Option: {name}`
  String optionName(Object name) {
    return Intl.message(
      'Option: $name',
      name: 'optionName',
      desc: '',
      args: [name],
    );
  }

  /// `complete`
  String get complete {
    return Intl.message(
      'complete',
      name: 'complete',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get tOpen {
    return Intl.message(
      'Open',
      name: 'tOpen',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get tClosed {
    return Intl.message(
      'Closed',
      name: 'tClosed',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get tClose {
    return Intl.message(
      'Close',
      name: 'tClose',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Reopen`
  String get reopen {
    return Intl.message(
      'Reopen',
      name: 'reopen',
      desc: '',
      args: [],
    );
  }

  /// `minute`
  String get minute {
    return Intl.message(
      'minute',
      name: 'minute',
      desc: '',
      args: [],
    );
  }

  /// `minutes`
  String get minutes {
    return Intl.message(
      'minutes',
      name: 'minutes',
      desc: '',
      args: [],
    );
  }

  /// `hour`
  String get hour {
    return Intl.message(
      'hour',
      name: 'hour',
      desc: '',
      args: [],
    );
  }

  /// `hours`
  String get hours {
    return Intl.message(
      'hours',
      name: 'hours',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get days {
    return Intl.message(
      'days',
      name: 'days',
      desc: '',
      args: [],
    );
  }

  /// `day`
  String get day {
    return Intl.message(
      'day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `month`
  String get month {
    return Intl.message(
      'month',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `months`
  String get months {
    return Intl.message(
      'months',
      name: 'months',
      desc: '',
      args: [],
    );
  }

  /// `year`
  String get year {
    return Intl.message(
      'year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `years`
  String get years {
    return Intl.message(
      'years',
      name: 'years',
      desc: '',
      args: [],
    );
  }

  /// `Past due by`
  String get pastDueBy {
    return Intl.message(
      'Past due by',
      name: 'pastDueBy',
      desc: '',
      args: [],
    );
  }

  /// `Due by `
  String get dueBy {
    return Intl.message(
      'Due by ',
      name: 'dueBy',
      desc: '',
      args: [],
    );
  }

  /// `Delete Milestone`
  String get deleteMilestone {
    return Intl.message(
      'Delete Milestone',
      name: 'deleteMilestone',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to delete miletsone?\nThis action cannot be undone.`
  String get descDeleteMilestone {
    return Intl.message(
      'Are you sure want to delete miletsone?\nThis action cannot be undone.',
      name: 'descDeleteMilestone',
      desc: '',
      args: [],
    );
  }

  /// `Delete Label`
  String get deleteLabel {
    return Intl.message(
      'Delete Label',
      name: 'deleteLabel',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to delete miletsone?\nThis action cannot be undone.`
  String get descDeleteLabel {
    return Intl.message(
      'Are you sure want to delete miletsone?\nThis action cannot be undone.',
      name: 'descDeleteLabel',
      desc: '',
      args: [],
    );
  }

  /// `Please select channel`
  String get pleaseSelectChannel {
    return Intl.message(
      'Please select channel',
      name: 'pleaseSelectChannel',
      desc: '',
      args: [],
    );
  }

  /// `Select Channel`
  String get selectChannel {
    return Intl.message(
      'Select Channel',
      name: 'selectChannel',
      desc: '',
      args: [],
    );
  }

  /// `Search Channel`
  String get searchChannel {
    return Intl.message(
      'Search Channel',
      name: 'searchChannel',
      desc: '',
      args: [],
    );
  }

  /// `Recent channel`
  String get recentChannel {
    return Intl.message(
      'Recent channel',
      name: 'recentChannel',
      desc: '',
      args: [],
    );
  }

  /// `opened this issue {time}.`
  String openThisIssue(Object time) {
    return Intl.message(
      'opened this issue $time.',
      name: 'openThisIssue',
      desc: '',
      args: [time],
    );
  }

  /// `_No description provided._`
  String get noDescriptionProvided {
    return Intl.message(
      '_No description provided._',
      name: 'noDescriptionProvided',
      desc: '',
      args: [],
    );
  }

  /// `New label`
  String get newLabel {
    return Intl.message(
      'New label',
      name: 'newLabel',
      desc: '',
      args: [],
    );
  }

  /// `New milestone`
  String get newMilestone {
    return Intl.message(
      'New milestone',
      name: 'newMilestone',
      desc: '',
      args: [],
    );
  }

  /// `List Archived`
  String get listArchive {
    return Intl.message(
      'List Archived',
      name: 'listArchive',
      desc: '',
      args: [],
    );
  }

  /// `Add Params Commands`
  String get addParamsCommands {
    return Intl.message(
      'Add Params Commands',
      name: 'addParamsCommands',
      desc: '',
      args: [],
    );
  }

  /// `/ Add shortcut`
  String get addShortcut {
    return Intl.message(
      '/ Add shortcut',
      name: 'addShortcut',
      desc: '',
      args: [],
    );
  }

  /// `Add text`
  String get addText {
    return Intl.message(
      'Add text',
      name: 'addText',
      desc: '',
      args: [],
    );
  }

  /// `https:// Add url`
  String get addUrl {
    return Intl.message(
      'https:// Add url',
      name: 'addUrl',
      desc: '',
      args: [],
    );
  }

  /// `List of people in the workspace`
  String get listWorkspaceMember {
    return Intl.message(
      'List of people in the workspace',
      name: 'listWorkspaceMember',
      desc: '',
      args: [],
    );
  }

  /// `{fullName} has assign you in an issue`
  String assignIssue(Object fullName) {
    return Intl.message(
      '$fullName has assign you in an issue',
      name: 'assignIssue',
      desc: '',
      args: [fullName],
    );
  }

  /// `{fullName} has unassign you in an issue`
  String unassignIssue(Object fullName) {
    return Intl.message(
      '$fullName has unassign you in an issue',
      name: 'unassignIssue',
      desc: '',
      args: [fullName],
    );
  }

  /// `{assignUser} has reopened an issue {issueauthor} created in {channelName} channel`
  String reopened(Object assignUser, Object issueauthor, Object channelName) {
    return Intl.message(
      '$assignUser has reopened an issue $issueauthor created in $channelName channel',
      name: 'reopened',
      desc: '',
      args: [assignUser, issueauthor, channelName],
    );
  }

  /// `{name} has changed avatar this group`
  String changeAvatarDm(Object name) {
    return Intl.message(
      '$name has changed avatar this group',
      name: 'changeAvatarDm',
      desc: '',
      args: [name],
    );
  }

  /// `{fullName} has invite you to {channelName} channel`
  String inviedChannel(Object fullName, Object channelName) {
    return Intl.message(
      '$fullName has invite you to $channelName channel',
      name: 'inviedChannel',
      desc: '',
      args: [fullName, channelName],
    );
  }

  /// ` Has invite you to channel`
  String get inviedChannels {
    return Intl.message(
      ' Has invite you to channel',
      name: 'inviedChannels',
      desc: '',
      args: [],
    );
  }

  /// ` {user} has invited {invitedUser}`
  String invied(Object user, Object invitedUser) {
    return Intl.message(
      ' $user has invited $invitedUser',
      name: 'invied',
      desc: '',
      args: [user, invitedUser],
    );
  }

  /// `{assignUser} has closed an issue {issueauthor} created in {channelName} channel`
  String closeIssues(
      Object assignUser, Object issueauthor, Object channelName) {
    return Intl.message(
      '$assignUser has closed an issue $issueauthor created in $channelName channel',
      name: 'closeIssues',
      desc: '',
      args: [assignUser, issueauthor, channelName],
    );
  }

  /// `{assignUser} has closed an issue you has been assign in {channelName} channel`
  String closeIssues1(Object assignUser, Object channelName) {
    return Intl.message(
      '$assignUser has closed an issue you has been assign in $channelName channel',
      name: 'closeIssues1',
      desc: '',
      args: [assignUser, channelName],
    );
  }

  /// `{assignUser} has reopened an issue you has been assign in {channelName} channel`
  String reopened1(Object assignUser, Object channelName) {
    return Intl.message(
      '$assignUser has reopened an issue you has been assign in $channelName channel',
      name: 'reopened1',
      desc: '',
      args: [assignUser, channelName],
    );
  }

  /// `{fullName} has invite you to {workspaceName} workspace`
  String inviedWorkSpace(Object fullName, Object workspaceName) {
    return Intl.message(
      '$fullName has invite you to $workspaceName workspace',
      name: 'inviedWorkSpace',
      desc: '',
      args: [fullName, workspaceName],
    );
  }

  /// `Delete Message`
  String get deleteMessages {
    return Intl.message(
      'Delete Message',
      name: 'deleteMessages',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this message?`
  String get deleteThisMessages {
    return Intl.message(
      'Are you sure you want to delete this message?',
      name: 'deleteThisMessages',
      desc: '',
      args: [],
    );
  }

  /// `Delete for me`
  String get deleteForMe {
    return Intl.message(
      'Delete for me',
      name: 'deleteForMe',
      desc: '',
      args: [],
    );
  }

  /// `Delete for everyone`
  String get deleteForEveryone {
    return Intl.message(
      'Delete for everyone',
      name: 'deleteForEveryone',
      desc: '',
      args: [],
    );
  }

  /// `{character} Sticker`
  String sticker(Object character) {
    return Intl.message(
      '$character Sticker',
      name: 'sticker',
      desc: '',
      args: [character],
    );
  }

  /// `Sent a sticker`
  String get sticker1 {
    return Intl.message(
      'Sent a sticker',
      name: 'sticker1',
      desc: '',
      args: [],
    );
  }

  /// `Sent a shared message`
  String get share {
    return Intl.message(
      'Sent a shared message',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Replied to a message`
  String get reply {
    return Intl.message(
      'Replied to a message',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get replyThread {
    return Intl.message(
      'Reply',
      name: 'replyThread',
      desc: '',
      args: [],
    );
  }

  /// `This poll is disabled`
  String get pollIsDisabled {
    return Intl.message(
      'This poll is disabled',
      name: 'pollIsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Has left this conversation`
  String get leaveDirect {
    return Intl.message(
      'Has left this conversation',
      name: 'leaveDirect',
      desc: '',
      args: [],
    );
  }

  /// `Set Roles`
  String get setrole {
    return Intl.message(
      'Set Roles',
      name: 'setrole',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get Notification {
    return Intl.message(
      'Notification',
      name: 'Notification',
      desc: '',
      args: [],
    );
  }

  /// `Leave conversation`
  String get leaveConversation {
    return Intl.message(
      'Leave conversation',
      name: 'leaveConversation',
      desc: '',
      args: [],
    );
  }

  /// `Type a message`
  String get typeAMessage {
    return Intl.message(
      'Type a message',
      name: 'typeAMessage',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message(
      'Yesterday',
      name: 'yesterday',
      desc: '',
      args: [],
    );
  }

  /// `Request`
  String get request {
    return Intl.message(
      'Request',
      name: 'request',
      desc: '',
      args: [],
    );
  }

  /// `minutes ago`
  String get minutesAgo {
    return Intl.message(
      'minutes ago',
      name: 'minutesAgo',
      desc: '',
      args: [],
    );
  }

  /// `No items have been pinned yet!`
  String get noItems {
    return Intl.message(
      'No items have been pinned yet!',
      name: 'noItems',
      desc: '',
      args: [],
    );
  }

  /// `Admins`
  String get admins {
    return Intl.message(
      'Admins',
      name: 'admins',
      desc: '',
      args: [],
    );
  }

  /// `Editor`
  String get editors {
    return Intl.message(
      'Editor',
      name: 'editors',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get owner {
    return Intl.message(
      'Owner',
      name: 'owner',
      desc: '',
      args: [],
    );
  }

  /// `View all`
  String get viewAll {
    return Intl.message(
      'View all',
      name: 'viewAll',
      desc: '',
      args: [],
    );
  }

  /// `Unarchive Channel`
  String get unarchiveChannel {
    return Intl.message(
      'Unarchive Channel',
      name: 'unarchiveChannel',
      desc: '',
      args: [],
    );
  }

  /// `PENDING REQUEST`
  String get pendingRequest {
    return Intl.message(
      'PENDING REQUEST',
      name: 'pendingRequest',
      desc: '',
      args: [],
    );
  }

  /// `Workspace details`
  String get workspaceDetails {
    return Intl.message(
      'Workspace details',
      name: 'workspaceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Invite member`
  String get inviteMember {
    return Intl.message(
      'Invite member',
      name: 'inviteMember',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `MESSAGE NAME`
  String get messageName {
    return Intl.message(
      'MESSAGE NAME',
      name: 'messageName',
      desc: '',
      args: [],
    );
  }

  /// `Report direct message`
  String get reportDirectMessage {
    return Intl.message(
      'Report direct message',
      name: 'reportDirectMessage',
      desc: '',
      args: [],
    );
  }

  /// `Hide direct message`
  String get hideDirectMessage {
    return Intl.message(
      'Hide direct message',
      name: 'hideDirectMessage',
      desc: '',
      args: [],
    );
  }

  /// `Delete direct message`
  String get deleteDirectMessage {
    return Intl.message(
      'Delete direct message',
      name: 'deleteDirectMessage',
      desc: '',
      args: [],
    );
  }

  /// `Unpin message`
  String get unpinMessage {
    return Intl.message(
      'Unpin message',
      name: 'unpinMessage',
      desc: '',
      args: [],
    );
  }

  /// `Create issue`
  String get createIssue {
    return Intl.message(
      'Create issue',
      name: 'createIssue',
      desc: '',
      args: [],
    );
  }

  /// `Copy text`
  String get copyText {
    return Intl.message(
      'Copy text',
      name: 'copyText',
      desc: '',
      args: [],
    );
  }

  /// `Reply in thread`
  String get replyInThread {
    return Intl.message(
      'Reply in thread',
      name: 'replyInThread',
      desc: '',
      args: [],
    );
  }

  /// `Reply message`
  String get replyThisMessage {
    return Intl.message(
      'Reply message',
      name: 'replyThisMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit message`
  String get editMessage {
    return Intl.message(
      'Edit message',
      name: 'editMessage',
      desc: '',
      args: [],
    );
  }

  /// `Channels list`
  String get channelsList {
    return Intl.message(
      'Channels list',
      name: 'channelsList',
      desc: '',
      args: [],
    );
  }

  /// `Channel Settings`
  String get channelSettings {
    return Intl.message(
      'Channel Settings',
      name: 'channelSettings',
      desc: '',
      args: [],
    );
  }

  /// `USER MANAGEMENT`
  String get userManagement {
    return Intl.message(
      'USER MANAGEMENT',
      name: 'userManagement',
      desc: '',
      args: [],
    );
  }

  /// `Private Channel`
  String get privateChannel {
    return Intl.message(
      'Private Channel',
      name: 'privateChannel',
      desc: '',
      args: [],
    );
  }

  /// `Public Channel`
  String get publicChannel {
    return Intl.message(
      'Public Channel',
      name: 'publicChannel',
      desc: '',
      args: [],
    );
  }

  /// `BOARDS`
  String get boards {
    return Intl.message(
      'BOARDS',
      name: 'boards',
      desc: '',
      args: [],
    );
  }

  /// `New boards`
  String get newBoards {
    return Intl.message(
      'New boards',
      name: 'newBoards',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Checklists`
  String get checkList {
    return Intl.message(
      'Checklists',
      name: 'checkList',
      desc: '',
      args: [],
    );
  }

  /// `Priority`
  String get priority {
    return Intl.message(
      'Priority',
      name: 'priority',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `No label`
  String get noLabel {
    return Intl.message(
      'No label',
      name: 'noLabel',
      desc: '',
      args: [],
    );
  }

  /// `No attachment`
  String get noAttachment {
    return Intl.message(
      'No attachment',
      name: 'noAttachment',
      desc: '',
      args: [],
    );
  }

  /// `No checkList`
  String get noCheckList {
    return Intl.message(
      'No checkList',
      name: 'noCheckList',
      desc: '',
      args: [],
    );
  }

  /// `Add more detailed`
  String get addMoreDetailed {
    return Intl.message(
      'Add more detailed',
      name: 'addMoreDetailed',
      desc: '',
      args: [],
    );
  }

  /// `No members`
  String get noMembers {
    return Intl.message(
      'No members',
      name: 'noMembers',
      desc: '',
      args: [],
    );
  }

  /// `Due date`
  String get dueDates {
    return Intl.message(
      'Due date',
      name: 'dueDates',
      desc: '',
      args: [],
    );
  }

  /// `No due date`
  String get noDueDate {
    return Intl.message(
      'No due date',
      name: 'noDueDate',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message(
      'None',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  /// `Urgent`
  String get urgent {
    return Intl.message(
      'Urgent',
      name: 'urgent',
      desc: '',
      args: [],
    );
  }

  /// `Hight`
  String get hight {
    return Intl.message(
      'Hight',
      name: 'hight',
      desc: '',
      args: [],
    );
  }

  /// `Medium`
  String get medium {
    return Intl.message(
      'Medium',
      name: 'medium',
      desc: '',
      args: [],
    );
  }

  /// `Low`
  String get low {
    return Intl.message(
      'Low',
      name: 'low',
      desc: '',
      args: [],
    );
  }

  /// `Invite Only`
  String get inviteOnly {
    return Intl.message(
      'Invite Only',
      name: 'inviteOnly',
      desc: '',
      args: [],
    );
  }

  /// `Group name`
  String get groupName {
    return Intl.message(
      'Group name',
      name: 'groupName',
      desc: '',
      args: [],
    );
  }

  /// `All friends`
  String get allFriends {
    return Intl.message(
      'All friends',
      name: 'allFriends',
      desc: '',
      args: [],
    );
  }

  /// `Pin message`
  String get pinMessage {
    return Intl.message(
      'Pin message',
      name: 'pinMessage',
      desc: '',
      args: [],
    );
  }

  /// `by`
  String get by {
    return Intl.message(
      'by',
      name: 'by',
      desc: '',
      args: [],
    );
  }

  /// `Share message`
  String get shareMessages {
    return Intl.message(
      'Share message',
      name: 'shareMessages',
      desc: '',
      args: [],
    );
  }

  /// `New checklist`
  String get newChecklist {
    return Intl.message(
      'New checklist',
      name: 'newChecklist',
      desc: '',
      args: [],
    );
  }

  /// `Add a new attachment`
  String get addANewAtt {
    return Intl.message(
      'Add a new attachment',
      name: 'addANewAtt',
      desc: '',
      args: [],
    );
  }

  /// `Archived items`
  String get archivedItems {
    return Intl.message(
      'Archived items',
      name: 'archivedItems',
      desc: '',
      args: [],
    );
  }

  /// `Also send to channel`
  String get alsoSendToChannel {
    return Intl.message(
      'Also send to channel',
      name: 'alsoSendToChannel',
      desc: '',
      args: [],
    );
  }

  /// `Expand`
  String get expand {
    return Intl.message(
      'Expand',
      name: 'expand',
      desc: '',
      args: [],
    );
  }

  /// `Collapse`
  String get collapse {
    return Intl.message(
      'Collapse',
      name: 'collapse',
      desc: '',
      args: [],
    );
  }

  /// `View whole file`
  String get viewWholeFile {
    return Intl.message(
      'View whole file',
      name: 'viewWholeFile',
      desc: '',
      args: [],
    );
  }

  /// `Download file`
  String get downloadFile {
    return Intl.message(
      'Download file',
      name: 'downloadFile',
      desc: '',
      args: [],
    );
  }

  /// `Replied to thread`
  String get repliedToThread {
    return Intl.message(
      'Replied to thread',
      name: 'repliedToThread',
      desc: '',
      args: [],
    );
  }

  /// `Last reply at`
  String get lastReplyAt {
    return Intl.message(
      'Last reply at',
      name: 'lastReplyAt',
      desc: '',
      args: [],
    );
  }

  /// `replies`
  String get replies {
    return Intl.message(
      'replies',
      name: 'replies',
      desc: '',
      args: [],
    );
  }

  /// `NEW`
  String get news {
    return Intl.message(
      'NEW',
      name: 'news',
      desc: '',
      args: [],
    );
  }

  /// `has`
  String get hass {
    return Intl.message(
      'has',
      name: 'hass',
      desc: '',
      args: [],
    );
  }

  /// `assign`
  String get assign {
    return Intl.message(
      'assign',
      name: 'assign',
      desc: '',
      args: [],
    );
  }

  /// `unassign`
  String get unassign {
    return Intl.message(
      'unassign',
      name: 'unassign',
      desc: '',
      args: [],
    );
  }

  /// `Review Issue`
  String get reviewIssue {
    return Intl.message(
      'Review Issue',
      name: 'reviewIssue',
      desc: '',
      args: [],
    );
  }

  /// `you in an issue in`
  String get youInAnIssueIn {
    return Intl.message(
      'you in an issue in',
      name: 'youInAnIssueIn',
      desc: '',
      args: [],
    );
  }

  /// `has invite you to`
  String get hasInviteYouTo {
    return Intl.message(
      'has invite you to',
      name: 'hasInviteYouTo',
      desc: '',
      args: [],
    );
  }

  /// `an issue `
  String get anIssue {
    return Intl.message(
      'an issue ',
      name: 'anIssue',
      desc: '',
      args: [],
    );
  }

  /// `an issue you has been assign in`
  String get anIssueYouHasBeenAssignIn {
    return Intl.message(
      'an issue you has been assign in',
      name: 'anIssueYouHasBeenAssignIn',
      desc: '',
      args: [],
    );
  }

  /// `created in`
  String get createdIn {
    return Intl.message(
      'created in',
      name: 'createdIn',
      desc: '',
      args: [],
    );
  }

  /// `Discard`
  String get discard {
    return Intl.message(
      'Discard',
      name: 'discard',
      desc: '',
      args: [],
    );
  }

  /// `Discarded`
  String get discarded {
    return Intl.message(
      'Discarded',
      name: 'discarded',
      desc: '',
      args: [],
    );
  }

  /// `A new device`
  String get aNewDevice {
    return Intl.message(
      'A new device',
      name: 'aNewDevice',
      desc: '',
      args: [],
    );
  }

  /// `request sync data`
  String get requestSyncData {
    return Intl.message(
      'request sync data',
      name: 'requestSyncData',
      desc: '',
      args: [],
    );
  }

  /// `Device id`
  String get deviceId {
    return Intl.message(
      'Device id',
      name: 'deviceId',
      desc: '',
      args: [],
    );
  }

  /// `Request time`
  String get requestTime {
    return Intl.message(
      'Request time',
      name: 'requestTime',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Issues with no milestone`
  String get issuesWithNoMilestone {
    return Intl.message(
      'Issues with no milestone',
      name: 'issuesWithNoMilestone',
      desc: '',
      args: [],
    );
  }

  /// `Invite your friend`
  String get inviteYourFriend {
    return Intl.message(
      'Invite your friend',
      name: 'inviteYourFriend',
      desc: '',
      args: [],
    );
  }

  /// ` has joined the channel by invitation code`
  String get hasJoinedTheChannelByCode {
    return Intl.message(
      ' has joined the channel by invitation code',
      name: 'hasJoinedTheChannelByCode',
      desc: '',
      args: [],
    );
  }

  /// ` has invited `
  String get hasInvited {
    return Intl.message(
      ' has invited ',
      name: 'hasInvited',
      desc: '',
      args: [],
    );
  }

  /// ` to channel`
  String get toChannel {
    return Intl.message(
      ' to channel',
      name: 'toChannel',
      desc: '',
      args: [],
    );
  }

  /// `to this conversation`
  String get toThisConversation {
    return Intl.message(
      'to this conversation',
      name: 'toThisConversation',
      desc: '',
      args: [],
    );
  }

  /// `has changed`
  String get hasChanged {
    return Intl.message(
      'has changed',
      name: 'hasChanged',
      desc: '',
      args: [],
    );
  }

  /// `this group `
  String get thisGroup {
    return Intl.message(
      'this group ',
      name: 'thisGroup',
      desc: '',
      args: [],
    );
  }

  /// `has left `
  String get hasLeft {
    return Intl.message(
      'has left ',
      name: 'hasLeft',
      desc: '',
      args: [],
    );
  }

  /// `this conversation`
  String get thisConversation {
    return Intl.message(
      'this conversation',
      name: 'thisConversation',
      desc: '',
      args: [],
    );
  }

  /// `has left the channel`
  String get hasLeftTheChannel {
    return Intl.message(
      'has left the channel',
      name: 'hasLeftTheChannel',
      desc: '',
      args: [],
    );
  }

  /// ` was kicked from this channel`
  String get wasKickedFromThisChannel {
    return Intl.message(
      ' was kicked from this channel',
      name: 'wasKickedFromThisChannel',
      desc: '',
      args: [],
    );
  }

  /// `has changed`
  String get hasChangedChannelTopicTo {
    return Intl.message(
      'has changed',
      name: 'hasChangedChannelTopicTo',
      desc: '',
      args: [],
    );
  }

  /// `has changed channel name to `
  String get hasChangedChannelNameTo {
    return Intl.message(
      'has changed channel name to ',
      name: 'hasChangedChannelNameTo',
      desc: '',
      args: [],
    );
  }

  /// `has changed group name to `
  String get hasChangedDMNameTo {
    return Intl.message(
      'has changed group name to ',
      name: 'hasChangedDMNameTo',
      desc: '',
      args: [],
    );
  }

  /// `has changed channel`
  String get hasChangedChannel {
    return Intl.message(
      'has changed channel',
      name: 'hasChangedChannel',
      desc: '',
      args: [],
    );
  }

  /// `this channel`
  String get thisChannel {
    return Intl.message(
      'this channel',
      name: 'thisChannel',
      desc: '',
      args: [],
    );
  }

  /// `has changed channel workflow to `
  String get hasChangedChannelWorkflowTo {
    return Intl.message(
      'has changed channel workflow to ',
      name: 'hasChangedChannelWorkflowTo',
      desc: '',
      args: [],
    );
  }

  /// `Kanban mode`
  String get kanbanMode {
    return Intl.message(
      'Kanban mode',
      name: 'kanbanMode',
      desc: '',
      args: [],
    );
  }

  /// `Dev mode`
  String get devMode {
    return Intl.message(
      'Dev mode',
      name: 'devMode',
      desc: '',
      args: [],
    );
  }

  /// `archived`
  String get archived {
    return Intl.message(
      'archived',
      name: 'archived',
      desc: '',
      args: [],
    );
  }

  /// `unarchived`
  String get unarchived {
    return Intl.message(
      'unarchived',
      name: 'unarchived',
      desc: '',
      args: [],
    );
  }

  /// `at`
  String get ats {
    return Intl.message(
      'at',
      name: 'ats',
      desc: '',
      args: [],
    );
  }

  /// `public`
  String get public {
    return Intl.message(
      'public',
      name: 'public',
      desc: '',
      args: [],
    );
  }

  /// `to`
  String get to {
    return Intl.message(
      'to',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `private`
  String get privates {
    return Intl.message(
      'private',
      name: 'privates',
      desc: '',
      args: [],
    );
  }

  /// `Recent Searches`
  String get recentSearches {
    return Intl.message(
      'Recent Searches',
      name: 'recentSearches',
      desc: '',
      args: [],
    );
  }

  /// `Add Comment`
  String get addComment {
    return Intl.message(
      'Add Comment',
      name: 'addComment',
      desc: '',
      args: [],
    );
  }

  /// `issue Details`
  String get issueDetails {
    return Intl.message(
      'issue Details',
      name: 'issueDetails',
      desc: '',
      args: [],
    );
  }

  /// `opened this issue`
  String get openedThisIssue {
    return Intl.message(
      'opened this issue',
      name: 'openedThisIssue',
      desc: '',
      args: [],
    );
  }

  /// `Create Poll`
  String get createPoll {
    return Intl.message(
      'Create Poll',
      name: 'createPoll',
      desc: '',
      args: [],
    );
  }

  /// `Add an option`
  String get addAnOption {
    return Intl.message(
      'Add an option',
      name: 'addAnOption',
      desc: '',
      args: [],
    );
  }

  /// `What's your poll about?`
  String get whatYourPollAbout {
    return Intl.message(
      'What\'s your poll about?',
      name: 'whatYourPollAbout',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get deleteAccount {
    return Intl.message(
      'Delete account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Backup DM`
  String get backupDM {
    return Intl.message(
      'Backup DM',
      name: 'backupDM',
      desc: '',
      args: [],
    );
  }

  /// `Restore DM`
  String get restoreDM {
    return Intl.message(
      'Restore DM',
      name: 'restoreDM',
      desc: '',
      args: [],
    );
  }

  /// `Storage direct message`
  String get StorageDirectDessage {
    return Intl.message(
      'Storage direct message',
      name: 'StorageDirectDessage',
      desc: '',
      args: [],
    );
  }

  /// `other`
  String get other {
    return Intl.message(
      'other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `mobile`
  String get mobile {
    return Intl.message(
      'mobile',
      name: 'mobile',
      desc: '',
      args: [],
    );
  }

  /// `mobile data`
  String get mobileData {
    return Intl.message(
      'mobile data',
      name: 'mobileData',
      desc: '',
      args: [],
    );
  }

  /// `When using`
  String get whenUsing {
    return Intl.message(
      'When using',
      name: 'whenUsing',
      desc: '',
      args: [],
    );
  }

  /// `No selected`
  String get noSelected {
    return Intl.message(
      'No selected',
      name: 'noSelected',
      desc: '',
      args: [],
    );
  }

  /// `Media auto-download`
  String get MediaAutoDownload {
    return Intl.message(
      'Media auto-download',
      name: 'MediaAutoDownload',
      desc: '',
      args: [],
    );
  }

  /// `Profile Edit`
  String get profileEdit {
    return Intl.message(
      'Profile Edit',
      name: 'profileEdit',
      desc: '',
      args: [],
    );
  }

  /// `User name`
  String get userName {
    return Intl.message(
      'User name',
      name: 'userName',
      desc: '',
      args: [],
    );
  }

  /// `Nearby Scan`
  String get nearbyScan {
    return Intl.message(
      'Nearby Scan',
      name: 'nearbyScan',
      desc: '',
      args: [],
    );
  }

  /// `Send Friend Request`
  String get sendFriendRequest {
    return Intl.message(
      'Send Friend Request',
      name: 'sendFriendRequest',
      desc: '',
      args: [],
    );
  }

  /// `You will need both their username and a tag. Keep in mind that username is case sensitive.`
  String get youWillNeedBoth {
    return Intl.message(
      'You will need both their username and a tag. Keep in mind that username is case sensitive.',
      name: 'youWillNeedBoth',
      desc: '',
      args: [],
    );
  }

  /// `* Your username and tag is `
  String get yourUsernameAndTag {
    return Intl.message(
      '* Your username and tag is ',
      name: 'yourUsernameAndTag',
      desc: '',
      args: [],
    );
  }

  /// `Add your friend on Pancake`
  String get addYourFriendPancake {
    return Intl.message(
      'Add your friend on Pancake',
      name: 'addYourFriendPancake',
      desc: '',
      args: [],
    );
  }

  /// `opened`
  String get opened {
    return Intl.message(
      'opened',
      name: 'opened',
      desc: '',
      args: [],
    );
  }

  /// `Download attachment`
  String get downloadAttachment {
    return Intl.message(
      'Download attachment',
      name: 'downloadAttachment',
      desc: '',
      args: [],
    );
  }

  /// `Do you want  to download`
  String get doYouWantToDownload {
    return Intl.message(
      'Do you want  to download',
      name: 'doYouWantToDownload',
      desc: '',
      args: [],
    );
  }

  /// `Start downloading`
  String get startDownloading {
    return Intl.message(
      'Start downloading',
      name: 'startDownloading',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `New Card`
  String get newCard {
    return Intl.message(
      'New Card',
      name: 'newCard',
      desc: '',
      args: [],
    );
  }

  /// `New List`
  String get newList {
    return Intl.message(
      'New List',
      name: 'newList',
      desc: '',
      args: [],
    );
  }

  /// `Name List`
  String get nameList {
    return Intl.message(
      'Name List',
      name: 'nameList',
      desc: '',
      args: [],
    );
  }

  /// `Create board`
  String get createBoard {
    return Intl.message(
      'Create board',
      name: 'createBoard',
      desc: '',
      args: [],
    );
  }

  /// `Name Board`
  String get nameBoard {
    return Intl.message(
      'Name Board',
      name: 'nameBoard',
      desc: '',
      args: [],
    );
  }

  /// `Messages and calls in this chat will be encrypted end-to-end. Only participants could read or listen to them.`
  String get messagesAndCallsInThisChatWill {
    return Intl.message(
      'Messages and calls in this chat will be encrypted end-to-end. Only participants could read or listen to them.',
      name: 'messagesAndCallsInThisChatWill',
      desc: '',
      args: [],
    );
  }

  /// `reply`
  String get replys {
    return Intl.message(
      'reply',
      name: 'replys',
      desc: '',
      args: [],
    );
  }

  /// `Direct message details`
  String get directMessageDetails {
    return Intl.message(
      'Direct message details',
      name: 'directMessageDetails',
      desc: '',
      args: [],
    );
  }

  /// `replied to a thread : `
  String get repliedToAThread {
    return Intl.message(
      'replied to a thread : ',
      name: 'repliedToAThread',
      desc: '',
      args: [],
    );
  }

  /// `Archive`
  String get archive {
    return Intl.message(
      'Archive',
      name: 'archive',
      desc: '',
      args: [],
    );
  }

  /// `Switch to cards`
  String get switchToCards {
    return Intl.message(
      'Switch to cards',
      name: 'switchToCards',
      desc: '',
      args: [],
    );
  }

  /// `Switch to lists`
  String get switchToLists {
    return Intl.message(
      'Switch to lists',
      name: 'switchToLists',
      desc: '',
      args: [],
    );
  }

  /// `Search archive`
  String get searchArchive {
    return Intl.message(
      'Search archive',
      name: 'searchArchive',
      desc: '',
      args: [],
    );
  }

  /// `Send to board`
  String get sendToBoard {
    return Intl.message(
      'Send to board',
      name: 'sendToBoard',
      desc: '',
      args: [],
    );
  }

  /// `Create new list`
  String get createNewList {
    return Intl.message(
      'Create new list',
      name: 'createNewList',
      desc: '',
      args: [],
    );
  }

  /// `Enter card title`
  String get enterCardTitle {
    return Intl.message(
      'Enter card title',
      name: 'enterCardTitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to archive this list.`
  String get doYouWantToArchiveThisList {
    return Intl.message(
      'Do you want to archive this list.',
      name: 'doYouWantToArchiveThisList',
      desc: '',
      args: [],
    );
  }

  /// `No milestone`
  String get noMilestone {
    return Intl.message(
      'No milestone',
      name: 'noMilestone',
      desc: '',
      args: [],
    );
  }

  /// `None yet`
  String get noneYet {
    return Intl.message(
      'None yet',
      name: 'noneYet',
      desc: '',
      args: [],
    );
  }

  /// `No one-assign yourself`
  String get noOneAssignYourself {
    return Intl.message(
      'No one-assign yourself',
      name: 'noOneAssignYourself',
      desc: '',
      args: [],
    );
  }

  /// `commented`
  String get Commented {
    return Intl.message(
      'commented',
      name: 'Commented',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load image`
  String get failedToLoadImage {
    return Intl.message(
      'Failed to load image',
      name: 'failedToLoadImage',
      desc: '',
      args: [],
    );
  }

  /// `Create new label`
  String get createNewLabel {
    return Intl.message(
      'Create new label',
      name: 'createNewLabel',
      desc: '',
      args: [],
    );
  }

  /// `Closed`
  String get Closed {
    return Intl.message(
      'Closed',
      name: 'Closed',
      desc: '',
      args: [],
    );
  }

  /// `Create new Milestone`
  String get createNewMilestone {
    return Intl.message(
      'Create new Milestone',
      name: 'createNewMilestone',
      desc: '',
      args: [],
    );
  }

  /// `Create a new issue`
  String get createANewIssue {
    return Intl.message(
      'Create a new issue',
      name: 'createANewIssue',
      desc: '',
      args: [],
    );
  }

  /// `What's up for discussion?`
  String get whatUpForDiscussion {
    return Intl.message(
      'What\'s up for discussion?',
      name: 'whatUpForDiscussion',
      desc: '',
      args: [],
    );
  }

  /// `Created`
  String get created {
    return Intl.message(
      'Created',
      name: 'created',
      desc: '',
      args: [],
    );
  }

  /// `This is the start of`
  String get thisIsTheStartOf {
    return Intl.message(
      'This is the start of',
      name: 'thisIsTheStartOf',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to`
  String get welcomeTo {
    return Intl.message(
      'Welcome to',
      name: 'welcomeTo',
      desc: '',
      args: [],
    );
  }

  /// `You do not have sufficient permissions to perform the operation`
  String get youDoNotHaveSufficient {
    return Intl.message(
      'You do not have sufficient permissions to perform the operation',
      name: 'youDoNotHaveSufficient',
      desc: '',
      args: [],
    );
  }

  /// `Created by message`
  String get createdByMessage {
    return Intl.message(
      'Created by message',
      name: 'createdByMessage',
      desc: '',
      args: [],
    );
  }

  /// `Leave a description`
  String get leaveADescription {
    return Intl.message(
      'Leave a description',
      name: 'leaveADescription',
      desc: '',
      args: [],
    );
  }

  /// `Title cannot be empty`
  String get titleCannotBeEmpty {
    return Intl.message(
      'Title cannot be empty',
      name: 'titleCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Add app to channel`
  String get addAppToChannel {
    return Intl.message(
      'Add app to channel',
      name: 'addAppToChannel',
      desc: '',
      args: [],
    );
  }

  /// `App lists`
  String get appLists {
    return Intl.message(
      'App lists',
      name: 'appLists',
      desc: '',
      args: [],
    );
  }

  /// `Edit workspace name`
  String get editWorkspaceName {
    return Intl.message(
      'Edit workspace name',
      name: 'editWorkspaceName',
      desc: '',
      args: [],
    );
  }

  /// `View message`
  String get viewMessage {
    return Intl.message(
      'View message',
      name: 'viewMessage',
      desc: '',
      args: [],
    );
  }

  /// `Posted in`
  String get postedIn {
    return Intl.message(
      'Posted in',
      name: 'postedIn',
      desc: '',
      args: [],
    );
  }

  /// `Replied to`
  String get repliedTo {
    return Intl.message(
      'Replied to',
      name: 'repliedTo',
      desc: '',
      args: [],
    );
  }

  /// `[This message was deleted.]`
  String get thisMessageWasDeleted {
    return Intl.message(
      '[This message was deleted.]',
      name: 'thisMessageWasDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get signIn {
    return Intl.message(
      'Sign in',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Welcome!`
  String get welcome {
    return Intl.message(
      'Welcome!',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `We're so excited to see you`
  String get weSoExcitedToSeeYou {
    return Intl.message(
      'We\'re so excited to see you',
      name: 'weSoExcitedToSeeYou',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Remember me`
  String get rememberMe {
    return Intl.message(
      'Remember me',
      name: 'rememberMe',
      desc: '',
      args: [],
    );
  }

  /// `Not registered yet`
  String get notRegisteredYet {
    return Intl.message(
      'Not registered yet',
      name: 'notRegisteredYet',
      desc: '',
      args: [],
    );
  }

  /// `Create an Account`
  String get createAnAccount {
    return Intl.message(
      'Create an Account',
      name: 'createAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account`
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `I agree to the Terms of service and Privacy policy`
  String get iAgreeToTheTerms {
    return Intl.message(
      'I agree to the Terms of service and Privacy policy',
      name: 'iAgreeToTheTerms',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Enter your informations below`
  String get enterYourInformationsBelow {
    return Intl.message(
      'Enter your informations below',
      name: 'enterYourInformationsBelow',
      desc: '',
      args: [],
    );
  }

  /// `Confirm password`
  String get confirmPassword {
    return Intl.message(
      'Confirm password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `First name`
  String get firstName {
    return Intl.message(
      'First name',
      name: 'firstName',
      desc: '',
      args: [],
    );
  }

  /// `Last name`
  String get lastName {
    return Intl.message(
      'Last name',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }

  /// `Your email/phone`
  String get yourEmailPhone {
    return Intl.message(
      'Your email/phone',
      name: 'yourEmailPhone',
      desc: '',
      args: [],
    );
  }

  /// `Not set`
  String get notSet {
    return Intl.message(
      'Not set',
      name: 'notSet',
      desc: '',
      args: [],
    );
  }

  /// `Time create`
  String get timeCreate {
    return Intl.message(
      'Time create',
      name: 'timeCreate',
      desc: '',
      args: [],
    );
  }

  /// `Search discussions, directories, data, and more`
  String get SearchDiscussionsDirectories {
    return Intl.message(
      'Search discussions, directories, data, and more',
      name: 'SearchDiscussionsDirectories',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message(
      'From',
      name: 'from',
      desc: '',
      args: [],
    );
  }

  /// `In`
  String get trong {
    return Intl.message(
      'In',
      name: 'trong',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `You can’t undo this action`
  String get youCanUndoThisAction {
    return Intl.message(
      'You can’t undo this action',
      name: 'youCanUndoThisAction',
      desc: '',
      args: [],
    );
  }

  /// `labels Name`
  String get labelsName {
    return Intl.message(
      'labels Name',
      name: 'labelsName',
      desc: '',
      args: [],
    );
  }

  /// `Milestone title`
  String get milestoneTitle {
    return Intl.message(
      'Milestone title',
      name: 'milestoneTitle',
      desc: '',
      args: [],
    );
  }

  /// `You'll receive a 4 digit code to verify`
  String get enterYourCodeOnOtherDevices {
    return Intl.message(
      'You\'ll receive a 4 digit code to verify',
      name: 'enterYourCodeOnOtherDevices',
      desc: '',
      args: [],
    );
  }

  /// `An message has been send with a code to`
  String get anMessageHasBeenSend {
    return Intl.message(
      'An message has been send with a code to',
      name: 'anMessageHasBeenSend',
      desc: '',
      args: [],
    );
  }

  /// `to reset your device`
  String get toResetYourDevice {
    return Intl.message(
      'to reset your device',
      name: 'toResetYourDevice',
      desc: '',
      args: [],
    );
  }

  /// `ENTER YOUR CODE`
  String get enterYourCode {
    return Intl.message(
      'ENTER YOUR CODE',
      name: 'enterYourCode',
      desc: '',
      args: [],
    );
  }

  /// ` Sync data`
  String get syncData {
    return Intl.message(
      ' Sync data',
      name: 'syncData',
      desc: '',
      args: [],
    );
  }

  /// `alert`
  String get alert {
    return Intl.message(
      'alert',
      name: 'alert',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to delete your account?`
  String get doYouWantToDeleteYourAccount {
    return Intl.message(
      'Do you want to delete your account?',
      name: 'doYouWantToDeleteYourAccount',
      desc: '',
      args: [],
    );
  }

  /// `connecting`
  String get connecting {
    return Intl.message(
      'connecting',
      name: 'connecting',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get connected {
    return Intl.message(
      'Connected',
      name: 'connected',
      desc: '',
      args: [],
    );
  }

  /// `Are you want to`
  String get areYouWantTo {
    return Intl.message(
      'Are you want to',
      name: 'areYouWantTo',
      desc: '',
      args: [],
    );
  }

  /// `now`
  String get now {
    return Intl.message(
      'now',
      name: 'now',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get darkMode {
    return Intl.message(
      'Dark mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Light mode`
  String get lightMode {
    return Intl.message(
      'Light mode',
      name: 'lightMode',
      desc: '',
      args: [],
    );
  }

  /// `Logout this device`
  String get logoutThisDevice {
    return Intl.message(
      'Logout this device',
      name: 'logoutThisDevice',
      desc: '',
      args: [],
    );
  }

  /// `Overdue`
  String get overdue {
    return Intl.message(
      'Overdue',
      name: 'overdue',
      desc: '',
      args: [],
    );
  }

  /// `After`
  String get after {
    return Intl.message(
      'After',
      name: 'after',
      desc: '',
      args: [],
    );
  }

  /// `Before `
  String get before {
    return Intl.message(
      'Before ',
      name: 'before',
      desc: '',
      args: [],
    );
  }

  /// `Any match`
  String get anyMatch {
    return Intl.message(
      'Any match',
      name: 'anyMatch',
      desc: '',
      args: [],
    );
  }

  /// `Exact match`
  String get exactMatch {
    return Intl.message(
      'Exact match',
      name: 'exactMatch',
      desc: '',
      args: [],
    );
  }

  /// `Match any label and any member.`
  String get matchAnyLabelAnd {
    return Intl.message(
      'Match any label and any member.',
      name: 'matchAnyLabelAnd',
      desc: '',
      args: [],
    );
  }

  /// `exact`
  String get exact {
    return Intl.message(
      'exact',
      name: 'exact',
      desc: '',
      args: [],
    );
  }

  /// `Choose a member`
  String get chooseAMember {
    return Intl.message(
      'Choose a member',
      name: 'chooseAMember',
      desc: '',
      args: [],
    );
  }

  /// `Choose a label`
  String get chooseALabel {
    return Intl.message(
      'Choose a label',
      name: 'chooseALabel',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
      desc: '',
      args: [],
    );
  }

  /// `Search label`
  String get searchLabel {
    return Intl.message(
      'Search label',
      name: 'searchLabel',
      desc: '',
      args: [],
    );
  }

  /// `label selected`
  String get labelSelected {
    return Intl.message(
      'label selected',
      name: 'labelSelected',
      desc: '',
      args: [],
    );
  }

  /// `Leave a comment`
  String get leaveAComment {
    return Intl.message(
      'Leave a comment',
      name: 'leaveAComment',
      desc: '',
      args: [],
    );
  }

  /// `There was an error in updating information there was an error in updating your information, please try again later!`
  String get thereWasAnErrorInUpdating {
    return Intl.message(
      'There was an error in updating information there was an error in updating your information, please try again later!',
      name: 'thereWasAnErrorInUpdating',
      desc: '',
      args: [],
    );
  }

  /// `There was an error while uploading the avatar, please try again later!`
  String get thereWasAnErrorWhile {
    return Intl.message(
      'There was an error while uploading the avatar, please try again later!',
      name: 'thereWasAnErrorWhile',
      desc: '',
      args: [],
    );
  }

  /// `Allow to sync from this device?`
  String get allowToSyncFromThisDevice {
    return Intl.message(
      'Allow to sync from this device?',
      name: 'allowToSyncFromThisDevice',
      desc: '',
      args: [],
    );
  }

  /// `Do not sync`
  String get doNotSync {
    return Intl.message(
      'Do not sync',
      name: 'doNotSync',
      desc: '',
      args: [],
    );
  }

  /// `If you don't make that request, please choose`
  String get ifYouDontMakeThatRequest {
    return Intl.message(
      'If you don\'t make that request, please choose',
      name: 'ifYouDontMakeThatRequest',
      desc: '',
      args: [],
    );
  }

  /// `just logged in and requested to sync data from this device.`
  String get justLoggeInAndRequested {
    return Intl.message(
      'just logged in and requested to sync data from this device.',
      name: 'justLoggeInAndRequested',
      desc: '',
      args: [],
    );
  }

  /// `Auto refesh in`
  String get autoRefeshIn {
    return Intl.message(
      'Auto refesh in',
      name: 'autoRefeshIn',
      desc: '',
      args: [],
    );
  }

  /// `Just @mention`
  String get justMention {
    return Intl.message(
      'Just @mention',
      name: 'justMention',
      desc: '',
      args: [],
    );
  }

  /// `Off`
  String get off {
    return Intl.message(
      'Off',
      name: 'off',
      desc: '',
      args: [],
    );
  }

  /// `Silent`
  String get silent {
    return Intl.message(
      'Silent',
      name: 'silent',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get normal {
    return Intl.message(
      'Normal',
      name: 'normal',
      desc: '',
      args: [],
    );
  }

  /// `removed`
  String get removed {
    return Intl.message(
      'removed',
      name: 'removed',
      desc: '',
      args: [],
    );
  }

  /// `in an issue you had followed.`
  String get inAnIssueYouHadFollowed {
    return Intl.message(
      'in an issue you had followed.',
      name: 'inAnIssueYouHadFollowed',
      desc: '',
      args: [],
    );
  }

  /// `second`
  String get second {
    return Intl.message(
      'second',
      name: 'second',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for verification`
  String get waitingForVerification {
    return Intl.message(
      'Waiting for verification',
      name: 'waitingForVerification',
      desc: '',
      args: [],
    );
  }

  /// `Data processing`
  String get dataProcessing {
    return Intl.message(
      'Data processing',
      name: 'dataProcessing',
      desc: '',
      args: [],
    );
  }

  /// `Data is being transmitted`
  String get dataIsBeingTransmitted {
    return Intl.message(
      'Data is being transmitted',
      name: 'dataIsBeingTransmitted',
      desc: '',
      args: [],
    );
  }

  /// `Verification has failed`
  String get verificationHasFailed {
    return Intl.message(
      'Verification has failed',
      name: 'verificationHasFailed',
      desc: '',
      args: [],
    );
  }

  /// `Nothing`
  String get nothing {
    return Intl.message(
      'Nothing',
      name: 'nothing',
      desc: '',
      args: [],
    );
  }

  /// `Synchronization will take place as required by the device`
  String get synchronizationwilltake {
    return Intl.message(
      'Synchronization will take place as required by the device',
      name: 'synchronizationwilltake',
      desc: '',
      args: [],
    );
  }

  /// `Processing data`
  String get processingData {
    return Intl.message(
      'Processing data',
      name: 'processingData',
      desc: '',
      args: [],
    );
  }

  /// `Downloading data`
  String get downloadingData {
    return Intl.message(
      'Downloading data',
      name: 'downloadingData',
      desc: '',
      args: [],
    );
  }

  /// `Wrong code, please try again`
  String get wrongCodePleaseTryAgain {
    return Intl.message(
      'Wrong code, please try again',
      name: 'wrongCodePleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Getting data`
  String get gettingData {
    return Intl.message(
      'Getting data',
      name: 'gettingData',
      desc: '',
      args: [],
    );
  }

  /// `please choose`
  String get pleaseChoose {
    return Intl.message(
      'please choose',
      name: 'pleaseChoose',
      desc: '',
      args: [],
    );
  }

  /// ` closed this`
  String get closedThis {
    return Intl.message(
      ' closed this',
      name: 'closedThis',
      desc: '',
      args: [],
    );
  }

  /// ` reopened this`
  String get reopenedThis {
    return Intl.message(
      ' reopened this',
      name: 'reopenedThis',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get and {
    return Intl.message(
      'and',
      name: 'and',
      desc: '',
      args: [],
    );
  }

  /// `Save message`
  String get saveMessage {
    return Intl.message(
      'Save message',
      name: 'saveMessage',
      desc: '',
      args: [],
    );
  }

  /// `Remove saved`
  String get unsaveMessages {
    return Intl.message(
      'Remove saved',
      name: 'unsaveMessages',
      desc: '',
      args: [],
    );
  }

  /// `Unarchive card`
  String get unarchiveCard {
    return Intl.message(
      'Unarchive card',
      name: 'unarchiveCard',
      desc: '',
      args: [],
    );
  }

  /// `Archive Card`
  String get archiveCard {
    return Intl.message(
      'Archive Card',
      name: 'archiveCard',
      desc: '',
      args: [],
    );
  }

  /// `Add a workspace`
  String get newworkspace {
    return Intl.message(
      'Add a workspace',
      name: 'newworkspace',
      desc: '',
      args: [],
    );
  }

  /// `New message`
  String get newMessage {
    return Intl.message(
      'New message',
      name: 'newMessage',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Re-type new`
  String get enterANewPassword {
    return Intl.message(
      'Re-type new',
      name: 'enterANewPassword',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get NewPassword {
    return Intl.message(
      'New Password',
      name: 'NewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Create a new password`
  String get CreateANewPassword {
    return Intl.message(
      'Create a new password',
      name: 'CreateANewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get currentPassword {
    return Intl.message(
      'Current Password',
      name: 'currentPassword',
      desc: '',
      args: [],
    );
  }

  /// `Note: New password must be at least 6 characters or more & up to 32 characters.`
  String get noteNewPassword {
    return Intl.message(
      'Note: New password must be at least 6 characters or more & up to 32 characters.',
      name: 'noteNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `New password doesn't match`
  String get newPasswordDoesMatch {
    return Intl.message(
      'New password doesn\'t match',
      name: 'newPasswordDoesMatch',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get hide {
    return Intl.message(
      'Hide',
      name: 'hide',
      desc: '',
      args: [],
    );
  }

  /// `Appear`
  String get appear {
    return Intl.message(
      'Appear',
      name: 'appear',
      desc: '',
      args: [],
    );
  }

  /// `View profile`
  String get viewProfile {
    return Intl.message(
      'View profile',
      name: 'viewProfile',
      desc: '',
      args: [],
    );
  }

  /// `Attendance`
  String get attendance {
    return Intl.message(
      'Attendance',
      name: 'attendance',
      desc: '',
      args: [],
    );
  }

  /// `channel topic`
  String get channelTopic {
    return Intl.message(
      'channel topic',
      name: 'channelTopic',
      desc: '',
      args: [],
    );
  }

  /// `Login with QR code`
  String get loginWithQRCode {
    return Intl.message(
      'Login with QR code',
      name: 'loginWithQRCode',
      desc: '',
      args: [],
    );
  }

  /// `Basic info`
  String get basicInfo {
    return Intl.message(
      'Basic info',
      name: 'basicInfo',
      desc: '',
      args: [],
    );
  }

  /// `Contact info`
  String get contactInfo {
    return Intl.message(
      'Contact info',
      name: 'contactInfo',
      desc: '',
      args: [],
    );
  }

  /// `Edit Basic info`
  String get editBasicInfo {
    return Intl.message(
      'Edit Basic info',
      name: 'editBasicInfo',
      desc: '',
      args: [],
    );
  }

  /// `Edit name`
  String get editName {
    return Intl.message(
      'Edit name',
      name: 'editName',
      desc: '',
      args: [],
    );
  }

  /// `Contact support`
  String get contactSupport {
    return Intl.message(
      'Contact support',
      name: 'contactSupport',
      desc: '',
      args: [],
    );
  }

  /// `Notification & Sound`
  String get notificationSound {
    return Intl.message(
      'Notification & Sound',
      name: 'notificationSound',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get video {
    return Intl.message(
      'Video',
      name: 'video',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
