//
//  HealthTool.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2021/3/26.
//

import UIKit
import HealthKit

class HealthTool: NSObject {
    /*
     * 写入健康正念
     */
    static func addHealthMindfulness(startDateInMill: Int, endDateInMill: Int, completion: @escaping (Bool, String?) -> Void) {
        if #available(iOS 10.0, *) {
            HealthNormalTool.sharedInstance.commonAddHKCategoryType(type: .mindfulness,typeIdentifier:.mindfulSession,startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
        } else {
            completion(false,"iOS系统版本不能低于iOS10")
        }
    }

    /*
     * 写入身高到健康
     * 时间不设置的话，默认读取设备当前的时间Ï
     */
    static func addHealthStature(height: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue:height/100,type: .height, typeIdentifier: .height,unit: .meter(), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    
    /*
     * 写入身高体重指数
     */
    static func addHealthBodyMassIndex(bodyMassIndex: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue: bodyMassIndex, type: .bodyMassIndex, typeIdentifier: .bodyMassIndex,unit: .count(), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }

    /*
     * 写入体脂率
     */
    static func addHealthBodyFatPercentage(bodyFatPercentage: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue: bodyFatPercentage, type: .bodyFatPercentage, typeIdentifier: .bodyFatPercentage,unit:.percent(), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }

    /*
     * 写入体重
     */
    static func addHealthBodyMass(bodyMass: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue: bodyMass, type: .bodyMass, typeIdentifier: .bodyMass,unit: .gramUnit(with: .kilo), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }

    /*
     * 写入去脂体重
     */
    static func addHealthLeanBodyMass(leanBodyMass: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue: leanBodyMass, type: .leanBodyMass, typeIdentifier: .leanBodyMass,unit: .gramUnit(with: .kilo), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }

    /*
     * 写入步数
     */
    static func addHealthStepCount(stepCount: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue: stepCount, type: .stepCount, typeIdentifier: .stepCount,unit: .count(), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }

    /*
     * 写入步行+跑步
     */
    static func addHealthWalkingRunning(walkingRunning: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue: walkingRunning, type: .walkingRunning, typeIdentifier: .distanceWalkingRunning,unit: .meterUnit(with: .kilo), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }

    /*
     * 写入骑行
     */
    static func addHealthCycling(cycling: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue: cycling, type: .cycling, typeIdentifier: .distanceCycling,unit: .meterUnit(with: .kilo), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    
    /*
     * 写入心率
     */
   static func addHealthHeartRate(heartRate: Int,dateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
       HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue: Double(heartRate), type: .heartRate, typeIdentifier: .heartRate,unit:.count().unitDivided(by: .minute()), startDateInMill: dateInMill, endDateInMill: dateInMill, completion: completion)
    }
    
    /*
     * 写入血氧
     */
   static func addHealthBloodOxygen(bloodOxygen: Double,dateInMill: Int?, completion: @escaping (Bool, String?) -> Void) {
       HealthNormalTool.sharedInstance.commonAddHKQuantityType(contentValue: bloodOxygen, type: .bloodOxygen, typeIdentifier: .oxygenSaturation,unit: .percent(), startDateInMill: dateInMill, endDateInMill: dateInMill, completion: completion)
    }
    
    
    
    
    
    /*
     * 获取健康中的身高
     */
    static func getHealthStature(startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?,Double) -> Void) {
        completion(true,"",175)
    }
}
