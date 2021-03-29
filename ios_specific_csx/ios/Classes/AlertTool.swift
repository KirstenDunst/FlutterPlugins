//
//  AlertTool.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2021/3/29.
//

import UIKit

class AlertTool: NSObject {
    /*
     * 系统弹框
     */
    class func showAlert(title: String, message: String, cancelStr: String? = nil, cancelDeal:((UIAlertAction) -> Void)? = nil, ensureStr: String? = nil, ensureDeal:((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelStr, style: .cancel, handler: cancelDeal)
        let okAction = UIAlertAction(title: ensureStr, style: .default, handler: ensureDeal)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        AlertTool.currentVc().present(alertController, animated: true, completion: nil)
    }
    
    /*
     * 获取当前的控制器vc
     */
    class func currentVc() ->UIViewController{
        var vc = UIApplication.shared.keyWindow?.rootViewController
        if (vc?.isKind(of: UITabBarController.self))! {
            vc = (vc as! UITabBarController).selectedViewController
        } else if (vc?.isKind(of: UINavigationController.self))!{
            vc = (vc as! UINavigationController).visibleViewController
        } else if ((vc?.presentedViewController) != nil){
            vc =  vc?.presentedViewController
        }
        return vc!
    }
}
