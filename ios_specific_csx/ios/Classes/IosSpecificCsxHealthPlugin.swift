//
//  IosSpecificCsxHealthPlugin.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2021/5/8.
//
import Flutter
import UIKit

public class IosSpecificCsxHealthPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    var eventSink:FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ios_specific_csx_health", binaryMessenger: registrar.messenger())
        let instance = IosSpecificCsxHealthPlugin()
        let eventChannel = FlutterEventChannel(name: "ios_specific_csx_health_event", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.eventSink?(["method":call.method,"arguments":call.arguments as Any])
        switch call.method {
            case "requestHealthAuthority":
            HealthNormalTool.sharedInstance.requestHealthAuthority(subclassificationIndex: call.arguments as! Int,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "requestHealthSubmodulesAuthority":
            HealthNormalTool.sharedInstance.requestHealthSubmodulesAuthority(subclassificationIndexs: call.arguments as! [Int],eventSink: eventSink) { (success, errorStr) in
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
            HealthTool.addHealthMindfulness(startDateInMill: argument["startDate"] as! CLong, endDateInMill: argument["endDate"] as! CLong, eventSink: self.eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthStature":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthStature(height: argument["height"] as! Double,startDateInMill:argument["startDate"] as? CLong, endDateInMill:argument["endDate"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "getHealthStature":
                let argument = call.arguments as! NSDictionary;
                HealthTool.getHealthStature(startDateInMill:argument["startDate"] as? CLong, endDateInMill:argument["endDate"] as? CLong) { (success, errorStr, arg)  in
                    result(["resultBase":["success":success,"errorDescri":errorStr as Any],"result":arg])
                }
                break;
            case "addHealthBodyMassIndex":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthBodyMassIndex(bodyMassIndex: argument["bodyMassIndex"] as! Double,startDateInMill:argument["startDate"] as? CLong, endDateInMill:argument["endDate"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthBodyFatPercentage":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthBodyFatPercentage(bodyFatPercentage: argument["bodyFatPercentage"] as! Double,startDateInMill:argument["startDate"] as? CLong, endDateInMill:argument["endDate"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthBodyMass":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthBodyMass(bodyMass: argument["bodyMass"] as! Double,startDateInMill:argument["startDate"] as? CLong, endDateInMill:argument["endDate"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthLeanBodyMass":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthLeanBodyMass(leanBodyMass: argument["leanBodyMass"] as! Double,startDateInMill:argument["startDate"] as? CLong, endDateInMill:argument["endDate"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthStepCount":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthStepCount(stepCount: argument["stepCount"] as! Double,startDateInMill:argument["startDate"] as? CLong, endDateInMill:argument["endDate"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthWalkingRunning":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthWalkingRunning(walkingRunning: argument["walkingRunning"] as! Double,startDateInMill:argument["startDate"] as? CLong, endDateInMill:argument["endDate"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthCycling":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthCycling(cycling: argument["cycling"] as! Double,startDateInMill:argument["startDate"] as? CLong, endDateInMill:argument["endDate"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthHeartRate":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthHeartRate(heartRate: argument["heartRate"] as! Int,dateInMill:argument["time"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            case "addHealthBloodOxygen":
                let argument = call.arguments as! NSDictionary;
                HealthTool.addHealthBloodOxygen(bloodOxygen: argument["bloodOxygen"] as! Double,dateInMill:argument["time"] as? CLong,eventSink: eventSink) { (success, errorStr) in
                    result(["success":success,"errorDescri":errorStr as Any])
                }
                break;
            default:
                break;
            }
    }
    
    //ios 主动给flutter 发送消息回调方法
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            self.eventSink = events
            return nil
        }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
            return nil
        }
    
}

