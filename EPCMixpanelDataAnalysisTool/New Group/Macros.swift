//
//  Macros.swift
//  EPCMixpanelDataAnalysisTool
//
//  Created by LioWu on 11/01/2018.
//  Copyright © 2018 Expedia. All rights reserved.
//

import Cocoa


enum NumberValueType:String {
    case size
    case totalTime
    case avgSpeed
    
    static let allValues = [size.rawValue, totalTime.rawValue, avgSpeed.rawValue]
}

struct MixpanelFile {
    let content:String
    let filePath:String
    let fileName:String
    init(content:String, filePath:String, fileName:String) {
        self.content = content
        self.filePath = filePath
        self.fileName = fileName
    }
}

let kTime = "time"
let kProperties = "properties"
let kModel = "$model"

// TP
let TP = [50,95]

/// ["TP50", "TP95"]
let TP_Desc = TP.map { (tp) -> String in
    return "TP\(tp)"
}

/// ["TP50":-1, "TP95":-1]
let TP_Default = { () -> [String: Float] in
    var tpDefaultDict = [String:Float]()
    for tp in TP {
        tpDefaultDict["TP\(tp)"] = Float(-1)
    }
    return tpDefaultDict
}()

/// Device for different Hardware strings
public let Dict_DeviceForHardwareStrings:[String:String] = [
    // iPhone
    "iPhone1,1":"iPhone",
    
    "iPhone1,2":"iPhone 3G",
    
    "iPhone2,1":"iPhone 3GS",
    
    "iPhone3,1":"iPhone 4",
    "iPhone3,2":"iPhone 4",
    "iPhone3,3":"iPhone 4",
    
    "iPhone4,1":"iPhone 4S",
    
    "iPhone5,1":"iPhone 5",
    "iPhone5,2":"iPhone 5",
    
    "iPhone5,3":"iPhone 5C",
    "iPhone5,4":"iPhone 5C",
    
    "iPhone6,1":"iPhone 5S",
    "iPhone6,2":"iPhone 5S",
    
    "iPhone7,2":"iPhone 6",
    
    "iPhone7,1":"iPhone 6 Plus",
    
    "iPhone8,1":"iPhone 6S",
    
    "iPhone8,2":"iPhone 6S Plus",
    
    "iPhone8,4":"iPhone SE",
    
    "iPhone9,1":"iPhone 7",
    "iPhone9,3":"iPhone 7",
    
    "iPhone9,2":"iPhone 7 Plus",
    "iPhone9,4":"iPhone 7 Plus",
    
    "iPhone10,1":"iPhone 8",
    "iPhone10,4":"iPhone 8",
    
    "iPhone10,2":"iPhone 8 Plus",
    "iPhone10,5":"iPhone 8 Plus",
    
    "iPhone10,3":"iPhone X",
    "iPhone10,6":"iPhone X",
    
    // iPad
    "iPad1,1": "iPad (1st generation)",
    
    "iPad2,1": "iPad 2",
    "iPad2,2": "iPad 2",
    "iPad2,3": "iPad 2",
    "iPad2,4": "iPad 2",
    
    "iPad3,1": "iPad (3rd generation)",
    "iPad3,2": "iPad (3rd generation)",
    "iPad3,3": "iPad (3rd generation)",
    
    "iPad3,4": "iPad (4th generation)",
    "iPad3,5": "iPad (4th generation)",
    "iPad3,6": "iPad (4th generation)",
    
    "iPad4,1": "iPad Air",
    "iPad4,2": "iPad Air",
    "iPad4,3": "iPad Air",
    
    "iPad5,3": "iPad Air 2",
    "iPad5,4": "iPad Air 2",
    
    "iPad6,11": "iPad(2017)",
    "iPad6,12": "iPad(2017)",
    
    "iPad2,5": "iPad mini",
    "iPad2,6": "iPad mini",
    "iPad2,7": "iPad mini",
    
    "iPad4,4": "iPad mini 2",
    "iPad4,5": "iPad mini 2",
    "iPad4,6": "iPad mini 2",
    
    "iPad4,7": "iPad mini 3",
    "iPad4,8": "iPad mini 3",
    "iPad4,9": "iPad mini 3",
    
    "iPad5,1": "iPad mini 4",
    "iPad5,2": "iPad mini 4",
    
    "iPad6,7": "iPad Pro 12.9-inch (1st generation)",
    "iPad6,8": "iPad Pro 12.9-inch (1st generation)",
    
    "iPad6,3": "iPad Pro 9.7-inch",
    "iPad6,4": "iPad Pro 9.7-inch",
    
    "iPad7,1": "iPad Pro 12.9-inch (2nd generation)",
    "iPad7,2": "iPad Pro 12.9-inch (2nd generation)",
    
    "iPad7,3": "iPad Pro 10.5-inch",
    "iPad7,4": "iPad Pro 10.5-inch"
]
