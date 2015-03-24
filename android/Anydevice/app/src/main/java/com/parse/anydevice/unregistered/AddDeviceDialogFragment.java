package com.parse.anydevice.unregistered;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.StringRes;
import android.support.v4.app.DialogFragment;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Spinner;

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.anydevice.R;
import com.parse.anydevice.models.InfrastructureKey;
import com.parse.anydevice.models.Model;
import com.parse.anydevice.provisioning.DeviceConfig;
import com.parse.anydevice.provisioning.NetworkInfrastructure;
import com.parse.anydevice.provisioning.ProvisioningCallback;
import com.parse.anydevice.provisioning.ProvisioningDispatcher;
import com.parse.anydevice.registered.RegisteredDevicesActivity;

import java.util.List;

/**
 * Dialog for provisioning a device
 */
public class AddDeviceDialogFragment extends DialogFragment implements ProvisioningCallback {
    private static final String TAG = AddDeviceDialogFragment.class.getName();
    public static final String ARGS_SSID = "arg_ssid";
    public static final String ARGS_BSSID = "arg_bssid";
    public static final String ARGS_APP_NAME = "arg_app_name";
    public static final String ARGS_BOARD_TYPE = "arg_board_type";

    private Model model;
    private DeviceApConfig deviceApConfig;
    private String currentSsid, currentBssid;
    private InfrastructureKey restoredNetwork;
    private ProvisioningDispatcher provisioningDispatcher;

    private EditText deviceNameEditText, networkSsidEditText, passwordEditText;
    private Spinner securitySpinner;
    private CheckBox saveWifiConfigCheckBox;
    private Button addButton, cancelButton;
    private ProgressDialog progressDialog;

    @Override
    public void onAttach(final Activity activity) {
        super.onAttach(activity);
        getCurrentWifi();
        provisioningDispatcher = new ProvisioningDispatcher(getActivity());
    }

    @Override
    public void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final Bundle args = getArguments();
        if (null != args) {
            final String bssid = args.getString(ARGS_BSSID);
            final String ssid = args.getString(ARGS_SSID);
            final String modelAppName = args.getString(ARGS_APP_NAME);
            final String defaultDeviceName = String.format(getResources().getString(R.string.device_title_format), ParseUser.getCurrentUser().getUsername(), args.getString(ARGS_BOARD_TYPE));
            deviceApConfig = new DeviceApConfig(ssid, bssid, modelAppName, defaultDeviceName);
            Model.getQuery().findInBackground(new FindCallback<Model>() {
                @Override
                public void done(final List<Model> models, final ParseException e) {
                    if (e == null) {
                        Model defaultModel = null;
                        for (Model m : models) {
                            if (deviceApConfig.modelAppName.equals(m.getAppName())) {
                                model = m;
                            }
                            if (m.isDefault()) {
                                defaultModel = m;
                            }
                        }
                        if (model == null) {
                            model = defaultModel;
                        }
                    } else {
                        Log.e(TAG, "Failed to get models", e);
                    }
                }
            });
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        final Context contextThemeWrapper = new ContextThemeWrapper(getActivity(), R.style.Theme_App_Impl);
        final LayoutInflater localInflater = inflater.cloneInContext(contextThemeWrapper);
        final View view = localInflater.inflate(R.layout.fragment_add_device, container, false);
        deviceNameEditText = (EditText) view.findViewById(R.id.add_device_name);
        networkSsidEditText = (EditText) view.findViewById(R.id.network_ssid);
        passwordEditText = (EditText) view.findViewById(R.id.network_password);
        saveWifiConfigCheckBox = (CheckBox) view.findViewById(R.id.save_infra_key);
        addButton = (Button) view.findViewById(R.id.add);
        cancelButton = (Button) view.findViewById(R.id.cancel);
        securitySpinner = (Spinner) view.findViewById(R.id.network_security);
        return view;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        getDialog().setTitle(R.string.set_up_device);

        deviceNameEditText.setText(deviceApConfig.defaultDeviceName);
        networkSsidEditText.setText(currentSsid);

        setupErrors(deviceNameEditText, R.string.required_device_name);
        setupErrors(networkSsidEditText, R.string.required_network_ssid);
        setupErrors(passwordEditText, R.string.required_network_password);

        securitySpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position == 0) {
                    passwordEditText.setVisibility(View.GONE);
                } else {
                    passwordEditText.setVisibility(View.VISIBLE);
                }
                updateFormErrors();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });

        populateInfrastructureFields();
        addButton.setOnClickListener(new AddButtonClickListener());
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                dismiss();
            }
        });
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        deviceNameEditText = null;
        networkSsidEditText = null;
        passwordEditText = null;
        saveWifiConfigCheckBox = null;
        addButton = null;
        cancelButton = null;
        securitySpinner = null;
    }

    @Override
    public void success() {
        progressDialog.dismiss();
        final Intent back = new Intent(getActivity(), RegisteredDevicesActivity.class);
        back.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(back);
    }

    @Override
    public void failure() {
        progressDialog.dismiss();
        dismiss();
    }

    private void getCurrentWifi() {
        final WifiManager wifiManager = (WifiManager) getActivity().getSystemService(Context.WIFI_SERVICE);
        final WifiInfo info = wifiManager.getConnectionInfo();
        if (info != null) {
            currentSsid = info.getSSID().replace("\"", "");
            currentBssid = info.getBSSID();
        } else {
            currentSsid = "";
            currentBssid = "";
        }
    }

    /**
     * Validates that the there is a device name and that the network credentials are filled
     * out properly
     */
    private void updateFormErrors() {
        if (editTextHasValue(deviceNameEditText) && editTextHasValue(networkSsidEditText)) {
            if (securitySpinner.getSelectedItemPosition() == 0) {
                addButton.setEnabled(true);
            } else if (editTextHasValue(passwordEditText)) {
                addButton.setEnabled(true);
            } else {
                addButton.setEnabled(false);
            }
        } else {
            addButton.setEnabled(false);
        }
    }

    /**
     * Adds the change listeners to the edit texts, binding the error checker
     *
     * @param editText The edit text to display errors for
     * @param error    The string resource id for the error text
     */
    private void setupErrors(@NonNull final EditText editText, @StringRes final int error) {
        editText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                maybeShowError(editText, error);
            }
        });
        maybeShowError(editText, error);
    }

    /**
     * Show an error and disable add button if there is an error in the form.
     *
     * @param editText The edit text to display errors for
     * @param error    The string resource id for the error text
     */
    private void maybeShowError(final EditText editText, @StringRes final int error) {
        if (!editTextHasValue(editText)) {
            editText.setError(getString(error));
            addButton.setEnabled(false);
        } else {
            editText.setError(null);
            updateFormErrors();
        }
    }

    /**
     * Check if an editText view has a value
     *
     * @param editText The edit text to check the size of
     *
     * @return returns false if the EditText is empty
     */
    private static boolean editTextHasValue(@NonNull final EditText editText) {
        return editText.getText().toString().length() > 0;
    }

    private class AddButtonClickListener implements View.OnClickListener {
        @Override
        public void onClick(View v) {
            showProgressDialog();
            final String deviceName = deviceNameEditText.getText().toString();
            final String ssid = networkSsidEditText.getText().toString();
            final int securityType = securitySpinner.getSelectedItemPosition() + 1;
            final String password = passwordEditText.getText().toString();

            maybeSaveNetwork(ssid, securityType, password);
            beginProvisioning(deviceName, ssid, securityType, password);
        }
    }

    private void maybeSaveNetwork(final String ssid, final int securityType, final String password) {
        if (saveWifiConfigCheckBox.isChecked()) {
            if (restoredNetwork == null) {
                // You can only save the network credentials in the case that you are connected to that network
                if (currentSsid.equals(ssid)) {
                    final InfrastructureKey key = new InfrastructureKey();
                    key.setACL(new ParseACL(ParseUser.getCurrentUser()));
                    key.setSsid(currentSsid);
                    key.setBssid(currentBssid);
                    key.setKey(password);
                    key.setSecurity(securityType);
                    key.saveInBackground();
                }
            } else {
                // even if we stored the object before we might need to update
                // password and security on the server in case it changed.
                restoredNetwork.setKey(password);
                restoredNetwork.setSecurity(securityType);
                restoredNetwork.saveInBackground();
            }
        }
    }

    private void beginProvisioning(final String deviceName, final String ssid, final int securityType, final String password) {
        final DeviceConfig config = new DeviceConfig();
        config.setName(deviceName);
        config.setSsid(deviceApConfig.ssid);
        config.setBssid(deviceApConfig.bssid);
        config.setModel(model);

        final NetworkInfrastructure networkInfrastructure = new NetworkInfrastructure();
        networkInfrastructure.setSsid(ssid);
        networkInfrastructure.setPassword(password);
        networkInfrastructure.setSecurity(securityType);

        provisioningDispatcher.beginProvisioning(config, networkInfrastructure, this);
    }

    /**
     * Displays a dialog with a progress bar and message
     */
    private void showProgressDialog() {
        progressDialog = new ProgressDialog(getActivity());
        progressDialog.setIndeterminate(true);
        progressDialog.setCancelable(false);
        progressDialog.setMessage(getString(R.string.progress_setup_message));
        progressDialog.show();
    }

    /**
     * Queries Parse to try to obtain old Wi-Fi information that it will populate the fields with
     */
    private void populateInfrastructureFields() {
        final ParseQuery<InfrastructureKey> query = InfrastructureKey.getQuery();
        query.whereEqualTo(InfrastructureKey.SSID, currentSsid);
        query.whereEqualTo(InfrastructureKey.BSSID, currentBssid);
        query.getFirstInBackground(new GetCallback<InfrastructureKey>() {
            @Override
            public void done(final InfrastructureKey infrastructureKey, final ParseException e) {
                if (e == null) {
                    restoredNetwork = infrastructureKey;
                    passwordEditText.setText(restoredNetwork.getKey());
                    securitySpinner.setSelection(restoredNetwork.getSecurity() - 1);

                }
            }
        });
    }

    private static class DeviceApConfig {
        public final String bssid, ssid, modelAppName, defaultDeviceName;

        public DeviceApConfig(@NonNull final String ssid, @NonNull final String bssid, @NonNull final String modelAppName, @NonNull final String defaultDeviceName) {
            this.ssid = ssid;
            this.bssid = bssid;
            this.modelAppName = modelAppName;
            this.defaultDeviceName = defaultDeviceName;
        }
    }
}
