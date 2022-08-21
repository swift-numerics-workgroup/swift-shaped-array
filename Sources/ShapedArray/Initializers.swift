// Copyright 2020 The TensorFlow Authors. All Rights Reserved.
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
    
    /// Stacks `arrays`, along the `axis` dimension, into a new ShapedArray with rank one higher than
    /// the current ShapedArray and each ShapedArray in `arrays`.
    ///
    /// Given that `arrays` all have shape `[A, B, C]`, and `arrays.count = N`, then:
    /// - if `axis == 0` then the resulting ShapedArray will have the shape `[N, A, B, C]`.
    /// - if `axis == 1` then the resulting ShapedArray will have the shape `[A, N, B, C]`.
    /// - etc.
    ///
    /// For example:
    /// ```
    /// // 'x' is [1, 4]
    /// // 'y' is [2, 5]
    /// // 'z' is [3, 6]
    /// ShapedArray(stacking: [x, y, z]) // is [[1, 4], [2, 5], [3, 6]]
    /// ShapedArray(stacking: [x, y, z], alongAxis: 1) // is [[1, 2, 3], [4, 5, 6]]
    /// ```
    ///
    /// This is the opposite of `ShapedArray.unstacked(alongAxis:)`.
    ///
    /// - Parameters:
    ///   - arrays: ShapedArrays to stack.
    ///   - axis: Dimension along which to stack. Values should be in range of `[0, rank]`.
    ///
    /// - Precondition: `arrays` cannot be empty.
    /// - Precondition: All ShapedArrays must have the same shape.
    /// - Precondition: `axis` must be in the range `[0, rank]`, where `rank` is the rank of the
    ///   provided ShapedArrays.
    ///
    /// - Returns: The stacked ShapedArray.
    @inlinable
    public init<S>(stacking arrays: [S], alongAxis axis: Int = 0) where S: _ShapedArrayProtocol, S.Scalar == Scalar {
        precondition(!arrays.isEmpty, "Cannot pack empty array of ShapedArrays.")
        let shape = arrays.first!.shape
        precondition(axis >= 0 && axis <= shape.count, "axis = \(axis) is not within [0, \(shape.count)]")
        // we use assert here for increased performance in release mode.
        assert(!arrays.contains(where: { $0.shape != shape }), "Shapes of all inputs must match: \(shape).")
        let scalarCount = arrays.first!.scalarCount
        let totalScalars = scalarCount * arrays.count
        
        let rowLengthForAxis = shape[axis..<shape.count].reduce(1, *)
        let combinedRowLength = rowLengthForAxis * arrays.count
        
        let elements = Array<Scalar>(unsafeUninitializedCapacity: totalScalars) { buffer, initializedCount in
            for (i, value) in arrays.enumerated() {
                for j in 0..<scalarCount {
                    let mod = j % rowLengthForAxis
                    let finishedRows = j / rowLengthForAxis
                    let offset = i * rowLengthForAxis
                    let newIndex = mod + offset + finishedRows * combinedRowLength
                    
                    buffer[newIndex] = value.scalars[j]
                }
            }
            initializedCount = totalScalars
        }
        
        var newShape = shape
        newShape.insert(arrays.count, at: axis)
        
        self = ShapedArray(shape: newShape, scalars: elements)
    }
}
