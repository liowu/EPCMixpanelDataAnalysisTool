//
//  ViewController.swift
//  EPCMixpanelDataAnalysisTool
//
//  Created by LioWu on 11/01/2018.
//  Copyright © 2018 Expedia. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {
    @IBOutlet weak var eventLabel: NSTextField!
    @IBOutlet weak var singleValueRadio: NSButton!
    @IBOutlet weak var keyValueRadio: NSButton!
    
    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var endDatePicker: NSDatePicker!
    @IBOutlet weak var dateSperatorPicker: NSPopUpButton!
    
    @IBOutlet weak var firstKeyPopMenu: NSPopUpButton!
    @IBOutlet weak var secKeyPopMenu: NSPopUpButton!
    
    @IBOutlet weak var checkDragFileView: CheckFileDragView!
    @IBOutlet weak var dataInfoTF: NSTextView!
    @IBOutlet weak var filePathLabel: NSTextField!
    @IBOutlet weak var refreshDataBtn: NSButton!
    @IBOutlet weak var exportBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkDragFileView.wantsLayer = true
        checkDragFileView.layer?.backgroundColor = NSColor.red.cgColor
        checkDragFileView.layer?.borderWidth = 2
        checkDragFileView.layer?.borderColor = NSColor.black.cgColor
        
        checkDragFileView.delegate = self
        
        refreshSubviews()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func refreshSubviews() {
        eventLabel.stringValue = EPCMixpanelDataAnalysisTool.default.eventName ?? "???"
        singleValueRadio.state = .on
        filePathLabel.stringValue = EPCMixpanelDataAnalysisTool.fileExportFolderPath
        refreshDate()
        refreshKeyPopMenu()
    }
    
    func refreshKeyPopMenu() {
        refreshFirstPopMenu()
        refreshSecondPopMenu()
    }
    
    func refreshDate() {
        let calendar = Calendar.current
        let startDate = Date(timeIntervalSince1970: TimeInterval(EPCMixpanelDataAnalysisTool.default.mixDateTimeInterval/1000))
        let endDate = Date(timeIntervalSince1970: TimeInterval(EPCMixpanelDataAnalysisTool.default.maxDateTimeInterval/1000))
        let startDateComponent = calendar.dateComponents([.year, .month, .day], from: startDate)
        let endDateComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
    
        startDatePicker.dateValue = calendar.date(from: startDateComponent) ?? Date()
        endDatePicker.dateValue = calendar.date(from: endDateComponents) ?? Date()
        
        dateSperatorPicker.removeAllItems()
        dateSperatorPicker.addItems(withTitles: DateSeperatorType.allValues)
    }
    
    func refreshFirstPopMenu() {
        firstKeyPopMenu.removeAllItems()
        if singleValueRadio.state == .on {
            firstKeyPopMenu.addItems(withTitles: NumberValueType.allValues)
        } else {
            firstKeyPopMenu.addItems(withTitles: EPCMixpanelDataAnalysisTool.default.stringKeyArray)
        }
    }
    
    func refreshSecondPopMenu() {
        secKeyPopMenu.removeAllItems()
        secKeyPopMenu.isHidden = singleValueRadio.state == .on
        if singleValueRadio.state == .off {
            secKeyPopMenu.addItems(withTitles: NumberValueType.allValues)
        }
    }
    
    func refreshData() {
        let startDate = Int64(startDatePicker.dateValue.timeIntervalSince1970 * 1000)
        let endDate = Int64(endDatePicker.dateValue.timeIntervalSince1970 * 1000 + 24 * 60 * 60 * 1000)
        let datesSep = MixpanelDate.formatDate(startTime: startDate, endTime: endDate, sepDaysLength: dateSperatorPickerSelectedItem())
        
        
        if singleValueRadio.state == .on {
            let valueKey = NumberValueType.allValues[firstKeyPopMenu.indexOfSelectedItem]
            // 1、一个字段（数值型）TP50 TP95
            let date = MixpanelDate.formatDate(startTime: startDate, endTime: endDate, sepDaysLength: 0)[0]
            EPCMixpanelDataAnalysisTool.default.tpFor(dates: datesSep, valueKey: valueKey, dateDesc:date.decription)
        } else {
            let key = EPCMixpanelDataAnalysisTool.default.stringKeyArray[firstKeyPopMenu.indexOfSelectedItem]
            let valueKey = NumberValueType.allValues[secKeyPopMenu.indexOfSelectedItem]
            // 2、以某关键字（字符型）分类，再以某字段（数值型）的TP50，TP95
            EPCMixpanelDataAnalysisTool.default.tpFor(dates: datesSep, key: key, valueKey: valueKey)
        }
        
        dataInfoTFScrollToBottom()
    }
    
    private func dataInfoTFScrollToBottom() {
        dataInfoTF.string = dataInfoTF.string + "\n" + EPCMixpanelDataAnalysisTool.default.exportFilesDescription()
        let ani = NSViewAnimation(duration: 0.5, animationCurve: NSAnimation.Curve.linear)
        ani.start()
        dataInfoTF.scrollRangeToVisible(NSRange(location: dataInfoTF.string.count, length: 0))
        ani.stop()
        
    }
    
    // MARK: - action
    @IBAction func keyModeChangeAction(_ sender: Any) {
        refreshKeyPopMenu()
    }
    
    @IBAction func refreshDataAction(_ sender: Any) {
        refreshData()
    }
    
    @IBAction func exportDataAction(_ sender: Any) {
        EPCMixpanelDataAnalysisTool.default.exportFiles()
    }
    
    func newfile() {
        let filePath =  Bundle.main.path(forResource: "mixpanel_1", ofType: "json")!
        EPCMixpanelDataAnalysisTool.default.loadJsonData(jsonFilePath: filePath)
    }
    
    // MARK: - private
    private func dateSperatorPickerSelectedItem() -> Int {
        let index = dateSperatorPicker.indexOfSelectedItem
        return DateSeperatorType.allIndexes[index]
    }
}

extension ViewController:CheckFileDragViewDelegate {
    func dragView(didDragFile filePath: String) {
        EPCMixpanelDataAnalysisTool.default.loadJsonData(jsonFilePath: filePath)
        refreshSubviews()
    }
}
