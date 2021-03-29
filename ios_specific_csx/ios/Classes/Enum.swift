//
//  Enum.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2021/3/29.
//

import UIKit
//健康管理内部小程序的分类,定义和flutter枚举index同步
enum HealthAppSubclassification : Int {
    //正念
    case mindfulness
    //未定义，安全占位扩展，
    case noDefined
    
    static func fromRow(index: Int)-> HealthAppSubclassification {
        return allMap["\(index)"] ?? .noDefined
    }
    static var allMap = ["0":mindfulness]
}
