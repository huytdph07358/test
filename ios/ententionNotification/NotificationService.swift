//
//  NotificationService.swift
//  ententionNotification
//
//  Created by DuNM on 13/01/2022.
//

import UserNotifications
import os.log
import CommonCrypto

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        let userdefault = UserDefaults(suiteName: "group.vn.pancake.chat")
        var thread = "";
        if let bestAttemptContent = bestAttemptContent {
//            Modify the notification content here...       
            let conversation_id = (bestAttemptContent.userInfo["gcm.notification.conversation_id"] ?? "") as! String
//            let channel_id =  (bestAttemptContent.userInfo["gcm.notification.channel_id"] ?? "") as! String
//            let activedTime = userdefault?.string(forKey: "paramsNoti_\(channel_id)") as! String
            if (conversation_id == "") {
                bestAttemptContent.categoryIdentifier = "message"
                var threadName  = (bestAttemptContent.userInfo["gcm.notification.parent_message_id"] ?? "") as! String
                if (threadName != "") {
                    bestAttemptContent.title = "thread - \(bestAttemptContent.title)"
                }
                thread = "\((bestAttemptContent.userInfo["gcm.notification.channel_id"] ?? "channel") as! String )_\(threadName)"
                bestAttemptContent.threadIdentifier = thread 
            }
            else {
                thread = (bestAttemptContent.userInfo["gcm.notification.conversation_id"] ?? "") as! String
                bestAttemptContent.threadIdentifier = thread
                let k: String = "\((bestAttemptContent.userInfo["gcm.notification.user_id"] ?? "") as! String)_\((bestAttemptContent.userInfo["gcm.notification.conversation_id"] ?? "") as! String)"
                let key = userdefault?.string(forKey: k)
                let messageEn = (bestAttemptContent.userInfo["gcm.notification.message"] ?? "") as! String
                let str = decryption(key: key!, message: messageEn)
                let anyObj: AnyObject? = try! JSONSerialization.jsonObject(with: Data(str.utf8)) as AnyObject
                let message  = (anyObj?["message"] ?? "")! as! String
                if (message != ""){
                    bestAttemptContent.body = ((bestAttemptContent.userInfo["gcm.notification.full_name"] ?? "") as! String) + ": " + message
                    return  contentHandler(bestAttemptContent)
                }
                var resultStr = ""
                var objType: [String: Int] = [
                    "image": 0,
                    "video": 0,
                    "other": 0,
                    "sticker": 0
                ]

                let atts = (anyObj?["attachments"] ?? "")! as! NSArray
                for a in atts {
                    let att = a as? NSDictionary
                    let type  = (att?.object(forKey: "type") ?? "") as! String
                    if (type == "mention"){
                        let data = (att?.object(forKey: "data") ?? []) as! NSArray
                        for d in data {
                            let attMention = d as? NSDictionary
                            let type = (attMention?.object(forKey: "type") ?? "") as! String
                            var elements = ["user", "all", "issue"]
                            if(elements.contains(type)) {
                                resultStr += ((attMention?.object(forKey: "trigger") ?? "") as! String)
                                resultStr += ((attMention?.object(forKey: "name") ?? "") as! String)
                            } else {
                                resultStr += ((attMention?.object(forKey: "value") ?? "") as! String)
                            }
                        }
                    } else {
                        var mime = (att?.object(forKey: "mime_type") ?? "") as! String
                        var type = (att?.object(forKey: "type") ?? "") as! String
                        if (mime == "image") {
                            objType["image"] = (objType["image"] ?? 0) as Int + 1
                        } else if (mime == "video" || mime == "mp4" || mime == "mov"){
                            objType["video"] = (objType["video"] ?? 0) as Int + 1
                        } else if (type == "sticker" ){
                            objType["sticker"] = (objType["sticker"] ?? 0) as Int + 1
                        } else {
                            objType["other"] = (objType["other"] ?? 0) as Int + 1
                        }
                    }
                }

                var stringAtts: String = getTextAtts(video: objType["video"] ?? 0, other: objType["other"] ?? 0, image: objType["image"] ?? 0 , sticker: objType["sticker"] ?? 0)
                if (resultStr == "") {
                    bestAttemptContent.body = ((bestAttemptContent.userInfo["gcm.notification.full_name"] ?? "") as! String) + ": " + stringAtts
                } else if (stringAtts == "") {
                    bestAttemptContent.body = ((bestAttemptContent.userInfo["gcm.notification.full_name"] ?? "") as! String) + ": " + resultStr
                } else {
                    bestAttemptContent.body = ((bestAttemptContent.userInfo["gcm.notification.full_name"] ?? "") as! String) + ": " + resultStr + "\n" + stringAtts
                }

            }
            if (((bestAttemptContent.userInfo["gcm.notification.clear_notification_group"] ?? "") as! String) != ""){
                UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                    notifications.map { n in
                        if (n.request.content.threadIdentifier == thread) {
                            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [n.request.identifier])
                        }
                        
                    }
                }

                return;
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    func getTextAtts(video: Int, other: Int, image: Int, sticker: Int) -> String{
        if (video == 1 && other == 0 && image == 0) {return "sent a video";}
        if (video > 1 && other == 0 && image == 0)  {return "sent videos";}
        if (video == 0 && other == 1 && image == 0) {return "sent a file";}
        if (video == 0 && other > 1 && image == 0)  {return "sent files";}
        if (video == 0 && other == 0 && image == 1) {return "sent an image";}
        if (video == 0 && other == 0 && image > 1)  {return "sent images";}
        if (sticker == 1) {return "sent a sticker";}
        if (video == 0 && other == 0 && image == 0) {return "";}
        return "sent attachments";
    }
    
    func decryption(key: String, message: String) -> String {
        guard let k = Data(base64Encoded: key) else { return "sent a message" }
        guard let mes = Data(base64Encoded: message) else { return "sent a message" }
        guard  let iv = Data(base64Encoded: "AAAAAAAAAAAAAAAAAAAAAA==") else { return "sent a message" }
        do {
            let decryptedData = try? testCrypt(data: mes, keyData: k, ivData: iv, operation:kCCDecrypt)
            if (decryptedData != nil){
               return String(bytes: decryptedData!, encoding: String.Encoding.utf8) ?? ""
            }
            
        } catch {
            return "sent a message"
        }
        return "sent a message"
    }
    
    func testCrypt(data:Data, keyData:Data, ivData:Data, operation:Int) -> Data {
        let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)

        let keyLength             = size_t(kCCKeySizeAES256)
        let options   = CCOptions(kCCOptionPKCS7Padding)


        var numBytesEncrypted :size_t = 0

        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                ivData.withUnsafeBytes {ivBytes in
                    keyData.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(operation),
                                  CCAlgorithm(kCCAlgorithmAES),
                                  options,
                                  keyBytes, keyLength,
                                  ivBytes,
                                  dataBytes, data.count,
                                  cryptBytes, cryptLength,
                                  &numBytesEncrypted)
                    }
                }
            }
        }
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)

        } else {
            print("Error: \(cryptStatus)")
        }
        return cryptData;
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            bestAttemptContent.categoryIdentifier = "message"
            // bestAttemptContent.title = "error"
            contentHandler(bestAttemptContent)
        }
    }

}
