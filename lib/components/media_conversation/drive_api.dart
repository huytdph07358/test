
import 'dart:io';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:http/http.dart';

import 'model.dart';

class DriveService {
  static gdrive.DriveApi? instance;


  static login() async {
    final _googleSignIn = GoogleSignIn(scopes: <String>[gdrive.DriveApi.driveAppdataScope],);
    if (await _googleSignIn.isSignedIn())
      await _googleSignIn.signInSilently();
    else {
      await _googleSignIn.signOut();
      await _googleSignIn.signIn();
      await _googleSignIn.signInSilently();
    }
    var a = (await _googleSignIn.authenticatedClient());
    if (a ==  null) return;
    DriveService.instance = gdrive.DriveApi(a);
  }

  static Future<bool> checkIsSigned() async {
    final _googleSignIn = GoogleSignIn(scopes: <String>[gdrive.DriveApi.driveAppdataScope],);
    return await _googleSignIn.isSignedIn();
  }

  static Future<bool> logout() async {
    try {
      final _googleSignIn = GoogleSignIn(scopes: <String>[gdrive.DriveApi.driveAppdataScope],);
      if (await checkIsSigned()){
        _googleSignIn.signOut();
        return true;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static uploadFile(Media file) async {
    if (DriveService.instance == null) await DriveService.login();
    if (DriveService.instance == null) return;

    gdrive.File f = gdrive.File();
    f.name = file.name;
    f.parents = ["appDataFolder"];

    final fileList = await DriveService.instance!.files.list(spaces: 'appDataFolder', q: "name='${file.name}'", $fields: 'files(id, name, modifiedTime)');
    List existedFileWithName = fileList.files ?? [];
    await Future.wait(existedFileWithName.map((e) => DriveService.instance!.files.delete( (e as gdrive.File).id ?? "")));
    await DriveService.instance!.files.create(
      f,
      uploadMedia: gdrive.Media(File(file.pathInDevice ?? "").openRead(), file.size),
    );
  }

  static Future<gdrive.File?> getFileBackUpMessage({String backupName = "backup_message_v1_encrypted.text"}) async {
    if (DriveService.instance == null) await DriveService.login();
    if (DriveService.instance == null) return null;
    final fileList = await DriveService.instance!.files.list(spaces: 'appDataFolder', q: "name='$backupName'", $fields: 'files(id, name, modifiedTime)');
    List existedFileWithName = fileList.files ?? [];
    if (existedFileWithName.length == 0) return null;
    return existedFileWithName[0];
  }

  static Future<List<int>?> getContentFile(String fileId) async {
    try {
      if (DriveService.instance == null) await DriveService.login();
      if (DriveService.instance == null) return null;
      gdrive.Media i = await DriveService.instance!.files.get(fileId, downloadOptions: gdrive.DownloadOptions.fullMedia) as gdrive.Media; 
      return (await (i.stream as ByteStream).toBytes());      
    } catch (e) {
      return null;
    }
  }

}