package com.example.stone_deep_link

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat.startActivity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** StoneDeepLinkPlugin */
class StoneDeepLinkPlugin: FlutterPlugin, MethodCallHandler, PluginRegistry.NewIntentListener  {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var context : Context? = null
  private var channelName : String = "stone_deep_link"

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext;
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    if (call.method == "fazerPagamento") {
      sendDeeplink(
        call.argument<Int?>("amount"),
        call.argument<Boolean?>("editableAmount"),
        call.argument<String?>("transactionType"),
        call.argument<Int?>("installmentCount"),
        call.argument<String?>("installmentType"),
        call.argument<Int?>("orderId"),
        call.argument<String?>("returnScheme")
      )
      result.success(true)
    }
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else {
      result.notImplemented()
    }
  }
  private fun sendDeeplink(
    amount: Int?,
    editableAmount: Boolean?,
    transactionType: String?,
    installmentCount: Int?,
    installmentType: String?,
    orderId: Int?,
    returnScheme: String?
  ) {

    val uriBuilder = Uri.Builder()
    uriBuilder.authority("pay")
    uriBuilder.scheme("payment-app")
    uriBuilder.appendQueryParameter(RETURN_SCHEME, "flutterdeeplinkdemo")
    uriBuilder.appendQueryParameter(EDITABLE_AMOUNT, if (editableAmount == true) "1" else "0")

    if (amount != null) {
      uriBuilder.appendQueryParameter(AMOUNT, amount.toLong().toString())
    }

    if (transactionType != null) {
      uriBuilder.appendQueryParameter(TRANSACTION_TYPE, transactionType)
    }

    if (installmentType != null) {
      uriBuilder.appendQueryParameter(INSTALLMENT_TYPE, installmentType)
    }

    if (installmentCount != null) {
      uriBuilder.appendQueryParameter(INSTALLMENT_COUNT, installmentCount.toString())
    }

    if (orderId != null) {
      uriBuilder.appendQueryParameter(ORDER_ID, orderId.toLong().toString())
    }

    val intent = Intent(Intent.ACTION_VIEW)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    intent.data = uriBuilder.build()
    context?.let { startActivity(it, intent, Bundle()) }

    Log.v(TAG, "toUri(scheme = ${intent.data})")
  }

  private fun handleDeepLinkResponse(intent: Intent) {
    try {
      channel.invokeMethod("deep_link_response", intent.data.toString())
      if(context == null){
           return;
      }
      Log.i("onNewIntent", intent?.data.toString())
      if (intent?.data != null) {
        Toast.makeText(context, intent.data.toString(), Toast.LENGTH_LONG).show()
        Log.i("DeeplinkPay Response", intent.data.toString())
      }
    } catch (e: Exception) {
      Toast.makeText(context, e.toString(), Toast.LENGTH_LONG).show()
      Log.e("Deeplink error", e.toString())
    }
  }

     override fun onNewIntent(intent: Intent): Boolean {
       if (intent.action === Intent.ACTION_VIEW) {
         handleDeepLinkResponse(intent)
       }
       return  true;
  }

  companion object {
    private const val AMOUNT = "amount"
    private const val ORDER_ID = "order_id"
    private const val EDITABLE_AMOUNT = "editable_amount"
    private const val TRANSACTION_TYPE = "transaction_type"
    private const val INSTALLMENT_TYPE = "installment_type"
    private const val INSTALLMENT_COUNT = "installment_count"
    private const val RETURN_SCHEME = "return_scheme"
    private const val TAG = "SendDeeplinkPayment"
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }


}
