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
        entity.name <-- "Bob"
        XCTAssertEqual(entity.name.value, "Bob")
        XCTAssertTrue(entity.name == "Bob")
        XCTAssertFalse(entity.name == "Bobb")
        XCTAssertTrue("Bob" == entity.name)
    }
    
    func testObservation() {
        let view = View()
        let entity = Entity()
        entity.name.addObserver(view)
        entity.name <-- "Alice"
        XCTAssertEqual(view.value, "Alice")
        
        var value:String = "test"
        entity.name --> { value = $0.value! }
        entity.name <-- "NEW VALUE"
        XCTAssertEqual(value, "NEW VALUE")
    }
    
    func testBinding() {
        let a = Entity()
        let b = Entity()
        
        a.name <-- "John"
        b.name <-- "John"
        XCTAssertTrue(a.name == b.name)
        
        b.name <-- "Bob"
        
        XCTAssertFalse(a.name == b.name)
        
        XCTAssertNotEqual(a.name.value, b.name.value)
        
        a.name <--> b.name
        
        XCTAssertEqual(a.name.value, "Bob")
        XCTAssertEqual(b.name.value, "Bob")
        
        a.name <-- "Martha"
        
        XCTAssertEqual(a.name.value, b.name.value)
        
        let c = Entity()
        let d = Entity()
        c.name <-- "Alice"
        d.name <-- "Joan"
        
        XCTAssertNotEqual(c.name.value, d.name.value)
        
        c.name <-- d.name
        XCTAssertEqual(c.name.value, d.name.value)
        
        c.name <-- "Kevin"
        XCTAssertNotEqual(c.name.value, d.name.value)
        
        // Setting c.name to a constant removes the observation
        d.name <-- "Rebecca"
        XCTAssertEqual(d.name.value, "Rebecca")
        XCTAssertNotEqual(c.name.value, d.name.value)
        
        c.name <-- d.name
        d.name <-- "Rebecca"
        XCTAssertEqual(c.name.value, d.name.value)
        
    }
    
    
}
