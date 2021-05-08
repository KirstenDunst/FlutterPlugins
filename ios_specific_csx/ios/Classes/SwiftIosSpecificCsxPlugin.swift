import Flutter
import UIKit

public class SwiftIosSpecificCsxPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ios_specific_csx", binaryMessenger: registrar.messenger())
        let instance = SwiftIosSpecificCsxPlugin()
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
        case "requestHealthAuthority":
            HealthTool.sharedInstance.requestHealthAuthority { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
            }
            break;
        case "getHealthAuthorityStatus":
            let answer = HealthTool.sharedInstance.getHealthAuthorityStatus(subclassificationIndex: call.arguments as! Int).rawValue
            result(answer)
            break;
        case "addHealthStature":
            let argument = call.arguments as! NSDictionary;
            HealthTool.sharedInstance.addHealthStature(height: argument["height"] as! Double,startDateInMill:argument["startDate"] as? Int, endDateInMill:argument["endDate"] as? Int) { (success, errorStr) in
                result(["success":success,"errorDescri":errorStr as Any])
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
            break;
        case "isHealthDataAvailable":
            let answer = HealthTool.sharedInstance.isHealthDataAvailable()
            result(answer)
            break;
        case "gotoHealthApp":
            guard let url = URL.init(string: "x-apple-health://app/") else {
                result(false)
                fatalError("生成跳转链接失败")
            }
            UIApplication.shared.open(url){(success) in
                result(success)
            }
            break;
        default:
            break;
        }
       
    }
}
