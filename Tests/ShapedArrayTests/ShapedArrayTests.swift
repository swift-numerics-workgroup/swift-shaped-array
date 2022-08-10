import XCTest
@testable import ShapedArray
import CoreML

final class ShapedArrayTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        print(ShapedArray(shape: [4], scalars: [1, 2, 3, 4]))
    }
    
    func testElementIndexing() {
        let array3D = ShapedArray<Float>(shape: [3, 4, 5], scalars: Array(stride(from: 0.0, to: 60, by: 1)))
        let array2D = array3D[2]
        let array1D = array3D[1][3]
        let array0D = array3D[2][0][3]

        /// Test shapes
        XCTAssertEqual(array2D.shape, [4, 5])
        XCTAssertEqual(array1D.shape, [5])
        XCTAssertEqual(array0D.shape, [])

        /// Test scalars
        XCTAssertEqual(array2D.scalars, Array(stride(from: 40.0, to: 60, by: 1)))
        XCTAssertEqual(array1D.scalars, Array(stride(from: 35.0, to: 40, by: 1)))
        XCTAssertEqual(array0D.scalars, [43])
    }
    
    func testElementIndexingAssignment() {
        var array3D = ShapedArray<Float>(shape: [3, 4, 5],
                                         scalars: Array(stride(from: 0.0, to: 60, by: 1)))
        array3D[2] = ShapedArraySlice(base: ShapedArray<Float>(shape: [4, 5],
                                        scalars: Array(stride(from: 20.0, to: 40, by: 1))))
        let array2D = array3D[2]
        let array1D = array3D[1][3]
        let array0D = array3D[2][0][3]

        /// Test shapes
        XCTAssertEqual(array2D.shape, [4, 5])
        XCTAssertEqual(array1D.shape, [5])
        XCTAssertEqual(array0D.shape, [])

        /// Test scalars
        XCTAssertEqual(array2D.scalars, Array(stride(from: 20.0, to: 40, by: 1)))
        XCTAssertEqual(array1D.scalars, Array(stride(from: 35.0, to: 40, by: 1)))
        XCTAssertEqual(array0D.scalars, [23])
    }

    func testSliceIndexing() {
        let array3D = ShapedArray<Float>(shape: [3, 4, 5],
                                         scalars: Array(stride(from: 0.0, to: 60, by: 1)))
        let slice3D = array3D[2...]
        let slice2D = array3D[1][0..<2]
        let slice1D = array3D[0][0][3..<5]

        /// Test shapes
        XCTAssertEqual(slice3D.shape, [1, 4, 5])
        XCTAssertEqual(slice2D.shape, [2, 5])
        XCTAssertEqual(slice1D.shape, [2])

        /// Test scalars
        XCTAssertEqual(slice3D.scalars, Array(stride(from: 40.0, to: 60, by: 1)))
        XCTAssertEqual(slice2D.scalars, Array(stride(from: 20.0, to: 30, by: 1)))
        XCTAssertEqual(slice1D.scalars, Array(stride(from: 3.0, to: 5, by: 1)))
    }
    
    func testPack() {
        let x: ShapedArray<Double> = ShapedArray(shape: [2, 3], scalars: Array(stride(from: 0.0, to: 6.0, by: 1.0)))
        let y: ShapedArray<Double> = ShapedArray(shape: [2, 3], scalars: Array(stride(from: 6.0, to: 12.0, by: 1.0)))
        let z: ShapedArray<Double> = ShapedArray(shape: [2, 3], scalars: Array(stride(from: 12.0, to: 18.0, by: 1.0)))
        
        let p1 = ShapedArray.pack([x,y,z], axis: 0)
        let p2 = ShapedArray.pack([x,y,z], axis: 1)
        let p3 = ShapedArray.pack([x,y,z], axis: 2)
        
        /// Test shapes
        XCTAssertEqual(p1.shape, [3, 2, 3])
        XCTAssertEqual(p2.shape, [2, 3, 3])
        XCTAssertEqual(p3.shape, [2, 3, 3])
        
        /// Test scalars
        XCTAssertEqual(p1.scalars, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0])
        XCTAssertEqual(p2.scalars, [0.0, 1.0, 2.0, 6.0, 7.0, 8.0, 12.0, 13.0, 14.0, 3.0, 4.0, 5.0, 9.0, 10.0, 11.0, 15.0, 16.0, 17.0])
        XCTAssertEqual(p3.scalars, [0.0, 6.0, 12.0, 1.0, 7.0, 13.0, 2.0, 8.0, 14.0, 3.0, 9.0, 15.0, 4.0, 10.0, 16.0, 5.0, 11.0, 17.0])
    }
    
    func testExpressibleByArrayLiteral() {
        let a: ShapedArray<Int> = [
            [[1, 2, 3], [4, 5, 6]],
            [[1, 2, 3], [4, 5, 6]],
            [[1, 2, 3], [4, 5, 6]]
        ]
        
        XCTAssertEqual(a.shape, [3, 2, 3])
    }
}
