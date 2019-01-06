package com.arena.media;

import android.graphics.Bitmap;
import android.graphics.Matrix;

/**
 * Created by seven on 2017/9/30.
 */

public class BitmapUtil {

    /**
     * 压缩图片
     * @param bitmap
     * @return
     */
    public static Bitmap getSmallerBitmap(Bitmap bitmap) {
        int size = bitmap.getWidth() * bitmap.getHeight() / 160000;
        if (size <= 1) {
            return bitmap; // 如果小于
        } else {
            Matrix matrix = new Matrix();
            matrix.postScale((float) (1 / Math.sqrt(size)), (float) (1 / Math.sqrt(size)));
            Bitmap resizeBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
            return resizeBitmap;
        }
    }

}
