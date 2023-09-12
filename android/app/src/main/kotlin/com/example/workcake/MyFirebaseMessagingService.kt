package vn.pancake.chat

import android.app.*
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.*
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.style.StyleSpan
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.Person
import androidx.core.app.RemoteInput
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import androidx.preference.PreferenceManager
import com.example.workcake.MarkAsReadAction
//import com.example.workcake.MuteAction
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.*
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec
import kotlin.random.Random.Default.nextInt

class MyFirebaseMessagingService : FirebaseMessagingService() {

    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    // [START receive_message]

    fun getSharedKey(conversationId: String, userId: String): String{
        try {
            var sh:SharedPreferences? =  PreferenceManager.getDefaultSharedPreferences(this)
            if (sh != null) {
                return sh.getString(userId + "_" + conversationId, "").toString()
            }
            return "";
        } catch (e: Exception){
            return "";
        }
    }

    fun saveData(conversationId: String, messageId: String ,dataStringfy: String){
        try {
            // var sh:SharedPreferences? =  PreferenceManager.getDefaultSharedPreferences(this)
            // if (sh != null) {
            //     sh.edit().putString( "conversation_" + messageId, dataStringfy).apply()
            // }
        } catch (e: Exception){
        }
    }

    fun getValueOfTypeJSONObject(obj: JSONObject, key: String): Any {
        try {
            return obj[key];
        } catch (e: Exception) {
            return "";
        }
    };

    fun getTextAtts(video: Int, other: Int, image: Int, sticker: Int): String{
        if (video == 1 && other == 0 && image == 0) return "sent a video";
        if (video > 1 && other == 0 && image == 0) return "sent videos";
        if (video == 0 && other == 1 && image == 0) return "sent a file";
        if (video == 0 && other > 1 && image == 0) return "sent files";
        if (video == 0 && other == 0 && image == 1) return "sent an image";
        if (video == 0 && other == 0 && image > 1) return "sent images";
        if (sticker == 1) return "sent a sticker";
        if (video == 0 && other == 0 && image == 0) return "";
        return "sent attachments";
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun decryptMessageConversation(userId: String, conversationId: String, message: String, messageId: String): JSONObject {
//        {
//            "success": true,
//            "text": "______",
//            "data": JSONObject() //thong tin da giai ma
//        }
        val result  = JSONObject()
        result.put("success", true);
        result.put("text", "send a message");
        result.put("data", {});

        try {
            val conversationKeyUserValue = getSharedKey(conversationId, userId)
            val secretKey: SecretKeySpec = SecretKeySpec(Base64.getDecoder().decode(conversationKeyUserValue), "AES");

           try {
                val cipher = Cipher.getInstance("AES/CBC/PKCS7PADDING")
                cipher.init(Cipher.DECRYPT_MODE, secretKey, IvParameterSpec(Base64.getDecoder().decode("AAAAAAAAAAAAAAAAAAAAAA==")))
                var stringfyJson =  String(cipher.doFinal(Base64.getDecoder().decode(message)));
                // save to
                var obj: JSONObject =  JSONObject(stringfyJson);
                obj.put("user_id", userId)
                obj.put("conversation_id", conversationId)
                obj.put("id", messageId)
                result.put("data", obj)
                saveData("conversation_id", messageId, obj.toString())
                if (obj["message"] != null && obj["message"] != "") result.put("text", obj["message"] as String);
                var atts:JSONArray = (obj["attachments"] as JSONArray)
                result.put("attachments", atts);
               var objType = JSONObject();
               objType.put("video", 0)
               objType.put("image", 0)
               objType.put("other", 0)
               objType.put("sticker", 0)
                var text: String = getValueOfTypeJSONObject(obj, "message") as String;
                val typeAtts = JSONObject()
                for (i in 0 until atts.length()) {
                    val att = atts.getJSONObject(i)
                    if (getValueOfTypeJSONObject(att, "type") == "mention"){
                        text = "";
                        var dataMentions = att["data"] as JSONArray;
                        for (j in 0 until dataMentions.length()){
                            var mention:JSONObject = dataMentions.get(j) as JSONObject;
                            val listType = listOf("all", "user", "issue")
                            if(listType.contains(mention["type"])) {
                                text += mention["trigger"]
                                text += mention["name"]
                            } else {
                                text += mention["value"]
                            }
                        }
                    } else {
                        if (getValueOfTypeJSONObject(att, "type") == "image" || getValueOfTypeJSONObject(att, "mime_type") == "image") {
                            objType.put("image", objType["image"] as Int + 1)
                        } else if (getValueOfTypeJSONObject(att, "mime_type") == "video" || getValueOfTypeJSONObject(att, "mime_type") == "mp4" || getValueOfTypeJSONObject(att, "mime_type") == "mov") {
                                objType.put("video", objType["video"] as Int + 1)
                        } else if (getValueOfTypeJSONObject(att, "type") == "sticker") {
                          objType.put("sticker", objType["sticker"] as Int + 1)
                        } else {
                          objType.put("other", objType["other"] as Int + 1)
                      }
                    }
                }
               var stringAtts = getTextAtts(objType["video"] as Int, objType["other"] as Int, objType["image"] as Int, objType["sticker"] as Int)
               if (text == "") result.put("text", stringAtts);
               else if (stringAtts ==  "") result.put("text", text);
               else  result.put("text", text + "\n" + stringAtts);

            //    System.out.println("objTypeobjType: "+ objType)
            } catch (e: Exception) {
               System.out.println("Error while encrypting: " + e.toString() )
            }
            return result
        } catch (e: Exception) {
            System.out.println("Error while encrypting: " + e.toString() )
            result.put("success", false)
            return result
        }
    }
    fun getBitmapFromURL(src: String?): Bitmap? {
        return try {
            val url = URL(src)
            val connection: HttpURLConnection = url.openConnection() as HttpURLConnection
            connection.setDoInput(true)
            connection.connect()
            val input: InputStream = connection.getInputStream()
            BitmapFactory.decodeStream(input)
        } catch (e: IOException) {
            // Log exception
            null
        }
    }

    fun getActivedTime(channelId: String): Long {
        try {
            val sh = getSharedPreferences("sharedName", Context.MODE_PRIVATE)
            if (sh != null) {
                var activedTime = sh.getLong("offNoti_${channelId}", 1L)
                if(activedTime != null || activedTime != 1L) {
                    return activedTime
                }
            }
            return  0;
        }
        catch (e: Exception) {
            System.out.println(e)
            return 0;
        }
    }


    fun checkNotificationMatch(convesationId: String?, channelId: String?): Boolean {
        try {
            var sh:SharedPreferences? =  PreferenceManager.getDefaultSharedPreferences(this)
            if (sh == null) return true;
            var stringChannelIds = sh.getString("channel_ids", null)
            var stringConversationIds = sh.getString("conversation_ids", null)
            if (stringChannelIds == null && stringConversationIds == null) return true;
            if (convesationId != null){
                if (stringConversationIds == null) return  true;
                return stringConversationIds.contains("_" + convesationId + "_" );
            }
            if (channelId != null){
                if (stringChannelIds == null) return  true;
                return stringChannelIds.contains("_" + channelId + "_" );
            }
            return false;
        } catch (e: Exception) {
            System.out.println(e)
            return false;
        }
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // [START_EXCLUDE]
        // There are two types of messages data messages and notification messages. Data messages are handled
        // here in onMessageReceived whether the app is in the foreground or background. Data messages are the type
        // traditionally used with GCM. Notification messages are only received here in onMessageReceived when the app
        // is in the foreground. When the app is in the background an automatically generated notification is displayed.
        // When the user taps on the notification they are returned to the app. Messages containing both notification
        // and data payloads are treated as notification messages. The Firebase console always sends notification
        // messages. For more see: https://firebase.google.com/docs/cloud-messaging/concept-options
        // [END_EXCLUDE]

        // TODO(developer): Handle FCM messages here.
        // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
        // Check if message contains a data payload.
        var current_time = System.currentTimeMillis()
        var channel_id = remoteMessage.data["channel_id"].toString()
        if (remoteMessage.data["type"] == "delete_message") return deleteMessageStyle(remoteMessage.data["current_time"].toString().toLong(), remoteMessage.data["idSummy"].toString().toInt());
        if (remoteMessage.data["type"] == "request_sync_data") return;
        if (remoteMessage.data["current_time"] != null){
            current_time = remoteMessage.data["current_time"].toString().toLong()
        }
        if (getActivedTime(channel_id) > current_time) return;
        try {
            val sh = getSharedPreferences("sharedName", Context.MODE_PRIVATE)
            var editor = sh.edit()
            editor.remove("offNoti_${remoteMessage.data["channel_id"].toString()}")
            if (
                !checkNotificationMatch(
                    (remoteMessage.data["conversation_id"]) as String?,
                    (remoteMessage.data["channel_id"]) as String?
                )
            ) return;
            if (remoteMessage.data["incoming_notification"] != null) return
            if (remoteMessage.data["clear_notification_group"] != null) return clearNotification(
                remoteMessage.data["clear_notification_group"]!!.toInt());
            if (remoteMessage.data["idSummy"] != null)
                if (remoteMessage.data["conversation_id"] == null)
                    return sendNotification(
                        remoteMessage.data["body"].toString(),
                        remoteMessage.data["idSummy"].toString().toInt(),
                        remoteMessage.data["groupName"].toString(),
                        JSONObject(remoteMessage.data as Map<*, *>?).toString(),
                        remoteMessage.data["full_name"].toString(),
                        remoteMessage.data["avatar_url"].toString(),
                        false,
                        current_time,
                        remoteMessage.data["channel_id"].toString(),
                        false
                    );
            var result =  JSONObject();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
                result = decryptMessageConversation(
                    remoteMessage.data["user_id"] as String,
                    remoteMessage.data["conversation_id"] as String,
                    remoteMessage.data["message"] as String,
                    remoteMessage.data["message_id"] as String,
                )
            }
            val endObject = JSONObject(remoteMessage.data as Map<*, *>?)
            if (result["success"] as Boolean){
                endObject.put("data_message", result["data"])
            }
            sendNotification(
                result["text"] as String,
                remoteMessage.data["idSummy"].toString().toInt(),
                remoteMessage.data["groupName"].toString(),
                endObject.toString(),
                remoteMessage.data["full_name"].toString(),
                remoteMessage.data["avatar_url"].toString(),
                remoteMessage.data["isDirect11"].toBoolean(),
                current_time,
                remoteMessage.data["conversation_id"].toString(),
                true
            )
        }
        finally {

        }


        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
    }
    // [END receive_message]

    // [START on_new_token]
    /**
     * Called if the FCM registration token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the
     * FCM registration token is initially generated so this is where you would retrieve the token.
     */
    override fun onNewToken(token: String) {
        Log.d(TAG, "Refreshed token: $token")

        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // FCM registration token to your app server.
        sendRegistrationToServer(token)
    }
    // [END on_new_token]

    /**
     * Schedule async work using WorkManager.
     */
    private fun scheduleJob() {
        // [START dispatch_job]
        // val work = OneTimeWorkRequest.Builder(MyWorker::class.java).build()
        // WorkManager.getInstance(this).beginWith(work).enqueue()
        // // [END dispatch_job]
    }

    /**
     * Handle time allotted to BroadcastReceivers.
     */
    private fun handleNow() {
        Log.d(TAG, "Short lived task is done.")
    }

    /**
     * Persist token to third-party servers.
     *
     * Modify this method to associate the user's FCM registration token with any server-side account
     * maintained by your application.
     *
     * @param token The new token.
     */
    private fun sendRegistrationToServer(token: String?) {
        // TODO: Implement this method to send token to your app server.
        Log.d(TAG, "sendRegistrationTokenToServer($token)")
    }

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     * @param messageBody FCM message body received.
     */

    fun findActiveNotification(context: Context, notificationId: Int): Notification? {
        return (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .activeNotifications.find { it.id == notificationId }?.notification
    }

    fun createPerson(name: String, avatarUrl: String): Person{
        val sb: SpannableStringBuilder = SpannableStringBuilder(name);
        sb.setSpan(StyleSpan(android.graphics.Typeface.BOLD), 0, name.length, Spannable.SPAN_INCLUSIVE_INCLUSIVE)
        val person = Person.Builder()
            .setName(sb)
        val bitmapAvatar = getBitmapFromURL(avatarUrl)
        if (bitmapAvatar != null)
            person.setIcon(IconCompat.createWithBitmap(getCircularBitmap(bitmapAvatar)))
        return person.build();
    };

    fun createShortCut(id: String, url: String, intent: Intent, shortcutName: String, isDirect1_1: Boolean) {
        val bitmap = getBitmapFromURL(url)
        val shortcut = ShortcutInfoCompat.Builder(this, id)
            .setShortLabel(shortcutName)
            .setLongLabel(shortcutName)
            .setLongLived(true)
            .setIcon(IconCompat.createWithResource(this, R.drawable.panchat_logo_72x72))
            .setIntent(
                intent.setAction(Intent.ACTION_VIEW)
            )
//      chi hien icon khi la direct 1-1
        if (isDirect1_1){

            if (bitmap != null){
                shortcut.setIcon(IconCompat.createWithBitmap(getCircularBitmap(bitmap)))
            }
        }
        ShortcutManagerCompat.pushDynamicShortcut(this, shortcut.build())
    }
    fun getCircularBitmap(bitmap: Bitmap): Bitmap {
        val output: Bitmap
        output = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)

        val canvas = Canvas(output)
        val color = -0xbdbdbe
        val paint = Paint()
        val rect = Rect(0, 0, bitmap.width, bitmap.height)
        paint.setAntiAlias(true)
        canvas.drawARGB(0, 0, 0, 0)
        paint.setColor(color)

        if(bitmap.width > bitmap.height) {
            canvas.drawCircle((bitmap.width / 2).toFloat(), (bitmap.height / 2).toFloat(), (bitmap.height / 2).toFloat(), paint)
        }
        else{
            canvas.drawCircle((bitmap.width / 2).toFloat(), (bitmap.height / 2).toFloat(), (bitmap.width / 2).toFloat(), paint)
        }

        paint.setXfermode(PorterDuffXfermode(PorterDuff.Mode.SRC_IN))
        canvas.drawBitmap(bitmap, rect, rect, paint)
        return output
    }



    private fun sendNotification(
        messageBody: String,
        messageSummaryId: Int,
        messageGroupName: String,
        notiStringfy : String,
        fullName: String,
        avatarUrl: String,
        isDirect11: Boolean,
        currentTime: Long,
        idFlag : String,
        isDirectMessage: Boolean,
    ) {
        var result = JSONObject()
        if(isDirectMessage) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
                result = decryptMessageConversation(
                    JSONObject(notiStringfy)["user_id"].toString(),
                    JSONObject(notiStringfy)["conversation_id"].toString(),
                    JSONObject(notiStringfy)["message"].toString(),
                    JSONObject(notiStringfy)["message_id"].toString(),
                )
            }
        }

        val bitmap = getBitmapFromURL(avatarUrl)
        val intent = Intent(this, NotificationActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent.putExtra("notification", notiStringfy)
        val requestCode: Int = nextInt(from = 1, until = 2000000000)
        var pendingIntent = PendingIntent.getActivity(this, requestCode/* Request code */, intent, PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val replyIntent = Intent(this, RepLyAction::class.java)
        replyIntent.putExtra("notification", notiStringfy)
        val replyPendingIntent = PendingIntent.getBroadcast(this, requestCode/* Request code */, replyIntent, PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

//        val offNotiIntent = Intent(this, MuteAction::class.java)
//        offNotiIntent.putExtra("offNoti", notiStringfy)
//        val offNotiPendingIntent = PendingIntent.getBroadcast(this, 0, offNotiIntent, PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

        val markAsReadIntent = Intent(this, MarkAsReadAction::class.java)
        markAsReadIntent.putExtra("markAsRead", notiStringfy)
        val markAsReadPendingIntent = PendingIntent.getBroadcast(this, requestCode, markAsReadIntent, PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        // Since android Oreo notification channel is needed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val sound = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + packageName + "/" + R.raw.incoming)
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                .build()
            val channel = NotificationChannel("channelId",
                "Panchat message",
                NotificationManager.IMPORTANCE_HIGH)
                .apply {
                    setSound(sound, audioAttributes)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
            notificationManager.createNotificationChannel(channel)
        }

        //Add reply button on notification
        var replyLabel: String = "Reply here"
        var remoteInput: RemoteInput = RemoteInput.Builder("key reply").run {
            setLabel(replyLabel)
            build()
        }

        var action: NotificationCompat.Action = NotificationCompat.Action.Builder(
            R.drawable.ic_small_panchat_final,
            "Reply",
            replyPendingIntent
        )
            .addRemoteInput(remoteInput)
            .build()

        var reactionsAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
            R.drawable.ic_small_panchat_final,
            "Like",
            replyPendingIntent
        )
            .build()

        var markAsReadAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
            R.drawable.ic_small_panchat_final,
            "Mark as read",
            markAsReadPendingIntent
        )
            .build()

        val color = 0xff1E3D73.toInt()
        val summaryNotification = NotificationCompat.Builder(this, "channelId")
            .setSmallIcon(R.drawable.ic_small_panchat_final)
            .setColor(color)
            .setStyle(NotificationCompat.InboxStyle()
                .setSummaryText("messages"))
            .setGroup("message")
            .setSound(Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + packageName + "/" + R.raw.incoming))
            .setAutoCancel(true)
            .setGroupSummary(true)
            .build()
//      new api for conversation_notification
//      find notification
        val existed =  notificationManager.activeNotifications.find { it.id == messageSummaryId }
        createShortCut(messageSummaryId.toString(), avatarUrl, intent, messageGroupName, isDirect11)
        var person: Person? = null
        if (!isDirect11){
            person = createPerson(fullName, avatarUrl)
        }
        if (existed == null){
            val messageStyle  = NotificationCompat.MessagingStyle(
                Person.
                Builder().
                setName(fullName).
                build()
            )
                .setConversationTitle(messageGroupName)
                .setGroupConversation(!isDirect11)
            if (isDirect11)
                messageStyle.addMessage(messageBody, currentTime, "")
            else messageStyle.addMessage(messageBody, currentTime, person)
            val notificationBuilder = NotificationCompat.Builder(this, "channelId")
                     .setSmallIcon(R.drawable.ic_small_panchat_final)
                     .setShortcutId(messageSummaryId.toString())
                     .setStyle(
                         messageStyle
                     )
                     .setContentIntent(pendingIntent)
                     .setColor(color)
                     .setGroup("message")
                     .setSound(Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + packageName + "/" + R.raw.incoming))
                     .setCategory(Notification.CATEGORY_MESSAGE)
                     .setVisibility(NotificationCompat.VISIBILITY_SECRET)
                     .setAutoCancel(true)
                    if (!isDirectMessage) {
                        notificationBuilder.addAction(reactionsAction)
                    }
                    if(!isDirectMessage || (isDirectMessage && result["success"] == true)) {
                        notificationBuilder.addAction(markAsReadAction)
                    }
                    if (!isDirectMessage) {
                        notificationBuilder.addAction(action)
                    }
            androidx.core.app.NotificationManagerCompat.from(this).apply {
                notify(messageSummaryId, notificationBuilder.build())
                notify(0, summaryNotification)
            }

        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val activeStyle = NotificationCompat.MessagingStyle.extractMessagingStyleFromNotification(existed.notification)
                val newStyle = NotificationCompat.MessagingStyle(
                    Person.
                    Builder().
                    setName(fullName).
                    build()
                )
                    .setGroupConversation(!isDirect11)
                    .setConversationTitle(messageGroupName)
                activeStyle?.messages?.forEach {
                    if (isDirect11)
                      newStyle.addMessage(it.text, it.timestamp, "")
                    else newStyle.addMessage(it.text, it.timestamp, it.person)
                }
                if (isDirect11)
                    newStyle.addMessage(messageBody, currentTime, "")
                else newStyle.addMessage(messageBody, currentTime, person)

                // clearNotification(existed!!.id)
                val notificationBuilder = NotificationCompat.Builder(this, "channelId")
                    .setSmallIcon(R.drawable.ic_small_panchat_final)
                    .setShortcutId(messageSummaryId.toString())
                    .setStyle(newStyle)
                    .setContentIntent(pendingIntent)
                    .setColor(color)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setGroup("message")
                    .setSound(Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + packageName + "/" + R.raw.incoming))
                    .setCategory(Notification.CATEGORY_MESSAGE)
                    .setAutoCancel(true)
                    if (!isDirectMessage) {
                        notificationBuilder.addAction(reactionsAction)
                    }
                    if(!isDirectMessage || (isDirectMessage && result["success"] == true)) {
                        notificationBuilder.addAction(markAsReadAction)
                    }
                    if (!isDirectMessage) {
                        notificationBuilder.addAction(action)
                    }
                androidx.core.app.NotificationManagerCompat.from(this).apply {
                    notify(messageSummaryId, notificationBuilder.build())
                    notify(0, summaryNotification)
                }
            } else {
                TODO("VERSION.SDK_INT < N")
            }
        }
    }

    private fun clearNotification(id: Int) {
        var mNotificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mNotificationManager.cancel(id);
        if (mNotificationManager.activeNotifications.size == 1){
            mNotificationManager.cancelAll()
        }
    }

    private fun deleteMessageStyle(currentTime: Long,  messageSummaryId: Int,) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existed =  notificationManager.activeNotifications.find { it.id == messageSummaryId }
        if (existed != null) {
            val activeStyle = NotificationCompat.MessagingStyle.extractMessagingStyleFromNotification(existed.notification)
            val notificationBuilder = NotificationCompat.Builder(this, existed.notification)
            var acceptMessage:  List<NotificationCompat.MessagingStyle.Message> = activeStyle?.messages?.filter { it.timestamp !=  currentTime} as List<NotificationCompat.MessagingStyle.Message>
            if (acceptMessage?.count() == 0) {
                return notificationManager.cancel(messageSummaryId)
            }
            else {
                val person: Person = acceptMessage.get(0)?.person!!
                var fullName:String = activeStyle.conversationTitle as String
                if (!activeStyle.isGroupConversation) fullName = person.name as String;
                if (fullName == "") fullName = " "
                val newStyle = NotificationCompat.MessagingStyle(
                    Person.
                    Builder().
                    setName(fullName).
                    build()
                )
                    .setConversationTitle(activeStyle.conversationTitle)
                    .setGroupConversation(activeStyle.isGroupConversation)
                if (acceptMessage != null) {
                    acceptMessage.forEach {
                        newStyle?.addMessage(it)
                    }
                }
                notificationBuilder.setStyle(newStyle)
                androidx.core.app.NotificationManagerCompat.from(this).apply {
                    notify(messageSummaryId, notificationBuilder.build())
                }
            }

        }
    }

    companion object {

        private const val TAG = "MyFirebaseMsgService"
    }
}