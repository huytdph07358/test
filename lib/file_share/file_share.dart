import 'dart:async';


class DataFileShare {
  late String localPath;
  late String mimeType;
  late String type;

  DataFileShare(this.localPath, this.mimeType, this.type);
}


class FileShare {
  static var instance = new FileShare();
  final _statusFileShareController = StreamController<List<DataFileShare>>.broadcast(sync: false);
  Stream<List<DataFileShare>> get status => _statusFileShareController.stream;

  List<DataFileShare> fileFromShare = [];
  setFileFromNative(List data){
    fileFromShare = data.map<DataFileShare>((e) {
      return DataFileShare(e["local_path"] as String, e["mime_type"] ?? "share", e["type"] ?? "share");
    }).toList();
    _statusFileShareController.add(fileFromShare);
  }

  List<DataFileShare> getFileFromShare(){
    List<DataFileShare> source = fileFromShare;
    fileFromShare = [];
    _statusFileShareController.add(fileFromShare);
    return source;
  }
}