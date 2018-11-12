//
//  DBTVisitor.swift
//  CDSwiftASTPackageDescription
//
//  Created by Sara on 11/12/17.
//

import Foundation
import AST
import Parser
import Source

var managedObjectsVars: [VariableDeclaration] = []
var managedContextVars: [VariableDeclaration] = []
var managedContextConstants: [ConstantDeclaration] = []
var coreDataRelatedFuncs: [FunctionDeclaration] = []
var managedObjectClasses: [ClassDeclaration] = []
var arrayOfManagedObjContextMethodNames: [String] = ["fetch", "count", "object", "registeredObject", "existingObject", "registeredObjects", "execute", "refreshAllObjects", "retainsRegisteredObjects", "shouldHandleInaccessibleFault", "insert", "delete", "assign", "obtainPermanentIDs", "detectConflicts", "refresh", "processPendingChanges", "observeValue", "mergeChanges", "setQueryGenerationFrom", "save", "undo", "redo" ,"reset", "rollback"]

private var classesVisitedArr : [ClassDeclaration] = []
private var functionsVisitedArr : [[String : FunctionDeclaration]] = []
private var managedObjFunctionsVisitedArr : [FunctionDeclaration] = []

class DBTVisitor : ASTVisitor
{
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
        let str = varStmt.body.description
//        print("var: \(varStmt.description)")
        if let index = str.index(of: ":") {
            let variableType = str[index..<str.endIndex]
           
            if variableType.contains("NSManagedObjectContext") || variableType.contains(".viewContext")
            {
                managedContextVars.append(varStmt)
            }
        }
        return true
    }
    func visit(_ constStmt: ConstantDeclaration) throws -> Bool {
        if ((constStmt.initializerList.first?.textDescription.contains("NSManagedObjectContext"))! || (constStmt.initializerList.first?.textDescription.contains("viewContext"))!)
        {
            managedContextConstants.append(constStmt)
        }
        
        return true
    }
    
    func visit(_ funcStmt: FunctionDeclaration) throws -> Bool {
        //variables
        for managedObjectVar in managedContextVars {
            let str = managedObjectVar.body.description
            if let index = str.index(of: ":") {
                _ = str[index..<str.endIndex]
                let variableName = String(str[str.startIndex..<index])
                let regexStr = String(format:"%@..*\\(.*\\)", variableName)
                
                
                var str = funcStmt.body?.description.trimmingCharacters(in: [" "])
                let matchesArr = regexMatches(for: regexStr, in: str!)
                if matchesArr.count > 0
                {
                    for arrMatch in arrayOfManagedObjContextMethodNames
                    {
                        let methodReg = String(format:"%@..*%@\\(.*\\)", variableName, arrMatch)
                        let matchesArr = regexMatches(for: methodReg, in: str!)
                        if matchesArr.count > 0
                        {
                            let filteredArray = coreDataRelatedFuncs.filter {$0.textDescription.contains (funcStmt.description)}
                            if filteredArray.count == 0
                            {
                                //context background mode
                                let varNameAndMethod = "\(variableName).\(arrMatch)"
                                //context background mode
                                var trimmedStr =  str!.replacingOccurrences(of: "\\\n", with: "", options: .regularExpression)
                                trimmedStr =  trimmedStr.replacingOccurrences(of: " ", with: "", options: .regularExpression)
                                let regexStr00000 = String(format:"performBackgroundTask\\{.*\(varNameAndMethod)\\(.*\\)")
                                let regexStr0000 = String(format:"perform\\{.*\(varNameAndMethod)\\(.*\\)")
                                let regexStr000 = String(format:"performAndWait\\{.*\(varNameAndMethod)\\(.*\\)")
                                let regexStr00 = String(format:"performBlockAndWait\\{.*\(varNameAndMethod)\\(.*\\)")
                                let regexStr0 = String(format:"performBlock\\{.*\(varNameAndMethod)\\(.*\\)")
                                //Operation case
                                let regexStr1 = String(format:"completionBlock\(varNameAndMethod).*")
                                //multi threading
                                //let regexStr2 = String(format:"DispatchQueue\\.global\\(.*\\).async{.*%@.*}", (funcDecl!.name))
                                let regexStr2 = String("DispatchQueue\\.global\\(.*\\).async\\{([^}]*\(varNameAndMethod)[^}]*)\\}")
                                let regexStr3 = String(".async *\\{.*\(varNameAndMethod)\\(.*\\}")
                                let regexStr4 = String("success\\:\\{.*\(varNameAndMethod)\\(.*\\}")
                                let regexStr5 = String("failure\\:\\{.*\(varNameAndMethod)\\(.*\\}")
                                str = str!.replacingOccurrences(of: "\\\n", with: "", options: .regularExpression)
                                str = str!.replacingOccurrences(of: " ", with: "", options: .regularExpression)

                                var matchesArr2 = regexMatches(for: regexStr0, in: str!)
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr00000, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr0000, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr000, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr00, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr1, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr2, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr3, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr4, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr5, in: str!))
                               
                                if matchesArr2.count == 0
                                {
                                    
                                    if funcStmt.name == "disconnectJetpack"
                                    {
                                        print("disconnectJetpack")
                                    }
                                    coreDataRelatedFuncs.append(funcStmt)
                                }
                            }
                        }
                    }
                   
                }
            }
        }
        //constants
        for managedObjectVar in managedContextConstants {
            let str = managedObjectVar.description
            if let index = str.index(of: "=") {
                _ = str[index..<str.endIndex]
                var variableDef = String(str[str.startIndex..<index])
                variableDef = variableDef.replacingOccurrences(of: "let", with: "")
                let variableName = variableDef.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let regexStr = String(format:"%@..*\\(.*\\)", variableName)
                
                var str = funcStmt.body?.description.trimmingCharacters(in: [" "])
                let matchesArr = regexMatches(for: regexStr, in: str!)
                if matchesArr.count > 0
                {
                    for arrMatch in arrayOfManagedObjContextMethodNames
                    {
                        let methodReg = String(format:"%@..*%@.*\\(\\)", variableName, arrMatch)
                        let matchesArr = regexMatches(for: methodReg, in: str!)
                        if matchesArr.count > 0
                        {
                            let filteredArray = coreDataRelatedFuncs.filter {$0.textDescription.contains (funcStmt.description)}
                            if filteredArray.count == 0
                            {
                                let varNameAndMethod = "\(variableName).\(arrMatch)"
                                //context background mode
                                var trimmedStr =  str!.replacingOccurrences(of: "\\\n", with: "", options: .regularExpression)
                                trimmedStr =  trimmedStr.replacingOccurrences(of: " ", with: "", options: .regularExpression)
                                let regexStr0000 = String(format:"perform\\{.*\(varNameAndMethod)\\(.*\\)")
                                let regexStr000 = String(format:"performAndWait\\{.*\(varNameAndMethod)\\(.*\\)")
                                let regexStr00 = String(format:"performBlockAndWait\\{.*\(varNameAndMethod)\\(.*\\)")
                                let regexStr0 = String(format:"performBlock\\{.*\(varNameAndMethod)\\(.*\\)")
                                //Operation case
                                let regexStr1 = String(format:"completionBlock\(varNameAndMethod).*")
                                //multi threading
                                //let regexStr2 = String(format:"DispatchQueue\\.global\\(.*\\).async{.*%@.*}", (funcDecl!.name))
                                let regexStr2 = String("DispatchQueue\\.global\\(.*\\).async\\{([^}]*\(varNameAndMethod)[^}]*)\\}")
                                let regexStr3 = String(".async *\\{.*\(varNameAndMethod)\\(.*\\}")
                                let regexStr4 = String("success\\:\\{.*\(varNameAndMethod)\\(.*\\}")
                                let regexStr5 = String("failure\\:\\{.*\(varNameAndMethod)\\(.*\\}")
                                str = str!.replacingOccurrences(of: "\\\n", with: "", options: .regularExpression)
                                
                                var matchesArr2 = regexMatches(for: regexStr0, in: str!)
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr0000, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr000, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr00, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr1, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr2, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr3, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr4, in: str!))
                                matchesArr2.append(contentsOf:regexMatches(for: regexStr5, in: str!))
                                if matchesArr2.count == 0
                                {
                                    
                                    if funcStmt.name == "disconnectJetpack"
                                    {
                                        print("disconnectJetpack")
                                    }
                                    coreDataRelatedFuncs.append(funcStmt)
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        let filteredArray = functionsVisitedArr.filter {
            if let statement = $0[funcStmt.name]
            {
                return statement === funcStmt
            }
            else
            {
                return false
            }
        }
        
        if filteredArray.count == 0
        {
            functionsVisitedArr.append([currentClass.name: funcStmt])
        }
        
        return true
    }
    func visit(_ classStmt: ClassDeclaration) throws -> Bool {
        
        currentClass = classStmt
        if let clause = classStmt.typeInheritanceClause
        {
            if((clause.typeInheritanceList[0] as TypeIdentifier!)).names[0].name == "NSManagedObject"
            {
                managedObjectClasses.append(classStmt)
            }
        }
        return true
    }
    
    public func regexMatches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    public func checkIfCoreDataFunctionIsCalledInBGThread()
    {
        traverseAllFunctions()
    }
    func traverseAllFunctions()
    {
        for cdrFuncSt in coreDataRelatedFuncs
        {
            for funcStmtDic in functionsVisitedArr
            {
                
                if(funcStmtDic.values.first?.description.contains(".\(cdrFuncSt.name)("))! && funcStmtDic.values.first?.name != cdrFuncSt.name
                {
                    let funcDecl = funcStmtDic.values.first
                    //context background mode
                    let regexStr0000 = String(format:"perform.*%@", (cdrFuncSt.name))
                    let regexStr000 = String(format:"performAndWait.*%@", (cdrFuncSt.name))
                    let regexStr00 = String(format:"performBlockAndWait.*.%@\\(.*", (cdrFuncSt.name))
                    let regexStr0 = String(format:"performBlock.*.%@\\(.*", (cdrFuncSt.name))
                    //Operation case
                    let regexStr1 = String(format:"completionBlock.*%@.*", (cdrFuncSt.name))
                    //multi threading
                    //let regexStr2 = String(format:"DispatchQueue\\.global\\(.*\\).async{.*%@.*}", (funcDecl!.name))
                    let regexStr2 = String("DispatchQueue\\.global\\(.*\\).async\\{([^}]*\(cdrFuncSt.name)[^}]*)\\}")
                    let regexStr3 = String(".async *\\{.*\(cdrFuncSt.name)\\(.*\\}")
                    let regexStr4 = String("success\\:\\{.*\(cdrFuncSt.name)\\(.*\\}")
                    let regexStr5 = String("failure\\:\\{.*\(cdrFuncSt.name)\\(.*\\}")
                    let str = funcStmtDic.values.first?.description.replacingOccurrences(of: "\\\n", with: "", options: .regularExpression)

                    var matchesArr = regexMatches(for: regexStr0, in: str!)
                    matchesArr.append(contentsOf:regexMatches(for: regexStr0000, in: str!))
                    matchesArr.append(contentsOf:regexMatches(for: regexStr000, in: str!))
                    matchesArr.append(contentsOf:regexMatches(for: regexStr00, in: str!))
                    matchesArr.append(contentsOf:regexMatches(for: regexStr1, in: str!))
                    matchesArr.append(contentsOf:regexMatches(for: regexStr2, in: str!))
                    matchesArr.append(contentsOf:regexMatches(for: regexStr3, in: str!))
                    matchesArr.append(contentsOf:regexMatches(for: regexStr4, in: str!))
                    matchesArr.append(contentsOf:regexMatches(for: regexStr5, in: str!))
                    if matchesArr.count == 0
                    {
                        let text = String(format:"CDASTAnalyzer Warning! You are doing Database related tasks (\(cdrFuncSt.name)) on the main thread in function:%@ \nLine: %i Column:%i Class:%@",(funcDecl?.name)!, (funcDecl?.sourceLocation.line)!, (funcDecl?.sourceLocation.column)!, funcStmtDic.keys.first!)
                        print(text)
                        write(text: text, to: "CDPerfDetectionResults")
                    }
                    
                }
            }
            
        }
    }
}

