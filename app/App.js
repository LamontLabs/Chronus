import React from "react";
import { SafeAreaView, View, Platform, StatusBar } from "react-native";
import { WebView } from "react-native-webview";
import Constants from "expo-constants";

const uri = Platform.select({
  ios: "https://example.invalid/chronus", // placeholder for future iOS
  android: "file:///android_asset/dist/index.html"
});

export default function App() {
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: "#0b0f14", paddingTop: StatusBar.currentHeight || 0 }}>
      <View style={{ flex: 1 }}>
        <WebView
          originWhitelist={["*"]}
          source={Platform.OS === "android" ? { uri } : { uri: "http://localhost:5173" }}
          javaScriptEnabled
          domStorageEnabled
          allowFileAccess
          allowUniversalAccessFromFileURLs
          mixedContentMode="always"
          cacheEnabled
          setSupportMultipleWindows={false}
          onMessage={(event) => {
            // bridge messages from Phaser to RN if needed
            if (__DEV__) console.log("WebView message:", event.nativeEvent.data);
          }}
          injectedJavaScriptBeforeContentLoaded={`
            window.__CHRONUS_ENV__ = ${JSON.stringify(Constants.expoConfig?.extra || {})};
            true;
          `}
        />
      </View>
    </SafeAreaView>
  );
}
