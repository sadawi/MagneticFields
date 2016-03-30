//
//  TransformerTests.swift
//  MagneticFields
//
//  Created by Sam Williams on 2/16/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import MagneticFields

struct Price: Equatable, ValueTransformable {
    var value: Float
    
    static var valueTransformer: ValueTransformer<Price> {
        return ValueTransformer<Price>(
            importAction: { value in
                var importableValue: Float? = nil
                if let floatValue = value as? Float {
                    importableValue = floatValue
                } else if let intValue = value as? Int {
                    importableValue = Float(intValue)
                }
                
                if let importableValue = importableValue {
                    return Price(value: importableValue)
                } else {
                    return nil
                }
            },
            exportAction: { price in
                return price?.value
        })
    }
}
func ==(a:Price, b:Price) -> Bool {
    return a.value == b.value
}

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
        let floatField = Field<Float>(key: "number")
        
        let floatDict = ["number": 3.0]
        floatField.readFromDictionary(floatDict)
        XCTAssertEqual(3.0, floatField.value)
        
        let intDict = ["number": 2]
        floatField.readFromDictionary(intDict)
        XCTAssertEqual(2.0, floatField.value)
        
        let priceField = AutomaticField<Price>(key: "price")
        let transformer = priceField.defaultValueTransformer()
        let imported = transformer.importValue(0.2)
        XCTAssertEqual(imported, Price(value: 0.2))

        let priceDict = ["price": 10.0]
        priceField.readFromDictionary(priceDict)
        XCTAssertEqual(priceField.value?.value, 10.0)
    }
}
