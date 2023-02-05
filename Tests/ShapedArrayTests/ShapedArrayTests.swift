import XCTest
@testable import ShapedArray

final class ShapedArrayTests: XCTestCase {
    func testElementIndexing() {
        let array3D = ShapedArray<Float>(shape: [3, 4, 5], scalars: Array(stride(from: 0, to: 60, by: 1)))
        let array2D = array3D[2]
        let array1D = array3D[1][3]
        let array0D = array3D[2][0][3]

        /// Test shapes
        XCTAssertEqual(array2D.shape, [4, 5])
        XCTAssertEqual(array1D.shape, [5])
        XCTAssertEqual(array0D.shape, [])

        /// Test scalars
        XCTAssertEqual(array2D.scalars, Array(stride(from: 40, to: 60, by: 1)))
        XCTAssertEqual(array1D.scalars, Array(stride(from: 35, to: 40, by: 1)))
        XCTAssertEqual(array0D.scalars, [43])
    }
    
    func testElementIndexingAssignment() {
        var array3D = ShapedArray<Float>(shape: [3, 4, 5],
                                         scalars: Array(stride(from: 0, to: 60, by: 1)))
        array3D[2] = ShapedArraySlice(base: ShapedArray<Float>(shape: [4, 5],
                                        scalars: Array(stride(from: 20, to: 40, by: 1))))
        let array2D = array3D[2]
        let array1D = array3D[1][3]
        let array0D = array3D[2][0][3]

        /// Test shapes
        XCTAssertEqual(array2D.shape, [4, 5])
        XCTAssertEqual(array1D.shape, [5])
        XCTAssertEqual(array0D.shape, [])

        /// Test scalars
        XCTAssertEqual(array2D.scalars, Array(stride(from: 20, to: 40, by: 1)))
        XCTAssertEqual(array1D.scalars, Array(stride(from: 35, to: 40, by: 1)))
        XCTAssertEqual(array0D.scalars, [23])
    }

    func testSliceIndexing() {
        let array3D = ShapedArray<Float>(shape: [3, 4, 5],
                                         scalars: Array(stride(from: 0, to: 60, by: 1)))
        let slice3D = array3D[2...]
        let slice2D = array3D[1][0..<2]
        let slice1D = array3D[0][0][3..<5]

        /// Test shapes
        XCTAssertEqual(slice3D.shape, [1, 4, 5])
        XCTAssertEqual(slice2D.shape, [2, 5])
        XCTAssertEqual(slice1D.shape, [2])

        /// Test scalars
        XCTAssertEqual(slice3D.scalars, Array(stride(from: 40, to: 60, by: 1)))
        XCTAssertEqual(slice2D.scalars, Array(stride(from: 20, to: 30, by: 1)))
        XCTAssertEqual(slice1D.scalars, Array(stride(from: 3, to: 5, by: 1)))
    }
    
    func testStacking() {
        let x: ShapedArray<Double> = ShapedArray(shape: [2, 3], scalars: Array(stride(from: 0, to: 6, by: 1)))
        let y: ShapedArray<Double> = ShapedArray(shape: [2, 3], scalars: Array(stride(from: 6, to: 12, by: 1)))
        let z: ShapedArray<Double> = ShapedArray(shape: [2, 3], scalars: Array(stride(from: 12, to: 18, by: 1)))

        let p1 = ShapedArray(stacking: [x, y, z], alongAxis: 0)
        let p2 = ShapedArray(stacking: [x, y, z], alongAxis: 1)
        let p3 = ShapedArray(stacking: [x, y, z], alongAxis: 2)

        /// Test shapes
        XCTAssertEqual(p1.shape, [3, 2, 3])
        XCTAssertEqual(p2.shape, [2, 3, 3])
        XCTAssertEqual(p3.shape, [2, 3, 3])

        /// Test scalars
        XCTAssertEqual(p1.scalars, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17])
        XCTAssertEqual(p2.scalars, [0, 1, 2, 6, 7, 8, 12, 13, 14, 3, 4, 5, 9, 10, 11, 15, 16, 17])
        XCTAssertEqual(p3.scalars, [0, 6, 12, 1, 7, 13, 2, 8, 14, 3, 9, 15, 4, 10, 16, 5, 11, 17])
    }

    func testUnstacking() {
        let array: ShapedArray<Double> = ShapedArray(shape: [3, 2, 3], scalars: Array(stride(from: 0, to: 18, by: 1)))

        let p1 = array.unstacked(alongAxis: 0)
        let p2 = array.unstacked(alongAxis: 1)
        let p3 = array.unstacked(alongAxis: 2)

        /// Test shapes
        XCTAssertEqual(p1.count, 3)
        XCTAssertEqual(p2.count, 2)
        XCTAssertEqual(p1.count, 3)
        p1.forEach { XCTAssertEqual($0.shape, [2, 3]) }
        p2.forEach { XCTAssertEqual($0.shape, [3, 3]) }
        p3.forEach { XCTAssertEqual($0.shape, [3, 2]) }

        /// Test scalars
        XCTAssertEqual(
            p1.map { $0.scalars }.flatMap { $0 },
            [0.0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17])
        XCTAssertEqual(
            p2.map { $0.scalars }.flatMap { $0 },
            [0.0, 1, 2, 6, 7, 8, 12, 13, 14, 3, 4, 5, 9, 10, 11, 15, 16, 17])
        XCTAssertEqual(
            p3.map { $0.scalars }.flatMap { $0 },
            [0.0, 3, 6, 9, 12, 15, 1, 4, 7, 10, 13, 16, 2, 5, 8, 11, 14, 17])
    }

    func testStackingUnstacking() {
        let x: ShapedArray<Double> = ShapedArray(shape: [2, 3], scalars: Array(stride(from: 0, to: 6, by: 1)))
        let y: ShapedArray<Double> = ShapedArray(shape: [2, 3], scalars: Array(stride(from: 6, to: 12, by: 1)))
        let z: ShapedArray<Double> = ShapedArray(shape: [2, 3], scalars: Array(stride(from: 12, to: 18, by: 1)))

        let p1 = ShapedArray(stacking: [x, y, z], alongAxis: 0)
        let p2 = ShapedArray(stacking: [x, y, z], alongAxis: 1)
        let p3 = ShapedArray(stacking: [x, y, z], alongAxis: 2)

        XCTAssertEqual(
            p1.unstacked(alongAxis: 0).map { $0.scalars },
            [x.scalars, y.scalars, z.scalars])
        XCTAssertEqual(
            p2.unstacked(alongAxis: 1).map { $0.scalars },
            [x.scalars, y.scalars, z.scalars])
        XCTAssertEqual(
            p3.unstacked(alongAxis: 2).map { $0.scalars },
            [x.scalars, y.scalars, z.scalars])
    }
    
    func testExpressibleByArrayLiteral() {
        let a: ShapedArray<Int> = [
            [[1, 2, 3], [4, 5, 6]],
            [[1, 2, 3], [4, 5, 6]],
            [[1, 2, 3], [4, 5, 6]]
        ]
        
        XCTAssertEqual(a.shape, [3, 2, 3])
    }

    func testReshaped() {
        let a: ShapedArray<Int> = [
            [[1, 2, 3], [4, 5, 6]],
            [[1, 2, 3], [4, 5, 6]],
            [[1, 2, 3], [4, 5, 6]]
        ]
        
        let b = a.reshaped(to: [3, 6])
        XCTAssertEqual(b.scalarCount, a.scalarCount)
        XCTAssertEqual(b.shape, [3, 6])

        let c = b.reshaped(to: 18)
        XCTAssertEqual(c.scalarCount, a.scalarCount)
        XCTAssertEqual(c.shape, [18])
        
        let d = c.reshaped(like: b)
        XCTAssertEqual(d.scalarCount, a.scalarCount)
        XCTAssertEqual(d.shape, [3, 6])
        
        let e = a.reshaped(to: -1)
        XCTAssertEqual(e.shape, [18])
        
        let f = a.reshaped(to: [3, -1, 3])
        XCTAssertEqual(f.shape, [3, 2, 3])
        
        let g = a.reshaped(to: [3, 3, -1])
        XCTAssertEqual(g.shape, [3, 3, 2])
    }
    
    func testFlattened() {
        let a: ShapedArray<Int> = [
            [[1, 2, 3], [4, 5, 6]],
            [[1, 2, 3], [4, 5, 6]],
            [[1, 2, 3], [4, 5, 6]]
        ]
        
        let b = a.flattened()
        
        XCTAssertEqual(b, [1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6])
        XCTAssertEqual(b.shape, [18])
    }
}
