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
    
    func fieldValueChanged(value:Any?, field: FieldType?) {
        if let value = value as? String {
            self.value = value
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
        XCTAssertEqual(entity.name.state, LoadState.NotSet)
        
        entity.name.value = "Bob"
        XCTAssertEqual(entity.name.state, LoadState.Set)
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
        entity.name --> view
        entity.name.value = "Alice"
        XCTAssertEqual(view.value, "Alice")
        
        var value:String = "test"
        entity.name --> { value = $0.value! }
        entity.name.value = "NEW VALUE"
        XCTAssertEqual(value, "NEW VALUE")
        
        // Setting a new pure closure observer will remove the old one
        var value2:String = "another value"
        entity.name --> { value2 = $0.value! }
        entity.name.value = "VALUE 2"
        XCTAssertEqual(value2, "VALUE 2")
        XCTAssertEqual(value, "NEW VALUE")
        
        // But the registered observers are still active
        XCTAssertEqual(view.value, "VALUE 2")
        
        // ...until the observers are explicitly unregistered
        entity.name -/-> view
        entity.name.value = "VALUE 3"
        XCTAssertEqual(view.value, "VALUE 2")
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
    
    class ValidatedPerson {
        let age = Field<Int>().require { $0 > 0 }
        let name = Field<String>()
    }
    
    func testValidators() {
        let person = ValidatedPerson()
        
        person.age.value = -10
        
        XCTAssert(person.age.valid == false)
        
        person.age.value = 10
        XCTAssert(person.age.valid == true)
    }
    
    func testTimestamps() {
        let a = Entity()
        let b = Entity()
        
        a.name.value = "John"
        b.name.value = "Bob"
        
        XCTAssertGreaterThan(b.name.updatedAt!.timeIntervalSince1970, a.name.updatedAt!.timeIntervalSince1970)
        XCTAssertGreaterThan(b.name.changedAt!.timeIntervalSince1970, a.name.changedAt!.timeIntervalSince1970)
        
        a.name.value = "John"
        
        XCTAssertGreaterThan(a.name.updatedAt!.timeIntervalSince1970, b.name.updatedAt!.timeIntervalSince1970)

        XCTAssertGreaterThan(b.name.changedAt!.timeIntervalSince1970, a.name.changedAt!.timeIntervalSince1970)
    }
    
//    func testChaining() {
//        let a = Entity()
//        let b = Entity()
//        
//        a.name.value = "Alice"
//        b.name.value = "Betty"
//        
//        a.name --> { $0.value?.uppercaseString } --> b.name
//        
//        XCTAssertEqual(b.name.value, "ALICE")
//        
//        a.name.value = "Arnold"
//        XCTAssertEqual(b.name.value, "ARNOLD")
//    }
}
