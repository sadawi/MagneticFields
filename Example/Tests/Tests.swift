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

enum Color: String {
    case Red = "red"
    case Blue = "blue"
}

private class Entity {
    let name = Field<String>()
    let size = Field<Int>()
    
    let color = EnumField<Color>()
}

class Person: Observable {
    typealias ValueType = String
    
    var value: String? {
        didSet {
            self.notifyObservers()
        }
    }
    var observations = ObservationRegistry<String>()
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
    
    func testNothing() {
        XCTAssert(true)
    }
    
    func testEnums() {
        let entity = Entity()
        entity.color.value = .Blue

        var dict:[String:AnyObject] = [:]
        
        entity.color.writeToDictionary(&dict, name: "color")
        XCTAssertEqual(dict["color"] as? String, "blue")
        
        dict["color"] = "blue"
        entity.color.readFromDictionary(dict, name: "color")
        XCTAssertEqual(entity.color.value, Color.Blue)

        dict["color"] = "yellow"
        entity.color.readFromDictionary(dict, name: "color")
        XCTAssertNil(entity.color.value)
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
    
    
    class ValidatedPerson {
        let age             = Field<Int>().require { $0 > 0 }
        let evenNumber      = Field<Int>().require(message: "must be even") { $0 % 2 == 0 }
        let name            = Field<String>()
        
        let requiredField   = Field<String>().requireNotNil()
        let longString      = Field<String>().require(LengthRule(minimum:10))
    }
    
    func testValidators() {
        let person = ValidatedPerson()
        
        person.age.value = -10
        
        XCTAssert(person.age.valid == false)
        
        person.age.value = 10
        XCTAssert(person.age.valid == true)
        
        person.evenNumber.value = 3
        XCTAssertFalse(person.evenNumber.valid)
        XCTAssertEqual(ValidationState.Invalid(["must be even"]), person.evenNumber.validate())
        
        XCTAssertFalse(person.requiredField.valid)
        person.requiredField.value = "hello"
        XCTAssertTrue(person.requiredField.valid)
        
        person.longString.value = "123456789"
        XCTAssertFalse(person.longString.valid)
        person.longString.value = "123456789A"
        XCTAssertTrue(person.longString.valid)
    }
    
    func testMoreValidators() {
        let notBlankString = Field<String>().require(NotBlankRule())
        notBlankString.value = ""
        XCTAssertFalse(notBlankString.valid)
        notBlankString.value = "hi"
        XCTAssertTrue(notBlankString.valid)
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
    
    func testExport() {
        let a = Entity()
        a.name.value = "Bob"

        var dict:[String:AnyObject] = [:]
        a.name.writeToDictionary(&dict, name: "name")
        
        XCTAssertEqual(dict["name"] as? String, "Bob")
        
        dict["size"] = 100
        a.size.readFromDictionary(dict, name: "size")
        XCTAssertEqual(a.size.value, 100)
    }
    
    func testCustomTransformers() {
        let a = Entity()
        a.size.value = 100
        
        a.size.transform(
            importValue: { $0 as? Int },
            exportValue: { $0 == nil ? nil : String($0) },
            name: "stringify"
        )
        var dict:[String:AnyObject] = [:]
        
        a.size.writeToDictionary(&dict, name: "size")
        XCTAssertNil(dict["size"] as? String)

        /** 
        
        //        a.size.writeToDictionary(&dict, name: "size", valueTransformer: "stringify")
        //        XCTAssertEqual(dict["size"] as? String, "100")
        
        Just upgraded XCode to 7.2, now this dies with:
        
        Invalid bitcast
        %.asUnsubstituted = bitcast i64 %90 to i8*, !dbg !668
        LLVM ERROR: Broken function found, compilation aborted!

        Hmm...
        
        */
    }
    
    func testAnyObjectValue() {
        let a = Entity()
        a.name.value = "Bob"
        XCTAssertEqual(a.name.anyObjectValue as? String, "Bob")
        
        a.name.anyObjectValue = "Jane"
        XCTAssertEqual(a.name.anyObjectValue as? String, "Jane")
        
        // Trying to set invalid type has no effect (and does not raise error)
        a.name.anyObjectValue = 5
        XCTAssertEqual(a.name.value, "Jane")
        
        // But setting nil does work
        a.name.anyObjectValue = nil
        XCTAssertNil(a.name.value)
        
    }
}


class Label: Equatable {
    var name: String = "table"
    init(name: String) { self.name = name }
}
func ==(left:Label, right:Label) -> Bool { return left.name == right.name }

class ValueObject {
    let color = Field<String>(value: "red")
    let label = Field<Label>(value: Label(name: "shelf"))
}


class ValueFieldTests: XCTestCase {
    func testInitialValues() {
        let object = ValueObject()
        XCTAssertEqual("red", object.color.value)
        XCTAssertEqual("shelf", object.label.value?.name)
        XCTAssertEqual(LoadState.Set, object.color.state)
        
        let object2 = ValueObject()
        XCTAssertEqual("shelf", object2.label.value?.name)
        object2.label.value = Label(name: "table")
        XCTAssertEqual("shelf", object.label.value?.name)
        XCTAssertEqual("table", object2.label.value?.name)
        
    }
    
//    func testChainingClosure() {
//        let a = Entity()
//        
//        let observation = ( a.name --> { $0?.uppercaseString } )
//        a.name.value = "alice"
//        XCTAssertEqual("ALICE", observation.value)
//        
////        let b = Entity()
////        a.name --> { $0?.uppercaseString } --> b.name
////        a.name.value = "alice"
////        XCTAssertEqual(b.name.value, "ALICE")
//    }
}
