//
//  CDSwiftAST.swift
//  CDSwiftASTAnalyzer
//
//  Created by Sara on 11/9/17.
//

import Foundation
import AST
import Parser
import Source

var blurVisitor : BlurEffectVisitor = BlurEffectVisitor()
var mMTVisitor :MMTVisitor = MMTVisitor()
var dBTVisitor :DBTVisitor = DBTVisitor()
var transparencyVisitor :TransparencyVisitor = TransparencyVisitor()

func analyzeSourceFileForBlurEffect(asPath path:String) {
    do {
        let sourceFile = try SourceReader.read(at: path)
        let parser = Parser(source: sourceFile)
        let topLevelDecl = try parser.parse()
        
        blurVisitor = BlurEffectVisitor()
        try blurVisitor.traverse(topLevelDecl)
        if(blurVisitor.isClassTypeCell)
        {
            try blurVisitor.checkUIBlurEffectForCellClass()
        }
        else
        {
            
        }
        
    } catch let error{
        print("exception processing blur file  \(error.localizedDescription)")
    }
}
func analyzeSourceFileForMMT(asPath path:String) {
    do {
        let sourceFile = try SourceReader.read(at: path)
        let parser = Parser(source: sourceFile)
        let topLevelDecl = try parser.parse()
        
        mMTVisitor = MMTVisitor()
        try mMTVisitor.traverse(topLevelDecl)
        
    } catch {
        print("exception processing MMT file :/")
    }
}
func analyzeSourceFileForDBT(asPath path:String) {
    do {
        let sourceFile = try SourceReader.read(at: path)
        let parser = Parser(source: sourceFile)
        let topLevelDecl = try parser.parse()
        
        dBTVisitor = DBTVisitor()
        try dBTVisitor.traverse(topLevelDecl)
        
    } catch let error{
        print("exception processing DBT file  \(error.localizedDescription)")
    }
}

func analyzeSourceFileForOpacity(asPath path:String) {
    do {
        let sourceFile = try SourceReader.read(at: path)
        let parser = Parser(source: sourceFile)
        let topLevelDecl = try parser.parse()
        
        //        for stmt in topLevelDecl.statements {
        //            // consume statement
        //        }
        transparencyVisitor = TransparencyVisitor()
        try transparencyVisitor.traverse(topLevelDecl)
        if(transparencyVisitor.isClassTypeCell)
        {
            try transparencyVisitor.checkOpacityForCellClass()
        }
        
    } catch let error{
        print("exception processing blur file  \(error.localizedDescription)")
    }
}
func analyzeXMLFileForOpacity(asPath path:String) {
}

func findMMTAntiPattern ()
{
    try mMTVisitor.checkIfUIMainScreenFunctionIsCalledInBGThread()
}
func findDBTAntiPattern ()
{
    try dBTVisitor.checkIfCoreDataFunctionIsCalledInBGThread()
}
func findXMLOpacityAntiPattern (_ content:String)
{
    let lines = content.components(separatedBy: .newlines)
    for line in lines
    {
        let methodReg = "alpha\\=.*\\ "
        let matchesArr = regexMatches(for: methodReg, in: line)
        if matchesArr.count > 0
        {
            for match in matchesArr
            {
                if !match.contains("alpha=\"1\"")
                {
                    
                }
                
            }
        }
    }
}
