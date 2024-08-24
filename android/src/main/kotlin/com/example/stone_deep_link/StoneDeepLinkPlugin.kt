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
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream

import android.view.View
import android.widget.Toast
import java.lang.Exception
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
        print();
    }
    else {
      result.notImplemented()
    }
  }

  private fun print(){

    val pathJpg =
      Environment.getExternalStorageDirectory().absolutePath + "/download/comprovante2.jpg"
    val bm: Bitmap = BitmapFactory.decodeFile(pathJpg)
    val baos = ByteArrayOutputStream()
    bm.compress(Bitmap.CompressFormat.JPEG, 100, baos) // bm is the bitmap object

    val b: ByteArray = baos.toByteArray()

    val encodedImage: String = Base64.encodeToString(b, Base64.DEFAULT)


    val uriBuilder = Uri.Builder()
    uriBuilder.authority("print")
    uriBuilder.scheme("printer-app")
    uriBuilder.appendQueryParameter("SHOW_FEEDBACK_SCREEN", true.toString())
    uriBuilder.appendQueryParameter("SCHEME_RETURN", "deepstone")
    uriBuilder.appendQueryParameter("PRINTABLE_CONTENT", "[\n" +
            "  {\n" +
            "    \"type\": \"image\",\n" +
            "    \"imagePath\": \"iVBORw0KGgoAAAANSUhEUgAAAHcAAAAuCAAAAAA309lpAAACMklEQVRYw91YQXLDIAyUMj027Us606f6RL7lJP0Ise/bg7ERSLLdZkxnyiVGIK0AoRVh0J+0l2ZITCAmSus8tYNNv9wUl8Xn2A6XZec8tsK9lN0zEaFBCxMc0M3IoHawBAAxffLx9/frY1kkEV0/iYjC8bjjmSRuCrHjcXMoS9zD4/nqePNf10v2whrkDRjLR4t8BWPXbdyRmccDgBMZUXDiiv2DeSK4sKwWrfgIda8V/6L6blZvLMARTescAohCD7xlcsItjYXEXHn2LIESzO3mDARPYTJXwiQ/VgWFobsYGKRdRy5x6/1QuAPpKdq89MiTS1x9EBXuYJyVZd46p6ndXVwAqfwJpd4C20uLk/LsUIilQ5Q11A4tuIU8Ti4bi8oz6lNX8iD8rNUdXDm3iMs81le4pUOLOJrGatzBx1VqVRSU8qAdNRc855GwHxcFblQbYTvqx3M0ZxZnZeBq+UoayI0h3y7QPMhOyQA9JMkO9aMIqs6Rmrw73T6ey9anvDX5kbinvT2PW7yYzj8ogrcYqBOJjNxc21d5EjmH0e/iaqUV9dXj3YgYtkvCjbjaqs5O+85MxVvwTcZdhR5YuFbckCSfNkHUolTcE9Cq9iQfXtV62bo9nUBIm8AXedPidimVFIjZCdYlTw4W8RtsatKC7Bt7D4t5tMle9qPD+y4uyL81FS/UnnVu3eMzhuj3G7CqzkHF77ISsaoraSsqVnRhq3rSZ+F5Ur//b5zOOVoAwDc6szxdC+PYAAAAAABJRU5ErkJggg==\"\n" +
            "  }\n" +
            "]")

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


