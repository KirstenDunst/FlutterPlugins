//
//  ViewController.swift
//  example
//
//  Created by 曹世鑫 on 2025-06-27.
//

import UIKit
import Flutter

class ViewController: FlutterViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.cyan
        
        let button1 = UIButton.init(type: .custom)
        button1.setTitle("春", for: .normal)
        button1.backgroundColor = UIColor.orange
        button1.frame = CGRect(x: 10, y: 100, width: 100, height: 40)
        button1.addTarget(self, action: #selector(icon1Tap), for: .touchUpInside)
        self.view.addSubview(button1)
        
        let button2 = UIButton.init(type: .custom)
        button2.setTitle("夏", for: .normal)
        button2.backgroundColor = UIColor.orange
        button2.frame = CGRect(x: 10, y: 150, width: 100, height: 40)
        button2.addTarget(self, action: #selector(icon2Tap), for: .touchUpInside)
        self.view.addSubview(button2)
        
        let button3 = UIButton.init(type: .custom)
        button3.setTitle("秋", for: .normal)
        button3.frame = CGRect(x: 10, y: 200, width: 100, height: 40)
        button3.backgroundColor = UIColor.orange
        button3.addTarget(self, action: #selector(icon3Tap), for: .touchUpInside)
        self.view.addSubview(button3)
        
        let button4 = UIButton.init(type: .custom)
        button4.setTitle("冬", for: .normal)
        button4.frame = CGRect(x: 10, y: 250, width: 100, height: 40)
        button4.backgroundColor = UIColor.orange
        button4.addTarget(self, action: #selector(icon4Tap), for: .touchUpInside)
        self.view.addSubview(button4)
        
        let button5 = UIButton.init(type: .custom)
        button5.setTitle("默认", for: .normal)
        button5.frame = CGRect(x: 10, y: 300, width: 100, height: 40)
        button5.backgroundColor = UIColor.orange
        button5.addTarget(self, action: #selector(icondefaultTap), for: .touchUpInside)
        self.view.addSubview(button5)
        
    }
    
    @objc func icon1Tap(){
        setApplicationIconName("春")
    }
    @objc func icon2Tap(){
        setApplicationIconName("夏")
    }
    @objc func icon3Tap(){
        setApplicationIconName("秋")
    }
    @objc func icon4Tap(){
        setApplicationIconName("冬")
    }
    @objc func icondefaultTap(){
        setApplicationIconName(nil)
    }
    
    
    private func setApplicationIconName(_ iconName: String?) {
        
        if #available(iOS 10.3, *) {
            if UIApplication.shared.supportsAlternateIcons {
                print("替换前图标：\(UIApplication.shared.alternateIconName ?? "原始图标")")
                //当前显示的是原始图标
                UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error: Error?) in
                    print("替换后图标：\(UIApplication.shared.alternateIconName ?? "原始图标")")
                })
            }
        }
//        if UIApplication.shared.responds(to: #selector(getter: UIApplication.supportsAlternateIcons)) && UIApplication.shared.supportsAlternateIcons {
//            typealias setAlternateIconName = @convention(c) (NSObject, Selector, NSString?, @escaping (NSError) -> ()) -> ()
//
//            let selectorString = "_setAlternateIconName:completionHandler:"
//
//            let selector = NSSelectorFromString(selectorString)
//            let imp = UIApplication.shared.method(for: selector)
//            let method = unsafeBitCast(imp, to: setAlternateIconName.self)
//            method(UIApplication.shared, selector, iconName as NSString?, { _ in })
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.runtimeRemoveAlert()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.runtimeResetAlert()
    }
    
    //利用runtime指定方法实现
    func runtimeRemoveAlert() -> Void {
        if let presentM = class_getInstanceMethod(type(of: self), #selector(present(_:animated:completion:))),
            let presentSwizzlingM = class_getInstanceMethod(type(of: self), #selector(temporary_present(_:animated:completion:))){
            method_exchangeImplementations(presentM, presentSwizzlingM)
        }
    }
    //利用runtime恢复方法实现
    func runtimeResetAlert() -> Void {
        if let presentM = class_getInstanceMethod(type(of: self), #selector(present(_:animated:completion:))),
            let presentSwizzlingM = class_getInstanceMethod(type(of: self), #selector(temporary_present(_:animated:completion:))){
            method_exchangeImplementations(presentM, presentSwizzlingM)
        }
    }
    
    //在自己实现中特殊处理
    @objc dynamic func temporary_present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)? = nil){
        if viewControllerToPresent.isKind(of: UIAlertController.self) {
            if let alertController = viewControllerToPresent as? UIAlertController{
                //通过判断title和message都为nil，得知是替换icon触发的提示。
                if alertController.title == nil && alertController.message == nil {
                    return;
                }
            }
        }
        
        self.temporary_present(viewControllerToPresent, animated: flag, completion: completion)
    }


}

