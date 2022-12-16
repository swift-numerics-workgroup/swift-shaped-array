// Copyright 2021 The TensorFlow Authors. All Rights Reserved.
// Modified 2022 The Swift Numerics Workgroup.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


/// `ShapedArray` is a multi-dimensional array. It has a shape, which has type `[Int]` and defines
/// the array dimensions, and uses a `ShapedArrayBuffer` internally as storage.
@frozen
public struct ShapedArray<Scalar>: _ShapedArrayProtocol {
    /// Contiguous memory storing scalars.
    internal var buffer: [Scalar]
    
    /// The dimensions of the array.
    @noDerivative public private(set) var shape: [Int]
        
    /// Creates a `ShapedArray` from a `ShapedArrayBuffer` and a shape.
    internal init(buffer: __owned [Scalar], shape: __owned [Int]) {
        precondition(
            buffer.count == shape.reduce(1, *),
            "The scalar count of the buffer does not match the shape.")
        self.buffer = buffer
        self.shape = shape
    }
}

extension ShapedArray {
    /// The number of dimensions of the array.
    public var rank: Int {
        return shape.count
    }
    
    /// The total number of scalars in the array.
    public var scalarCount: Int {
        return buffer.count
    }
    
    /// Creates a `ShapedArray` with the same shape and scalars as the specified instance.
    public init(_ other: ShapedArray) {
        self.init(buffer: other.buffer, shape: other.shape)
    }
    
    /// Creates a `ShapedArray` with the specified shape and contiguous scalars in row-major order.
    /// - Precondition: The number of scalars must equal the product of the dimensions of the shape.
    public init(shape: __owned [Int], scalars: __owned [Scalar]) {
        precondition(shape.reduce(1, *) == scalars.count, "Scalar count mismatch.")
        self.init(buffer: scalars, shape: shape)
    }
    
    /// Creates a `ShapedArray` with the specified shape and sequence of scalars in row-major order.
    /// - Precondition: The number of scalars must equal the product of the dimensions of the shape.
    public init<S: Sequence>(shape: __owned [Int], scalars: __shared S) where S.Element == Scalar {
        let scalarCount = shape.reduce(1, *)
        let buffer = [Scalar](scalars)
        precondition(
            buffer.count == scalarCount,
            "The sequence has fewer elements than needed by the shape.")
        self.init(buffer: buffer, shape: shape)
    }
    
    /// Creates a `ShapedArray` from a scalar value.
    public init(_ scalar: __owned Scalar) {
        self.init(buffer: [scalar], shape: [])
    }
    
    /// Creates a `ShapedArray` with the specified shape and a single, repeated scalar value.
    /// - Parameters:
    ///   - repeatedValue: The scalar value to repeat.
    ///   - shape: The shape of the `ShapedArray`.
    public init(repeating repeatedValue: __owned Scalar, shape: __owned [Int]) {
        let scalarCount = shape.reduce(1, *)
        let buffer = Array(repeating: repeatedValue, count: scalarCount)
        self.init(buffer: buffer, shape: shape)
    }
}

extension ShapedArray: RandomAccessCollection, MutableCollection {
    public typealias Index = Int
    public typealias Element = ShapedArraySlice<Scalar>
    public typealias SubSequence = ShapedArraySlice<Scalar>
    
    public var indices: Range<Int> {
        return 0..<count
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return count
    }
    
    /// Access the element array specified by an index in the leading dimension.
    /// - Parameter index: Index of the element array.
    public subscript(index: Int) -> Element {
        get {
            precondition(!isScalar, "Scalar has no elements and cannot be subscripted.")
            precondition(index < endIndex, "ShapedArray index is out of range.")
            precondition(index >= startIndex, "Negative ShapedArray index is out of range.")
            return ShapedArraySlice(base: self, baseIndices: [index])
        }
        set {
            precondition(!isScalar, "Scalar has no elements and cannot be subscripted.")
            precondition(index < endIndex, "ShapedArray index is out of range.")
            precondition(index >= startIndex, "Negative ShapedArray index is out of range.")
            precondition(shape.dropFirst().elementsEqual(newValue.shape), "Element shape mismatch.")
            let scalarIndex = self.scalarIndex(fromIndex: index)
            withUnsafeMutableBufferPointer { destBuffPtr in
                let ptr = destBuffPtr.baseAddress!.advanced(by: scalarIndex)
                newValue.withUnsafeBufferPointer { srcBuffPtr in
                    ptr.initialize(from: srcBuffPtr.baseAddress!, count: srcBuffPtr.count)
                }
            }
        }
    }
    
    /// Access the subarray specified by a contiguous range of indices.
    /// - Parameter bounds: Contiguous range of indices.
    public subscript(bounds: Range<Int>) -> SubSequence {
        get {
            precondition(!isScalar, "Scalar has no elements and cannot be subscripted.")
            precondition(
                bounds.lowerBound >= startIndex && bounds.lowerBound <= endIndex
                && bounds.upperBound >= startIndex && bounds.upperBound <= endIndex,
                "ShapedArray indices are out of range")
            return ShapedArraySlice(base: self, bounds: bounds)
        }
        set {
            precondition(!isScalar, "Scalar has no elements and cannot be subscripted.")
            precondition(
                indices ~= bounds.lowerBound && indices ~= bounds.upperBound - 1,
                "ShapedArray indices are out of range.")
            let subArrayShape = [bounds.count] + shape.dropFirst()
            precondition(subArrayShape == newValue.shape, "Subarray shape mismatch.")
            let scalarIndex = self.scalarIndex(fromIndex: bounds.lowerBound)
            withUnsafeMutableBufferPointer { destBuffPtr in
                let ptr = destBuffPtr.baseAddress!.advanced(by: scalarIndex)
                newValue.withUnsafeBufferPointer { srcBuffPtr in
                    ptr.initialize(from: srcBuffPtr.baseAddress!, count: srcBuffPtr.count)
                }
            }
        }
    }
}

extension ShapedArray {
    /// Calls a closure with a pointer to the array’s contiguous storage.
    /// - Parameter body: A closure with an `UnsafeBufferPointer` parameter that points to the
    ///   contiguous storage for the array. If no such storage exists, it is created. If body has a
    ///   return value, that value is also used as the return value for the
    ///   `withUnsafeBufferPointer(_:)` method. The pointer argument is valid only for the duration
    ///   of the method's execution.
    public func withUnsafeBufferPointer<Result>(
        _ body: (UnsafeBufferPointer<Scalar>) throws -> Result
    ) rethrows -> Result {
        return try buffer.withUnsafeBufferPointer { ptr in try body(ptr) }
    }
    
    /// Calls the given closure with a pointer to the array’s mutable contiguous storage.
    /// - Parameter body: A closure with an `UnsafeMutableBufferPointer` parameter that points to
    ///   the contiguous storage for the array. If no such storage exists, it is created. If body
    ///   has a return value, that value is also used as the return value for the
    ///   `withUnsafeMutableBufferPointer(_:)` method. The pointer argument is valid only for the
    ///   duration of the method's execution.
    public mutating func withUnsafeMutableBufferPointer<Result>(
        _ body: (inout UnsafeMutableBufferPointer<Scalar>) throws -> Result
    ) rethrows -> Result {
        return try buffer.withUnsafeMutableBufferPointer { ptr in try body(&ptr) }
    }
}

// Array literal conversion.
// TODO: ExpressibleByArrayLiteral: This will need to be revisited.
// Path forward looks like:
// 1. Copy `_TensorElementLiteral` as `_ShapedArrayElementLiteral`.
// 2. Implement conformances equivalent to those of _TensorElementLiteral but
//    using ShapedArray affordances. Avoid tensorflow.
// extension ShapedArray: ExpressibleByArrayLiteral where Scalar: TensorFlowScalar {
//   public typealias ArrayLiteralElement = _TensorElementLiteral<Scalar>
//   @inlinable
//   public init(arrayLiteral elements: _TensorElementLiteral<Scalar>...) {
//     precondition(!elements.isEmpty, "Cannot create a 'ShapedArray' with no elements.")
//     self = Tensor<Scalar>(_tensorElementLiterals: elements).array
//   }
// }

// Equatable conformance.
extension ShapedArray: Equatable where Scalar: Equatable {
    public static func == (lhs: ShapedArray, rhs: ShapedArray) -> Bool {
        return lhs._isEqual(to: rhs)
    }
}

// Hashable conformance.
extension ShapedArray: Hashable where Scalar: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(shape)
        hasher.combine(scalars)
    }
}

// String conversion.
extension ShapedArray: CustomStringConvertible {
    /// A textual representation of this `ShapedArray`.
    ///
    /// - Note: use `fullDescription` for a non-pretty-printed description showing all scalars.
    public var description: String {
        // Summarize if there are more than 1000 scalars.
        let summarizing = scalarCount > 1000
        return description(summarizing: summarizing)
    }
}

// Xcode Playground display conversion.
extension ShapedArray: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        return description
    }
}

// Mirror representation, used by debugger/REPL.
extension ShapedArray: CustomReflectable {
    public var customMirror: Mirror {
        return Mirror(self, children: [], displayStyle: .struct)
    }
}

// Codable conformance.
extension ShapedArray: Codable where Scalar: Codable {
    private enum CodingKeys: String, CodingKey {
        case shape
        case scalars
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let shape = try container.decode([Int].self, forKey: .shape)
        let scalars = try container.decode([Scalar].self, forKey: .scalars)
        self.init(shape: shape, scalars: scalars)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(shape, forKey: .shape)
        try container.encode(scalars, forKey: .scalars)
    }
}
