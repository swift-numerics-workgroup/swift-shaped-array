//
//  Initializers.swift
//  
//
//  Created by Jaap Wijnen on 19/08/2022.
//

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
    /// - Precondition: All ShapedArrays must have the same shape.
    /// - Precondition: `axis` must be in the range `[0, rank]`, where `rank` is the rank of the
    ///   provided ShapedArrays.
    ///
    /// - Returns: The stacked ShapedArray.
    public init(stacking arrays: [ShapedArray<Scalar>], alongAxis axis: Int = 0) {
        self = .pack(arrays, axis: axis)
    }
}
