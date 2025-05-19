package com.aryanrogye.comfyremotetv;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.aryanrogye.comfyremotetv.client.Client;

import org.w3c.dom.Text;

import java.util.concurrent.atomic.AtomicBoolean;

public class MainActivity extends Activity {

    Client client = new Client();
    AtomicBoolean serverStarted = new AtomicBoolean(false);
    TextView serverStatus, ipText, portText;
    String ip = "192.168.68.98";
    int port = 50505;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.e("MainActivity", "onCreate() reached");
        super.onCreate(savedInstanceState);

        ///  Root Layout
        LinearLayout rootLayout = new LinearLayout(this);
        rootLayout.setOrientation(LinearLayout.HORIZONTAL);
        rootLayout.setBackgroundColor(0xFF000000);

        TextView tv = new TextView(this);
        tv.setText("Hello from Javaaa!");
        tv.setTextColor(0xFFFFFFFF);
        tv.setTextSize(32);

        LinearLayout serverLayout = buildServerLayout();

        /// Together Splitting 50/50
        LinearLayout.LayoutParams leftParams = new LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.MATCH_PARENT,
                1f
        );
        LinearLayout.LayoutParams rightParams = new LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.MATCH_PARENT,
                1f
        );

        rootLayout.addView(tv, leftParams);
        rootLayout.addView(serverLayout, rightParams);

        setContentView(rootLayout);

        client.pollServerConnection(ip, port, serverStarted, () -> {
            runOnUiThread(() -> {
                Log.d("MainActivity", "UI callback triggered, server started: " + serverStarted.get());
                if (serverStatus != null) {
                    serverStatus.setText(serverStarted.get()
                            ? "Server: Connected ✅"
                            : "Server: Not Connected ❌"
                    );
                }
                if (ipText != null) {
                    ipText.setText(serverStarted.get() ? "Server IP: " + ip : "");
                }
                if (portText != null) {
                    portText.setText(serverStarted.get() ? "Server Port: " + port : "");
                }
            });
        });
    }

    private LinearLayout buildServerLayout() {
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setBackgroundColor(0xFF111111);

        // Title
        TextView title = new TextView(this);
        title.setText("🛰 Server Status");
        title.setTextSize(28);
        title.setTextColor(0xFFFFFFFF);

        // Server IP
        ipText = new TextView(this);
        ipText.setText("Connecting....");
        ipText.setTextSize(20);
        ipText.setTextColor(0xFFAAAAAA);

        // Server Port
        portText = new TextView(this);
        portText.setText("Connecting....");
        portText.setTextSize(20);
        portText.setTextColor(0xFFAAAAAA);

        // Server status
        serverStatus = new TextView(this);
        serverStatus.setText("Server: Starting...");
        serverStatus.setTextSize(20);
        serverStatus.setTextColor(0xFFCCCCCC);

        layout.addView(title);
        layout.addView(ipText);
        layout.addView(portText);
        layout.addView(serverStatus);


        return layout;
    }
}