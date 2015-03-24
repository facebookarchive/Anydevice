/*
 *  Copyright (c) 2014, Parse, LLC. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Parse.
 *
 *  As with any software that integrates with the Parse platform, your use of
 *  this software is subject to the Parse Terms of Service
 *  [https://www.parse.com/about/terms]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

package com.parse.anydevice.login;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.parse.LogInCallback;
import com.parse.ParseException;
import com.parse.ParseUser;
import com.parse.anydevice.R;

/**
 * Fragment for the user login screen.
 */
public class ParseLoginFragment extends ParseLoginFragmentBase {

    public interface ParseLoginFragmentListener {
        public void onSignUpClicked(String username, String password);

        public void onLoginHelpClicked();

        public void onLoginSuccess();
    }

    private static final String LOG_TAG = "ParseLoginFragment";

    private View parseLogin;
    private EditText usernameField;
    private EditText passwordField;
    private TextView parseLoginHelpButton;
    private Button parseLoginButton;
    private Button parseSignupButton;
    private ParseLoginFragmentListener loginFragmentListener;
    private ParseOnLoginSuccessListener onLoginSuccessListener;

    public static ParseLoginFragment newInstance(Bundle configOptions) {
        ParseLoginFragment loginFragment = new ParseLoginFragment();
        loginFragment.setArguments(configOptions);
        return loginFragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup parent, Bundle savedInstanceState) {

        View v = inflater.inflate(R.layout.com_parse_ui_parse_login_fragment, parent, false);
        parseLogin = v.findViewById(R.id.parse_login);
        usernameField = (EditText) v.findViewById(R.id.login_username_input);
        passwordField = (EditText) v.findViewById(R.id.login_password_input);
        parseLoginHelpButton = (Button) v.findViewById(R.id.parse_login_help);
        parseLoginButton = (Button) v.findViewById(R.id.parse_login_button);
        parseSignupButton = (Button) v.findViewById(R.id.parse_signup_button);

        setUpParseLoginAndSignup();
        return v;
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);

        if (activity instanceof ParseLoginFragmentListener) {
            loginFragmentListener = (ParseLoginFragmentListener) activity;
        } else {
            throw new IllegalArgumentException("Activity must implemement ParseLoginFragmentListener");
        }

        if (activity instanceof ParseOnLoginSuccessListener) {
            onLoginSuccessListener = (ParseOnLoginSuccessListener) activity;
        } else {
            throw new IllegalArgumentException("Activity must implemement ParseOnLoginSuccessListener");
        }

        if (activity instanceof ParseOnLoadingListener) {
            onLoadingListener = (ParseOnLoadingListener) activity;
        } else {
            throw new IllegalArgumentException("Activity must implemement ParseOnLoadingListener");
        }
    }

    @Override
    protected String getLogTag() {
        return LOG_TAG;
    }

    private void setUpParseLoginAndSignup() {
        parseLogin.setVisibility(View.VISIBLE);

        parseLoginButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                String username = usernameField.getText().toString();
                String password = passwordField.getText().toString();

                if (username.length() == 0) {
                    showToast(R.string.com_parse_ui_no_username_toast);
                } else if (password.length() == 0) {
                    showToast(R.string.com_parse_ui_no_password_toast);
                } else {
                    loadingStart(true);
                    ParseUser.logInInBackground(username, password, new LogInCallback() {
                        @Override
                        public void done(ParseUser user, ParseException e) {
                            if (isActivityDestroyed()) {
                                return;
                            }

                            if (user != null) {
                                loadingFinish();
                                loginSuccess();
                            } else {
                                loadingFinish();
                                if (e != null) {
                                    debugLog(getString(R.string.com_parse_ui_login_warning_parse_login_failed) + e.toString());
                                    if (e.getCode() == ParseException.OBJECT_NOT_FOUND) {
                                        showToast(R.string.com_parse_ui_parse_login_invalid_credentials_toast);
                                        passwordField.selectAll();
                                        passwordField.requestFocus();
                                    } else {
                                        showToast(R.string.com_parse_ui_parse_login_failed_unknown_toast);
                                    }
                                }
                            }
                        }
                    });
                }
            }
        });

        parseSignupButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                String username = usernameField.getText().toString();
                String password = passwordField.getText().toString();

                loginFragmentListener.onSignUpClicked(username, password);
            }
        });

        parseLoginHelpButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                loginFragmentListener.onLoginHelpClicked();
            }
        });
    }

    private void loginSuccess() {
        onLoginSuccessListener.onLoginSuccess();
    }

}
