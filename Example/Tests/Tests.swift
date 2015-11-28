//
//  FieldTests.swift
//  APIKit
//
//  Created by Sam Williams on 11/25/15.
//  Copyright © 2015 Sam Williams. All rights reserved.
//


import UIKit
import XCTest
import MagneticFields

class Entity {
    let name = Field<String>()
}

class View:FieldObserver {
    var value:String?
    
    func fieldValueChanged(field: FieldType) {
        if let field = field as? Field<String> {
            self.value = field.value
        }
    }
}

class FieldTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStates() {
        let entity = Entity()
        XCTAssert(entity.name.state == .NotLoaded)
    }
    
    func testOperators() {
        let entity = Entity()
        entity.name.value = "Bob"
        XCTAssertEqual(entity.name.value, "Bob")
        XCTAssertTrue(entity.name == "Bob")
        XCTAssertFalse(entity.name == "Bobb")
        XCTAssertTrue("Bob" == entity.name)
    }
    
    func testObservation() {
        let view = View()
        let entity = Entity()
        entity.name.addObserver(view)
        entity.name.value = "Alice"
        XCTAssertEqual(view.value, "Alice")
        
        var value:String = "test"
        entity.name --> { value = $0.value! }
        entity.name.value = "NEW VALUE"
        XCTAssertEqual(value, "NEW VALUE")
    }
    
    func testBinding() {
        let a = Entity()
        let b = Entity()
        
        a.name.value = "John"
        b.name.value = "John"
        XCTAssertTrue(a.name == b.name)
        
        b.name.value = "Bob"
        
        XCTAssertFalse(a.name == b.name)
        
        XCTAssertNotEqual(a.name.value, b.name.value)
        
        a.name <--> b.name
        
        XCTAssertEqual(a.name.value, "Bob")
        XCTAssertEqual(b.name.value, "Bob")
        
        a.name.value = "Martha"
        
        XCTAssertEqual(a.name.value, b.name.value)
        
        let c = Entity()
        let d = Entity()
        c.name.value = "Alice"
        d.name.value = "Joan"
        
        XCTAssertNotEqual(c.name.value, d.name.value)
        
        c.name <-- d.name
        XCTAssertEqual(c.name.value, d.name.value)
        
        c.name.value = "Kevin"
        XCTAssertNotEqual(c.name.value, d.name.value)
        
        d.name.value = "Rebecca"
        XCTAssertEqual(d.name.value, "Rebecca")
        
        c.name <-- d.name
        d.name.value = "Rebecca"
        XCTAssertEqual(c.name.value, d.name.value)
        
    }
    
//    class TestModel: FieldModel {
//        let name = Field<String>()
//        let age = Field<Int>()
//    }
//    
//    func testFieldModel() {
//        let model = TestModel()
//        model.name.value = "John"
//        
//        let fields = model.fields()
//        print(fields)
//        
////        let dictionaryValue = model.dictionaryValue
////        XCTAssertEqual(dictionaryValue["name"] as? String, "John")
//    }
    
    
    class ValidatedPerson {
        let age = Field<Int>().require(message: "Age must be greater than zero") { $0 > 0 }
        let name = Field<String>()
    }
    
    func testValidators() {
        let person = ValidatedPerson()
        
        person.age.value = -10
        
        XCTAssert(person.age.valid == false)
        
        person.age.value = 10
        XCTAssert(person.age.valid == true)
    }
}
