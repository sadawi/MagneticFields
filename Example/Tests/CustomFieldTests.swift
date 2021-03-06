//
//  CustomFieldTests.swift
//  MagneticFields
//
//  Created by Sam Williams on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import MagneticFields

let kSeen = "seen"

private class TestField<T: Equatable>: Field<T> {
    override init(value:T?=nil, name:String?=nil, priority:Int=0, key:String?=nil) {
        super.init(value: value, name: name, priority: priority, key: key)
    }
    
    private override func writeSeenValueToDictionary(inout dictionary: [String : AnyObject], inout seenFields: [FieldType], key: String) {
        dictionary[key] = kSeen
    }
}

private class Thing {
    let name = TestField<String>(key: "name")
}

class CustomFieldTests: XCTestCase {
    func testSeen() {
        var seenFields: [FieldType] = []
        
        let thing = Thing()
        thing.name.value = "Thing 1"
        
        var dictionary:[String: AnyObject] = [:]
        thing.name.writeToDictionary(&dictionary, seenFields: &seenFields)
        
        XCTAssertEqual(dictionary["name"] as? String, "Thing 1")
        thing.name.writeToDictionary(&dictionary, seenFields: &seenFields)

        XCTAssertEqual(dictionary["name"] as? String, kSeen)

        thing.name.writeToDictionary(&dictionary)
        XCTAssertEqual(dictionary["name"] as? String, "Thing 1")
    }
}
