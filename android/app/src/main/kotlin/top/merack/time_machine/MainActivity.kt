package top.merack.time_machine

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var ringtoneChannel: RingtoneChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ringtoneChannel = RingtoneChannel(this, flutterEngine)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        ringtoneChannel?.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        ringtoneChannel?.dispose()
        ringtoneChannel = null
        super.onDestroy()
    }
}
