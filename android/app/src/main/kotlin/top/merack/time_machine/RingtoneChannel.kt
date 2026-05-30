package top.merack.time_machine

import android.app.Activity
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import androidx.core.net.toUri

/**
 * 系统铃声选择 / 播放通道
 *
 * 通道名: top.merack.time_machine/ringtone
 * 方法:
 *   - pickRingtone(currentUri: String?) -> {uri, title} | null
 *   - playRingtone(uri: String) -> Boolean
 *   - stopRingtone()
 *   - getRingtoneTitle(uri: String) -> String?
 *
 * 回调(Dart 侧 setMethodCallHandler):
 *   - onRingtoneCompleted -> 单次铃声播放自然结束
 */
class RingtoneChannel(
    private val activity: MainActivity,
    flutterEngine: FlutterEngine,
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "top.merack.time_machine/ringtone"
        private const val REQ_PICK_RINGTONE = 1042
    }

    private val channel =
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

    private var pendingResult: MethodChannel.Result? = null
    private var currentPlayer: MediaPlayer? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "pickRingtone" -> handlePick(call, result)
            "playRingtone" -> handlePlay(call, result)

            "stopRingtone" -> {
                stopCurrent(notifyCompleted = false)
                result.success(null)
            }

            "getRingtoneTitle" -> handleGetTitle(call, result)

            else -> result.notImplemented()
        }
    }

    private fun handlePick(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        if (pendingResult != null) {
            result.error(
                "BUSY",
                "已有铃声选择请求在进行中",
                null
            )
            return
        }

        // 保存给flutter侧返回结果的对象, 因为在此函数中不处理返回, 只是通知系统打开铃声选择
        // 用户选完铃声后给flutter的返回处理在onActivityResult中
        pendingResult = result

        val intent =
            Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                putExtra(
                    RingtoneManager.EXTRA_RINGTONE_TYPE,
                    RingtoneManager.TYPE_NOTIFICATION or
                            RingtoneManager.TYPE_RINGTONE
                )

                putExtra(
                    RingtoneManager.EXTRA_RINGTONE_TITLE,
                    "选择提示音"
                )

                putExtra(
                    RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT,
                    true
                )

                putExtra(
                    RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT,
                    false
                )

                val current =
                    call.argument<String?>("currentUri")

                if (!current.isNullOrEmpty()) {
                    putExtra(
                        RingtoneManager.EXTRA_RINGTONE_EXISTING_URI,
                        current.toUri()
                    )
                }
            }

        try {
            activity.startActivityForResult(
                intent,
                REQ_PICK_RINGTONE
            )
        } catch (e: Exception) {
            pendingResult = null
            result.error(
                "PICK_FAILED",
                e.message,
                null
            )
        }
    }

    private fun handlePlay(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val uriStr = call.argument<String>("uri")

        if (uriStr.isNullOrEmpty()) {
            result.success(false)
            return
        }

        try {
            stopCurrent(notifyCompleted = false)

            val player = MediaPlayer()
            currentPlayer = player
            player.apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                isLooping = false
                setDataSource(activity, uriStr.toUri())
                setOnCompletionListener { mp ->
                    // 自然播放完成: 释放并通知 Dart 侧
                    if (currentPlayer === mp) {
                        stopCurrent(notifyCompleted = true)
                    }
//                    if (currentPlayer === it) {
//                        try { it.release() } catch (_: Exception) {}
//                        currentPlayer = null
//                    }
//                    channel.invokeMethod("onRingtoneCompleted", null)
                }
                setOnErrorListener { mp, _, _ ->
                    if (currentPlayer === mp) {
                        try { mp.release() } catch (_: Exception) {}
                        currentPlayer = null
                    }
                    true
                }
                prepare()
                start()
            }
//            currentPlayer = player
            result.success(true)

        } catch (e: Exception) {
            try {
                currentPlayer?.release()
            } catch (_: Exception) {}
            currentPlayer = null
            result.error(
                "PLAY_FAILED",
                e.message,
                null
            )
        }
    }

    private fun handleGetTitle(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val uriStr =
            call.argument<String>("uri")

        if (uriStr.isNullOrEmpty()) {
            result.success(null)
            return
        }

        try {
            val ringtone =
                RingtoneManager.getRingtone(
                    activity,
                    uriStr.toUri()
                )

            result.success(
                ringtone?.getTitle(activity)
            )

        } catch (_: Exception) {
            result.success(null)
        }
    }

    private fun stopCurrent(notifyCompleted: Boolean) {
        val player = currentPlayer ?: return
        currentPlayer = null
        try {
            if (player.isPlaying) {
                player.stop()
            }
        } catch (_: Exception) {
        }
        try {
            player.release()
        } catch (_: Exception) {
        }
        // 正常播放完毕
        if (notifyCompleted) {
            channel.invokeMethod("onRingtoneCompleted", null)
        }
    }

    fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ): Boolean {
        if (requestCode != REQ_PICK_RINGTONE) {
            return false
        }

        val result = pendingResult ?: return true
        pendingResult = null

        // 处理用户取消了选择的情况
        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return true
        }

        val uri: Uri? =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                data?.getParcelableExtra(
                    RingtoneManager.EXTRA_RINGTONE_PICKED_URI,
                    Uri::class.java
                )
            } else {  // 处理兼容Android 13以下系统
                @Suppress("DEPRECATION")
                data?.getParcelableExtra(
                    RingtoneManager.EXTRA_RINGTONE_PICKED_URI
                )
            }

        if (uri == null) {
            result.success(null)
            return true
        }

        val title = try {
            RingtoneManager
                .getRingtone(activity, uri)
                ?.getTitle(activity)
        } catch (_: Exception) {
            null
        } ?: "系统铃声"

        result.success(
            mapOf(
                "uri" to uri.toString(),
                "title" to title
            )
        )

        return true
    }

    fun dispose() {
        stopCurrent(notifyCompleted = false)
        channel.setMethodCallHandler(null)
    }
}
