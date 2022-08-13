// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
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

/// A contiguous slice of a `ShapedArray` or `ShapedArraySlice` instance.
///
/// `ShapedArraySlice` enables fast, efficient operations on contiguous slices of `ShapedArray`
/// instances. `ShapedArraySlice` instances do not have their own storage. Instead, they provides a
/// view onto the storage of their base `ShapedArray`. `ShapedArraySlice` can represent two
/// different kinds of slices: element arrays and subarrays.
///
/// Element arrays are subdimensional elements of a `ShapedArray`: their rank is one less than that
/// of their base. Element array slices are obtained by indexing a `ShapedArray` instance with a
/// singular `Int32` index.
///
/// For example:
/// ```
///     var matrix = ShapedArray(shape: [2, 2], scalars: [0, 1, 2, 3])
///     // `matrix` represents [[0, 1], [2, 3]].
///
///     let element = matrix[0]
///     // `element` is a `ShapedArraySlice` with shape [2]. It is an element
///     // array, specifically the first element in `matrix`: [0, 1].
///
///     matrix[1] = ShapedArraySlice(shape: [2], scalars: [4, 8])
///     // The second element in `matrix` has been mutated.
///     // `matrix` now represents [[0, 1, 4, 8]].
/// ```
///
/// Subarrays are a contiguous range of the elements in a `ShapedArray`. The rank of a subarray is
/// the same as that of its base, but its leading dimension is the count of the slice range.
/// Subarray slices are obtained by indexing a `ShapedArray` with a `Range<Int32>` that represents a
/// range of elements (in the leading dimension). Methods like `prefix(:)` and `suffix(:)` that
/// internally index with a range also produce subarray.
///
/// For example:
/// ```
///     let zeros = ShapedArray(repeating: 0, shape: [3, 2])
///     var matrix = ShapedArray(shape: [3, 2], scalars: Array(0..<6))
///     // `zeros` represents [[0, 0], [0, 0], [0, 0]].
///     // `matrix` represents [[0, 1], [2, 3], [4, 5]].
///
///     let subarray = matrix.prefix(2)
///     // `subarray` is a `ShapedArraySlice` with shape [2, 2]. It is a slice
///     // of the first 2 elements in `matrix` and represents [[0, 1], [2, 3]].
///
///     matrix[0..<2] = zeros.prefix(2)
///     // The first 2 elements in `matrix` have been mutated.
///     // `matrix` now represents [[0, 0], [0, 0], [4, 5]].
/// ```
@frozen
public struct ShapedArraySlice<Scalar>: _ShapedArrayProtocol {
    /// The underlying `ShapedArray` of the slice.
    @usableFromInline internal var base: ShapedArray<Scalar>
    /// The subdimensional indices of a slice.
    @usableFromInline internal var baseIndices: [Int]
    /// The subarray bounds of a slice.
    @usableFromInline internal var bounds: Range<Int>?
    
    /// Creates a `ShapedArraySlice` from a base `ShapedArray`, with the specified subdimensional
    /// indices and subarray bounds.
    @inlinable
    internal init(
        base: __owned ShapedArray<Scalar>,
        baseIndices indices: __owned [Int] = [],
        bounds: Range<Int>? = nil
    ) {
        precondition(indices.count <= base.rank, "Number of base indices exceeds base rank.")
        precondition(
            zip(base.shape, indices).allSatisfy { $1 >= 0 && $1 < $0 },
            "Base indices are out of range")
        self.base = base
        self.baseIndices = indices
        self.bounds = bounds
    }
}

extension ShapedArraySlice {
    /// Indexing depth of this slice, i.e. the difference in rank between the base and the slice.
    internal var indexingDepth: Int {
        return baseIndices.count
    }
    
    /// The number of dimensions of the array.
    public var rank: Int {
        return base.rank - indexingDepth
    }
    
    /// The shape of the array.
    public var shape: [Int] {
        if let bounds = bounds {
            return [bounds.count] + Array(base.shape.dropFirst(indexingDepth + 1))
        }
        return Array(base.shape.dropFirst(indexingDepth))
    }
    
    /// The total number of scalars in the array.
    public var scalarCount: Int {
        return shape.reduce(1, *)
    }
}

// Slice initializers.
extension ShapedArraySlice {
    /// Creates a `ShapedArraySlice` with the specified shape and contiguous scalars in row-major
    /// order.
    /// - Precondition: The number of scalars must equal the product of the dimensions of the shape.
    public init(shape: __owned [Int], scalars: __owned [Scalar]) {
        self.init(base: ShapedArray(shape: shape, scalars: scalars))
    }
    
    /// Creates an `ShapedArraySlice` with the specified shape and sequence of scalars in row-major
    /// order.
    /// - Precondition: The number of scalars must equal the product of the dimensions of the shape.
    public init<S: Sequence>(shape: __owned [Int], scalars: __shared S) where S.Element == Scalar {
        self.init(base: ShapedArray(shape: shape, scalars: scalars))
    }
    
    /// Creates a `ShapedArraySlice` from a scalar value.
    public init(_ scalar: __owned Scalar) {
        self.init(base: ShapedArray(scalar))
    }
    
    /// Creates a `ShapedArraySlice` with the specified shape and a single, repeated scalar value.
    /// - Parameters:
    ///   - repeatedValue: The scalar value to repeat.
    ///   - shape: The shape of the `ShapedArraySlice`.
    public init(repeating repeatedValue: __owned Scalar, shape: __owned [Int]) {
        self.init(base: ShapedArray(repeating: repeatedValue, shape: shape))
    }
}

extension ShapedArraySlice {
    /// The range of scalars from the base `ShapedArray` represented by a `ShapedArraySlice`.
    var scalarRange: Range<Int> {
        let trimmedShape = base.shape.dropFirst()
        var (start, end) = baseIndices.enumerated().reduce((0, base.scalarCount)) { (acc, next) in
            let stride = trimmedShape.dropFirst(next.offset).reduce(1, *)
            if next.offset == indexingDepth - 1 {
                let temp = acc.0 + next.element * stride
                return (temp, temp + stride)
            }
            return (acc.0 + next.element * stride, acc.1)
        }
        if let bounds = bounds {
            let stride = trimmedShape.dropFirst(indexingDepth).reduce(1, *)
            let oldStart = start
            start = start + bounds.startIndex * stride
            end = oldStart + bounds.endIndex * stride
        }
        return start..<end
    }
}

extension ShapedArraySlice {
    /// Calls a closure with a pointer to the `ShapedArraySlice`’s contiguous storage.
    /// - Parameter body: A closure with an `UnsafeBufferPointer` parameter that points to the
    ///   contiguous storage for the `ShapedArraySlice`. If no such storage exists, it is created.
    ///   If body has a return value, that value is also used as the return value for the
    ///   `withUnsafeBufferPointer(_:)` method. The pointer argument is valid only for the duration
    ///   of the method's execution.
    public func withUnsafeBufferPointer<Result>(
        _ body: (UnsafeBufferPointer<Scalar>) throws -> Result
    ) rethrows -> Result {
        return try base.withUnsafeBufferPointer { baseBuffPtr in
            let basePtr = baseBuffPtr.baseAddress!
            let ptr = UnsafeBufferPointer(
                start: basePtr.advanced(by: scalarRange.startIndex),
                count: scalarRange.count)
            return try body(ptr)
        }
    }
    
    /// Calls the given closure with a pointer to the `ShapedArraySlice`'s mutable contiguous
    /// storage.
    /// - Parameter body: A closure with an `UnsafeMutableBufferPointer` parameter that points to
    ///   the contiguous storage for the `ShapedArraySlice`. If no such storage exists, it is
    ///   created. If body has a return value, that value is also used as the return value for the
    ///   `withUnsafeMutableBufferPointer(_:)` method. The pointer argument is valid only for the
    ///   duration of the method’s execution.
    public mutating func withUnsafeMutableBufferPointer<Result>(
        _ body: (inout UnsafeMutableBufferPointer<Scalar>) throws -> Result
    ) rethrows -> Result {
        // NOTE: Copying `scalarRange` to a local variable here is necessary for
        // exclusive access.
        let scalarRange = self.scalarRange
        return try base.withUnsafeMutableBufferPointer { baseBuffPtr in
            let basePtr = baseBuffPtr.baseAddress!
            var ptr = UnsafeMutableBufferPointer(
                start: basePtr.advanced(by: scalarRange.startIndex),
                count: scalarRange.count)
            return try body(&ptr)
        }
    }
}

extension ShapedArraySlice: RandomAccessCollection, MutableCollection {
    public typealias Index = Int
    public typealias Element = ShapedArraySlice
    public typealias SubSequence = ShapedArraySlice
    
    public var indices: Range<Int> {
        if let bounds = bounds {
            return bounds
        } else if indexingDepth < base.rank {
            return 0..<base.shape[indexingDepth]
        }
        return 0..<0
    }
    
    public var startIndex: Int {
        return indices.startIndex
    }
    
    public var endIndex: Int {
        return indices.endIndex
    }
    
    /// Access the element array specified by an index in the leading dimension.
    /// - Parameter index: Index of the element array.
    public subscript(index: Int) -> Element {
        get {
            precondition(!isScalar, "Scalar has no elements and cannot be subscripted.")
            precondition(index < endIndex, "ShapedArraySlice index is out of range.")
            precondition(
                index >= startIndex,
                "ShapeArraySlice index is out of range (before startIndex).")
            return ShapedArraySlice(base: base, baseIndices: baseIndices + [index], bounds: nil)
        }
        set {
            precondition(!isScalar, "Scalar has no elements and cannot be subscripted.")
            precondition(index < endIndex, "ShapedArraySlice index is out of range")
            precondition(
                index >= startIndex,
                "ShapeArraySlice index is out of range (before startIndex).")
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
                indices ~= bounds.lowerBound && indices ~= bounds.upperBound - 1,
                "ShapedArraySlice indices are out of range.")
            return ShapedArraySlice(base: base, baseIndices: baseIndices, bounds: bounds)
        }
        set {
            precondition(!isScalar, "Scalar has no elements and cannot be subscripted.")
            precondition(
                indices ~= bounds.lowerBound && indices ~= bounds.upperBound - 1,
                "ShapedArraySlice indices are out of range.")
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

// Array literal conversion.
// Array literal conversion.
// TODO: ExpressibleByArrayLiteral: This will need to be revisited.
// This will be trivial to implement once `ShapedArray: ExpressibleByArrayLiteral`
// is implemented.
// extension ShapedArraySlice: ExpressibleByArrayLiteral where Scalar: TensorFlowScalar {
//   public typealias ArrayLiteralElement = _TensorElementLiteral<Scalar>
//   @inlinable
//   public init(arrayLiteral elements: _TensorElementLiteral<Scalar>...) {
//     precondition(!elements.isEmpty, "Cannot create a 'ShapedArraySlice' with no elements.")
//     self.init(base: Tensor(_tensorElementLiterals: elements).array)
//   }
// }

// Equatable conformance.
extension ShapedArraySlice: Equatable where Scalar: Equatable {
    public static func == (lhs: ShapedArraySlice, rhs: ShapedArraySlice) -> Bool {
        return lhs._isEqual(to: rhs)
    }
}

// Hashable conformance.
extension ShapedArraySlice: Hashable where Scalar: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(shape)
        hasher.combine(scalars)
    }
}

// String conversion.
extension ShapedArraySlice: CustomStringConvertible {
    /// A textual representation of this `ShapedArraySlice`.
    ///
    /// - Note: use `fullDescription` for a non-pretty-printed representation showing all scalars.
    public var description: String {
        // Summarize if there are more than 1000 scalars.
        let summarizing = scalarCount > 1000
        return description(summarizing: summarizing)
    }
}

// Xcode Playground display conversion.
extension ShapedArraySlice: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        return description
    }
}

// Mirror representation, used by debugger/REPL.
extension ShapedArraySlice: CustomReflectable {
    public var customMirror: Mirror {
        return Mirror(self, children: [], displayStyle: .struct)
    }
}

// Codable conformance.
extension ShapedArraySlice: Codable where Scalar: Codable {
    private enum CodingKeys: String, CodingKey {
        case shape
        case scalars
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(shape, forKey: .shape)
        try container.encode(scalars, forKey: .scalars)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let shape = try container.decode([Int].self, forKey: .shape)
        let scalars = try container.decode([Scalar].self, forKey: .scalars)
        self.init(shape: shape, scalars: scalars)
    }
}
