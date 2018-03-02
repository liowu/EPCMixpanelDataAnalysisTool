//
//  EPCMixpanelDataAnalysisTool.swift
//  EPCMixpanelDataAnalysisTool
//
//  Created by LioWu on 10/01/2018.
//  Copyright © 2018 Expedia. All rights reserved.
//

import Foundation
import SwiftyJSON

class EPCMixpanelDataAnalysisTool: NSObject {
    
    public static let `default` = EPCMixpanelDataAnalysisTool()
    public static let fileExportFolderPath = { () -> String in
        return NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0] + "/mixpanel-analysis"
    }()
    
    private var globalJson:[JSON]?
    var eventName:String?
    var mixDateTimeInterval:Int64 = 0
    var maxDateTimeInterval:Int64 = 0
    var stringKeyArray = [String]()
    var files = [MixpanelFile]()
    
    func loadJsonData(jsonFilePath:String) {
        if let jsonFilePath = try? String(contentsOfFile: jsonFilePath),
            let jsonData = jsonFilePath.data(using: String.Encoding.utf8) {
            globalJson = JSON(jsonData).array
            loadJsonDataInfo()
        }
    }
    
    func loadJsonDataInfo() {
        // event
        eventName = globalJson?.first?["name"].string
        
        // min,max date
        if let time = globalJson?.first?[kTime].int64 {
            mixDateTimeInterval = time
            maxDateTimeInterval = time
        }
        if let globalJsonArray = globalJson {
            for itemJson in globalJsonArray {
                if let time = itemJson[kTime].int64 {
                    if time < mixDateTimeInterval {
                        mixDateTimeInterval = time
                    }
                    
                    if time > maxDateTimeInterval {
                        maxDateTimeInterval = time
                    }
                }
            }
        }
        
        // key
        stringKeyArray.removeAll()
        if let kv = globalJson?.first?[kProperties].dictionary {
            for case let k in kv.keys {
                if let _ = kv[k]?.string, NumberValueType.allValues.contains(k) == false  {
                    stringKeyArray.append(k)
                }
            }
        }
    }
    
    static func filterJson(_ jsonArray:[JSON]?) -> [JSON]? {
        return jsonArray
    }
    
    // 时间段划分的 key -> valueKey 统计
    func tpFor(dates:[MixpanelDate], key:String, valueKey:String) {
        files.removeAll()
        for item in dates {
            tpFor(date: item, key: key, valueKey: valueKey)
        }
    }
    
    // 时间段划分的 valueKey 统计
    func tpFor(dates:[MixpanelDate], valueKey:String, dateDesc:String) {
        files.removeAll()
        var dateAndValuesDict = [String:(count:Int, tp:[Float])]()
        for item in dates {
            if let value = tpFor(date: item, valueKey: valueKey) {
                dateAndValuesDict[item.decription] = value
            }
        }
        
        if dateAndValuesDict.keys.isEmpty {
            return
        }
        
        // 文件
        var csv = "Date"
        csv = "Date" + ", count"
        for tp in TP_Desc {
            csv.append(", "+tp)
        }
        csv = csv + "\n"
        
        for (dateKey, v) in dateAndValuesDict {
            // 日期
            csv = csv + dateKey
            
            // count
            csv = csv + ", \(v.count)"
            
            // tp
            for item in v.tp {
              csv = csv + ", \(item)"
            }
            csv = csv + "\n"
        }
        let file = MixpanelFile(content: csv, filePath: EPCMixpanelDataAnalysisTool.fileExportFolderPath, fileName: "[All \(valueKey)] " + dateDesc +  ".xls")
        files.append(file)
    }
    
    private func tpFor(date:MixpanelDate, valueKey:String) -> (count:Int, tp:[Float])? {
        var filterArray = [Float]()
        if let globalJsonArray = globalJson {
            for itemJson in globalJsonArray {
                if let time = itemJson[kTime].int64,
                    case date.time.startTime..<date.time.endTime = time,
//                    添加过滤器，这里过滤出美国的
                    let mp_country_code = itemJson["properties"]["mp_country_code"].string,
                    mp_country_code == "US"
                {
                    let value = Util.correctData(key: valueKey, keyJson: itemJson[kProperties][valueKey])
                    filterArray.append(value)
                }
            }
        }
        
        if filterArray.isEmpty {
            return nil
        }
        
        // 排序
        filterArray = filterArray.sorted()
        
        // tp
        var tpValueArray = [Float]()
        for tp in TP {
            let index = Int(Float(tp * filterArray.count) / 100)
            tpValueArray.append(filterArray[index])
        }
        return (count:filterArray.count, tp:tpValueArray)
    }
    
    // 不同机型下的 size TP50,TP95
    func tpFor(date:MixpanelDate, key:String, valueKey:String) {
        var keySet = Set<String>()
        var keyDiff_Value = [String:[Float]]()
        var keyDiff_TP = [String: [String:Float]]()
        
        var filterJsonArray = globalJson?.map({ (json) -> [String:Any] in
            var tempDict = [String:Any]()
            let keyJson = json[kProperties][key]
            let valueJson = json[kProperties][valueKey]
            tempDict[key] = Util.correctStringKeyData(key: key, keyJson: keyJson)
            tempDict[valueKey] = Util.correctData(key: valueKey, keyJson: valueJson)
            tempDict[kTime] = json[kTime].int64
            return tempDict
        })
        
        filterJsonArray = filterJsonArray?.filter({ (dict) -> Bool in
            if let time = dict[kTime] as? Int64, case date.time.startTime..<date.time.endTime = time {
                if let k = dict[key] as? String {
                    keySet.insert(k)
                }
                return true
            }
            return false
        })
        
        print(keySet)
        if keySet.isEmpty {
            return
        }
        
        if let filterJsonArray = filterJsonArray {
            for item in keySet {
                keyDiff_Value[item] = [Float]()
                keyDiff_TP[item] = TP_Default
            }
            
            // 分别收集数据
            for item in filterJsonArray {
                if let k = item[key] as? String,
                    let v = item[valueKey] as? Float {
                    var values = keyDiff_Value[k]
                    values?.append(v)
                    keyDiff_Value[k] = values
                }
            }
            
            // 数据排序, 并计算 TP
            for (k, v) in keyDiff_Value {
                let sortedValue = v.sorted()
                keyDiff_Value[k] = sortedValue
                for tp in TP {
                    let index = Int(Float(tp * sortedValue.count) / 100)
                    let tpValue = sortedValue[index]
                    
                    if var tpDict = keyDiff_TP[k] {
                        tpDict["TP\(tp)"] = tpValue
                        keyDiff_TP[k] = tpDict
                    }
                }
            }
            
            // 文件
            var csv = "\(key)"
            for tp in TP {
                csv.append(", TP\(tp)")
            }
            csv = csv + "\n"
            
            for (k, v) in keyDiff_TP {
                csv = csv + "\(k), \(v["TP50"]!), \(v["TP95"]!)" + "\n"
            }
            let file = MixpanelFile(content: csv, filePath: EPCMixpanelDataAnalysisTool.fileExportFolderPath, fileName: "[\(key) -> \(valueKey)] " + date.decription + ".xls")
            files.append(file)
        }
    }
    
    func exportFilesDescription() -> String {
        var desc = "======= Files ====== \n"
        if files.count == 0 {
            desc = desc + "no files \n"
            return desc
        }
        
        for item in files {
            desc = desc + item.fileName + "\n"
        }
        return desc
    }
    
    func exportFiles() {
        for item in files {
            try! createXlsFile(content: item.content, filePath: item.filePath, fileName: item.fileName)
        }
    }
    
    private func createXlsFile(content:String, filePath:String, fileName:String) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
        }
        try content.write(to: URL(fileURLWithPath: filePath + "/\(fileName)"), atomically: true, encoding: .utf8)
    }
}

struct Util {
    static func correctStringKeyData(key:String?, keyJson:JSON?) -> String? {
        if key == kModel {
            return mapDevice(key: key, keyJson: keyJson)
        }
        return keyJson?.string
    }
    
    static func correctData(key:String?, keyJson:JSON?) -> Float {
        if key == NumberValueType.size.rawValue {
            return correctSize(keyJson)
        } else if key == NumberValueType.totalTime.rawValue {
            return correctTotalTime(keyJson)
        } else if key == NumberValueType.avgSpeed.rawValue {
            return correctAvgSpeed(keyJson)
        } else if let value = keyJson?.int {
            return Float(value)
        }
        
        return 0
    }
    
    static func mapDevice(key:String?, keyJson:JSON?) -> String? {
        if key == kModel, let model = keyJson?.string {
            return Dict_DeviceForHardwareStrings[model]
        }
        return nil
    }
    
    static func correctSize(_ size:JSON?) -> Float {
        // "10485760", 10
        // byte,       MB
        if let value = size?.string, let intValue = Int(value) {
            return Float(intValue)/1024/1024
        } else if let value = size?.int {
            return Float(value)
        }
        return 0;
    }
    
    static func correctTotalTime(_ totalTime:JSON?) -> Float {
        // "5000", 5
        // ms,     s
        if let value = totalTime?.string, let intValue = Int(value) {
            return Float(intValue)/1000
        } else if let value = totalTime?.int {
            return Float(value)
        }
        return 0;
    }
    
    static func correctAvgSpeed(_ avgSpeed:JSON?) -> Float {
        // "50 bps", 50
        // byte/s,   k/s
        if let value = avgSpeed?.string,
            let intValue = Int(value[...value.index(value.endIndex, offsetBy: -5)]) {
            return Float(intValue)/1024
        } else if let value = avgSpeed?.int {
            return Float(value)
        }
        return 0;
    }
}

