//
//  MixpanelDate.swift
//  EPCMixpanelDataAnalysisTool
//
//  Created by LioWu on 12/01/2018.
//  Copyright © 2018 Expedia. All rights reserved.
//

import Cocoa


enum DateSeperatorType:String {
    case none
    case day
    case week
    case month
    
    static let allValues = [none.rawValue, day.rawValue, week.rawValue]
    static let allIndexes = [0, 1, 7]
}

public struct MixpanelDate {
    let time:(startTime:Int64, endTime:Int64)
    let decription:String
    init(time:(startTime:Int64, endTime:Int64)) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy.MM.dd"
        // dateformatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        
        self.time = time
        self.decription =
            dateformatter.string(from: Date(timeIntervalSince1970: TimeInterval(time.startTime/1000)))
            + " - "
            + dateformatter.string(from: Date(timeIntervalSince1970: TimeInterval(time.endTime/1000) - 1))
    }
    
    static func formatDate(startTime:Int64, endTime:Int64, sepDaysLength:Int) -> [MixpanelDate] {
        var mDateArray = [MixpanelDate]()
        let startTimeInt = String(startTime).count >= 13 ? startTime : startTime * 1000
        let endTimeInt = String(endTime).count >= 13 ? endTime : endTime * 1000
        
        if sepDaysLength == 0 {
            let noSepDate = MixpanelDate(time: (startTimeInt, endTimeInt))
            mDateArray.append(noSepDate)
        } else {
            let offset = Int64(sepDaysLength * 24 * 60 * 60 * 1000)
            var tempStartTime = startTimeInt
            while tempStartTime < endTimeInt {
                let tempEndTime = tempStartTime + offset
                let endDate = tempEndTime > endTimeInt ? endTimeInt : tempEndTime
                let sepDate = MixpanelDate(time: (tempStartTime, endDate))
                mDateArray.append(sepDate)
                tempStartTime = tempEndTime
            }
        }
        
        for item in mDateArray {
            print(item.decription)
        }
        
        return mDateArray
    }
}
