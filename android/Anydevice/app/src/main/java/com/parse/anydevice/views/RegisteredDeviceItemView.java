package com.parse.anydevice.views;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.parse.ParseImageView;
import com.parse.anydevice.R;
import com.parse.anydevice.models.Event;
import com.parse.anydevice.models.Model;

/**
 * Registered device view for use in list
 */
public class RegisteredDeviceItemView extends RelativeLayout {
    private ParseImageView image;
    private TextView name, type;
    private View error;

    public RegisteredDeviceItemView(Context context) {
        super(context);
    }

    public RegisteredDeviceItemView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public RegisteredDeviceItemView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        image = (ParseImageView) findViewById(R.id.item_device_image);
        name = (TextView) findViewById(R.id.item_device_name);
        type = (TextView) findViewById(R.id.item_device_type);
        error = findViewById(R.id.error);
    }

    /**
     * Populate views with data
     *
     * @param deviceModel    {@link Model} representing board
     * @param deviceName     Name of the device
     * @param boardType      Model name of the board
     * @param hasRecentEvent Whether we have a recent {@link Event}; if not show an error indicator
     */
    public void setDevice(@NonNull final Model deviceModel, @NonNull final String deviceName, @NonNull final String boardType, final boolean hasRecentEvent) {
        Model.putLogoIntoImageView(deviceModel, image, R.drawable.board_icon_list);
        name.setText(deviceName);
        type.setText(boardType);
        error.setVisibility(hasRecentEvent ? View.INVISIBLE : View.VISIBLE);
    }
}
