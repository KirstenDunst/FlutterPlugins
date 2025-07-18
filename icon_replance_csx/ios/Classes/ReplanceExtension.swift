//
//  Untitled.swift
//  Pods
//
//  Created by 曹世鑫 on 2025-07-10.
//

import UIKit
import ObjectiveC.runtime

private var hasSwizzledPresent = false

extension UIViewController {
    @objc func temporary_present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if viewControllerToPresent.isKind(of: UIAlertController.self) {
            if let alertController = viewControllerToPresent as? UIAlertController {
                // 通过判断title和message都为nil，得知是替换icon触发的提示。
                if alertController.title == nil && alertController.message == nil {
                    return
                }
            }
        }
        self.temporary_present(viewControllerToPresent, animated: animated, completion: completion)
    }

    // MARK: - 执行交换
    static func swizzlePresentMethod() {
        let result = swizzleMethod()
        if result == true {
            hasSwizzledPresent = true
        }
    }
    
    static func swizzleMethod() -> Bool {
        guard
            let originalMethod = class_getInstanceMethod(self, #selector(present(_:animated:completion:))),
            let swizzledMethod = class_getInstanceMethod(self, #selector(temporary_present(_:animated:completion:)))
        else {
            return false
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
        return true
    }

    // MARK: - 恢复原始实现（再次交换）
    static func unswizzlePresentMethod() {
        let result = swizzleMethod()
        if result == true {
            hasSwizzledPresent = false
        }
    }
}
