//
//  HealthTool.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2021/3/26.
//

import UIKit
import HealthKit

class HealthTool: NSObject {
    static let sharedInstance = HealthTool()
    // 重写init方法，设为私有方法
    private override init(){}
    lazy var healthStore: HKHealthStore = HKHealthStore.init()
    /*
     * 统一授权
     */
    private func getPermissions(writeDataType:HKSampleType?, readDataType: HKSampleType?, completion: @escaping (Bool, String?) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            var writeType: NSSet?
            if writeDataType != nil {
                writeType =  NSSet.init(object: writeDataType!)
            }
            var readType: NSSet?
            if readDataType != nil {
                readType = NSSet.init(object: readDataType!)
            }
            //need main thread, orelse get permission timeout!
            DispatchQueue.main.async {
                self.healthStore.requestAuthorization(toShare: writeType as? Set<HKSampleType>, read: readType as? Set<HKObjectType>) { (success, error) in
                    completion(success, (error != nil) ? error!.localizedDescription: nil)
                }
            }
        } else {
            completion(false,"健康APP不可用，请安装并打开健康查看")
        }
    }
    /*
     * 获取类型的授权状态
     */
    func getHealthAuthorityStatus(subclassificationIndex: Int) -> HKAuthorizationStatus {
        var categoryType:HKSampleType;
        let subclassification:HealthAppSubclassification = HealthAppSubclassification.fromRow(index: subclassificationIndex)
        switch subclassification {
            case .mindfulness:
                if #available(iOS 10.0, *) {
                    categoryType = HealthKit.HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
                } else {
                    fatalError("正念需要最低ios版本为iOS10.0")
                }
                break
            case .height:
                categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .height)!
                break
            case .bodyMassIndex:
                categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!
                break
            case .bodyFatPercentage:
                categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!
                break
            case .bodyMass:
                categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .bodyMass)!
                break
            case .leanBodyMass:
                categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .leanBodyMass)!
                break
            case .stepCount:
                categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .stepCount)!
                break
            case .walkingRunning:
                categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
                break
            case .cycling:
                categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .distanceCycling)!
                break
            case .heartRate:
                categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .heartRate)!
                break
            default:
                fatalError("类型传入错误:\(subclassificationIndex)")
                break
        }
        return self.healthStore.authorizationStatus(for: categoryType);
    }

    //健康APP是否可用
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    func requestHealthAuthority(completion: @escaping (Bool, String?) -> Void) {
        if #available(iOS 10.0, *) {
            guard let categoryType =
                    HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession) else {
                let errorStr = "mindfulSession创建HKCategoryType失败"
                completion(false,errorStr)
                fatalError(errorStr)
            }
            getPermissions(writeDataType: categoryType, readDataType: nil) { (success, error) in
                if(success){
                    completion(success, (error != nil) ? error: nil)
                } else {
                    completion(false,error)
                }
            }
        } else {
            completion(false,"iOS系统版本不能低于iOS10")
        }
    }
    
    /*
     * 写入健康正念
     */
    func addHealthMindfulness(startDateInMill: Int, endDateInMill: Int, completion: @escaping (Bool, String?) -> Void) {
        if #available(iOS 10.0, *) {
            commonAddHKCategoryType(type: .mindfulness,typeIdentifier:.mindfulSession,startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
        } else {
            completion(false,"iOS系统版本不能低于iOS10")
        }
    }
    //通用CategoryType写入
    private func commonAddHKCategoryType(type:HealthAppSubclassification,typeIdentifier: HKCategoryTypeIdentifier, startDateInMill: Int?, endDateInMill: Int?, completion: @escaping (Bool, String?) -> Void) {
        guard let categoryType =
                HealthKit.HKCategoryType.categoryType(forIdentifier: typeIdentifier) else {
            let errorStr = "\(typeIdentifier)创建HKCategoryType失败"
            completion(false,errorStr)
            fatalError(errorStr)
        }
        var startDate: Date = Date()
        if startDateInMill != nil {
            startDate = Date.init(timeIntervalSince1970: TimeInterval(startDateInMill!/1000))
        }
        var endDate: Date = Date()
        if endDateInMill != nil {
            endDate = Date.init(timeIntervalSince1970: TimeInterval(endDateInMill!/1000))
        }
        //value后面扩展需要关注一下
        let categorySample = HKCategorySample.init(type: categoryType, value: HKCategoryValue.notApplicable.rawValue, start:startDate, end:endDate)
        let state = getHealthAuthorityStatus(subclassificationIndex: type.rawValue)
        switch state {
            case HKAuthorizationStatus.notDetermined:
                getPermissions(writeDataType: categoryType, readDataType: nil) { (success, error) in
                    if(success){
                        self.healthStore.save([categorySample]) { (success, error) in
                            completion(success, (error != nil) ? error!.localizedDescription: nil)
                        }
                    } else {
                        completion(false,error)
                    }
                }
                break;
            case HKAuthorizationStatus.sharingDenied:
                completion(false,"健康app内部\(typeIdentifier)的数据与访问权限-数据源将自己的app访问权限设置为了‘不活跃’,请修改为活跃之后才能更好地为您服务")
                break;
            case HKAuthorizationStatus.sharingAuthorized:
                self.healthStore.save([categorySample]) { (success, error) in
                    completion(success, error?.localizedDescription)
                }
                break;
            default:
                completion(false,"获取健康权限状态问题异常，请安装健康app并打开查看\(typeIdentifier)权限")
                break;
        }
    }

    /*
    * 写入身高到健康
    * 时间不设置的话，默认读取设备当前的时间
    */
    func addHealthStature(height: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        commonAddHKQuantityType(num:height,type: .height, typeIdentifier: .height,unit: .init(from: "cm"), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    /*
     * 写入身高体重指数
     */
    func addHealthBodyMassIndex(bodyMassIndex: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        commonAddHKQuantityType(num: bodyMassIndex, type: .bodyMassIndex, typeIdentifier: .bodyMassIndex,unit: .init(from: "BMI"), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    /*
     * 写入体脂率
     */
    func addHealthBodyFatPercentage(bodyFatPercentage: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        commonAddHKQuantityType(num: bodyFatPercentage, type: .bodyFatPercentage, typeIdentifier: .bodyFatPercentage,unit:.init(from: "%"), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    /*
     * 写入体重
     */
    func addHealthBodyMass(bodyMass: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        commonAddHKQuantityType(num: bodyMass, type: .bodyMass, typeIdentifier: .bodyMass,unit: .gramUnit(with: .kilo), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    /*
     * 写入去脂体重
     */
    func addHealthLeanBodyMass(leanBodyMass: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        commonAddHKQuantityType(num: leanBodyMass, type: .leanBodyMass, typeIdentifier: .leanBodyMass,unit: .gramUnit(with: .kilo), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    /*
     * 写入步数
     */
    func addHealthStepCount(stepCount: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        commonAddHKQuantityType(num: stepCount, type: .stepCount, typeIdentifier: .stepCount,unit: .count(), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    /*
     * 写入步行+跑步
     */
    func addHealthWalkingRunning(walkingRunning: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        commonAddHKQuantityType(num: walkingRunning, type: .walkingRunning, typeIdentifier: .distanceWalkingRunning,unit: .gramUnit(with: .kilo), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    /*
     * 写入骑行
     */
    func addHealthCycling(cycling: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        commonAddHKQuantityType(num: cycling, type: .cycling, typeIdentifier: .distanceCycling,unit: .gramUnit(with: .kilo), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    /*
     * 写入心率
     */
    func addHealthHeartRate(heartRate: Double,startDateInMill: Int?, endDateInMill: Int?,completion: @escaping (Bool, String?) -> Void) {
        commonAddHKQuantityType(num: heartRate, type: .heartRate, typeIdentifier: .heartRate,unit: .init(from: "次/分"), startDateInMill: startDateInMill, endDateInMill: endDateInMill, completion: completion)
    }
    
    //通用QuantityType写入
    private func commonAddHKQuantityType(num:Double, type:HealthAppSubclassification,typeIdentifier: HKQuantityTypeIdentifier,unit:HKUnit, startDateInMill: Int?, endDateInMill: Int?, completion: @escaping (Bool, String?) -> Void) {
        guard let categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height) else {
            let errorStr = "\(typeIdentifier)创建HKCategoryType失败"
            completion(false,errorStr)
            fatalError(errorStr)
        }
        var startDate: Date = Date()
        if startDateInMill != nil {
            startDate = Date.init(timeIntervalSince1970: TimeInterval(startDateInMill!/1000))
        }
        var endDate: Date = Date()
        if endDateInMill != nil {
            endDate = Date.init(timeIntervalSince1970: TimeInterval(endDateInMill!/1000))
        }
        let quantitySample = HealthKit.HKQuantitySample.init(type: categoryType, quantity: HealthKit.HKQuantity.init(unit: unit, doubleValue: num), start: startDate, end: endDate)
        let state = getHealthAuthorityStatus(subclassificationIndex: type.rawValue)
        switch state {
            case HKAuthorizationStatus.notDetermined:
                getPermissions(writeDataType: categoryType, readDataType: nil) { (success, error) in
                    if(success){
                        self.healthStore.save([quantitySample]) { (success, error) in
                            completion(success, (error != nil) ? error!.localizedDescription: nil)
                        }
                    } else {
                        completion(false,error)
                    }
                }
                break;
            case HKAuthorizationStatus.sharingDenied:
                completion(false,"健康app内部\(typeIdentifier)的数据与访问权限-数据源将自己的app访问权限设置为了‘不活跃’,请修改为活跃之后才能更好地为您服务")
                break;
            case HKAuthorizationStatus.sharingAuthorized:
                self.healthStore.save([quantitySample]) { (success, error) in
                    completion(success, error?.localizedDescription)
                }
                break;
            default:
                completion(false,"获取健康权限状态问题异常，请安装健康app并打开查看\(typeIdentifier)权限")
                break;
        }
    }
}
