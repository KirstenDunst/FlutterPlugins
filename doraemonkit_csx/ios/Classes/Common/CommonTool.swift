public class CommonTool: NSObject {
    // 进入app的设置界面
    static func openAppSettings(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            completion(false)
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { success in
                    completion(success)
                }
            } else {
                let success = UIApplication.shared.openURL(url)
                completion(success)
            }
        } else {
            completion(false)
        }
    }

    // 获取所有userdefault存储的数据
    static func getUserDefaults() -> [String: String] {
        let tempDic = UserDefaults.standard.dictionaryRepresentation()
        var resultDic: [String: String] = [:]
        for (key, value) in tempDic {
            resultDic[key] = "\(value)" // 转成字符串表示
        }
        return resultDic
    }

    // 本地存储
    static func setUserDefaults(_ dic: [String: Any]?) {
        guard let dic = dic else { return }
        let defaults = UserDefaults.standard
        for (key, value) in dic {
            defaults.setValue(value, forKey: key)
        }
        defaults.synchronize()
    }
}
