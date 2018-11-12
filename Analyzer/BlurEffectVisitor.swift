//
//  Visitor.swift
//  CDSwiftASTAnalyzer
//
//  Created by Sara on 11/9/17.
//

import Foundation
import AST
import Parser
import Source

var selfClassStmt: ClassDeclaration? = nil
var blurVarialblesArr: [[String:VariableDeclaration?]] = []


class BlurEffectVisitor : ASTVisitor {
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
        for varDict in blurVarialblesArr
        {
            let varName = [String](varDict.keys)[0]
            if forStmt.textDescription.contains(varName)
            {
                let varDecl = varDict[varName]! as VariableDeclaration?
                let text = String(format:"CDASTAnalyzer Warning! You are adding UIEffectView defined in %@ in a for in loop which could be repeated and hit performance \nLine: %i Column:%i Class: %@",varName, (varDecl?.sourceLocation.line)!, (varDecl?.sourceLocation.column)!, (selfClassStmt?.name)!)
                print(text)
                write(text: text, to: "BlurEffectDetectionResults")
            }
        }
        return true
    }
    func visit(_ whileStmt: WhileStatement) throws -> Bool {
        for varDict in blurVarialblesArr
        {
            let varName = [String](varDict.keys)[0]
            if whileStmt.textDescription.contains(varName)
            {
                let varDecl = varDict[varName]! as VariableDeclaration?
                let text = String(format:"CDASTAnalyzer Warning! You are adding UIEffectView defined in %@ in a while loop which could be repeated and hit performance \nLine: %i Column:%i Class: %@",varName, (varDecl?.sourceLocation.line)!, (varDecl?.sourceLocation.column)!, (selfClassStmt?.name)!)
                print(text)
                write(text: text, to: "BlurEffectDetectionResults")
            }
        }
        return true
    }
    func visit(_ repeatWhileStmt: RepeatWhileStatement) throws -> Bool {
        for varDict in blurVarialblesArr
        {
            let varName = [String](varDict.keys)[0]
            if repeatWhileStmt.textDescription.contains(varName)
            {
                let varDecl = varDict[varName]! as VariableDeclaration?
                let text = String(format:"CDASTAnalyzer Warning! You are adding UIEffectView defined in %@ in a repeat while loop which could be repeated and hit performance \nLine: %i Column:%i Class: %@",varName, (varDecl?.sourceLocation.line)!, (varDecl?.sourceLocation.column)!, (selfClassStmt?.name)!)
                print(text)
                write(text: text, to: "BlurEffectDetectionResults")
            }
        }
        return true
    }
    func visit(_ decl: VariableDeclaration) throws -> Bool {
        
        let str = decl.body.description
        if let index = str.index(of: ":") {
            let variableType = str[index..<str.endIndex]
            var variableName = ""
            if variableType.contains("UIVisualEffectView")
            {
                variableName = String(str[str.startIndex..<index])
                let dic = [variableName : decl]
                let filteredArray = blurVarialblesArr.filter { $0.keys.contains(variableName)}
                if filteredArray.count == 0
                {
                    blurVarialblesArr.append(dic)
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
        
        //check for blur effect

        selfClassStmt = classStmt
        if let clause = classStmt.typeInheritanceClause
        {
            if((clause.typeInheritanceList[0] as TypeIdentifier!)).names[0].name == "UICollectionViewCell" || ((clause.typeInheritanceList[0] as TypeIdentifier!)).names[0].name == "UITableViewCell"
            {
                isClassTypeCell = true
            }
            else
            {
                isClassTypeCell = false
            }
        }
        
        //check for SQLite
            return true
    }
    public func checkUIBlurEffectForCellClass()
    {
        let str = selfClassStmt?.textDescription
        let className = selfClassStmt?.name
        let matchesArr = regexMatches(for: "addSubview([(][a-zA-Z0-9_]*[)])", in: str!)
        for varDict in blurVarialblesArr
        {
            for match in matchesArr
            {
                let varName = [String](varDict.keys)[0]
                if match.trimmingCharacters(in: [" "]) == String(format:"addSubview(%@)", varName)
                {
                    let varDecl = varDict[varName] as! VariableDeclaration
                    let text = String(format:"CDASTAnalyzer Warning! You are adding UIEffectView defined in %@ in a cell which could be repeated and hit performance \nLine: %i Column:%i Class: %@",varName, varDecl.sourceLocation.line, varDecl.sourceLocation.column, className!)
                    print(text)
                    write(text: text, to: "BlurEffectDetectionResults")
                }
                
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




