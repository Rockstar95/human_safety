package com.example.human_safety

import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val sendSmsCHANNEL = "sendSms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, sendSmsCHANNEL).setMethodCallHandler { call: MethodCall, result ->
            if (call.method.equals("send")) {
                val num: String? = call.argument("phone")
                val msg: String? = call.argument("msg")

                if(num != null && msg != null) {
                    sendSMS(num, msg, result)
                }
                else {
                    result.error("Invalid Data", "Invalid Number or Message", "")
                }
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun sendSMS(phoneNo: String, msg: String, result: MethodChannel.Result) {
        try {
            val smsManager: SmsManager = SmsManager.getDefault()
            smsManager.sendTextMessage(phoneNo, null, msg, null, null)
            result.success("SMS Sent")
        }
        catch (ex: Exception) {
            ex.printStackTrace()
            result.error("Err", "Sms Not Sent", "")
        }
    }
}
