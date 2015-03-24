package com.parse.anydevice.views;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.drawable.Drawable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.util.AttributeSet;
import android.widget.TextView;

import com.parse.anydevice.R;

public class InnerDrawableTextView extends TextView {
    private Drawable drawable;

    public InnerDrawableTextView(final Context context) {
        super(context);
    }

    public InnerDrawableTextView(final Context context, final AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public InnerDrawableTextView(final Context context, final AttributeSet attrs, final int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(attrs);
    }

    /**
     * Extract the drawable attribute if it has one and store that drawable
     *
     * @param attrs {@link AttributeSet}
     */
    private void init(final AttributeSet attrs) {
        final TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.InnerDrawableTextView);
        final int drawableId = a.getResourceId(R.styleable.InnerDrawableTextView_drawable, -1);
        if (drawableId > 0) {
            drawable = getContext().getResources().getDrawable(drawableId);
        }
        a.recycle();
    }

    /**
     * When we set the text on the text view, we want to replace the placeholder with an ImageSpan
     */
    @Override
    public void setText(final CharSequence text, final BufferType type) {
        String string = text.toString();
        final int replacePos = string.indexOf("%s");
        if (replacePos >= 0) {
            string = string.replaceFirst("%s", " ");
            final SpannableString spannable = new SpannableString(string);
            final Drawable d = drawable;
            d.setBounds(0, 0, d.getIntrinsicWidth(), d.getIntrinsicHeight());
            final ImageSpan span = new ImageSpan(d, ImageSpan.ALIGN_BOTTOM);
            spannable.setSpan(span, replacePos, replacePos + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
            super.setText(spannable);
        } else {
            super.setText(text, type);
        }
    }
}
