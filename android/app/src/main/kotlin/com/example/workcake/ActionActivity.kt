package com.example.workcake
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.view.Gravity
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.PreferenceManager
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executor
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class CallApi (
    private val executor : Executor
) {
    fun markAsReadChannel(
        workspace_id: String,
        channel_id: String,
        token: String,
        id: Int,
        jsonBody: String,
        notificationManager: NotificationManager
    ) {
        executor.execute {
            try {
                val url = URL("https://chat.pancake.vn/api/workspaces/${workspace_id}/channels/${channel_id}/mark_as_read?token=${token}")
                (url.openConnection() as? HttpURLConnection)?.run {
                    requestMethod = "POST"
                    setRequestProperty("Content-Type", "application/json; charset=utf-8")
                    setRequestProperty("Accept", "application/json")
                    doInput = true
                    val outputStreamWriter = OutputStreamWriter(outputStream)
                    outputStreamWriter.write(jsonBody)
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

    fun markAsReadChannelThread (
        workspace_id: String,
        token: String,
        jsonBody: String,
        id: Int,
        notificationManager: NotificationManager
    ) {
        executor.execute{
            try {
                val url = URL("https://chat.pancake.vn/api/workspaces/${workspace_id}/update_unread_thread?token=${token}")
                (url.openConnection() as? HttpURLConnection)?.run {
                    requestMethod = "POST"
                    setRequestProperty("Content-Type", "application/json; charset=utf-8")
                    setRequestProperty("Accept", "application/json")
                    val outputStreamWriter = OutputStreamWriter(outputStream)
                    outputStreamWriter.write(jsonBody)
                    outputStreamWriter.flush()
                    outputStreamWriter.flush()
                    val response =  inputStream.bufferedReader().use { it.readText() }
                    notificationManager.cancel(id);
                    if (notificationManager.activeNotifications.size == 1){
                        notificationManager.cancelAll()
                    }
                }
            }
            catch (e: Exception) {
                print("error mark as read channel thread" + e)
            }
        }
    }

    fun markAsReadDms(
        token: String,
        device_id: String,
        jsonBody: String,
        id: Int,
        notificationManager: NotificationManager,
        conversationId: String
    ) {
        executor.execute {
            try {
                val url = URL("https://chat.pancake.vn/api/direct_messages/$conversationId/mark_read_v2?token=$token&device_id=$device_id&version_api=2")
                (url.openConnection() as? HttpURLConnection)?.run {
                    requestMethod = "POST"
                    setRequestProperty("Content-Type", "application/json; charset=utf-8")
                    setRequestProperty("Accept", "application/json")
                    val outputStreamWriter = OutputStreamWriter(outputStream)
                    outputStreamWriter.write(jsonBody)
                    outputStreamWriter.flush()
                    outputStreamWriter.flush()
                    val response =  inputStream.bufferedReader().use { it.readText() }
                    notificationManager.cancel(id);
                    if (notificationManager.activeNotifications.size == 1){
                        notificationManager.cancelAll()
                    }
                }
            }
            catch (e: Exception) {
                print("Mark as read Dms error $e")
                e.printStackTrace()
            }
        }
    }

    fun markAsReadThreadDms(
        token: String,
        device_id: String,
        id: Int,
        notificationManager: NotificationManager,
        conversationId: String,
        messageId: String
    ) {
        executor.execute {
            try {
                val url = URL("https://chat.pancake.vn/api/direct_messages/$conversationId/thread_messages/$messageId/messages?token=$token&device_id=$device_id&mark_read_thread=true")
                (url.openConnection() as? HttpURLConnection)?.run {
                    requestMethod = "GET"
                    setRequestProperty("Content-Type", "application/json; charset=utf-8")
                    setRequestProperty("Accept", "application/json")
                    val response =  inputStream.bufferedReader().use { it.readText() }
                    notificationManager.cancel(id);
                    if (notificationManager.activeNotifications.size == 1){
                        notificationManager.cancelAll()
                    }
                }
            }
            catch (e: Exception) {
                print("Mark as read Dms error $e")
                e.printStackTrace()
            }
        }
    }
}

class MuteAction : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val params = intent?.getStringExtra("offNoti").toString()
        var channel_id = JSONObject(params)["channel_id"]
        var activedTime = System.currentTimeMillis() + (60 * 60 * 1000)
        val sh = context?.getSharedPreferences("sharedName", Context.MODE_PRIVATE)
        var editor = sh?.edit()
        editor?.putLong("offNoti_${channel_id}", activedTime)
        editor?.commit()
        var group_id = JSONObject(params)["idSummy"].toString();
        var mNotificationManager = context?.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        mNotificationManager.cancel(group_id.toInt())
        if (mNotificationManager.activeNotifications.size == 1){
            mNotificationManager.cancelAll()
        }
        val text = "Thông báo của channel này sẽ được mở lại sau 1 giờ hoặc khi vào lại channel"
        val duration = Toast.LENGTH_LONG

        val toast = Toast.makeText(context, text, duration)
        toast.setGravity(Gravity.CENTER, 0, 0);
        toast.show()
    }

}

class MarkAsReadAction : BroadcastReceiver() {
    private val executorSystem: ExecutorService = Executors.newFixedThreadPool(4)
    override fun onReceive(context: Context?, intent: Intent?) {
        val params = intent?.getStringExtra("markAsRead").toString()
        var token = "";
        var device_id = "";
        var encrypted_data = ""
        var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(context)
        if (sh != null) {
            token = sh.getString("token", "").toString();
            device_id = sh.getString("device_id", "").toString();
            encrypted_data = sh.getString("encrypted_data", "").toString();
        }
        var mNotificationManager = context?.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        var channel_thread_id = "";
        var is_direct_1_1 = "";
        try {
            channel_thread_id = JSONObject(params)["parent_message_id"].toString();
        } catch (e: Exception) {
            channel_thread_id = "";
        }

        try {
            is_direct_1_1 = JSONObject(params)["is_direct_1_1"].toString();
        }
        catch (e: Exception) {
            is_direct_1_1 = "";
        }

        //Mark as read thread channel
        if (channel_thread_id != "" && is_direct_1_1 == "") {
            val body = JSONObject()
            body.put("message_id", JSONObject(params)["parent_message_id"].toString())
            body.put("channel_id", JSONObject(params)["channel_id"].toString())
            body.put("workspace_id", JSONObject(params)["workspace_id"].toString())
            body.put("issue_id", "")
            CallApi(executorSystem).markAsReadChannelThread(
                JSONObject(params)["workspace_id"].toString(),
                token,
                body.toString(),
                JSONObject(params)["idSummy"].toString().toInt(),
                mNotificationManager
            )
        }

        //Mark as read Direct
        else if(channel_thread_id == "" && is_direct_1_1 != "") {
            val body = JSONObject()
            body.put("data", encrypted_data)
            CallApi(executorSystem).markAsReadDms(
                token,
                device_id,
                body.toString(),
                JSONObject(params)["idSummy"].toString().toInt(),
                mNotificationManager,
                JSONObject(params)["conversation_id"].toString()
            )
        }

        //Mark as read thread direct
        else if(channel_thread_id != "" && is_direct_1_1 != "") {
            CallApi(executorSystem).markAsReadThreadDms(
                token,
                device_id,
                JSONObject(params)["idSummy"].toString().toInt(),
                mNotificationManager,
                JSONObject(params)["conversation_id"].toString(),
                JSONObject(params)["parent_message_id"].toString(),
            )
        }

        //Mark as read channel message
        else {
            CallApi(executorSystem).markAsReadChannel(JSONObject(params)["workspace_id"].toString(), JSONObject(params)["channel_id"].toString(), token, JSONObject(params)["idSummy"].toString().toInt(),"", mNotificationManager)
        }

    }
}