package com.arena.media;

import android.content.Context;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.widget.TextView;


/**
 * Created by seven on 2017/6/19.
 */

public class IconFont {

    public static String encode(String code){
        if (TextUtils.isEmpty(code)) {
            return "";
        }
        String type = "\\u" + code;
        return decodeUnicode(type);
    }

    public static void encodeView(String code, TextView view) {
        if (TextUtils.isEmpty(code)) {
            return;
        }

        Typeface typeface = getTypeface(view.getContext());
        view.setTypeface(typeface);
        String type = "\\u" + code;
        if (view != null) {
            view.setText(decodeUnicode(type));
        }
    }

    private static String decodeUnicode(final String dataStr) {
        int start = 0;
        int end = 0;
        final StringBuffer buffer = new StringBuffer();
        while (start > -1) {
            end = dataStr.indexOf("\\u", start + 2);
            String charStr = "";
            if (end == -1) {
                charStr = dataStr.substring(start + 2, dataStr.length());
            } else {
                charStr = dataStr.substring(start + 2, end);
            }
            char letter = (char) Integer.parseInt(charStr, 16); // 16进制parse整形字符串。
            buffer.append(new Character(letter).toString());
            start = end;
        }
        return buffer.toString();
    }

    public static Typeface getTypeface(Context context) {

        Typeface typeface = null;
        try {
            typeface = Typeface.createFromAsset(context.getAssets(), "iconfont/iconfont.ttf");
        }catch(Exception e) {

            e.printStackTrace();
        }

        return typeface;

    }

}
