package com.example.stone_deep_link

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.util.Base64
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat.startActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream

/** StoneDeepLinkPlugin */
class StoneDeepLinkPlugin: FlutterPlugin, MethodCallHandler  {
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

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: Result) {

    if (call.method == "fazerPagamento") {
      var amount = call.argument<String?>("amount")
      var editableAmount = call.argument<String?>("editableAmount")
      var transactionType = call.argument<String?>("transactionType")
      var installmentCount =   call.argument<String?>("installmentCount")




      var installmentType =   call.argument<String?>("installmentType");
      sendDeeplink(
        amount?.toInt(),
        editableAmount?.toBoolean(),
        transactionType,
        installmentCount?.toInt(),
        installmentType,
        call.argument<String?>("orderId")?.toInt(),
        call.argument<String?>("returnScheme")
      )
      result.success(true)
    }else if(call.method == "fazerEstorno")  {
      var amount = call.argument<String>("amount")
      var editableAmount = call.argument<String?>("editableAmount")
      var atk =  call.argument<String?>("atk")
      sendDeepLinkToEstorno(
        amount!!.toInt(),
        atk!!,
        call.argument<String?>("returnScheme"),
        editableAmount!!.toBoolean()
      );

    }
    else if(call.method == "serial"){
      var data = Build.SERIAL;
      result.success(data);
    }
    else if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }
    else if(call.method == "imprimir"){
       var json = call.argument<String>("json")
        print(json);
    }
    else {
      result.notImplemented()
    }
  }

  private fun print(json: String){
    val uriBuilder = Uri.Builder()
    uriBuilder.authority("print")
    uriBuilder.scheme("printer-app")
    uriBuilder.appendQueryParameter("SHOW_FEEDBACK_SCREEN", true.toString())
    uriBuilder.appendQueryParameter("SCHEME_RETURN", "deepstone")
    uriBuilder.appendQueryParameter("PRINTABLE_CONTENT", json )

    val intent = Intent(Intent.ACTION_VIEW)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    intent.data = uriBuilder.build()
    context?.let { context?.startActivity(intent, Bundle()) }
    Log.v(TAG, "toUri(scheme = ${intent.data})")
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
    uriBuilder.appendQueryParameter(RETURN_SCHEME, returnScheme ?: "deepstone")
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
    context?.let { context?.startActivity(intent, Bundle()) }

    Log.v(TAG, "toUri(scheme = ${intent.data})")
  }

  private fun  sendDeepLinkToEstorno(
    amount: Int,
    atk: String,
    returnScheme: String?,
    editableAmount: Boolean?
  ){

    val uriBuilder = Uri.Builder()
    uriBuilder.authority("cancel")
    uriBuilder.scheme("cancel-app")
    uriBuilder.appendQueryParameter(RETURN_SCHEME, returnScheme ?: "deepstone")
    uriBuilder.appendQueryParameter(EDITABLE_AMOUNT, if (editableAmount == true) "1" else "0")
    uriBuilder.appendQueryParameter(AMOUNT, amount.toLong().toString())
    uriBuilder.appendQueryParameter(ATK, atk)


    val intent = Intent(Intent.ACTION_VIEW)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    intent.data = uriBuilder.build()
    context?.let { context?.startActivity(intent, Bundle()) }

    Log.v(TAG, "toUri(scheme = ${intent.data})")
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
    private  const val ATK = "atk"
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }


}


