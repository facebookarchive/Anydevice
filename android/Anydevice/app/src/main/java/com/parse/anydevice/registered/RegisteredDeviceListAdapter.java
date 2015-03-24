package com.parse.anydevice.registered;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.anydevice.R;
import com.parse.anydevice.models.Installation;
import com.parse.anydevice.models.Model;
import com.parse.anydevice.models.UserSession;
import com.parse.anydevice.views.RegisteredDeviceItemView;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Adapter for all devices registered to the current user
 */
class RegisteredDeviceListAdapter extends RecyclerView.Adapter<RegisteredDeviceListAdapter.RegisteredDeviceViewHolder> {

    public static interface OnDeviceClickListener {
        void onDeviceClicked(final Installation installation);
    }

    private final List<Installation> installations = Collections.synchronizedList(new ArrayList<Installation>());
    private OnDeviceClickListener deviceClickListener;

    public RegisteredDeviceListAdapter() {}

    @Override
    public RegisteredDeviceViewHolder onCreateViewHolder(final ViewGroup parent, final int viewType) {
        final View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.device_item, parent, false);
        return new RegisteredDeviceViewHolder(view);
    }

    @Override
    public void onBindViewHolder(final RegisteredDeviceViewHolder holder, final int position) {
        holder.setInstallation(installations.get(position));
    }

    @Override
    public int getItemCount() {
        return installations.size();
    }

    public void setInstallations(@NonNull final List<Installation> newInstallations) {
        installations.clear();
        installations.addAll(newInstallations);
        notifyDataSetChanged();
    }

    public void setOnDeviceClickListener(@NonNull final OnDeviceClickListener listener) {
        this.deviceClickListener = listener;
    }

    /**
     * Make a request to the Parse.com cloud to fetch all device {@link Installation}s that correspond to the current user
     */
    public void loadObjects() {
        final ParseQuery<UserSession> query = ParseQuery.getQuery(UserSession.class);
        query.setCachePolicy(ParseQuery.CachePolicy.CACHE_THEN_NETWORK);

        final ParseQuery<Installation> installationParseQuery = ParseQuery.getQuery(Installation.class);
        installationParseQuery.whereMatchesKeyInQuery(Installation.INSTALLATION_ID, UserSession.INSTALLATION_ID, query);
        installationParseQuery.whereEqualTo(Installation.DEVICE_TYPE, "embedded");
        installationParseQuery.whereExists(Installation.MODEL);
        installationParseQuery.include(Installation.MODEL);
        installationParseQuery.include(Installation.LATEST_EVENT);

        installationParseQuery.findInBackground(new FindCallback<Installation>() {
            @Override
            public void done(final List<Installation> installations, final ParseException e) {
                if (e == null) {
                    setInstallations(installations);
                } else {
                    e.printStackTrace();
                }
            }
        });
    }

    class RegisteredDeviceViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        private final RegisteredDeviceItemView view;
        private Installation installation;

        public RegisteredDeviceViewHolder(final View view) {
            super(view);
            this.view = (RegisteredDeviceItemView) view;
            this.view.setOnClickListener(this);
        }

        @Override
        public void onClick(final View v) {
            deviceClickListener.onDeviceClicked(installation);
        }

        public void setInstallation(@NonNull final Installation installation) {
            this.installation = installation;
            final Model model = installation.getModel();
            this.view.setDevice(model, installation.getDeviceName(), model.getBoardType(), installation.hasRecentEvent());
        }
    }
}
