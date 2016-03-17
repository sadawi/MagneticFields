//
//  TransformerTests.swift
//  MagneticFields
//
//  Created by Sam Williams on 2/16/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import MagneticFields

class TransformerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDateTransformer() {
        let transformer = DateTransformer(dateFormat: "yyyy-MM-dd")
        let date = NSDate(timeIntervalSince1970: 0)
        let string = transformer.exportValue(date) as? String
        XCTAssertEqual("1969-12-31", string)
        
        let string2 = "2015-03-03"
        let date2 = transformer.importValue(string2)
        XCTAssertNotNil(date2)
    }
    
    func testDefaultTransformers() {
        let floatField = Field<Float>()
        
        let floatDict = ["number": 3.0]
        floatField.readFromDictionary(floatDict, name: "number")
        XCTAssertEqual(3.0, floatField.value)
        
        let intDict = ["number": 2]
        floatField.readFromDictionary(intDict, name: "number")
        XCTAssertEqual(2.0, floatField.value)
        
    }
}
