//
//  MathTests.swift
//  
//
//  Created by Khalid Alotaibi on 11/25/22.
//

import XCTest
@testable import ShapedArray

final class MathTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        print(ShapedArray(shape: [4], scalars: [1, 2, 3, 4]))
    }
 
    func testMath() {
        let a: ShapedArray<Float> = [1, 4, 9]
        //let b: ShapedArray<Float> = [1.57, 3.14, 4.71, 6.28]

        XCTAssert(ShapedArray.sqrt(a) == [1, 2, 3], "It failed")
       //XCTAssert(ShapedArray.cos(b) == [0.0, -1.0, 0.0, 1.0], "\(ShapedArray.cos(b))")
    }
}