//
//  NormalChannel.swift
//  Runner
//
//  Created by 曹世鑫 on 2022/3/2.
//

import UIKit
import hot_fix_csx

class NormalChannel: NSObject,FlutterPlugin,FlutterStreamHandler {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel.init(name: NormalChannel.CHANNEL_NAME, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(NormalChannel(), channel: channel)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    static var CHANNEL_NAME = "hot_fix_csx_example123";
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        print("channel method:" + method)
        switch method {
        case "move_base_zip":
            // let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
            // let documentPath = documentPaths.first ?? ""
            // let targetPath = documentPath + "/www.zip"
            let targetPath = call.arguments as! String
            let back = Tool.copyFile(from: Bundle.main.path(forResource: "dist", ofType: "zip")!, to: targetPath)
            result(back)
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
}

class Tool {
    static func copyFile(from:String,to:String)->Int{
        if !FileManager.default.fileExists(atPath: from){
            return 0
        }
        do{
            try FileManager.default.copyItem(atPath: from, toPath: to)
            return 1
        }catch{
            return 0
        }
    }
}
