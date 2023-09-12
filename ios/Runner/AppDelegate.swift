import UIKit
import Flutter
import PushKit
import Firebase
import NetworkExtension
import CoreLocation
import os
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import Foundation
import AVFAudio

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
  
  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?
  
  private let linkStreamHandler = LinkStreamHandler()
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    let controller = window.rootViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(name: "workcake.pancake.vn/channel", binaryMessenger: controller.binaryMessenger)
    eventChannel = FlutterEventChannel(name: "workcake.pancake.vn/events", binaryMessenger: controller.binaryMessenger)

    
    methodChannel?.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) in
        switch call.method {
            
            case "active_sound_send_message":
                do {
                    var filePath: String?
                    filePath = Bundle.main.path(forResource: "send2", ofType: "wav")
                    let fileURL = NSURL(fileURLWithPath: filePath!)
                    var soundID:SystemSoundID = 0
                    AudioServicesCreateSystemSoundID(fileURL, &soundID)
                    AudioServicesPlaySystemSound(soundID)
                }
                catch{
                    
                }
                
            case "scan_wifi":
            if #available(iOS 14.0, *) {
                do {
                    var locationManger: CLLocationManager?
                    guard locationManger == nil else {
                        locationManger?.requestWhenInUseAuthorization()
                        locationManger?.startUpdatingLocation()
                        return
                    }
                    locationManger = CLLocationManager()
                    locationManger?.delegate = self
                    locationManger?.desiredAccuracy = kCLLocationAccuracyKilometer
                    locationManger?.requestWhenInUseAuthorization()
                    locationManger?.startUpdatingLocation()
                    NEHotspotNetwork.fetchCurrent(completionHandler: {(network) in
                        if let unwrappedNetwork = network {
                            let bssid = unwrappedNetwork.bssid
                            result("BSSID \(bssid)")
                        }
                        else {
                            result("abc")
                        }
                    })
                    let options: [String: NSObject] = [kNEHotspotHelperOptionDisplayName : "Join our WIFI" as NSObject]
                    let queue: DispatchQueue = DispatchQueue(label: "com.myapp.appname", attributes: DispatchQueue.Attributes.concurrent)
                    NSLog("Started wifi list scanning.")

                    NEHotspotHelper.register(options: options, queue: queue) { (cmd: NEHotspotHelperCommand) in
                      NSLog("Received command: \(cmd.commandType.rawValue)")
                    }
                } catch  {
                    result(false)
                }
            }
            case "initialLink":
                result(FlutterMethodNotImplemented)
                return
            case "copy_image":
                do {
                    var args = call.arguments
                    if (args == nil) {return result(true)}
                    var urlImage:String = args as! String
                    if (urlImage.contains("https")){
                        urlImage = urlImage.replacingOccurrences(of: " ", with: "%20")
                        let data:NSData = try NSData.init(contentsOf: URL(string: urlImage)!)
                        UIPasteboard.general.image = UIImage.init(data: (data as? Data)!)
                    } else {
                        let data = FileManager.default.contents(atPath: urlImage)
                        if (data != nil){
                            UIPasteboard.general.image = UIImage.init(data: data!)
                        }
                    }
                    result(true)
                } catch  {
                    result(false)
                }
            case "shared_key":
                let userdefault = UserDefaults(suiteName: "group.vn.pancake.chat")
                let args = call.arguments as? Optional<NSArray?>
                if (args == nil) {return result(true)}
                for item in (args!!!) {
                    let obj = item as? NSDictionary
                    userdefault!.set((obj?.object(forKey: "value") ?? "" ) as! String , forKey: (obj?.object(forKey: "key") ?? "" ) as! String)
                }
                userdefault?.synchronize()

                result(true)
                return;
            case "logout": 
                let userdefault = UserDefaults(suiteName: "group.vn.pancake.chat")
                userdefault?.removePersistentDomain(forName: "group.vn.pancake.chat")
                

            default:
                result(true)
                return
            }
    })
    
    FirebaseApp.configure()


    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      print("???????????????????????????????????????????????????")
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
        UNUserNotificationCenter.current().setNotificationCategories([
          UNNotificationCategory(
            identifier: "message",
            actions: [
              UNTextInputNotificationAction(
                  identifier: "message.reply",
                  title: "Reply",
                  textInputButtonTitle: "Send",
                  textInputPlaceholder: "Reply here"
              ),
              UNNotificationAction(identifier: "message.turnoffNoti", title: "Mute", options: [])
            ],
            intentIdentifiers: [],
            options: []
          )
        ])
    } else {
      let settings: UIUserNotificationSettings =
      UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()


    GeneratedPluginRegistrant.register(with: self)
    eventChannel?.setStreamHandler(linkStreamHandler)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    eventChannel?.setStreamHandler(linkStreamHandler)
    return linkStreamHandler.handleLink(url.absoluteString)
  }
    
  override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    if response.actionIdentifier  ==  "message.reply" {
      if let textResponse =  response as? UNTextInputNotificationResponse {
        let sendText =  textResponse.userText
        let channel_id = (response.notification.request.content.userInfo["gcm.notification.channel_id"] ?? "") as! String
        let workspace_id = (response.notification.request.content.userInfo["gcm.notification.workspace_id"] ?? "") as! String
        var channel_thread_id = response.notification.request.content.userInfo["gcm.notification.parent_message_id"]
        let userdefault = UserDefaults(suiteName: "group.vn.pancake.chat")
        let token = (userdefault?.string(forKey: "token") ?? "") as! String
        let user_id = userdefault?.string(forKey: "user_id")
        let sUrl: String = "https://chat.pancake.vn/api/workspaces/\(workspace_id)/channels/\(channel_id)/messages?token=\(token)"
        if let url = URL.init(string: sUrl) {
          var request = URLRequest(url: url)
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          request.addValue("application/json", forHTTPHeaderField: "Accept")
          request.httpMethod = "POST"
          let parameters: [String: Any] = [
              "attachments": [],
              "user_id": user_id,
              "message": sendText,
              "key": "dfsdfsdfdsfsdf",
              "channel_thread_id": channel_thread_id
          ]
          let bodyData = try? JSONSerialization.data(
              withJSONObject: parameters,
              options: []
          )
          request.httpBody = bodyData
          
          let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                completionHandler()
            }
          }
          task.resume()
        } else {
          print("urlllll: \(URL.init(string: sUrl)) _____\(URL(string: sUrl))")
          completionHandler()
        }
      } else {
          super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
      }
    }
      else if response.actionIdentifier  ==  "message.turnoffNoti" {
          let activedTime = NSDate().timeIntervalSince1970 + 1 * 60
          let userdefault = UserDefaults(suiteName: "group.vn.pancake.chat")
          let channel_id = (response.notification.request.content.userInfo["gcm.notification.channel_id"] ?? "") as! String
          userdefault?.set("\(activedTime)", forKey: "paramsNoti_\(channel_id)")
          userdefault?.synchronize()
//          let test = userdefault?.string(forKey: "paramsNoti_\(channel_id)") as! String
//          print(test)
      }
      else {
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
  }
}

class LinkStreamHandler:NSObject, FlutterStreamHandler {
  
  var eventSink: FlutterEventSink?
  
  // links will be added to this queue until the sink is ready to process them
  var queuedLinks = [String]()
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    queuedLinks.forEach({ events($0) })
    queuedLinks.removeAll()
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
  
  func handleLink(_ link: String) -> Bool {
    guard let eventSink = eventSink else {
      queuedLinks.append(link)
      return false
    }
    eventSink(link)
    return true
  }
}
