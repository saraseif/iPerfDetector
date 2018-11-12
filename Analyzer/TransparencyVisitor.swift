//
//  TransparencyVisitor.swift
//  CDSwiftASTPackageDescription
//
//  Created by Sara on 5/28/18.
//

import Foundation
import AST
import Parser
import Source

var selfClassStmt2: ClassDeclaration? = nil
var transparentVariableArr : [[String:VariableDeclaration?]] = []
var transparentVariableArrInCells : [[String:VariableDeclaration?]] = []

class TransparencyVisitor : ASTVisitor {
    
    public var isClassTypeCell: Bool = false
    
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
    func visit(_ forStmt: ForInStatement) throws -> Bool {
        for varDict in transparentVariableArr
        {
            let varName = [String](varDict.keys)[0]
            if forStmt.textDescription.contains(varName)
            {
                let varDecl = varDict[varName]! as VariableDeclaration?
                let text = String(format:"CDASTAnalyzer Warning! You are adding Transparency defined in %@ in a for in loop which could be repeated and hit performance \nLine: %i Column:%i Class: %@",varName, (varDecl?.sourceLocation.line)!, (varDecl?.sourceLocation.column)!, (selfClassStmt?.name)!)
                print(text)
                write(text: text, to: "TransparencyDetectionResults")
            }
        }
        return true
    }
    func visit(_ whileStmt: WhileStatement) throws -> Bool {
        for varDict in transparentVariableArr
        {
            let varName = [String](varDict.keys)[0]
            if whileStmt.textDescription.contains(varName)
            {
                let varDecl = varDict[varName]! as VariableDeclaration?
                let text = String(format:"CDASTAnalyzer Warning! You are adding Transparency defined in %@ in a while loop which could be repeated and hit performance \nLine: %i Column:%i Class: %@",varName, (varDecl?.sourceLocation.line)!, (varDecl?.sourceLocation.column)!, (selfClassStmt?.name)!)
                print(text)
                write(text: text, to: "TransparencyDetectionResults")
            }
        }
        return true
    }
    func visit(_ repeatWhileStmt: RepeatWhileStatement) throws -> Bool {
        for varDict in transparentVariableArr
        {
            let varName = [String](varDict.keys)[0]
            if repeatWhileStmt.textDescription.contains(varName)
            {
                let varDecl = varDict[varName]! as VariableDeclaration?
                let text = String(format:"CDASTAnalyzer Warning! You are adding Transparency defined in %@ in a repeat while loop which could be repeated and hit performance \nLine: %i Column:%i Class: %@",varName, (varDecl?.sourceLocation.line)!, (varDecl?.sourceLocation.column)!, (selfClassStmt?.name)!)
                print(text)
                write(text: text, to: "TransparencyDetectionResults")
            }
        }
        return true
    }
    func visit(_ decl: VariableDeclaration) throws -> Bool {
        
        let str = decl.body.description.replacingOccurrences(of:" ", with: "")
        if let index = str.index(of: "=") {
//            let variableType = str[index..<str.endIndex]
            var variableName : String = String(str[str.startIndex...index])
            if variableName.contains(":")
            {
                variableName = String(str[str.startIndex..<variableName.index(of:":")!])
            }
            if variableName.contains("=")
            {
                variableName = String(str[str.startIndex..<variableName.index(of:"=")!])
            }
            if str.contains("alpha:") || str.contains("ithAlphaComponent") || str.contains("alpha=")
            {
                var alpha : Float = 0.0
                if str.contains("ithAlphaComponent")
                {
                    let arr = str.components(separatedBy: "ithAlphaComponent(")
                    if arr.count>0
                    {
                        let arr2 = arr[1].components(separatedBy: ")")
                        if let floatAlpha = Float(arr2.first!)
                        {
                            alpha = floatAlpha
                        }
                        
                    }
                }
                if str.contains("alpha:")
                {
                    let arr = str.components(separatedBy: "alpha:")
                    if arr.count>0
                    {
                        let arr2 = arr[1].components(separatedBy: ")")
                        if let floatAlpha = Float(arr2.first!)
                        {
                            alpha = floatAlpha
                        }
                        
                    }
                }
                if str.contains("alpha=")
                {
                    let arr = str.components(separatedBy: "alpha=")
                    if arr.count>0
                    {
                        let arr2 = arr[1].components(separatedBy: "\n")
                        if let floatAlpha = Float(arr2.first!)
                        {
                            alpha = floatAlpha
                        }
                        
                    }
                }
                if alpha != 1.0 && alpha != 0.0
                {
                    if isClassTypeCell
                    {
                        transparentVariableArrInCells.append([variableName: decl])
                    }
                    else
                    {
                        transparentVariableArr.append([variableName: decl])
                    }
                }
            }
        }
        
        
        switch decl.body {
        case .initializerList(let inits):
            for initializer in inits
            {
                if(initializer.pattern.textDescription.contains("UIVisualEffectView"))
                {
                    //                    print(String(format: "variable %@ is of type UIVisualEffectView", decl.attributes))
                }
                
            }
        case let .codeBlock(_, type, block):
            if(type.description.contains("UIVisualEffectView"))
            {
                //                print(String(format: "variable %@ is of type UIVisualEffectView", decl.description))
                //                decl.n
                //                try self.visit(InitializerDeclaration)
                
            }
            
            if (block.statements.last?.description.contains("return "))!
            {
                let stmt = block.statements.last
                if(stmt?.description.contains("return "))!
                {
                    //                    print(String(format: "variable %@ is returning", decl.description))
                }
                
            }
        default:
            break
        }
        return true
    }
    func visit(_ classStmt: ClassDeclaration) throws -> Bool {
        transparentVariableArrInCells = []
        transparentVariableArr = []
        //check for blur effect
        selfClassStmt = classStmt
        if let clause = classStmt.typeInheritanceClause
        {
            if((clause.typeInheritanceList[0] as TypeIdentifier!)).names[0].name == "UICollectionViewCell" || ((clause.typeInheritanceList[0] as TypeIdentifier!)).names[0].name == "UITableViewCell"
            {
                isClassTypeCell = true
                
            }
        }
        
        //check for SQLite
        return true
    }
    public func checkOpacityForCellClass()
    {
//        let str = selfClassStmt?.textDescription
        let className = selfClassStmt?.name
        for varDict in transparentVariableArrInCells
        {
            let varName = [String](varDict.keys)[0]
            if let varDecl = varDict[varName]
            {
                let text = "CDASTAnalyzer Warning! You are using transparrancy in variable: \(varName) in a cell which could be repeated and hit performance \nLine:\(String(describing: varDecl!.sourceLocation.line))  Column:\(String(describing: varDecl!.sourceLocation.column)) Class: \(className!)"
                print(text)
                write(text: text, to: "TransparencyDetectionResults")
            }
        }
        
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
    
}






