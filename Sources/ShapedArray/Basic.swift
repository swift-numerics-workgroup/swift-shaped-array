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

extension ShapedArray {
    public func reshaped(to newShape: [Int]) -> ShapedArray {
        precondition(newShape.reduce(1, *) == self.scalarCount, "Cannot reshape to shape \(newShape) because it has a different number of elements than the original shape \(self.shape).")
        return .init(shape: newShape, scalars: self.scalars)
    }

    public func reshaped(to newShape: Int...) -> ShapedArray {
        return self.reshaped(to: newShape)
    }

    public func reshaped<T>(like other: ShapedArray<T>) -> ShapedArray {
        return self.reshaped(to: other.shape)
    }

    /// Unpacks the given dimension of a rank-`R` ShapedArray into multiple rank-`(R-1)` ShapedArrays.
    /// Unpacks `N` ShapedArrays from this ShapedArray by chipping it along the `axis` dimension, where `N`
    /// is inferred from this ShapedArray's shape. For example, given a ShapedArray with shape
    /// `[A, B, C, D]`:
    ///
    ///   - If `axis == 0` then the `i`-th ShapedArray in the returned array is the slice
    ///     `self[i, :, :, :]` and each ShapedArray in that array will have shape `[B, C, D]`.
    ///     (Note that the dimension unpacked along is gone, unlike
    ///     `ShapedArray.split(numSplits:alongAxis)`, or `ShapedArray.split(sizes:alongAxis)`).
    ///   - If `axis == 1` then the `i`-th ShapedArray in the returned array is the slice
    ///     `value[:, i, :, :]` and each ShapedArray in that array will have shape `[A, C, D]`.
    ///   - Etc.
    ///
    /// This is the opposite of `ShapedArray.init(stacking:alongAxis:)`.
    ///
    /// - Parameters:
    ///   - axis: Dimension along which to unstack. Negative values wrap around.
    ///
    /// - Precondition: `axis` must be in the range `[-rank, rank)`, where `rank` is the rank of
    ///   the provided ShapedArrays.
    ///
    /// - Returns: Array containing the unstacked ShapedArrays.
    @inlinable
    public func unstacked(alongAxis axis: Int = 0) -> [ShapedArray] {
        ensureValid(axis: axis)
        let axis = axis < 0 ? axis + self.rank : axis
        let numberOfArrays = self.shape[axis]

        let lengthAfterAxis = self.shape[(axis + 1)..<self.shape.count].reduce(1, *)
        let lengthAtAxis = self.shape[axis..<self.shape.count].reduce(1, *)
        let newShape = self.shape.enumerated().filter { $0.0 != axis }.map { $0.1 }
        let scalarsPerArray = newShape.reduce(1, *)

        let newArrays = (0..<numberOfArrays).map { i in
            Array<Scalar>(unsafeUninitializedCapacity: scalarsPerArray) { buffer, initializedCount in
                for j in 0..<scalarsPerArray {
                    let mod = j % lengthAfterAxis
                    let finishedRows = j / lengthAfterAxis
                    let arrayOffset = i * lengthAfterAxis
                    let skipAxisLength = finishedRows * lengthAtAxis

                    let value = self.scalars[mod + arrayOffset + skipAxisLength]
                    buffer[j] = value
                }
                initializedCount = scalarsPerArray
            }
        }

        return newArrays.map { ShapedArray(shape: newShape, scalars: $0) }
    }
}

//===------------------------------------------------------------------------------------------===//
// Precondition utilities
//===------------------------------------------------------------------------------------------===//

extension ShapedArray {
    /// Returns `true` iff `k` denotes an axis of `self`.
    @usableFromInline
    internal func isValid<T: BinaryInteger>(axis k: T) -> Bool {
        let axis = Int(k)
        return axis >= -rank && axis < rank
    }

    /// Returns `true` iff each element of `axes` denotes an axis of `self`.
    @usableFromInline
    internal func areValid<T: BinaryInteger>(axes: [T]) -> Bool {
        return axes.allSatisfy { isValid(axis: $0) }
    }

    /// Returns `true` iff each element of `axes` denotes an axis of `self`.
    ///
    /// - Precondition: `axes` has rank 0 or rank 1.
    @usableFromInline
    internal func areValid(
        axes: ShapedArray<Int32>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Bool {
        precondition(
        axes.rank < 2,
        "Axes must have rank 0 or rank 1; axes has rank \(axes.rank) with values \(axes.scalars).",
        file: file,
        line: line)
        return areValid(axes: axes.scalars)
    }

    /// Checks that each element of `axes` denotes an axis of `self`, and stops the program with a
    /// diagnostic otherwise.
    @usableFromInline
    func ensureValid(
        axes: ShapedArray<Int32>,
        function: StaticString = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        precondition(
        areValid(axes: axes, file: file, line: line),
        "All axes must be in `-rank..<rank` when calling \(function) (rank: \(rank), axes: \(axes))",
        file: file,
        line: line)
    }

    /// Checks that each element of `axes` denotes an axis of `self`, and stops the program with a
    /// diagnostic otherwise.
    @usableFromInline
    func ensureValid(
        axes: [Int],
        function: StaticString = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        precondition(
        areValid(axes: axes),
        "All axes must be in `-rank..<rank` when calling \(function) (rank: \(rank), axes: \(axes))",
        file: file,
        line: line)
    }

    /// Checks that `k` denotes an axis of `self`, and stops the program with a diagnostic otherwise.
    @usableFromInline
    func ensureValid(
        axis k: Int,
        function: StaticString = #function,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        precondition(
        isValid(axis: k),
        "Axis must be in `-rank..<rank` when calling \(function) (rank: \(rank), axis: \(k))",
        file: file,
        line: line)
    }
}
