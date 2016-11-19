//
//  ObservationTests.swift
//  MagneticFields
//
//  Created by Sam Williams on 2/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import MagneticFields

private class Entity {
    let name = Field<String>()
    let size = Field<Int>()
}

private class View:Observer, Observable {
    var value:String? {
        didSet {
            self.notifyObservers()
        }
    }
    
    // Observer
    func valueChanged<ObservableType:Observable>(_ value:String?, observable: ObservableType?) {
        self.value = value
    }
    
    // Observable
    typealias ValueType = String
    var observations = ObservationRegistry<ValueType>()
}

class ObservationTests: XCTestCase {

    func testObservation() {
        let view = View()
        let entity = Entity()
        entity.name --> view
        entity.name.value = "Alice"
        XCTAssertEqual(view.value, "Alice")
        
        var value:String = "test"
        entity.name --> { value = $0! }
        entity.name.value = "NEW VALUE"
        XCTAssertEqual(value, "NEW VALUE")
        
        // Setting a new pure closure observer will remove the old one
        var value2:String = "another value"
        entity.name --> { value2 = $0! }
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
    
    func testHeterogeneousBinding() {
        let a = Entity()
        let v = View()
        
        a.name.value = "Title"
        v <--> a.name
        XCTAssertEqual(v.value, "Title")
        a.name.value = "New Title"
        XCTAssertEqual(v.value, "New Title")
        v.value = "New New Title"
        XCTAssertEqual("New New Title", a.name.value)
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
    
    func testObservable() {
        let object = Person()
        let field = Field<String>()
        let secondField = Field<String>()
        
        object.value = "Bob"
        XCTAssertNotEqual(object.value, field.value)
        
        object --> field
        object --> secondField
        
        object.value = "Alice"
        XCTAssertEqual(object.value, field.value)
        XCTAssertEqual(object.value, secondField.value)
        
        object -/-> field
        object.value = "Phil"
        XCTAssertNotEqual(object.value, field.value)
        XCTAssertEqual(object.value, secondField.value)
    }
    
    func testChaining() {
        let a = Entity()
        let b = Entity()
        
        let observation = (a.name --> b.name)
        a.name.value = "Wayne"
        
        XCTAssertEqual(a.name.value, b.name.value)
        XCTAssertEqual(a.name.value, observation.value)
        
        let c = Entity()
        observation --> c.name
        
        XCTAssertEqual(a.name.value, c.name.value)
        
        a.name.value = "John"
        XCTAssertEqual("John", c.name.value)
    }
    
    func testChainingInline() {
        let a = Entity()
        let b = Entity()
        let c = Entity()
        let d = Entity()
        
        ((a.name --> b.name) --> c.name) --> d.name
        a.name.value = "John"
        
        XCTAssertEqual(a.name.value, b.name.value)
        XCTAssertEqual(a.name.value, c.name.value)
        XCTAssertEqual(a.name.value, d.name.value)
    }
    
    func testChainingClosureWithSideEffect() {
        let a = Entity()
        let b = Entity()
        
        var output:String? = nil
        
        (a.name --> b.name) --> { value in
            output = value
        }
        
        a.name.value = "Joe"
        XCTAssertEqual("Joe", output)
    }


}
