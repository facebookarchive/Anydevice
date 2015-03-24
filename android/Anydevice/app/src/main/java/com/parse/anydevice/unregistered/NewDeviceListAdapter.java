package com.parse.anydevice.unregistered;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.parse.anydevice.R;
import com.parse.anydevice.views.NewDeviceItemView;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Adapter for available devices
 */
class NewDeviceListAdapter extends RecyclerView.Adapter<NewDeviceListAdapter.NewDeviceViewHolder> {

    public static interface OnDeviceAddClickListener {
        void onAddClick(@NonNull final NewDevice device);
    }

    private final List<NewDevice> devices = Collections.synchronizedList(new ArrayList<NewDevice>());
    private OnDeviceAddClickListener addDeviceClickListener;

    @Override
    public NewDeviceViewHolder onCreateViewHolder(final ViewGroup parent, final int viewType) {
        final View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.new_device_item, parent, false);
        return new NewDeviceViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final NewDeviceViewHolder holder, final int position) {
        holder.setNewDevice(devices.get(position));
    }

    @Override
    public int getItemCount() {
        return devices.size();
    }

    public void setDevices(@NonNull final List<NewDevice> newDevices) {
        devices.clear();
        devices.addAll(newDevices);
        notifyDataSetChanged();
    }

    public void setOnDeviceAddClickListener(@NonNull final OnDeviceAddClickListener listener) {
        this.addDeviceClickListener = listener;
    }

    public void clear() {
        devices.clear();
        notifyDataSetChanged();
    }

    class NewDeviceViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        private final NewDeviceItemView view;
        private NewDevice device;

        public NewDeviceViewHolder(final View view) {
            super(view);
            this.view = (NewDeviceItemView) view;
            this.view.setOnClickListener(this);
        }

        @Override
        public void onClick(final View v) {
            addDeviceClickListener.onAddClick(device);
        }

        /**
         * Setup the view with the new device details/information
         *
         * @param newDevice The device that contains the information to display {@link NewDevice}
         */
        public void setNewDevice(@NonNull final NewDevice newDevice) {
            device = newDevice;
            view.setNewDevice(newDevice);
        }
    }

}
