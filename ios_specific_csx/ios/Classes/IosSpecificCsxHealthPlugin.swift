//
//  IosSpecificCsxHealthPlugin.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2021/5/8.
//
import Flutter
import UIKit

public class IosSpecificCsxHealthPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ios_specific_csx_health", binaryMessenger: registrar.messenger())
        let instance = IosSpecificCsxHealthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "requestHealthAuthority":
            HealthNormalTool.sharedInstance.requestHealthAuthority(subclassificationIndex: call.arguments as! Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "getHealthAuthorityStatus":
            let answer = HealthNormalTool.sharedInstance.getHealthAuthorityStatus(subclassificationIndex: call.arguments as! Int).rawValue
                result(answer)
                break;
            case "isHealthDataAvailable":
                result(HealthNormalTool.sharedInstance.isHealthDataAvailable())
                break;
            case "gotoHealthApp":
            HealthNormalTool.sharedInstance.gotoHealthApp { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            //单独写入，读取
            case "addHealthMindfulness":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthMindfulness(startDateInMill: argument["startDate"] as! Int, endDateInMill: argument["endDate"] as! Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthStature":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthStature(height: argument["height"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "getHealthStature":
                let argument = call.arguments as! NSDictionary;
                HealthTool.getHealthStature(startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr, arg)  in
                    result(["resultBase":["success":success,"errorDescri":errorStr as Any],"result":arg])
                }
                break;
            case "addHealthBodyMassIndex":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthBodyMassIndex(bodyMassIndex: argument["bodyMassIndex"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthBodyFatPercentage":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthBodyFatPercentage(bodyFatPercentage: argument["bodyFatPercentage"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthBodyMass":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthBodyMass(bodyMass: argument["bodyMass"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthLeanBodyMass":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthLeanBodyMass(leanBodyMass: argument["leanBodyMass"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthStepCount":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthStepCount(stepCount: argument["stepCount"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthWalkingRunning":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthWalkingRunning(walkingRunning: argument["walkingRunning"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthCycling":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthCycling(cycling: argument["cycling"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthHeartRate":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthHeartRate(heartRate: argument["heartRate"] as! Int,dateInMill:argument["time"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthBloodOxygen":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthBloodOxygen(bloodOxygen: argument["bloodOxygen"] as! Double,dateInMill:argument["time"] as? Int) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            default:
                break;
            }
    }
}

