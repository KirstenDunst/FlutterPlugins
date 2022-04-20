//
//  NormalChannel.swift
//  Runner
//
//  Created by 曹世鑫 on 2022/3/2.
//

class NormalTool {
    static func copyFile(from:String,to:String)->Swift.Bool{
        if !FileManager.default.fileExists(atPath: from){
            return false
        }
        do{
            try FileManager.default.copyItem(atPath: from, toPath: to)
            return true
        }catch{
            return false
        }
    }
}
