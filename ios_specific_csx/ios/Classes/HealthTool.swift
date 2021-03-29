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
                    categoryType = HKCategoryType.categoryType(forIdentifier: .mindfulSession)!
                } else {
                    fatalError("正念需要最低ios版本为iOS10.0")
                }
                break
            default:
                fatalError("类型传入错误:\(subclassificationIndex)")
                break
        }
        return self.healthStore.authorizationStatus(for: categoryType);
    }
    
    /*
     * 写入健康正念
     */
    func addHealthMindfulness(startDateInMill: Int, endDateInMill: Int, completion: @escaping (Bool, String?) -> Void) {
        if #available(iOS 10.0, *) {
            guard let categoryType =
                    HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession) else {
                let errorStr = "mindfulSession创建HKCategoryType失败"
                completion(false,errorStr)
                fatalError(errorStr)
            }
            let startDate: Date = Date.init(timeIntervalSince1970: TimeInterval(startDateInMill/1000))
            let endDate: Date = Date.init(timeIntervalSince1970: TimeInterval(endDateInMill/1000))
            let mindness = HKCategorySample.init(type: categoryType, value: HKCategoryValue.notApplicable.rawValue, start:startDate, end:endDate)
            let state = getHealthAuthorityStatus(subclassificationIndex: HealthAppSubclassification.mindfulness.rawValue)
                self.healthStore.authorizationStatus(for: categoryType);
            switch state {
                case HKAuthorizationStatus.notDetermined:
                    getPermissions(writeDataType: categoryType, readDataType: nil) { (success, error) in
                        if(success){
                            self.healthStore.save([mindness]) { (success, error) in
                                completion(success, (error != nil) ? error!.localizedDescription: nil)
                            }
                        } else {
                            completion(false,error)
                        }
                    }
                    break;
                case HKAuthorizationStatus.sharingDenied:
                    completion(false,"健康app内部mindless的数据与访问权限-数据源将自己的app访问权限设置为了‘不活跃’,请修改为活跃之后才能更好地为您服务")
                    break;
                case HKAuthorizationStatus.sharingAuthorized:
                    self.healthStore.save([mindness]) { (success, error) in
                        completion(success, error?.localizedDescription)
                    }
                    break;
                default:
                    completion(false,"获取健康权限状态问题异常，请安装健康app并打开查看mindless权限")
                    break;
            }
        } else {
            completion(false,"iOS系统版本不能低于iOS10")
        }
    }
}
