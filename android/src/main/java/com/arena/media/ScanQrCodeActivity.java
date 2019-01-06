package com.arena.media;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.FormatException;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.NotFoundException;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Reader;
import com.google.zxing.Result;
import com.google.zxing.client.android.Intents;
import com.google.zxing.common.HybridBinarizer;
import com.journeyapps.barcodescanner.CaptureManager;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;

import java.io.IOException;

/**
 *
 */
public class ScanQrCodeActivity extends Activity implements View.OnClickListener, DecoratedBarcodeView.TorchListener {


    private final static String TAG = ScanQrCodeActivity.class.getSimpleName();

    private CaptureManager capture;
    private DecoratedBarcodeView barcodeScannerView;
    private LinearLayout layoutTorch;
    private LinearLayout layoutPicture;
    private TextView tvTorch;
    private TextView tvPicture;
    private TextView tvBack;
    private boolean isTorchOn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_scan_qrcode);
        barcodeScannerView = (DecoratedBarcodeView) findViewById(R.id.zxing_barcode_scanner);
        barcodeScannerView.setTorchListener(this);

        capture = new CostomCaptureManager(this, barcodeScannerView);
        capture.initializeFromIntent(getIntent(), savedInstanceState);
        capture.decode();


        init();

    }

    private void init() {
        layoutTorch = (LinearLayout) findViewById(R.id.layout_torch);
        layoutPicture = (LinearLayout) findViewById(R.id.layout_picture);
        tvTorch = (TextView) findViewById(R.id.tv_torch);
        tvPicture = (TextView) findViewById(R.id.tv_picture);
        tvBack = (TextView) findViewById(R.id.tv_back);
        IconFont.encodeView("e6b2", tvTorch);
        IconFont.encodeView("e670", tvPicture);
        IconFont.encodeView("e648", tvBack);
        layoutTorch.setOnClickListener(this);
        layoutPicture.setOnClickListener(this);
        tvBack.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {

        int _id = v.getId();
        if (_id == R.id.layout_torch) {
            if (isTorchOn) {
                barcodeScannerView.setTorchOff();
            } else {
                barcodeScannerView.setTorchOn();
            }
        } else if (_id == R.id.layout_picture) {
            //打开手机的图库;
            Intent intent = new Intent();
            intent.setType("image/*");
            intent.setAction(Intent.ACTION_GET_CONTENT);
            startActivityForResult(intent, 0x1);
        } else if (_id == R.id.tv_back) {
            this.finish();
        }

    }

    @Override
    public void onTorchOn() {
        isTorchOn = true;
        IconFont.encodeView("e6b3", tvTorch);
    }

    @Override
    public void onTorchOff() {
        isTorchOn = false;
        IconFont.encodeView("e6b2", tvTorch);
    }


    @Override
    protected void onResume() {
        super.onResume();
        capture.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        capture.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        capture.onDestroy();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        capture.onSaveInstanceState(outState);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return barcodeScannerView.onKeyDown(keyCode, event) || super.onKeyDown(keyCode, event);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Uri sourceUri = null;
        Log.i("seven", "requestCode:" + requestCode + " , resultCode:" + resultCode);

        if (resultCode == RESULT_OK) {

            // 首先获取到此图片的Uri
            sourceUri = data.getData();

            try {
                // 下面这句话可以通过URi获取到文件的bitmap
                Bitmap bitmap = MediaStore.Images.Media.getBitmap(this.getContentResolver(), sourceUri);

                bitmap = BitmapUtil.getSmallerBitmap(bitmap);

                // 获取bitmap的宽高，像素矩阵
                int width = bitmap.getWidth();
                int height = bitmap.getHeight();
                int[] pixels = new int[width * height];
                bitmap.getPixels(pixels, 0, width, 0, 0, width, height);

                // 最新的库中，RGBLuminanceSource 的构造器参数不只是bitmap了
                RGBLuminanceSource source = new RGBLuminanceSource(width, height, pixels);
                BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(source));
                Reader reader = new MultiFormatReader();
                Result result = null;

                // 尝试解析此bitmap，！！注意！！ 这个部分一定写到外层的try之中，因为只有在bitmap获取到之后才能解析。写外部可能会有异步的问题。（开始解析时bitmap为空）
                try {
                    result = reader.decode(binaryBitmap);
//                    Intent intent = new Intent();
//                    intent.putExtra(Intents.Scan.RESULT, result.getText());
//                    this.setResult(RESULT_OK, intent);
                    RNArenaMediaModule.module.result(result.getText());
                    finish();
                } catch (NotFoundException e) {
                    Toast.makeText(this, "未识别到二维码/条码", Toast.LENGTH_SHORT).show();
                    Log.i(TAG, "onActivityResult: notFind");
                    e.printStackTrace();
                } catch (ChecksumException e) {
                    e.printStackTrace();
                } catch (FormatException e) {
                    e.printStackTrace();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

}
