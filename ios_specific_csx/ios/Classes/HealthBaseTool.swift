//
//  HealthBaseTool.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2022/7/25.
//

import Foundation
import Flutter
import HealthKit


class HealthNormalTool : NSObject {
    static let sharedInstance = HealthNormalTool()
    // 重写init方法，设为私有方法
    private override init(){}
    lazy var healthStore: HKHealthStore = HKHealthStore.init()
    /*
     * 统一授权
     */
    private func getPermissions(writeDataTypes:[HKSampleType]?, readDataTypes: [HKSampleType]?,eventSink:FlutterEventSink?,  completion: @escaping (Bool, String?) -> Void) {
        if isHealthDataAvailable() {
            var writeType: Set<HKSampleType>?
            if writeDataTypes != nil {
                writeType =  Set(writeDataTypes!)
            }
            var readType: Set<HKSampleType>?
            if readDataTypes != nil {
                readType = Set(readDataTypes!)
            }
            eventSink?("getPermissions isHealthDataAvailable")
            //need main thread, orelse get permission timeout!
            DispatchQueue.main.async {
                eventSink?("getPermissions DispatchQueue.main")
                self.healthStore.requestAuthorization(toShare: writeType, read: readType) { (success, error) in
                    eventSink?("getPermissions requestAuthorization：\(success),\(String(describing: error?.localizedDescription))")
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
        let categoryType:HKSampleType = getCategoryType(subclassificationIndex:subclassificationIndex)
        return self.healthStore.authorizationStatus(for: categoryType)
    }
    
    /*
     * 健康APP是否可用
     */
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /*
     * 跳转进入健康app
     */
    func gotoHealthApp(completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL.init(string: "x-apple-health://app/") else {
            let errorStr = "生成跳转链接失败"
            completion(false,errorStr)
            fatalError(errorStr)
        }
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { (result) in
                    completion(result,"")
                }
            } else {
                UIApplication.shared.open(url)
            }
        } else {
            completion(false,"未安装健康App，请先前往App Store安装健康App！")
        }
    }

    /*
     * 对不同类型进行系统的授权
     */
    func requestHealthAuthority(subclassificationIndex: Int, eventSink:FlutterEventSink?, completion: @escaping (Bool, String?) -> Void) {
        let categoryType:HKSampleType = getCategoryType(subclassificationIndex:subclassificationIndex)
        eventSink?("requestHealthAuthority categoryType:\(categoryType)")
        getPermissions(writeDataTypes: [categoryType], readDataTypes: [categoryType],eventSink: eventSink) { (success, error) in
            if(success){
                completion(success, (error != nil) ? error: nil)
            } else {
                completion(false,error)
            }
        }
    }
    
    /*
     * 批量请求对应健康app模块的权限
     */
    func requestHealthSubmodulesAuthority(subclassificationIndexs: [Int],eventSink:FlutterEventSink?,  completion: @escaping (Bool, String?) -> Void) {
        var categoryTypes:[HKSampleType] = []
        for subclassificationIndex in subclassificationIndexs {
            categoryTypes.append(getCategoryType(subclassificationIndex:subclassificationIndex))
        }
        eventSink?("requestHealthSubmodulesAuthority categoryTypes:\(categoryTypes)")
        getPermissions(writeDataTypes: categoryTypes, readDataTypes: categoryTypes,eventSink: eventSink) { (success, error) in
            if(success){
                completion(success, (error != nil) ? error: nil)
            } else {
                completion(false,error)
            }
        }
    }
    
    
    /*
    * 通用根据类型获取categoryType对象
    */
    private func getCategoryType(subclassificationIndex: Int) -> HKSampleType {
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
                   case .bloodOxygen:
                       categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
                       break
                   default:
                       fatalError("类型传入错误:\(subclassificationIndex)")
                       break
               }
               return categoryType
           }
    
    
    /*
     * 通用CategoryType写入
     */
    func commonAddHKCategoryType(type:HealthAppSubclassification,typeIdentifier: HKCategoryTypeIdentifier, startDateInMill: CLong?, endDateInMill: CLong?,eventSink:FlutterEventSink?, completion: @escaping (Bool, String?) -> Void) {
        guard let categoryType =
                HealthKit.HKCategoryType.categoryType(forIdentifier: typeIdentifier) else {
            let errorStr = "\(typeIdentifier)创建HKCategoryType失败"
            eventSink?("commonAddHKCategoryType\(errorStr)")
            completion(false,errorStr)
            fatalError(errorStr)
        }
        eventSink?("commonAddHKCategoryType categoryType:\(categoryType)")
        var startDate: Date = Date()
        if startDateInMill != nil {
            startDate = Date.init(timeIntervalSince1970: TimeInterval(startDateInMill!/1000))
        }
        var endDate: Date = Date()
        if endDateInMill != nil {
            endDate = Date.init(timeIntervalSince1970: TimeInterval(endDateInMill!/1000))
        }
        eventSink?("commonAddHKCategoryType startDate:\(startDate),endDate:\(endDate)")
        //value后面扩展需要关注一下
        let categorySample = HKCategorySample.init(type: categoryType, value: HKCategoryValue.notApplicable.rawValue, start:startDate, end:endDate)
        eventSink?("commonAddHKCategoryType categorySample:\(categorySample)")
        let state = getHealthAuthorityStatus(subclassificationIndex: type.rawValue)
        eventSink?("commonAddHKCategoryType state:\(state)")
        switch state {
            case HKAuthorizationStatus.notDetermined:
                getPermissions(writeDataTypes: [categoryType], readDataTypes: [categoryType],eventSink: eventSink) { (success, error) in
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
    
    //通用QuantityType写入
    func commonAddHKQuantityType(contentValue:Double, type:HealthAppSubclassification,typeIdentifier: HKQuantityTypeIdentifier,unit:HKUnit, startDateInMill: CLong?, endDateInMill: CLong?,eventSink:FlutterEventSink?,  completion: @escaping (Bool, String?) -> Void) {
         guard let categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
             let errorStr = "\(typeIdentifier)创建HKCategoryType失败"
             eventSink?("commonAddHKQuantityType\(errorStr)")
             completion(false,errorStr)
             fatalError(errorStr)
         }
        eventSink?("commonAddHKQuantityType categoryType:\(categoryType)")
         var startDate: Date = Date()
         if startDateInMill != nil {
             startDate = Date.init(timeIntervalSince1970: TimeInterval(startDateInMill!/1000))
         }
         var endDate: Date = Date()
         if endDateInMill != nil {
             endDate = Date.init(timeIntervalSince1970: TimeInterval(endDateInMill!/1000))
         }
        eventSink?("commonAddHKQuantityType startDate:\(startDate),endDate:\(endDate)")
         let quantity = HKQuantity.init(unit: unit, doubleValue: contentValue)
         let quantitySample = HKQuantitySample.init(type: categoryType, quantity: quantity, start: startDate, end: endDate)
        eventSink?("commonAddHKQuantityType quantitySample:\(quantitySample)")
         let state = getHealthAuthorityStatus(subclassificationIndex: type.rawValue)
        eventSink?("commonAddHKQuantityType state:\(state)")
         switch state {
             case HKAuthorizationStatus.notDetermined:
                 getPermissions(writeDataTypes: [categoryType], readDataTypes: [categoryType],eventSink: eventSink) { (success, error) in
                     if(success){
                         self.healthStore.save([quantitySample]) { (success, error) in
                             completion(success, error?.localizedDescription)
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
    
//    //通用读取
//        func commonGetHKQuantityType() {
//            let predicate =  HKQuery.predicateForWorkouts(with: HKWorkoutActivityType.running)
//            let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
//            let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
//                { (sampleQuery, results, error ) -> Void in
//                  if let queryError = error {
//    //                ("There was an error while reading the samples: \(queryError.localizedDescription)")
//                  }
//                  completion(results,error)
//                }
//              // 4. Execute the query
//            self.healthStore.execute(sampleQuery)
//        }
}
