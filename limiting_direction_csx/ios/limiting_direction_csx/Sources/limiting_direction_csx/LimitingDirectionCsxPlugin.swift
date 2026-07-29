import Flutter
import UIKit

public class LimitingDirectionCsxPlugin: NSObject, FlutterPlugin {
    private static var channel: FlutterMethodChannel?

    private var iOSOrientation: UIDeviceOrientation
    private var lastLandOrientation: UIDeviceOrientation?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "limiting_direction_csx",
            binaryMessenger: registrar.messenger()
        )
        self.channel = channel
        let instance = LimitingDirectionCsxPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public override init() {
        iOSOrientation = UIDevice.current.orientation
        super.init()
        LimitingDirectionCsxPlugin.channel?.invokeMethod(
            "orientationCallback",
            arguments: dealOrientationCallBack()
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rotateDevice(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: UIDevice.current
        )
    }

    @objc private func rotateDevice(_ sender: Notification) {
        if let device = sender.object as? UIDevice {
            iOSOrientation = device.orientation
        }
        LimitingDirectionCsxPlugin.channel?.invokeMethod(
            "orientationCallback",
            arguments: dealOrientationCallBack()
        )
    }

    private func dealOrientationCallBack() -> String {
        switch iOSOrientation {
        case .portrait:
            return "1"
        case .portraitUpsideDown:
            return "2"
        case .landscapeLeft:
            return "3"
        case .landscapeRight:
            return "4"
        case .faceUp:
            return "5"
        case .faceDown:
            return "6"
        default:
            return "0"
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "changeScreenDirection":
            guard let arguments = call.arguments as? [Any],
                  let index = (arguments.first as? NSNumber)?.intValue
            else {
                result(nil)
                return
            }
            changeScreenDirection(index: index)
            result(nil)
        case "getNowDeviceDirection":
            result(dealOrientationCallBack())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func changeScreenDirection(index: Int) {
        switch index {
        case 0:
            if iOSOrientation == .landscapeLeft || iOSOrientation == .landscapeRight {
                lastLandOrientation = iOSOrientation
            }
            iOSOrientation = .portrait
        case 1:
            iOSOrientation = .landscapeLeft
        case 2:
            iOSOrientation = .landscapeRight
        case 3:
            if iOSOrientation != .portrait && iOSOrientation != .portraitUpsideDown {
                iOSOrientation = .portrait
            }
        case 4:
            if iOSOrientation != .landscapeLeft && iOSOrientation != .landscapeRight {
                iOSOrientation = lastLandOrientation ?? .landscapeLeft
            }
            lastLandOrientation = iOSOrientation
        case 6:
            if iOSOrientation == .portraitUpsideDown {
                iOSOrientation = .portrait
            }
        default:
            break
        }

        if #available(iOS 16.0, *) {
            var windowScene = UIApplication.shared.connectedScenes.first { scene in
                scene.activationState == .foregroundActive
            } as? UIWindowScene
            if windowScene == nil {
                windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            }
            if let windowScene {
                let preferences = UIWindowScene.GeometryPreferences.iOS(
                    interfaceOrientations: Self.interfaceOrientationMask(from: iOSOrientation)
                )
                windowScene.requestGeometryUpdate(preferences) { error in
                    NSLog("requestGeometryUpdate error: %@", error.localizedDescription)
                }
            }
        } else {
            UIDevice.current.setValue(iOSOrientation.rawValue, forKey: "orientation")
        }
        NotificationCenter.default.post(
            name: Notification.Name("LimitingDirectionCsxPlugin"),
            object: nil,
            userInfo: ["orientationMask": index]
        )
        UIViewController.attemptRotationToDeviceOrientation()
    }

    private static func interfaceOrientationMask(
        from orientation: UIDeviceOrientation
    ) -> UIInterfaceOrientationMask {
        switch orientation {
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }
}
