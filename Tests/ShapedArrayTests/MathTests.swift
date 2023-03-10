import XCTest
@testable import ShapedArray

final class MathTests: XCTestCase {
    func testSumReduction() {
        // 1 x 5
        var array = ShapedArray<Float>([1, 2, 3, 4, 5])
        XCTAssertEqual(array.sum(), ShapedArray(15))
        XCTAssertEqual(array.sum(squeezingAxes: 0), ShapedArray(15))
        // 2 x 5
        array = ShapedArray<Float>([[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]])
        XCTAssertEqual(array.sum(), ShapedArray(30))
        XCTAssertEqual(array.sum(squeezingAxes: 0),
            ShapedArray(shape: [5], scalars: [2, 4, 6, 8, 10]))
        XCTAssertEqual(array.sum(squeezingAxes: 1),
            ShapedArray(shape: [2], scalars: [15, 15]))
        // 3 x 2 x 3
        array = ShapedArray<Float>(shape: [3, 2, 3], scalars: Array(stride(from: 0, to: 18, by: 1)))
        XCTAssertEqual(array.sum(), ShapedArray(153))
        XCTAssertEqual(array.sum(squeezingAxes: 0),
            ShapedArray(shape: [2, 3], scalars: [18, 21, 24, 27, 30, 33]))
        XCTAssertEqual(array.sum(squeezingAxes: 1),
            ShapedArray(shape: [3, 3], scalars: [3, 5, 7, 15, 17, 19, 27, 29, 31]))
        XCTAssertEqual(array.sum(squeezingAxes: 2),
            ShapedArray(shape: [3, 2], scalars: [3, 12, 21, 30, 39, 48]))
        XCTAssertEqual(array.sum(squeezingAxes: [0, 2]),
            ShapedArray(shape: [2], scalars: [63, 90.0]))
        XCTAssertEqual(array.sum(squeezingAxes: [1, 2]),
            ShapedArray(shape: [3], scalars: [15.0, 51.0, 87.0]))

        // 1 x 5 along axis
        array = ShapedArray<Float>([1, 2, 3, 4, 5])
        XCTAssertEqual(array.sum(alongAxes: 0), ShapedArray(shape:[1], scalars: [15]))
        // 2 x 5
        array = ShapedArray<Float>([[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]])
        XCTAssertEqual(array.sum(alongAxes: [0, 1]), ShapedArray([30]))
        XCTAssertEqual(array.sum(alongAxes: 0),
            ShapedArray(shape: [1, 5], scalars: [2, 4, 6, 8, 10]))
        XCTAssertEqual(array.sum(alongAxes: 1),
            ShapedArray(shape: [2, 1], scalars: [15, 15]))
        // 3 x 2 x 3
        array = ShapedArray<Float>(shape: [3, 2, 3], scalars: Array(stride(from: 0, to: 18, by: 1)))
        XCTAssertEqual(array.sum(alongAxes: [0, 1, 2]), ShapedArray([153]))
        XCTAssertEqual(array.sum(alongAxes: 0),
            ShapedArray(shape: [1, 2, 3], scalars: [18, 21, 24, 27, 30, 33]))
        XCTAssertEqual(array.sum(alongAxes: 1),
            ShapedArray(shape: [3, 1, 3], scalars: [3, 5, 7, 15, 17, 19, 27, 29, 31]))
        XCTAssertEqual(array.sum(alongAxes: 2),
            ShapedArray(shape: [3, 2, 1], scalars: [3, 12, 21, 30, 39, 48]))
        XCTAssertEqual(array.sum(alongAxes: [0, 2]),
            ShapedArray(shape: [1, 2, 1], scalars: [63, 90.0]))
        XCTAssertEqual(array.sum(alongAxes: [1, 2]),
            ShapedArray(shape: [3, 1, 1], scalars: [15.0, 51.0, 87.0]))
    }

    func testProductReduction() {
        // 1 x 5
        var floatArray = ShapedArray<Float>([1, 2, 3, 4, 5])
        XCTAssertEqual(floatArray.product(), ShapedArray(120))
        XCTAssertEqual(floatArray.product(squeezingAxes: 0), ShapedArray(120))
        // 2 x 5
        floatArray = ShapedArray<Float>([[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]])
        XCTAssertEqual(floatArray.product(), ShapedArray(14400))
        XCTAssertEqual(floatArray.product(squeezingAxes: 0),
            ShapedArray(shape: [5], scalars: [1, 4, 9, 16, 25]))
        XCTAssertEqual(floatArray.product(squeezingAxes: 1),
            ShapedArray(shape: [2], scalars: [120, 120]))
        // 3 x 2 x 3
        var doubleArray = ShapedArray<Double>(shape: [3, 2, 3], scalars: Array(stride(from: 1, to: 19, by: 1)))
        XCTAssertEqual(doubleArray.product(), ShapedArray(6402373705728000))
        XCTAssertEqual(doubleArray.product(squeezingAxes: 0),
            ShapedArray(shape: [2, 3], scalars: [91, 224, 405, 640, 935, 1296]))
        XCTAssertEqual(doubleArray.product(squeezingAxes: 1),
            ShapedArray(shape: [3, 3], scalars: [4, 10, 18, 70, 88, 108, 208, 238, 270]))
        XCTAssertEqual(doubleArray.product(squeezingAxes: 2),
            ShapedArray(shape: [3, 2], scalars: [6, 120, 504, 1320, 2730, 4896]))
        XCTAssertEqual(doubleArray.product(squeezingAxes: [0, 2]),
            ShapedArray(shape: [2], scalars: [8_255_520, 775_526_400]))
        XCTAssertEqual(doubleArray.product(squeezingAxes: [1, 2]),
            ShapedArray(shape: [3], scalars: [720.0, 665_280.0, 13_366_080.0]))

        // 1 x 5
        floatArray = ShapedArray<Float>([1, 2, 3, 4, 5])
        XCTAssertEqual(floatArray.product(alongAxes: 0), ShapedArray([120]))
        // 2 x 5
        floatArray = ShapedArray<Float>([[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]])
        XCTAssertEqual(floatArray.product(alongAxes: [0, 1]), ShapedArray([14400]))
        XCTAssertEqual(floatArray.product(alongAxes: 0),
            ShapedArray(shape: [1, 5], scalars: [1, 4, 9, 16, 25]))
        XCTAssertEqual(floatArray.product(alongAxes: 1),
            ShapedArray(shape: [2, 1], scalars: [120, 120]))
        // 3 x 2 x 3
        doubleArray = ShapedArray<Double>(shape: [3, 2, 3], scalars: Array(stride(from: 1, to: 19, by: 1)))
        XCTAssertEqual(doubleArray.product(alongAxes: [0, 1, 2]), ShapedArray([6402373705728000]))
        XCTAssertEqual(doubleArray.product(alongAxes: 0),
            ShapedArray(shape: [1, 2, 3], scalars: [91, 224, 405, 640, 935, 1296]))
        XCTAssertEqual(doubleArray.product(alongAxes: 1),
            ShapedArray(shape: [3, 1, 3], scalars: [4, 10, 18, 70, 88, 108, 208, 238, 270]))
        XCTAssertEqual(doubleArray.product(alongAxes: 2),
            ShapedArray(shape: [3, 2, 1], scalars: [6, 120, 504, 1320, 2730, 4896]))
        XCTAssertEqual(doubleArray.product(alongAxes: [0, 2]),
            ShapedArray(shape: [1, 2, 1], scalars: [8_255_520, 775_526_400]))
        XCTAssertEqual(doubleArray.product(alongAxes: [1, 2]),
            ShapedArray(shape: [3, 1, 1], scalars: [720.0, 665_280.0, 13_366_080.0]))
    }

    func testMeanReduction() {
        // 1 x 5
        var array = ShapedArray<Float>([1, 2, 3, 4, 5])
        XCTAssertEqual(array.mean(), ShapedArray(3))
        XCTAssertEqual(array.mean(squeezingAxes: 0), ShapedArray(3))
        // 2 x 5
        array = ShapedArray<Float>([[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]])
        XCTAssertEqual(array.mean(), ShapedArray(3))
        XCTAssertEqual(array.mean(squeezingAxes: 0),
            ShapedArray(shape: [5], scalars: [1, 2, 3, 4, 5]))
        XCTAssertEqual(array.mean(squeezingAxes: 1),
            ShapedArray(shape: [2], scalars: [3, 3]))
        // 3 x 2 x 3
        array = ShapedArray<Float>(shape: [3, 2, 3], scalars: Array(stride(from: 0, to: 18, by: 1)))
        XCTAssertEqual(array.mean(), ShapedArray(8.5))
        XCTAssertEqual(array.mean(squeezingAxes: 0),
            ShapedArray(shape: [2, 3], scalars: [6.0,  7.0,  8.0, 9.0, 10.0, 11.0]))
        XCTAssertEqual(array.mean(squeezingAxes: 1),
            ShapedArray(shape: [3, 3], scalars: [1.5,  2.5,  3.5, 7.5,  8.5,  9.5, 13.5, 14.5, 15.5]))
        XCTAssertEqual(array.mean(squeezingAxes: 2),
            ShapedArray(shape: [3, 2], scalars: [1.0,  4.0, 7.0, 10.0, 13.0, 16.0]))
        XCTAssertEqual(array.mean(squeezingAxes: [0, 2]),
            ShapedArray(shape: [2], scalars: [7, 10]))
        XCTAssertEqual(array.mean(squeezingAxes: [1, 2]),
            ShapedArray(shape: [3], scalars: [2.5,  8.5, 14.5]))

        // 1 x 5
        array = ShapedArray<Float>([1, 2, 3, 4, 5])
        XCTAssertEqual(array.mean(alongAxes: [0]), ShapedArray([3]))
        // 2 x 5
        array = ShapedArray<Float>([[1, 2, 3, 4, 5], [1, 2, 3, 4, 5]])
        XCTAssertEqual(array.mean(alongAxes: [0, 1]), ShapedArray([3]))
        XCTAssertEqual(array.mean(alongAxes: 0),
            ShapedArray(shape: [1, 5], scalars: [1, 2, 3, 4, 5]))
        XCTAssertEqual(array.mean(alongAxes: 1),
            ShapedArray(shape: [2, 1], scalars: [3, 3]))
        // 3 x 2 x 3
        array = ShapedArray<Float>(shape: [3, 2, 3], scalars: Array(stride(from: 0, to: 18, by: 1)))
        XCTAssertEqual(array.mean(alongAxes: [0, 1, 2]), ShapedArray([8.5]))
        XCTAssertEqual(array.mean(alongAxes: 0),
            ShapedArray(shape: [1, 2, 3], scalars: [6.0,  7.0,  8.0, 9.0, 10.0, 11.0]))
        XCTAssertEqual(array.mean(alongAxes: 1),
            ShapedArray(shape: [3, 1, 3], scalars: [1.5,  2.5,  3.5, 7.5,  8.5,  9.5, 13.5, 14.5, 15.5]))
        XCTAssertEqual(array.mean(alongAxes: 2),
            ShapedArray(shape: [3, 2, 1], scalars: [1.0,  4.0, 7.0, 10.0, 13.0, 16.0]))
        XCTAssertEqual(array.mean(alongAxes: [0, 2]),
            ShapedArray(shape: [1, 2, 1], scalars: [7, 10]))
        XCTAssertEqual(array.mean(alongAxes: [1, 2]),
            ShapedArray(shape: [3, 1, 1], scalars: [2.5,  8.5, 14.5]))
    }
}
