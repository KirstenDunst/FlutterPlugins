import Flutter
import UIKit

public class IconReplanceCsxPlugin: NSObject, FlutterPlugin {
    let replanceCtl = ReplanceController()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "icon_replance_csx", binaryMessenger: registrar.messenger())
        let instance = IconReplanceCsxPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "changeIcon":
            do {
                let iconName = call.arguments as! String?
                replanceIcon(iconName, result: result)
            }
        case "removeSystemAlert":
            do {
                replanceCtl.runtimeRemoveAlert()
                result(true)
            }
        case "resetSystemAlert":
            do {
                replanceCtl.runtimeResetAlert()
                result(true)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func replanceIcon(_ iconName: String?, result: @escaping FlutterResult) {
        if #available(iOS 10.3, *) {
            if UIApplication.shared.supportsAlternateIcons {
                UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error: Error?) in
                    if error != nil {
                        result(["isSuccess": false, "msg": "更换\(iconName ?? "原始图标")可能未成功:\(String(describing: error))", "errorCode": 3])
                    } else {
                        result(["isSuccess": true, "msg": nil, "errorCode": nil])
                    }
                })
            } else {
                result(["isSuccess": false, "msg": "不支持修改icon:\(iconName ?? "原始图标")", "errorCode": 2])
            }
        } else {
            result(["isSuccess": false, "msg": "版本低于10.3", "errorCode": 1])
        }
    }
}
