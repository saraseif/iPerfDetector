//
//  MTTVisitor.swift
//  CDSwiftASTPackageDescription
//
//  Created by Sara on 11/12/17.
//

import Foundation
import AST
import Parser
import Source

private var mainScreenConstansArr: [[String:ConstantDeclaration?]] = []
private var mainScreenVarialblesArr: [[String:VariableDeclaration?]] = []
private var mainScreenFunctionsArr: [[String:Array<Any>]] = []
private var classesVisitedArr : [ClassDeclaration] = []
private var functionsVisitedArr : [FunctionDeclaration] = []
private var visitConstCalledOnce : Bool = false
private var visitFuncCalledOnce : Bool = false
private var visitClassCalledOnce : Bool = false

class MMTVisitor : ASTVisitor {
    
    public var currentClass : ClassDeclaration = ClassDeclaration(name: "")
    func write(text: String, to fileNamed: String, folder: String = "SavedFiles") {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
        guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return }
        try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
        let file = writePath.appendingPathComponent(fileNamed + ".txt")
        if FileManager.default.fileExists(atPath: file.path)
        {
            let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            if let fileHandle = FileHandle(forWritingAtPath: file.path) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        }
        else
        {
            try? text.write(to: file, atomically: false, encoding: String.Encoding.utf8)
        }
    }
    func visit(_ varStmt: VariableDeclaration) throws -> Bool {
        let str = varStmt.textDescription
        var criteriaIndex : String.Index
        if let index = str.index(of: "=") {
            criteriaIndex = index
            if let colonIndex = str.index(of: ":")
            {
                if colonIndex<index
                {
                    criteriaIndex = colonIndex
                }
            }
            let variableType = str[index..<str.endIndex]
            
            if let range = str.range(of:"var ")
            {
                let variableName = String(str[range.upperBound..<criteriaIndex]).trimmingCharacters(in:[" "])
                let uiArr = ["UIScreen.main", "UIWindow", "UIApplication", "UIWebView", "UIPickerView", "UIImageView", "UIScrollView", "UIButton", "UIProgressView", "UIPageControl", "UISlider", "UISegmentControl", "UILabel", "UISwitch", "UITextView", "UITextField", "UIBarItem", "UIBarButtonItem", "UISearchbar"]
                for uiElement in uiArr
                {
                    if variableType.contains(uiElement)
                    {
                        let dic = [variableName: varStmt]
                        let filteredArray = mainScreenVarialblesArr.filter { $0.keys.contains(variableName)}
                        if filteredArray.count == 0
                        {
                            mainScreenVarialblesArr.append(dic)
                        }
                        break
                        
                    }
                    
                }
            }
        }
        return true
    }
    func visit(_ letStmt: ConstantDeclaration) throws -> Bool {
        let str = letStmt.textDescription
        if let index = str.index(of: "=") {
            let variableType = str[index..<str.endIndex]
            let variableName = (letStmt.initializerList.first as PatternInitializer!).pattern.textDescription
            let uiArr = ["UIScreen.main", "UIWindow", "UIApplication", "UIWebView", "UIPickerView", "UIImageView", "UIScrollView", "UIButton", "UIProgressView", "UIPageControl", "UISlider", "UISegmentControl", "UILabel", "UISwitch", "UITextView", "UITextField", "UIBarItem", "UIBarButtonItem", "UISearchbar"]
            for uiElement in uiArr
            {
                if variableType.contains(uiElement)
                {
                    let dic = [variableName : letStmt]
                    let filteredArray = mainScreenVarialblesArr.filter { $0.keys.contains(variableName)}
                    if filteredArray.count == 0
                    {
                        mainScreenConstansArr.append(dic)
                    }
                    break
                    
                }
                
            }
        }
        return true
    }
    func visit(_ funcStmt: FunctionDeclaration) throws -> Bool {
        let filteredArray = functionsVisitedArr.filter {
            return $0.name == funcStmt.name
        }
        if filteredArray.count == 0
        {
            functionsVisitedArr.append(funcStmt)
        }
        for variableDic in mainScreenConstansArr
        {
            if let funcBody = funcStmt.body
            {
                if (funcBody.textDescription.contains(variableDic.keys.first!))
                {
                    let dic = [funcStmt.name : [variableDic.keys.first!, funcStmt, variableDic.keys.first!]]
                    let filteredArray = mainScreenFunctionsArr.filter { $0.keys.contains(funcStmt.name)}
                    if filteredArray.count == 0
                    {
                        mainScreenFunctionsArr.append(dic)
                    }
                    //                return true
                }
            }
        }
        for variableDic in mainScreenVarialblesArr
        {
            if let funcBody = funcStmt.body
            {
                if (funcBody.textDescription.contains(variableDic.keys.first!))
                {
                    let dic = [funcStmt.name : [variableDic.keys.first!, funcStmt, variableDic.keys.first!]]
                    let filteredArray = mainScreenFunctionsArr.filter { $0.keys.contains(funcStmt.name)}
                    if filteredArray.count == 0
                    {
                        mainScreenFunctionsArr.append(dic)
                    }
                    //                return true
                }
            }
        }
        return true
    }
    func traverseAllFunctions()
    {
        var i = 0
        for funcStmt in functionsVisitedArr
        {
            //            print("funcStmt Series 1 = \(i)")
            for variableDic in mainScreenVarialblesArr
            {
                let key = [String](variableDic.keys)[0]
                //                print("variableDic \(key)")
                if let body = funcStmt.body
                {
                    if (body.textDescription.contains(key))
                    {
                        let dic = [funcStmt.name : [key, funcStmt, variableDic.keys.first!]]
                        let filteredArray = mainScreenFunctionsArr.filter { $0.keys.contains(funcStmt.name)}
                        if filteredArray.count == 0
                        {
                            mainScreenFunctionsArr.append(dic)
                            //print("\(arr.count) \(mainScreenFunctionsArr.count)")
                        }
                    }
                }
            }
            for variableDic in mainScreenConstansArr
            {
                let key = [String](variableDic.keys)[0]
                //                print("variableDic \(key)")
                if let body = funcStmt.body
                {
                    if (body.textDescription.contains(key))
                    {
                        let dic = [funcStmt.name : [key, funcStmt, (variableDic.values.first!! as ConstantDeclaration)]]
                        let filteredArray = mainScreenFunctionsArr.filter { $0.keys.contains(funcStmt.name)}
                        if filteredArray.count == 0
                        {
                            mainScreenFunctionsArr.append(dic)
                            //print("\(arr.count) \(mainScreenFunctionsArr.count)")
                        }
                    }
                }
            }
            i+=1
            
        }
        i = 0
        
        var arr = mainScreenFunctionsArr
        var funcArrGettingChanged = true
        while(funcArrGettingChanged)
        {
            funcArrGettingChanged = false
            for funcStmt in functionsVisitedArr
            {
                //            print("funcStmt Series 2 = \(i)")
                for functionDic in mainScreenFunctionsArr
                {
                    let key = [String](functionDic.keys)[0]
                    //                print("funcDict \(key)")
                    if let funcstBody = funcStmt.body
                    {
                        if (funcstBody.description.contains(key))
                        {
                            let dic = [funcStmt.name : [key, funcStmt, nil]]
                            let filteredArray = arr.filter { $0.keys.contains(funcStmt.name)}
                            if filteredArray.count == 0
                            {
                                arr.append(dic)
                                funcArrGettingChanged = true
                            }
                        }
                    }
                }
                i+=1
            }
            
            mainScreenFunctionsArr = arr
        }
        
    }
    func visit(_ classStmt: ClassDeclaration) throws -> Bool {
        classesVisitedArr.append(classStmt)
        currentClass = classStmt
        var arr = mainScreenFunctionsArr
        for functionDic in mainScreenFunctionsArr
        {
            let funcName = [String](functionDic.keys)[0]
            
            if classStmt.description.contains(funcName)
            {
                let filteredArray = mainScreenFunctionsArr.filter { $0.keys.contains(funcName)}
                if filteredArray.count == 0
                {
                    arr.append(functionDic)
                }
                
            }
        }
        mainScreenFunctionsArr = arr
        return true
    }
    public func checkIfUIMainScreenFunctionIsCalledInBGThread()
    {
        traverseAllFunctions()
        
        for dic in mainScreenFunctionsArr
        {
            let arr = dic.values.first
            let funcStmt = arr![1] as! FunctionDeclaration
            let variableName = dic.values.first?.first as! String
            //context background mode
            let regexStr0000 = String(format:"perform.*%@", funcStmt.name)
            let regexStr000 = String(format:"performAndWait.*%@", funcStmt.name)
            let regexStr00 = String(format:"performBlockAndWait.*.%@\\(.*", funcStmt.name)
            let regexStr0 = String(format:"performBlock.*.%@\\(.*", funcStmt.name)
            //Operation case
            let regexStr2 = String("DispatchQueue\\.global\\(.*\\).async\\{([^}]*\(funcStmt.name)[^}]*)\\}")
            
            let str = funcStmt.description.trimmingCharacters(in: [" "])
            
            var matchesArr = regexMatches(for: regexStr0, in: str)
            matchesArr.append(contentsOf:regexMatches(for: regexStr0000, in: str))
            matchesArr.append(contentsOf:regexMatches(for: regexStr000, in: str))
            matchesArr.append(contentsOf:regexMatches(for: regexStr00, in: str))
            matchesArr.append(contentsOf:regexMatches(for: regexStr2, in: str))
            if matchesArr.count != 0
            {
                print(String(format:"CDASTAnalyzer Warning! You are doing UI tasks in a background thread in function:%@ \nLine: %i Column:%i",funcStmt.name, funcStmt.sourceLocation.line, funcStmt.sourceLocation.column))
            }
            
            
            let regexStr20000 = String(format:"perform.*%@", variableName)
            let regexStr2000 = String(format:"performAndWait.*%@", variableName)
            let regexStr200 = String(format:"performBlockAndWait.*.%@\\(.*", variableName)
            let regexStr20 = String(format:"performBlock.*.%@\\(.*", variableName)
            //multi threading
            let regexStr22 = String("DispatchQueue\\.global\\(.*\\).async\\{([^}]*\(variableName)[^}]*)\\}")
     
            
            var matchesArr2 = regexMatches(for: regexStr0, in: str)
            matchesArr2.append(contentsOf:regexMatches(for: regexStr20000, in: str))
            matchesArr2.append(contentsOf:regexMatches(for: regexStr2000, in: str))
            matchesArr2.append(contentsOf:regexMatches(for: regexStr200, in: str))
            matchesArr2.append(contentsOf:regexMatches(for: regexStr20, in: str))
            matchesArr2.append(contentsOf:regexMatches(for: regexStr22, in: str))
            if matchesArr2.count != 0
            {
                let text = String(format:"CDASTAnalyzer Warning! You are doing UI tasks in a background thread using \"\(variableName)\" in function:%@ \nLine: %i Column:%i",funcStmt.name, funcStmt.sourceLocation.line, funcStmt.sourceLocation.column)
                write(text: text, to: "MMTDetectionResults")
                print(text)
            }
        }
        
    }
}

