import Flutter
import UIKit

public class DoraemonkitCsxPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "doraemonkit_csx", binaryMessenger: registrar.messenger())
        let instance = DoraemonkitCsxPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "openSettingPage":
            CommonTool.openAppSettings { success in
                result(success)
            }
        case "getUserDefaults":
            result(CommonTool.getUserDefaults())
        case "setUserDefault":
            if let args = call.arguments as? [String: Any] {
                CommonTool.setUserDefaults(args)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
