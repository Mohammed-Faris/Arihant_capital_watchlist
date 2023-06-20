package com.msf.acml

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import com.msf.push.service.MyFirebaseMessagingService
import com.msf.push.utils.ShieldPush
import com.msf.network.webservice.WebService

class MainActivity: FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL = "ACMLFlutterChannel"
        lateinit var methodChannel: MethodChannel
        lateinit var methodChannelResult: MethodChannel.Result
        private const val PUSH_CLICK_ACTION = "PUSH_CLICK_ACTION"
        private const val IS_FRESH_LAUNCH_KEY = "IS_FRESH_LAUNCH"
        private const val VIDEO_LINK = "VIDEO_LINK"
        var PUSH_LOGS_INTERVAL = 480
        private const val HANDLE_NOTIFICATION_CLICK = "handleNotificationClick"
    }

      override fun configureFlutterEngine( flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            methodChannelResult = result

            when (call.method) {
               "ShieldInit" -> {
                    val secretKey = call.argument<String>("secretKey") as String
                    val isCrypto = call.argument<Boolean>("isCrypto") as Boolean

                    shieldInit(isCrypto, secretKey, result)
                }
                "ShieldRegistration" -> {
                     val userName = call.argument<String>("username").toString()
                    val userType = call.argument<String>("userType").toString()
                    val appID = call.argument<String>("appID").toString()
                    val shieldPushURL = call.argument<String>("regUrl").toString()
                    val appVersion = call.argument<String>("appversion").toString()
                    shieldRegistration(appID, userName, userType, shieldPushURL, appVersion,result)
                }
                "pushLogsToServer" -> {
                    val secretKey = call.argument<String>("secretKey") as String
                    val isCrypto = call.argument<Boolean>("isCrypto") as Boolean
                    val appID = call.argument<String>("appID").toString()
                    val notifyUpdateURL = call.argument<String>("regUrl").toString()
                    sendPushLogsToServer(notifyUpdateURL, appID, isCrypto, secretKey)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onPostResume() {
        if (intent?.hasExtra(MyFirebaseMessagingService.MESSAGE_ID) == true)
            handleNotificationClick(isFreshLaunch = true)

        super.onPostResume()
    }

    override fun onNewIntent(intent: Intent) {
        if (intent.hasExtra(MyFirebaseMessagingService.MESSAGE_ID)) {
            this.intent = intent
            handleNotificationClick(isFreshLaunch = false)
        }

        super.onNewIntent(intent)
    }

    private fun handleNotificationClick(isFreshLaunch: Boolean) {
        intent?.extras?.let {

            // Sending push info to Shield SDK to update PUSH_LOG preference
            val msgID = it.getString(MyFirebaseMessagingService.MESSAGE_ID) as String
            val pushDeliveredAt = it.getLong(MyFirebaseMessagingService.DELIVERED_AT)
            ShieldPush(this).updateDeliveredPushInfo(
                msgID,
                System.currentTimeMillis(),
                pushDeliveredAt
            )

            // Send click action to flutter
            it.getString(MyFirebaseMessagingService.PUSH_CLICK_ACTION)?.let { clickAction ->
                if (clickAction.isNotEmpty()) {
                    val clickActionPair = Pair(PUSH_CLICK_ACTION, clickAction)
                    val isFreshLaunchPair = Pair(IS_FRESH_LAUNCH_KEY, isFreshLaunch)
                    var pushVideoLink = Pair(MyFirebaseMessagingService.VIDEO_LINK, "")

                    // Push Video Link
                    it.getString(VIDEO_LINK)?.let { video ->
                        if (video.isNotEmpty()) {
                            pushVideoLink = Pair(MyFirebaseMessagingService.VIDEO_LINK, video)
                        }
                    }

                    methodChannel.invokeMethod(
                        HANDLE_NOTIFICATION_CLICK,
                        hashMapOf(clickActionPair, isFreshLaunchPair, pushVideoLink)
                    )
                    intent = null
                }
            }
        }
    }

    private fun shieldInit(isCrypto: Boolean, secretKey: String, result: MethodChannel.Result) {
        val shieldPush = ShieldPush(this)
        shieldPush.initialize(
            packageName, "ic_push",
            makeLauncherToBitmap(R.drawable.ic_app_icon),
            MainActivity::class.java.name, isCrypto, secretKey
        )
        shieldPush.setClearStackOnNotificationClick(shouldClearStack = false)
        result.success(true)
    }

    private fun makeLauncherToBitmap(resID: Int): Bitmap {
        val mLargeIconWidth =
            this.resources.getDimension(R.dimen.notification_large_icon_width).toInt()
        val mLargeIconHeight =
            this.resources.getDimension(R.dimen.notification_large_icon_height).toInt()
        val drawable = ContextCompat.getDrawable(this, resID)
        val b = Bitmap.createBitmap(mLargeIconWidth, mLargeIconHeight, Bitmap.Config.ARGB_8888)
        val c = Canvas(b)
        drawable?.setBounds(0, 0, mLargeIconWidth, mLargeIconHeight)
        drawable?.draw(c)
        return b       
    }

     private fun shieldRegistration(
         appID: String,
         username: String,
         userType: String,
         regUrl: String,
         appVersion: String,
         result: MethodChannel.Result
     ) {
        ShieldPush(this, appID).register(username, userType, regUrl,appVersion)
        result.success(true)
    }

    private fun sendPushLogsToServer(
        notifyUpdateURL: String,
        appID: String,
        isCrypto: Boolean,
        secretKey: String
    ) {
        WebService.HttpConstants.isCrypto = isCrypto
        WebService.HttpConstants.cryptoKey = secretKey
        ShieldPush(this, appID).sendAllPushInfo(PUSH_LOGS_INTERVAL, notifyUpdateURL)
    }
}
