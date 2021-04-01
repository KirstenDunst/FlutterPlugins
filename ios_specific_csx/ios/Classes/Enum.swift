//
//  Enum.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2021/3/29.
//

import UIKit
import HealthKit

//健康管理内部小程序的分类,定义和flutter枚举index同步
enum HealthAppSubclassification : Int {
    //正念
    case mindfulness
    //身高
    case height
    //BodyMassIndex 身高体重指数
    case bodyMassIndex
    //BodyFatPercentage 体脂率
    case bodyFatPercentage
    //体重
    case bodyMass
    //LeanBodyMass 去脂体重
    case leanBodyMass
    //步数
    case stepCount
    //步行+跑步
    case walkingRunning
    //骑行
    case cycling
    //心率
    case heartRate
    //未定义，安全占位扩展，
    case noDefined
    
    static func fromRow(index: Int)-> HealthAppSubclassification {
        return ["0":mindfulness,"1":height,"2":bodyMassIndex,"3":bodyFatPercentage,"4":bodyMass,"5":leanBodyMass]["\(index)"] ?? .noDefined
    }
}
