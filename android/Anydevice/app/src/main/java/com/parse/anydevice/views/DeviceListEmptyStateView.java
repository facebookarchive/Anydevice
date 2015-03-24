package com.parse.anydevice.views;

import android.content.Context;
import android.graphics.PorterDuff;
import android.support.annotation.LayoutRes;
import android.util.AttributeSet;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.parse.anydevice.R;

/**
 * Custom view shown when a list is empty
 */
public abstract class DeviceListEmptyStateView extends RelativeLayout {
    protected TextView primaryText;
    protected InnerDrawableTextView secondaryText;
    protected ProgressBar progressBar;

    public DeviceListEmptyStateView(final Context context, @LayoutRes final int layoutRes) {
        super(context);
        init(layoutRes);
    }

    public DeviceListEmptyStateView(final Context context, final AttributeSet attrs, @LayoutRes final int layoutRes) {
        super(context, attrs);
        init(layoutRes);
    }

    public DeviceListEmptyStateView(final Context context, final AttributeSet attrs, final int defStyleAttr, @LayoutRes final int layoutRes) {
        super(context, attrs, defStyleAttr);
        init(layoutRes);
    }

    /**
     * Find all the views and tint the progress bar programmatically (xml tint not available below API 21)
     *
     * @param layoutRes The particular layout to inflate for this view (passed up from descendant)
     */
    private void init(@LayoutRes final int layoutRes) {
        inflate(getContext(), layoutRes, this);
        primaryText = (TextView) findViewById(R.id.empty_list_primary);
        secondaryText = (InnerDrawableTextView) findViewById(R.id.empty_list_secondary);
        progressBar = (ProgressBar) findViewById(R.id.progress_bar);
        progressBar.getIndeterminateDrawable().setColorFilter(getResources().getColor(R.color.white), PorterDuff.Mode.SRC_IN);
        setupInitialState();
    }

    protected abstract void setupInitialState();
}
