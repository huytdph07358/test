package vn.pancake.chat
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.PreferenceManager
import android.view.WindowManager

class NotificationActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        var firstIntent = getIntent()
        System.out.println("notification activity 11111________________________________________________________________________________________________________________________________________________\n")
        try {
            var sh: SharedPreferences? = PreferenceManager.getDefaultSharedPreferences(this)
            if (sh != null) {
                sh.edit().putString("noti_string_on_create", firstIntent?.extras?.getString("notification")).apply()
               System.out.println("notification activity 22222 _________________________________________________________________________\n" + firstIntent?.extras?.getString("notification") + "\n_________________________________________________________________________\n")
            }
            getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN)
        }
        catch(e: Exception) {     
           System.out.println(" otification activity catch _________________________________________________________________________\n")
        }

        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        this.finish()
        intent.putExtra("notification", "notiStringfy")
        startActivity(intent);
    }
}