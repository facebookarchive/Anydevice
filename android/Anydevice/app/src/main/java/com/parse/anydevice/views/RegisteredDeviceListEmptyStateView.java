package com.parse.anydevice.views;

import android.content.Context;
import android.support.annotation.LayoutRes;
import android.util.AttributeSet;
import android.view.View;

import com.parse.anydevice.R;

/**
 * Empty state view for list of registered devices
 */
public class RegisteredDeviceListEmptyStateView extends DeviceListEmptyStateView {
    @LayoutRes
    private static final int layoutRes = R.layout.layout_empty_state_registered;

    public RegisteredDeviceListEmptyStateView(final Context context) {
        super(context, layoutRes);
    }

    public RegisteredDeviceListEmptyStateView(final Context context, final AttributeSet attrs) {
        super(context, attrs, layoutRes);
    }

    public RegisteredDeviceListEmptyStateView(final Context context, final AttributeSet attrs, final int defStyleAttr) {
        super(context, attrs, defStyleAttr, layoutRes);
    }

    /**
     * There is only one state for this view
     */
    @Override
    protected void setupInitialState() {
        progressBar.setVisibility(View.GONE);
        primaryText.setText(R.string.empty_registered_device_list);
        secondaryText.setText(R.string.empty_registered_device_list_secondary);
    }
}
