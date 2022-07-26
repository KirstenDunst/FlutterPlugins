//
//  HealthBaseTool.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2022/7/25.
//

import Foundation
import HealthKit


class HealthNormalTool : NSObject {
    static let sharedInstance = HealthNormalTool()
    // 重写init方法，设为私有方法
    private override init(){}
    lazy var healthStore: HKHealthStore = HKHealthStore.init()
    /*
     * 统一授权
     */
    private func getPermissions(writeDataType:HKSampleType?, readDataType: HKSampleType?, completion: @escaping (Bool, String?) -> Void) {
        if isHealthDataAvailable() {
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
        let categoryType:HKSampleType = HealthNormalTool.sharedInstance.getCategoryType(subclassificationIndex:subclassificationIndex)
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
    func requestHealthAuthority(subclassificationIndex: Int, completion: @escaping (Bool, String?) -> Void) {
        let categoryType:HKSampleType = HealthNormalTool.sharedInstance.getCategoryType(subclassificationIndex:subclassificationIndex)
        getPermissions(writeDataType: categoryType, readDataType: categoryType) { (success, error) in
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
    func commonAddHKCategoryType(type:HealthAppSubclassification,typeIdentifier: HKCategoryTypeIdentifier, startDateInMill: Int?, endDateInMill: Int?, completion: @escaping (Bool, String?) -> Void) {
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
                getPermissions(writeDataType: categoryType, readDataType: categoryType) { (success, error) in
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
    func commonAddHKQuantityType(contentValue:Double, type:HealthAppSubclassification,typeIdentifier: HKQuantityTypeIdentifier,unit:HKUnit, startDateInMill: Int?, endDateInMill: Int?, completion: @escaping (Bool, String?) -> Void) {
         guard let categoryType = HealthKit.HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
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
         let quantity = HKQuantity.init(unit: unit, doubleValue: contentValue)
         let quantitySample = HKQuantitySample.init(type: categoryType, quantity: quantity, start: startDate, end: endDate)
         let state = getHealthAuthorityStatus(subclassificationIndex: type.rawValue)
         switch state {
             case HKAuthorizationStatus.notDetermined:
                 getPermissions(writeDataType: categoryType, readDataType: categoryType) { (success, error) in
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
