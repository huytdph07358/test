y tuowng ve media trong DM
Tat ca file up trong dm deu ma hoa boi aes256 voi key dc sinh ngau nhien
Key_encrypt dc sinh trong DirectMessageModel(updateImage);
Key dc luu trong tin nhan maf dc ma hoa boio tin nhan:
```
message  = {
    ...,
    "attachaments": [
        "content_url: "abc.xyz",
        "key_encrypt": "dfdsfsdfdsfdsf"
    ]
}
```



khi nhan dc tin nhan, tat ca media se dc tu dong tai ve va luu trong getApplicationDocumentsDirectory() + "/conversation_media"
Groupkey -> decryptMessage -> decryptMessageByMember -> ServiceMedia.getAllMediaFromMessageViaIsolate(dataFinalMessage);


Ham down load dc dat trong isolate rieng  IsolateMedia


```
class IsolateMedia {
  static var mainSendPort;
  static Store? storeObjectBox;
  static Future createIsolate() async {
    Completer completer = new Completer<SendPort>();
    ReceivePort isolateToMainStream = ReceivePort();

    isolateToMainStream.listen((data) {
      if (data is SendPort) {
        SendPort mainToIsolateStream = data;
        completer.complete(mainToIsolateStream);
      } else {
        try {
          if (data is Map && data["type"] == "path_in_device"){
            String remoteUrl = data["remote_url"];
            String pathInDevice =  data["path_in_device"];
            StreamMediaDownloaded.dataStatus[remoteUrl] = {
              "type": "local",
              "path": pathInDevice
            };
            StreamMediaDownloaded.instance.statusMediaDownloadedController.add(StreamMediaDownloaded.dataStatus);
          }          
        } catch (e) {
        }
      }
    });
    await Isolate.spawn(heavyComputationTask, isolateToMainStream.sendPort);
    return completer.future;
  }

  static heavyComputationTask(SendPort isolateToMainStream) async {
    ReceivePort mainToIsolateStream = ReceivePort();
    isolateToMainStream.send(mainToIsolateStream.sendPort);
    mainToIsolateStream.listen((data) {
      if (data["type"] == "get_all_media_from_message"){
        Store store = Store.fromReference(getObjectBoxModel(), data["box_reference"]);
        ServiceMedia.getAllMediaFromMessageIsolate(data["data"], store, data["path_save_file"], isolateToMainStream);
      }
    });
  }
}
```

Tat ca ham trong isolate can co Store, PathDownload(do 2 cai nay ko the tao trong isolate)
Flow tai
lay media -> Luu lai Media -> Luwu laij Media Conversation -> tai media -> Luwu lai media

```
static getAllMediaFromMessageIsolate(Map message, Store store, String pathSaveFile, SendPort isolateToMainStream) async {
    try {
      await Future.wait((message["attachments"] as List).map((m) async {
        try {
          if (!Utils.checkedTypeEmpty(m["content_url"])) return;
          var media = (await Media.checkFileHasDownloaded((m["content_url"]), store)) ?? Media.parseFromObj({
            ...m,
            "inserted_at": message["time_create"]
          });  
          MediaConversation? mediaConv = MediaConversation.parseFromObj({
            ...message,
            "local_id": (message["id"] + m["content_url"]).hashCode,
          });
          if (media == null || mediaConv == null) return;
          media.saveToDisk(store, isolateToMainStream);  

          mediaConv.media.target = media;
          store.box<MediaConversation>().put(mediaConv);
          media.downloadToDevice(store, pathSaveFile, isolateToMainStream);
        } catch (e, trace) {
          print(":::::::$e $trace  $m");
        }
        
      }));      
    } catch (e) {
      print("getAllMediaFromMessage: $e");
    }
  }
```



sau khi tai xong thi can broadcast lai cho StreamMediaDownloaded de render lai, Chi broadcast tai lan insert Media voi status = "downloaded"
```
  Future<Media?> saveToDisk(Store store, SendPort isolateToMainStream) async {
    try {
      Box box = store.box<Media>();
      box.put(this);
      if (this.status == "downloaded") {
        isolateToMainStream.send({
          "remote_url": this.remoteUrl,
          "path_in_device": this.pathInDevice,
          "type": "path_in_device"
        });
      }
      return this;
    } catch (e) {
      print("saveToDisk: $e");
      return null;
    }
  }
```





================================================================
Flow tu dong tai xuong
chia 2 case <bool>
{
  "wifi": {
    "image": bool,
    "video": bool,
    "other": bool
  },
  "mobile_data": {
    "image": bool,
    "video": bool,
    "other": bool
  }
}
