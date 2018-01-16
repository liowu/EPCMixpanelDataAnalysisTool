//
//  CheckFileDragView.swift
//  EPCMixpanelDataAnalysisTool
//
//  Created by LioWu on 15/01/2018.
//  Copyright © 2018 Expedia. All rights reserved.
//

import Cocoa

let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")

protocol CheckFileDragViewDelegate {
    func dragView(didDragFile filePath: String)
}

class CheckFileDragView: NSView {

    
    var delegate: CheckFileDragViewDelegate?
    
    //1
    private var fileTypeIsOk = false
    private var acceptedFileExtensions = ["json"]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.backwardsCompatibleFileURL])
    }
    
    //2
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        fileTypeIsOk = checkExtension(drag: sender)
        return []
    }
    
    //3
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return fileTypeIsOk ? .copy : []
    }
    
    //4
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let board = sender.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let jsonFilePath = board[0] as? String {
            delegate?.dragView(didDragFile: jsonFilePath)
            return true
        }
        return false
    }
    
    //5
    fileprivate func checkExtension(drag: NSDraggingInfo) -> Bool {
        
        if let board = drag.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? NSArray,
            let path = board[0] as? String {
            let url = NSURL(fileURLWithPath: path)
            if let fileExtension = url.pathExtension?.lowercased() {
                return acceptedFileExtensions.contains(fileExtension)
            }
        }
        return false
    }
    
    
}

//6
extension NSDraggingInfo {
    var draggedFileURL: NSURL? {
        let filenames = draggingPasteboard().propertyList(forType: .fileNameType(forPathExtension: ".json")) as? [String]
        let path = filenames?.first
        
        return path.map(NSURL.init)
    }
}

extension NSPasteboard.PasteboardType {
    
    static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {
        
        if #available(OSX 10.13, *) {
            return NSPasteboard.PasteboardType.fileURL
        } else {
            return NSPasteboard.PasteboardType(kUTTypeFileURL as String)
        }
        
    } ()
}
