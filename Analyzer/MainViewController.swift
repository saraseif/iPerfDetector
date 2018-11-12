//
//  MainViewController.swift
//  CDSwiftASTAnalyzer
//
//  Created by Sara on 11/9/17.
//

import Cocoa

import Foundation
class MainViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    var selectedURL: URL?
    
    @IBOutlet weak var filepathField: NSTextField!
    @IBAction func browse(_ sender: NSButton) {
        let dialog = NSOpenPanel();
        dialog.title = "Choose Swift project folder or Swift file";
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = true
//        dialog.allowedFileTypes = ["swift"]
        dialog.allowsOtherFileTypes = false
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            
            if let url = dialog.url {
             filepathField.stringValue = url.path
               selectedURL = url
                
            }
            
        }
    }
    @IBAction func detectBlurEffect(_ sender: NSButton) {
        guard let url = selectedURL else {
            print("selected url is empty")
            return
        }
        var isDir: ObjCBool = false
     FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        
        if !isDir.boolValue {
//            print("it is a file")
            analyzeSourceFileForBlurEffect(asPath: url.path)
        }
        else
        {
            // this is a directory
            let files = listFiles(atPath: url.path)
            for file in files {
                print("file: \(file)")
                analyzeSourceFileForBlurEffect(asPath: file)
            }
        }
    }
 
    @IBAction func detectDBT(_ sender: NSButton) {
        guard let url = selectedURL else {
            print("selected url is empty")
            return
        }
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        
        if !isDir.boolValue {
            //            print("it is a file")
            analyzeSourceFileForDBT(asPath: url.path)
        }else
        {
            // this is a directory
            let files = listFiles(atPath: url.path)
            for file in files {
                print("file: \(file)")
                analyzeSourceFileForDBT(asPath: file)
            }
        }
        findDBTAntiPattern()

    }
    @IBAction func detectMMT(_ sender: NSButton) {
        guard let url = selectedURL else {
            print("selected url is empty")
            return
        }
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        
        if !isDir.boolValue {
            //            print("it is a file")
            analyzeSourceFileForMMT(asPath: url.path)
        }
        else
        {
            // this is a directory
            let files = listFiles(atPath: url.path)
            for file in files {
                print("file: \(file)")
                analyzeSourceFileForMMT(asPath: file)
            }
        }
        findMMTAntiPattern()
    }
    
    @IBAction func detectOpacityInXib(_ sender: Any) {
        
        guard let url = selectedURL else {
            print("selected url is empty")
            return
        }
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        
        if !isDir.boolValue {
            //            print("it is a file")
            analyzeSourceFileForOpacity(asPath: url.path)
        }
        else
        {
            // this is a directory
            let files = listFiles(atPath: url.path)
            for file in files {
                print("file: \(file)")
                analyzeSourceFileForOpacity(asPath: file)
            }
        }
//        findOpacityAntiPattern()
    }
    @IBAction func detectOpacity(_ sender: Any) {
        
        guard let url = selectedURL else {
            print("selected url is empty")
            return
        }
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        
        if !isDir.boolValue {
            //            print("it is a file")
            analyzeSourceFileForOpacity(asPath: url.path)
        }
        else
        {
            // this is a directory
            let files = listFiles(atPath: url.path)
            for file in files {
                print("file: \(file)")
                analyzeSourceFileForOpacity(asPath: file)
            }
        }
//        findXMLOpacityAntiPattern()
    }
    func listFiles(atPath path: String) -> [String] {
        let fileManager = FileManager.default
        var files: [String] = []
        if let enumerator = try? fileManager.contentsOfDirectory(atPath: path) {
            
            for filePath in enumerator {
                
                let finalPath = NSURL(fileURLWithPath: path).appendingPathComponent(filePath)!.path
                
                if URL(fileURLWithPath: filePath).pathExtension == "swift" || URL(fileURLWithPath: filePath).pathExtension == "xib" {
                    files.append(finalPath)
                }
                files.append(contentsOf: listFiles(atPath: finalPath))
            }
        }
        
        return files
    }
}
