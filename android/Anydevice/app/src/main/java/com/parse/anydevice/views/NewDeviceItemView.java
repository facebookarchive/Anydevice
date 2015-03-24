package com.parse.anydevice.views;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.parse.anydevice.unregistered.NewDevice;
import com.parse.anydevice.R;

/**
 * Item view for provisioning list of devices
 */
public class NewDeviceItemView extends RelativeLayout {

    private TextView title, description;

    public NewDeviceItemView(Context context) {
        super(context);
    }

    public NewDeviceItemView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public NewDeviceItemView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        title = (TextView) findViewById(R.id.title);
        description = (TextView) findViewById(R.id.description);
    }

    /**
     * Populate views
     *
     * @param newDevice {@link NewDevice} to get data from
     */
    public void setNewDevice(@NonNull final NewDevice newDevice) {
        title.setText(newDevice.getTitle());
        description.setText(newDevice.getBoardType());
    }

}
