//
//  IosSpecificCsxCommonPlugin.swift
//  ios_specific_csx
//
//  Created by 曹世鑫 on 2021/5/8.
//

import Flutter
import UIKit

public class IosSpecificCsxCommonPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ios_specific_csx_common", binaryMessenger: registrar.messenger())
    let instance = IosSpecificCsxCommonPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
