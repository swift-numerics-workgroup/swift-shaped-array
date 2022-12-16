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

import Swift

//===------------------------------------------------------------------------------------------===//
// ShapedArrayProtocol: The protocol unifying ShapedArray and ShapedArraySlice.
//===------------------------------------------------------------------------------------------===//

public protocol _ShapedArrayProtocol<Scalar>: RandomAccessCollection, MutableCollection {
    associatedtype Scalar
    
    /// The number of dimensions of the array.
    var rank: Int { get }

    /// An integer array in which each element represents the size of the corresponding dimension.
    var shape: [Int] { get }

    /// The total number of scalars in the array.
    var scalarCount: Int { get }
    
    /// Creates an array with the specified shape and contiguous scalars in row-major order.
    /// - Precondition: The number of scalars must equal the product of the dimensions of the shape.
    init(shape: [Int], scalars: [Scalar])
    
    /// Creates an array with the specified shape and sequence of scalars in row-major order.
    /// - Precondition: The number of scalars must equal the product of the dimensions of the shape.
    init<S: Sequence>(shape: [Int], scalars: S) where S.Element == Scalar
    
    /// Calls a closure with a pointer to the array’s contiguous storage.
    /// - Parameter body: A closure with an `UnsafeBufferPointer` parameter that points to the
    ///   contiguous storage for the array. If no such storage exists, it is created. If body has a
    ///   return value, that value is also used as the return value for the
    ///   `withUnsafeBufferPointer(_:)` method. The pointer argument is valid only for the duration
    ///   of the method's execution.
    func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Scalar>) throws -> R) rethrows -> R
    
    /// Calls the given closure with a pointer to the array’s mutable contiguous storage.
    /// - Parameter body: A closure with an `UnsafeMutableBufferPointer` parameter that points to
    ///   the contiguous storage for the array. If no such storage exists, it is created. If body
    ///   has a return value, that value is also used as the return value for the
    ///   `withUnsafeMutableBufferPointer(_:)` method. The pointer argument is valid only for the
    ///   duration of the method's execution.
    mutating func withUnsafeMutableBufferPointer<R>(
        _ body: (inout UnsafeMutableBufferPointer<Scalar>) throws -> R
    ) rethrows -> R
}

extension _ShapedArrayProtocol {
    /// The scalars of the array in row-major order.
    public var scalars: [Scalar] {
        get {
            return withUnsafeBufferPointer(Array.init)
        }
        set {
            precondition(newValue.count == scalarCount, "Scalar count mismatch.")
            withUnsafeMutableBufferPointer { pointer in
                pointer.baseAddress!.initialize(from: newValue, count: newValue.count)
            }
        }
    }
    
    /// Returns `true` if the array has rank 0.
    public var isScalar: Bool {
        return rank == 0
    }
    
    /// Returns the single scalar element if the array has rank 0 and `nil` otherwise.
    public var scalar: Scalar? {
        get {
            guard rank == 0 else { return nil }
            return scalars.first
        }
        set {
            precondition(isScalar, "Array does not have shape [].")
            guard let newValue = newValue else {
                preconditionFailure("New scalar value cannot be nil.")
            }
            scalars[0] = newValue
        }
    }
}

extension _ShapedArrayProtocol where Scalar: Equatable {
    public static func == <Other>(lhs: Self, rhs: Other) -> Bool
    where Other: _ShapedArrayProtocol, Scalar == Other.Scalar {
        return lhs.shape == rhs.shape && lhs.scalars.elementsEqual(rhs.scalars)
    }
}

extension _ShapedArrayProtocol {
    /// Returns the number of element arrays in an array (equivalent to the first dimension).
    /// - Note: `count` is distinct from `scalarCount`, which represents the
    ///   total number of scalars.
    public var count: Int {
        return shape.first ?? 0
    }
}

extension _ShapedArrayProtocol {
    /// Returns the scalar count for an element of the array.
    var scalarCountPerElement: Int {
        return shape.isEmpty ? 0 : shape.dropFirst().reduce(1, *)
    }
    
    /// Returns the scalar index corresponding to an index in the leading dimension of the array.
    func scalarIndex(fromIndex index: Int) -> Int {
        return scalarCountPerElement * index
    }
    
    /// Returns the range of scalars corresponding to a range in the leading dimension of the array.
    func scalarSubrange(from arraySubrange: Range<Int>) -> Range<Int> {
        return scalarIndex(
            fromIndex: arraySubrange.lowerBound)..<scalarIndex(fromIndex: arraySubrange.upperBound)
    }
}

extension String {
    /// Returns a string of the specified length, padded with whitespace to the left.
    fileprivate func leftPadded(toLength length: Int) -> String {
        return repeatElement(" ", count: max(0, length - count)) + self
    }
}

// Common public protocol implementations.

extension _ShapedArrayProtocol
where Element: _ShapedArrayProtocol, Element == Element.Element {
    /// Returns the whitespace separator between elements, given the current indent level.
    fileprivate func separator(indentLevel: Int) -> String {
        if rank == 1 {
            return ", "
        }
        return String(repeating: "\n", count: rank - 1)
        + String(repeating: " ", count: indentLevel + 1)
    }
    
    /// A textual representation of the 1-D shaped array, starting at the given indent level.
    /// Returns a summarized description if `summarizing` is true and the element count exceeds
    /// twice the `edgeElementCount`.
    ///
    /// - Parameters:
    ///   - indentLevel: The indentation level.
    ///   - edgeElementCount: The maximum number of elements to print before and after summarization
    ///     via ellipses (`...`).
    ///   - maxScalarLength: The length of the longest scalar description in the entire original
    ///     array-to-print.
    ///   - maxScalarCountPerLine: The maximum number of scalars to print per line, used when
    ///     printing 1-D vectors.
    ///   - summarizing: If true, summarize description if element count exceeds twice
    ///     `edgeElementCount`.
    fileprivate func vectorDescription(
        indentLevel: Int,
        edgeElementCount: Int,
        maxScalarLength: Int,
        maxScalarCountPerLine: Int,
        summarizing: Bool
    ) -> String {
        // Get scalar descriptions.
        func scalarDescription(_ element: Element) -> String {
            let description = String(describing: element)
            return description.leftPadded(toLength: maxScalarLength)
        }
        
        var scalarDescriptions: [String] = []
        if summarizing && count > 2 * edgeElementCount {
            scalarDescriptions += prefix(edgeElementCount).map(scalarDescription)
            scalarDescriptions += ["..."]
            scalarDescriptions += suffix(edgeElementCount).map(scalarDescription)
        } else {
            scalarDescriptions += map(scalarDescription)
        }
        
        // Combine scalar descriptions into lines, based on the scalar count per line.
        let lines = stride(
            from: scalarDescriptions.startIndex,
            to: scalarDescriptions.endIndex,
            by: maxScalarCountPerLine
        ).map { i -> ArraySlice<String> in
            let upperBound = Swift.min(
                i.advanced(by: maxScalarCountPerLine),
                scalarDescriptions.count)
            return scalarDescriptions[i..<upperBound]
        }
        
        // Return lines joined with separators.
        let lineSeparator = ",\n" + String(repeating: " ", count: indentLevel + 1)
        return lines.enumerated().reduce(into: "[") { result, entry in
            let (i, line) = entry
            result += line.joined(separator: ", ")
            result += i != lines.count - 1 ? lineSeparator : ""
        } + "]"
    }
    
    /// A textual representation of the shaped array, starting at the given indent level. Returns a
    /// summarized description if `summarizing` is true and the element count exceeds twice the
    /// `edgeElementCount`.
    ///
    /// - Parameters:
    ///   - indentLevel: The indentation level.
    ///   - edgeElementCount: The maximum number of elements to print before and after summarization
    ///     via ellipses (`...`).
    ///   - maxScalarLength: The length of the longest scalar description in the entire original
    ///     array-to-print.
    ///   - maxScalarCountPerLine: The maximum number of scalars to print per line, used when
    ///     printing 1-D vectors.
    ///   - summarizing: If true, summarizing description if element count exceeds twice
    ///     `edgeElementCount`.
    fileprivate func description(
        indentLevel: Int,
        edgeElementCount: Int,
        maxScalarLength: Int,
        maxScalarCountPerLine: Int,
        summarizing: Bool
    ) -> String {
        // Handle scalars.
        if let scalar = scalar {
            return String(describing: scalar)
        }
        
        // Handle vectors, which have special line-width-sensitive logic.
        if rank == 1 {
            return vectorDescription(
                indentLevel: indentLevel,
                edgeElementCount: edgeElementCount,
                maxScalarLength: maxScalarLength,
                maxScalarCountPerLine: maxScalarCountPerLine,
                summarizing: summarizing)
        }
        
        // Handle higher-rank tensors.
        func elementDescription(_ element: Element) -> String {
            return element.description(
                indentLevel: indentLevel + 1,
                edgeElementCount: edgeElementCount,
                maxScalarLength: maxScalarLength,
                maxScalarCountPerLine: maxScalarCountPerLine,
                summarizing: summarizing)
        }
        
        var elementDescriptions: [String] = []
        if summarizing && count > 2 * edgeElementCount {
            elementDescriptions += prefix(edgeElementCount).map(elementDescription)
            elementDescriptions += ["..."]
            elementDescriptions += suffix(edgeElementCount).map(elementDescription)
        } else {
            elementDescriptions += map(elementDescription)
        }
        
        // Return lines joined with separators.
        let lineSeparator =
        "," + String(repeating: "\n", count: rank - 1)
        + String(repeating: " ", count: indentLevel + 1)
        return elementDescriptions.enumerated().reduce(into: "[") { result, entry in
            let (i, elementDescription) = entry
            result += elementDescription
            result += i != elementDescriptions.count - 1 ? lineSeparator : ""
        } + "]"
    }
}

extension _ShapedArrayProtocol
where Element: _ShapedArrayProtocol, Element == Element.Element {
    /// A textual representation of the shaped array. Returns a summarized description if
    /// `summarizing` is true and the element count exceeds twice the `edgeElementCount`.
    ///
    /// - Parameters:
    ///   - lineWidth: The max line width for printing. Used to determine number of scalars to print
    ///     per line.
    ///   - edgeElementCount: The maximum number of elements to print before and after summarization
    ///     via ellipses (`...`).
    ///   - summarizing: If true, summarizing description if element count exceeds twice
    ///     `edgeElementCount`.
    public func description(
        lineWidth: Int = 80,
        edgeElementCount: Int = 3,
        summarizing: Bool = false
    ) -> String {
        // Compute the number of scalars to print per line.
        let maxScalarLength = scalars.lazy.map { String(describing: $0).count }.max() ?? 3
        let maxScalarCountPerLine = Swift.max(1, lineWidth / maxScalarLength)
        return description(
            indentLevel: 0,
            edgeElementCount: edgeElementCount,
            maxScalarLength: maxScalarLength,
            maxScalarCountPerLine: maxScalarCountPerLine,
            summarizing: summarizing)
    }
    
    /// A full, non-pretty-printed textual representation of the shaped array, showing all scalars.
    public var fullDescription: String {
        if let scalar = scalar {
            return String(describing: scalar)
        }
        return "[\( map({"\($0.fullDescription)"}).joined(separator: ", ") )]"
    }
}

extension _ShapedArrayProtocol where Scalar: Equatable {
    internal func _isEqual(to other: Self) -> Bool {
        return shape == other.shape
        && withUnsafeBufferPointer { selfBuf in
            other.withUnsafeBufferPointer { otherBuf in
                selfBuf.elementsEqual(otherBuf)
            }
        }
    }
}
