//
//  Untitled.swift
//  Pods
//
//  Created by 曹世鑫 on 2025-07-10.
//
import UIKit

class ReplanceController: UIViewController {
    // 利用runtime指定方法实现
    func runtimeRemoveAlert(completion: (() -> Void)? = nil) {
        if let presentM = class_getInstanceMethod(type(of: self), #selector(present(_:animated:completion:))),
           let presentSwizzlingM = class_getInstanceMethod(type(of: self), #selector(temporary_present(_:animated:completion:)))
        {
            method_exchangeImplementations(presentM, presentSwizzlingM)
        }
        completion?()
    }

    // 利用runtime恢复方法实现
    func runtimeResetAlert() {
        if let presentM = class_getInstanceMethod(type(of: self), #selector(present(_:animated:completion:))),
           let presentSwizzlingM = class_getInstanceMethod(type(of: self), #selector(temporary_present(_:animated:completion:)))
        {
            method_exchangeImplementations(presentM, presentSwizzlingM)
        }
    }

    // 在自己实现中特殊处理
    @objc dynamic func temporary_present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        if viewControllerToPresent.isKind(of: UIAlertController.self) {
            if let alertController = viewControllerToPresent as? UIAlertController {
                // 通过判断title和message都为nil，得知是替换icon触发的提示。
                if alertController.title == nil && alertController.message == nil {
                    return
                }
            }
        }
        self.temporary_present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
