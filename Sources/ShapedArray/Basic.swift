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

    @inlinable
    public func reshaped(to newShape: [Int]) -> ShapedArray {
        let shape = {
            if newShape.contains(-1) {
                let newShapeScalarCount = newShape.reduce(1, *) * -1
                let remainingDim = self.scalarCount / newShapeScalarCount
                return newShape.map {
                    if $0 == -1 {
                        return remainingDim
                    }
                    return $0
                }
            } else {
                return newShape
            }
        }()

        precondition(shape.reduce(1, *) == self.scalarCount, "Cannot reshape to shape \(shape) because it has a different number of elements than the original shape \(self.shape).")

        return .init(shape: shape, scalars: self.scalars)
    }

    @inlinable
    public func reshaped(to newShape: Int...) -> ShapedArray {
        self.reshaped(to: newShape)
    }

    @inlinable
    public func reshaped<T>(like other: ShapedArray<T>) -> ShapedArray {
        self.reshaped(to: other.shape)
    }

    /// Return a copy of the ShapedArray collapsed into a 1-D `ShapedArray`, in row-major order.
    @inlinable
    public func flattened() -> ShapedArray {
        self.reshaped(to: -1)
    }

    // helper data structure for subarray generation
    @usableFromInline
    internal struct SubarrayIndices {
        @usableFromInline
        let start: [Int]
        @usableFromInline
        let end: [Int]
    }

    // helper function for subarray indices generation
    /// takes a shape for the original array, a shape for the subarray, 
    /// and an axis on which the original array would be divided 
    /// and returns an array of start and end indices for each subarray

    @usableFromInline
    internal func _calculateSubarrayIndices(shape: [Int], subarrayShape: [Int], axis: Int) -> [SubarrayIndices] {
        let numberOfSubarrays = shape[axis] / subarrayShape[axis]
        
        var subarrays = [SubarrayIndices]()
        
        for i in 0..<numberOfSubarrays {
            var startIndices = [Int](repeating: 0, count: shape.count)
            var endIndices = shape
            
            startIndices[axis] = i * subarrayShape[axis]
            endIndices[axis] = startIndices[axis] + subarrayShape[axis]
            
            subarrays.append(SubarrayIndices(start: startIndices, end: endIndices))
        }
        
        return subarrays
    }

    // helper function for subarray indices generation
    /// takes a start and end index for each dimension and returns all the n-dim indices in between
    @usableFromInline
    internal func _generateIndices(start: [Int], end: [Int], currentIndex: [Int] = [], depth: Int = 0) -> [[Int]] {
        if depth == start.count {
            return [currentIndex]
        }
        
        var indices = [[Int]]()
        
        for i in start[depth]..<end[depth] {
            let newIndex = currentIndex + [i]
            let subIndices = _generateIndices(start: start, end: end, currentIndex: newIndex, depth: depth + 1)
            indices += subIndices
        }
        return indices
    }

    // helper function for subarray indices generation
    /// takes a shape, strides, and n-dim indices and returns the linear index
    @usableFromInline
    internal func _calculateLinearIndex(shape: [Int], strides: [Int], indices: [Int]) -> Int {
      var linearIndex = 0
        for i in 0..<shape.count {
            let dimSize = shape[i]
            let stride = strides[i]
            let index = indices[i]
            if index >= dimSize {
                fatalError("Index out of bounds")
            }
            linearIndex += stride * index
        }
    return linearIndex
    }


    /// Splits the ShapedArray into multiple subarrays along the given axis.
    /// - Parameters:
    ///   - count: The number of subarrays to return.
    ///  - axis: The axis along which to split the ShapedArray. Negative values wrap around.
    /// - Returns: An array of ShapedArrays.
    /// - Precondition: `count` must evenly divide the size of the ShapedArray along the given axis.
    /// - Precondition: `axis` must be in the range `[-rank, rank)`.
    @inlinable
    public func split(count: Int, alongAxis axis: Int = 0) -> [ShapedArray] {
        ensureValid(axis: axis)
        let axis = axis < 0 ? axis + self.rank : axis

        let newShape = self.shape.enumerated().map { $0.0 == axis ? $0.1 / count : $0.1 }
        let scalarsPerArray = newShape.reduce(1, *)
        
        // Generate the n-dim start and end indices for each subarray
        let indices = _calculateSubarrayIndices(shape: self.shape, subarrayShape: newShape, axis: axis)
        
        let newArrays = (0..<count).map { i -> ShapedArray in

            // Generate all the n-dim indices for each subarray using the start and end indices
            let allIndices = _generateIndices(start: indices[i].start, end: indices[i].end)

            let scalars = Array<Scalar>(unsafeUninitializedCapacity: scalarsPerArray) { buffer, initializedCount in
                for j in 0..<scalarsPerArray {
                    // Calculate the linear index for each n-dim index
                    let index = _calculateLinearIndex(shape: self.shape, strides: self.stride, indices: allIndices[j])

                    let value = self.scalars[index]
                    buffer[j] = value
                }
                initializedCount = scalarsPerArray
            }
            return ShapedArray(shape: newShape, scalars: scalars)
        }

        return newArrays
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

        let lengthAfterAxis = self.stride[axis]
        let lengthAtAxis = axis == 0 ? self.stride.reduce(1, *) : self.stride[axis - 1]
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

    @inlinable
    public func expandingShape(at axes: [Int]) -> ShapedArray {
        var resultShape = self.shape
        for i in axes {
            var dim = i
            if dim < 0 { dim += resultShape.count + 1 }
            resultShape.insert(1, at: dim)
        }
        return self.reshaped(to: resultShape)
    }

    @inlinable
    public func expandingShape(at axes: Int...) -> ShapedArray {
        return self.expandingShape(at: axes)
    }

    @inlinable
    public func rankLifted() -> ShapedArray {
        return self.expandingShape(at: 0)
    }
    
    /// Removes the specified dimensions of size 1 from the shape of a tensor. If no dimensions are
    /// specified, then all dimensions of size 1 will be removed.
    @inlinable
    public func squeezingShape(at axes: [Int]) -> ShapedArray {
        var resultShape = self.shape
        for i in 0..<shape.count {
            if axes.contains(i) || (axes.isEmpty && shape[i] == 1) {
                precondition(shape[i] == 1, "Can't squeeze axis \(i) since its size is not 1")
                resultShape.remove(at: i)
            }
        }
        return self.reshaped(to: resultShape)
    }

    @inlinable
    public func squeezingShape(at axes: Int...) -> ShapedArray {
        return self.squeezingShape(at: axes)
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
        return axis >= -self.rank && axis < self.rank
    }

    /// Returns `true` iff each element of `axes` denotes an axis of `self`
    /// _and_ there is no repeated axis.
    @usableFromInline
    internal func areValid<T: BinaryInteger>(axes: [T]) -> Bool {
        let rank = self.rank
        return axes.allSatisfy { self.isValid(axis: $0) }
            && (Set(axes.map { $0 < 0 ? Int($0) + rank : Int($0) }).count == axes.count)
    }

    /// Returns `true` iff each element of `axes` denotes an axis of `self`
    /// _and_ there is no repeated axis.
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
        return self.areValid(axes: axes.scalars)
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
        self.areValid(axes: axes, file: file, line: line),
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
        self.areValid(axes: axes),
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
        self.isValid(axis: k),
        "Axis must be in `-rank..<rank` when calling \(function) (rank: \(rank), axis: \(k))",
        file: file,
        line: line)
    }
}
