import Flutter
import UIKit
import SSZipArchive

public class SwiftHotFixCsxPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "hot_fix_csx", binaryMessenger: registrar.messenger())
    let instance = SwiftHotFixCsxPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    switch method {
        case "move_resource":
          let argument = call.arguments as! Dictionary<String, String>
          let back = NormalTool.copyFile(from: Bundle.main.path(forResource: argument["resourseName"], ofType: nil)!, to: argument["targetPath"]!)
          result(back)
        break;
        case "unzip_resource":
          let param = call.arguments as! Dictionary<String, Any>
          let zipName = param["resourseName"] as! String
          let targetPath = param["targetDirectPath"] as! String
          DispatchQueue.global().async {
              let temp = SSZipArchive.unzipFile(atPath: Bundle.main.path(forResource: zipName, ofType: "")!, toDestination: targetPath)
              DispatchQueue.main.async {
                  result(temp)
              }
          }
        break;
    default:
        result("iOS " + UIDevice.current.systemVersion)
    }
  }
}
