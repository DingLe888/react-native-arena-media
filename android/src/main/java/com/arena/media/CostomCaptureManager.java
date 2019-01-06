package com.arena.media;

import android.app.Activity;
import android.content.Intent;

import com.journeyapps.barcodescanner.BarcodeResult;
import com.journeyapps.barcodescanner.CaptureManager;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;

public class CostomCaptureManager extends CaptureManager {
    public CostomCaptureManager(Activity activity, DecoratedBarcodeView barcodeView) {
        super(activity, barcodeView);
    }

    @Override
    protected void returnResult(BarcodeResult rawResult) {
        String str = rawResult.getText();
        RNArenaMediaModule.module.result(str);
        super.returnResult(rawResult);
    }
}
