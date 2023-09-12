package vn.pancake.chat

import android.app.DownloadManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.*
import android.content.pm.PackageInfo
import android.graphics.Rect
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.RingtoneManager
import android.net.Uri
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.view.View
import android.view.ViewTreeObserver
import android.view.Window
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.app.RemoteInput
import androidx.core.content.FileProvider
import androidx.core.view.WindowInsetsCompat
import androidx.multidex.BuildConfig
import androidx.preference.PreferenceManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.util.*
import java.util.concurrent.Executor
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import kotlin.random.Random.Default.nextInt

class MainActivity: FlutterFragmentActivity() {

    private val CHANNEL = "workcake.pancake.vn/channel"
    private val EVENTS = "workcake.pancake.vn/events"
    private var linksReceiver: BroadcastReceiver? = null
    private var eventSink: EventSink? = null
    private var downloadManager: DownloadManager? = null
    private val executorSystem: ExecutorService = Executors.newFixedThreadPool(4)
    private var firstIntent: Intent? = null;

    @RequiresApi(Build.VERSION_CODES.R)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->

            if (call.method == "save_channel_ids") {
                var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(this)
                if (sh != null) {
                    sh.edit().putString("channel_ids", call.arguments as String).apply()
                    result.success(true);
                }
                else result.success(false);
            }


            if (call.method == "save_conversation_ids") {
                var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(this)
                if (sh != null) {
                    sh.edit().putString("conversation_ids", call.arguments as String).apply()
                    result.success(true);
                }
                else result.success(false);
            }

            if (call.method == "logout") {
                var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(this)
                if (sh != null) {
                    sh.edit().clear().commit()
                    sh.edit().putString("conversation_ids", "").apply()
                    sh.edit().putString("channel_ids", "").apply()
                    result.success(true);
                }
                result.success(false)
            }

//            if (call.method == "scan_wifi") {
//                val wifiManager = getSystemService(Context.WIFI_SERVICE) as WifiManager
//                fun scanSuccess() {
//                    var results :List<ScanResult> = wifiManager.scanResults
//                    var deviceList :ArrayList<JSONObject> = ArrayList()
//                    for (scanResults in results) {
//                        var a :JSONObject = JSONObject()
//                        a.put("ssid", scanResults.SSID)
//                        a.put("bssid", scanResults.BSSID)
//                        deviceList.add(a)
//                    }
//                    result.success(deviceList.toString())
//                }
//
//                fun scanFailure() {
//                    val results :List<ScanResult> = wifiManager.scanResults
//                    System.out.println(results.toString())
//                }
//
//                val wifiScanReceiver = object : BroadcastReceiver() {
//
//                    override fun onReceive(context: Context, intent: Intent) {
//                        val success = intent.getBooleanExtra(WifiManager.EXTRA_RESULTS_UPDATED, false)
//                        if (success) {
//                            scanSuccess()
//                        } else {
//                            scanFailure()
//                        }
//                    }
//                }
//
//                val intentFilter = IntentFilter()
//                intentFilter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
//                registerReceiver(wifiScanReceiver, intentFilter)
//
//                val success = wifiManager.startScan()
//                if (!success) {
//                    // scan failure handling
//                    scanFailure()
//                }
//
//            }

            if (call.method == "noti_string_on_create"){
                var uuuuu:String? = "_"
                try {
                    var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(this)
                    if (sh != null) {
                        uuuuu = sh.getString("noti_string_on_create", "")
                    }
                }
                catch(e: Exception) {
                }
                result.success(uuuuu)
            }
            if (call.method == "initialLink") {
                if (firstIntent?.action == Intent.ACTION_SEND || firstIntent?.action == Intent.ACTION_SEND_MULTIPLE) {
                    processIntentAction(firstIntent!!, result)
                } else {

                    val mapNoti = JSONObject()
                    mapNoti.put("type", "data_notification")
                    mapNoti.put("data", getDataNotiFromCache())
                    mapNoti.put("flag_intent", firstIntent?.flags)
                    result.success(mapNoti.toString())
                }
            }

            if (call.method == "android_native_install") {
                val args: HashMap<String?, String?> = call.arguments as HashMap<String?, String?>;
                var newVersion: String = args["version_app"] as String;
                val pm = applicationContext.packageManager
                val info: PackageInfo = pm.getPackageInfo(applicationContext.packageName, 0)
                System.out.println("+++++" + newVersion.toInt() + "___" + info.versionCode)
                if ((newVersion.toInt()) > info.versionCode) {
                    Toast.makeText(this, "Downloading package", Toast.LENGTH_LONG).show()
                    var destination =
                        this.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS).toString() + "/"
                    destination += "panchat.apk"
                    val uri = Uri.parse("file://$destination")

                    val file = File(destination)
                    if (file.exists()) file.delete()
                    val downloadManager =
                        this.getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
                    val downloadUri = Uri.parse(args["url"])
                    val request = DownloadManager.Request(downloadUri)
                    request.setMimeType("application/vnd.android.package-archive")
                    request.setTitle("Panchat")
                    request.setDescription("Downloading resource")
                    request.setDestinationUri(uri)
                    downloadManager.enqueue(request)
                    val onComplete = object : BroadcastReceiver() {
                        override fun onReceive(
                            context: Context,
                            intent: Intent
                        ) {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                val contentUri = FileProvider.getUriForFile(
                                    context,
                                    BuildConfig.APPLICATION_ID + ".provider",
                                    File(destination)
                                )
                                val install = Intent(Intent.ACTION_INSTALL_PACKAGE)
                                install.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                install.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                                install.putExtra(Intent.EXTRA_NOT_UNKNOWN_SOURCE, true)
                                install.data = contentUri
                                context.startActivity(install)
                                context.unregisterReceiver(this)
                                // finish()
                            } else {
                                val install = Intent(Intent.ACTION_VIEW)
                                install.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                                install.setDataAndType(
                                    uri,
                                    "application/vnd.android.package-archive"
                                )
                                context.startActivity(install)
                                context.unregisterReceiver(this)
                                // finish()
                            }
                        }
                    }

                    registerReceiver(
                        onComplete,
                        IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE)
                    );

                }

            }

            if (call.method == "saveFileDirect") {
                val args: HashMap<String?, Any?>? = call.arguments as HashMap<String?, Any?>?;
                result.success("${args?.get("name")}")
                downloadFolderDirect(
                    args?.get("content_url") as String,
                    args?.get("name") as String,
                    args?.get("bytes") as ByteArray
                )
            }
            if (call.method == "saveFile") {
                val args: HashMap<String?, Any?>? = call.arguments as HashMap<String?, Any?>?;
                result.success("${args?.get("name")}")
                downloadFolder(args?.get("content_url") as String, args?.get("name") as String)
            }
            if (call.method == "onClick_channel_clear_notification") {
//                try {
//                    val args: HashMap<String, String?> = call.arguments as HashMap<String, String?>;
//                    var mNotificationManager =
//                        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//                    var listNoti =
//                        mNotificationManager.activeNotifications.find { it.notification.sortKey == args["channel_id"] }
//                    if (listNoti != null) {
//                        mNotificationManager.cancel(listNoti.id)
//                        if (mNotificationManager.activeNotifications.size == 1) mNotificationManager.cancel(0)
//                    };
//                } catch (e: Exception) {
//
//                }
            }
            if (call.method == "clear_notification") {
                try {
                    val args: HashMap<String, String?> = call.arguments as HashMap<String, String?>;
                    result.success("")
                    var mNotificationManager =
                        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    mNotificationManager.cancel(args["group_id"].toString().toInt())
                    if (mNotificationManager.activeNotifications.size == 1) mNotificationManager.cancel(
                        0
                    )
                } catch (e: Exception) {

                }

            }
            if (call.method == "shared_key") {
                System.out.println("shared_key" + call.arguments.javaClass.kotlin)
                val args: ArrayList<HashMap<String, String>> =
                    call.arguments as ArrayList<HashMap<String, String>>;
//              save to SharedPreferences to use when app not running
                var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(this)
                if (sh != null) {
                    for (i in args) {
                        sh.edit().putString(i["key"], i["value"]).apply()
                    }
                }
            }
            if (call.method == "active_sound_send_message") {
                try {
                    val sound = Uri.parse("android.resource://" + getPackageName() + "/raw/sound")
                    val track = RingtoneManager.getRingtone(applicationContext, sound)
                    // track.setStreamType(AudioManager.STREAM_SYSTEM);
                    track.play()
                }
                catch (e: Exception) {
                    System.out.println(e)
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor, EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(args: Any?, events: EventSink) {
                    linksReceiver = createChangeReceiver(events)
                    eventSink = events
                }

                override fun onCancel(args: Any?) {
                    linksReceiver = null
                    eventSink = null
                }
            }
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

//        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
//            this.finish()
//            intent.addFlags(FLAG_ACTIVITY_NEW_TASK);
//            startActivity(intent);
//        }
        downloadManager = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
//        val remoteReply = RemoteInput.getResultsFromIntent(intent);
//        if(remoteReply != null) {
//            var message: String = remoteReply.getCharSequence("key reply").toString()
//        }

 
        val mRootWindow: Window = window
        val mRootView: View = mRootWindow.getDecorView().findViewById(android.R.id.content)
        mRootView.getViewTreeObserver()
            .addOnGlobalLayoutListener(ViewTreeObserver.OnGlobalLayoutListener {
                val r = Rect()
                mRootView.getWindowVisibleDisplayFrame(r)
                val screenHeight = mRootView.rootView.height

                val keyboardHeight = screenHeight - r.bottom - r.top
                val objectData = JSONObject()
                objectData.put("height", keyboardHeight)
                objectData.put("type", "height_keyboard")

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    objectData.put("height", mRootView.rootWindowInsets.getInsets(WindowInsetsCompat.Type.ime()).bottom - mRootView.rootWindowInsets.getInsets(WindowInsetsCompat.Type.systemBars()).bottom)
                }
                eventSink?.success(objectData.toString());
                // IF height diff is more then 150, consider keyboard as visible.
            })


    }

    override fun onNewIntent(intent: Intent) {
        System.out.println("onNewIntent _________________________________________________________________________");
        super.onNewIntent(intent)
            when {
                intent?.action == Intent.ACTION_SEND -> {
                    processIntentAction(intent)
                }
                intent?.action == Intent.ACTION_SEND_MULTIPLE -> {
                    processIntentAction(intent)
                }
                else -> {
                    // Handle other intents, such as being started from the home screen
                    linksReceiver?.onReceive(this.applicationContext, intent)
                }
            }
    }

    override fun onDestroy() {
        super.onDestroy()
    }


    fun processUriFile(uri: Uri, fileCopyName: String): JSONObject {
        var inputStream = this.contentResolver.openInputStream(uri)
        var mimeType: String? = this.contentResolver.getType(uri)
        if (mimeType == null) mimeType = ".share"
        else {
            mimeType = mimeType.split("/").last()
        }
//        var byteArray = inputStream!!.readBytes()
        val tempFile: File = File.createTempFile("${fileCopyName}_share.", mimeType);
        System.out.println("inputStream" + inputStream)
        if (inputStream != null) {
            tempFile.outputStream().use { fileOut ->
                inputStream.copyTo(fileOut)
            }
        }
        var obj: JSONObject = JSONObject();
        obj.put("local_path", tempFile.path)
        obj.put("type", this.contentResolver.getType(uri))
        obj.put("mime_type", mimeType)
        return obj
    }

    fun processIntentAction(intent: Intent, resultEventSink: MethodChannel.Result? = null) {
        val bundle = intent.extras
        val data = JSONObject()
        data.put("type", "intent_action_send")
        var array: JSONArray = JSONArray()
        if (bundle != null) {
            for (key in bundle.keySet()) {
                if (bundle[key] != null) {
                    if (key == "android.intent.extra.STREAM") {
                        if (bundle[key] is java.util.ArrayList<*>) {
                            var fileShareCount: Int = 0;
                            for (uri in (bundle[key] as java.util.ArrayList<Uri>)) {
                                fileShareCount += 1;
                                array.put(processUriFile(uri, "${fileShareCount}"))
                            }

                        } else array.put(processUriFile(bundle[key] as Uri, "1"))
                    }
                    data.put(key, bundle[key])
                }
            }
        }
        data.put("files", array)
        if (resultEventSink != null) resultEventSink.success(data.toString())
        else eventSink?.success(data.toString())
    }

    fun createChangeReceiver(events: EventSink): BroadcastReceiver? {
        return object : BroadcastReceiver() {
            override fun onReceive(
                context: Context,
                intent: Intent
            ) { // NOTE: assuming intent.getAction() is Intent.ACTION_VIEW
                val mapNoti = JSONObject()
                mapNoti.put("type", "data_notification")
                mapNoti.put("data", getDataNotiFromCache())
                events.success(mapNoti.toString())
                broadcastDataFromNative(events)
            }

            fun sendData(data: HashMap<Any?, Any?>) {
                events.success(data.toString())
            }
        }
    }

    fun broadcastDataFromNative(events: EventSink) {
        try {
            var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(this)
            var map = JSONObject()
            if (sh != null) {
                val editor: SharedPreferences.Editor = sh.edit()
                val data = sh.all.filter { it.key.contains("conversation_") }
                for (i in data) {
                    map.put(i.key, JSONObject(i.value as String))
                    editor.remove(i.key)
                }
                editor.apply()
                val mapEnd = JSONObject()
                mapEnd.put("type", "data_messages_notification")
                mapEnd.put("data", map.toString())
                events.success(mapEnd.toString())
            }
        }
        catch(e: Exception) {
            System.out.println("ssssssssssssssss\n")
        }

    }

    fun getMimeFromFileName(fileName: String): String? {
        val map = android.webkit.MimeTypeMap.getSingleton()
        val ext = android.webkit.MimeTypeMap.getFileExtensionFromUrl(fileName)
        return map.getMimeTypeFromExtension(ext)
    }

    fun downloadFolderDirect(url: String?, name: String?, bytes: ByteArray) {
        val path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        val file = File("${path}/${name}")
        file.writeBytes(bytes);
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel("downloadStatus",
                "Panchat downloader",
                NotificationManager.IMPORTANCE_DEFAULT)
            notificationManager.createNotificationChannel(channel)
        }
        val downloaderIntent = Intent(Intent.ACTION_VIEW);
        downloaderIntent.setDataAndType(Uri.parse("${path}") ,"*/*");
        val downloaderPendingIntent: PendingIntent = PendingIntent.getActivity(this, 0, downloaderIntent, 0)
        val notificationBuilder = NotificationCompat.Builder(this, "downloadStatus")
            .setSmallIcon(R.drawable.ic_small_panchat_final)
            .setContentTitle("${name}")
            .setContentText("Download complete")
            .setGroup("downloader")
            .setAutoCancel(true)
            .setContentIntent(downloaderPendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
        val myRandomValues = nextInt(0, 100000)
        androidx.core.app.NotificationManagerCompat.from(this).apply {
            notify(myRandomValues, notificationBuilder.build())
        }
        Toast.makeText(this, "Downloaded ${name}", Toast.LENGTH_LONG).show()
    }

    fun downloadFolder(url: String?, name: String?) {

        val request = DownloadManager.Request(Uri.parse(url))

        request.setTitle("${name}")

        request.setDescription("Downloading ${name}")

        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);

        request.setMimeType(getMimeFromFileName(url as String))

        request.setDestinationInExternalPublicDir(
            Environment.DIRECTORY_DOWNLOADS,
            name
        )

        var id = downloadManager?.enqueue(request) ?: -1

        Toast.makeText(this, "Downloaded ${name}", Toast.LENGTH_LONG).show()
    }

    fun getDataNotiFromCache(): String? {
        try {
            var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(this)
            if (sh != null) {
                var str: String? = sh.getString("noti_string_on_create", null)
                val editor: SharedPreferences.Editor = sh.edit()
                editor.remove("noti_string_on_create")
                editor.apply()
                return str
            }
            return null
        }
        catch(e: Exception) {
            System.out.println(" getDataNotiFromCache activity catch _________________________________________________________________________\n")
            return null
        }
    }
}

class CallApi (
        private val executor : Executor
    ) {
    fun callApi(
        workspace_id: String,
        channel_id: String,
        token: String,
        jsonBody: String,
        id: Int,
        notificationManager: NotificationManager
    ) {
        executor.execute {
            try {
                val url = URL("https://chat.pancake.vn/api/workspaces/${workspace_id}/channels/${channel_id}/messages?token=${token}")
                (url.openConnection() as? HttpURLConnection)?.run {
                    requestMethod = "POST"
                    setRequestProperty("Content-Type", "application/json; charset=utf-8")
                    setRequestProperty("Accept", "application/json")
                    doInput = true
                    val outputStreamWriter = OutputStreamWriter(outputStream)
                    outputStreamWriter.write(jsonBody.toString())
                    outputStreamWriter.flush()
                    val response =  inputStream.bufferedReader().use { it.readText() }
                    notificationManager.cancel(id);
                    if (notificationManager.activeNotifications.size == 1){
                        notificationManager.cancelAll()
                    }
                }
            } catch (e: Exception) {
                println("errrrrr: " + e);
            }
        }
    }
}
class RepLyAction : BroadcastReceiver() {
    private val executorSystem: ExecutorService = Executors.newFixedThreadPool(4)
    override fun onReceive(context: Context?, intent: Intent?) {
        val remoteReply = RemoteInput.getResultsFromIntent(intent!!);
            var message = "";
            if(remoteReply == null) {
                message = "\uD83D\uDC4D"
            }
            else {
                message = remoteReply.getCharSequence("key reply").toString()
            }
            var startString = intent?.extras?.getString("notification");
            var channel_id = JSONObject(startString)["channel_id"].toString();
            var workspace_id = JSONObject(startString)["workspace_id"].toString();
            var group_id = JSONObject(startString)["idSummy"].toString();

            var token = "";
            var user_id = "";
            var channel_thread_id = "";
            try {
                channel_thread_id = JSONObject(startString)["parent_message_id"].toString();
            } catch (e: Exception) {
                channel_thread_id = ""
            }
            var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(context)
            if (sh != null) {
                token = sh.getString("token", "").toString();
                user_id = sh.getString("user_id", "").toString();
            }
            val key = System.currentTimeMillis().toString()
            val jsonBody = JSONObject()
            jsonBody.put("attachments", JSONArray())
            jsonBody.put("user_id", user_id)
            jsonBody.put("message", message)
            jsonBody.put("key", key)
            if (channel_thread_id != "" && channel_thread_id != null) {
                jsonBody.put("channel_thread_id", channel_thread_id)
            }
            var mNotificationManager = context?.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            CallApi(executorSystem).callApi(workspace_id, channel_id, token, jsonBody.toString(), group_id.toInt(), mNotificationManager)
        }

}

