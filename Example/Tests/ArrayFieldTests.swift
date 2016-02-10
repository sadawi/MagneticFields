//
//  ArrayFieldTests.swift
//  MagneticFields
//
//  Created by Sam Williams on 1/31/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import MagneticFields

private class Thing: Equatable {
    var name:String?
}
private func ==(left:Thing, right:Thing) -> Bool {
    return left.name == right.name
}

private class Pet {
    let name        = Field<String>()
    let commands    = *Field<String>()
    let things      = *Field<Thing>()
}

class ArrayFieldTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testArray() {
        let spot = Pet()
        spot.name.value = "Spot"
        spot.commands.value = ["fetch", "roll over"]
        
        XCTAssertEqual(spot.commands.value?.count, 2)
        
        let fido = Pet()
        fido.commands.value?.append("lie down")
        XCTAssertEqual(fido.commands.value?.count, 1)
    }

}
