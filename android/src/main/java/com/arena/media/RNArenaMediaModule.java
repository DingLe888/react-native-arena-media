
package com.arena.media;

import android.app.Activity;
import android.content.Intent;
import android.os.Looper;
import android.text.TextUtils;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

public class RNArenaMediaModule extends ReactContextBaseJavaModule {

    public static RNArenaMediaModule module;
  private final ReactApplicationContext reactContext;
  private Promise promise = null;

  public RNArenaMediaModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
      RNArenaMediaModule.module = this;

  }

  @Override
  public String getName() {
    return "RNArenaMedia";
  }

  @ReactMethod
  public void scanQRCode(ReadableMap data, Promise promise){

      this.promise = promise;

      final ReactContext context = this.reactContext;


      this.reactContext.runOnUiQueueThread(new Runnable() {
          @Override
          public void run() {
              Activity activity = getCurrentActivity();

              Intent intent = new Intent(context,ScanQrCodeActivity.class);
              intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
              activity.startActivityForResult(intent,200);
//              context.startActivityForResult(intent,300,null);
          }
      });

  }

  public void result(String text){
      this.promise.resolve(text);
  }


}