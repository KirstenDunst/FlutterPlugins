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
        case "addHealthMindfulness":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthMindfulness(startDateInMill: argument["startDate"] as! Int, endDateInMill: argument["endDate"] as! Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "addHealthStature":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthStature(height: argument["height"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "getHealthStature":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.getHealthStature(startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr, arg)  in
                result(["resultBase":["success":success,"errorDescri":errorStr as Any],"result":arg])
            }
            break;
        case "addHealthBodyMassIndex":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthBodyMassIndex(bodyMassIndex: argument["bodyMassIndex"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "addHealthBodyFatPercentage":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthBodyFatPercentage(bodyFatPercentage: argument["bodyFatPercentage"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "addHealthBodyMass":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthBodyMass(bodyMass: argument["bodyMass"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "addHealthLeanBodyMass":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthLeanBodyMass(leanBodyMass: argument["leanBodyMass"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "addHealthStepCount":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthStepCount(stepCount: argument["stepCount"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "addHealthWalkingRunning":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthWalkingRunning(walkingRunning: argument["walkingRunning"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "addHealthCycling":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthCycling(cycling: argument["cycling"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "addHealthHeartRate":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthHeartRate(heartRate: argument["heartRate"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "requestHealthAuthority":
            HealthTool.sharedInstance.requestHealthAuthority(subclassificationIndex: call.arguments as! Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "getHealthAuthorityStatus":
            let answer = HealthTool.sharedInstance.getHealthAuthorityStatus(subclassificationIndex: call.arguments as! Int).rawValue
            result(answer)
            break;
        case "isHealthDataAvailable":
            result(HealthTool.sharedInstance.isHealthDataAvailable())
            break;
        case "gotoHealthApp":
            HealthTool.sharedInstance.gotoHealthApp { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        default:
            break;
        }
       
    }
}

