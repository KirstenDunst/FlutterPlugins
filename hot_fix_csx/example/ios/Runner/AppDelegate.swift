import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    NormalChannel.register(with: self.registrar(forPlugin: "NormalChannel")!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
