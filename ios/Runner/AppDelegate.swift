import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let appPrefChannel = FlutterMethodChannel(name: "dubemarcantoine.github.io/authenticator_mfa",
                                              binaryMessenger: controller)
    appPrefChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: FlutterResult) -> Void in
        guard call.method == "openAppPreferences" else {
            result(FlutterMethodNotImplemented)
            return
        }
        UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
