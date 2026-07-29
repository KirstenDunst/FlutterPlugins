import Flutter
import UIKit

public class MainViewController: FlutterViewController {
    private var supportedOrientations: UIInterfaceOrientationMask = .all

    public override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(supportedOrientationsChanged(_:)),
            name: Notification.Name("LimitingDirectionCsxPlugin"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name("LimitingDirectionCsxPlugin"),
            object: nil
        )
    }

    @objc private func supportedOrientationsChanged(_ sender: Notification) {
        var param = 5
        if let userInfo = sender.userInfo,
           let value = userInfo["orientationMask"] as? NSNumber {
            param = value.intValue
        }
        supportedOrientations = OrientationUtil.getOrientationMask(index: param)
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return supportedOrientations
    }

    public override var shouldAutorotate: Bool {
        return true
    }
}

public class OrientationUtil: NSObject {
    public static func getOrientationMask(index: Int) -> UIInterfaceOrientationMask {
        switch index {
        case 0:
            return .portrait
        case 1:
            return .landscapeLeft
        case 2:
            return .landscapeRight
        case 3:
            return .portraitUpsideDown
        case 4:
            return .landscape
        case 6:
            return .allButUpsideDown
        default:
            return .all
        }
    }
}
