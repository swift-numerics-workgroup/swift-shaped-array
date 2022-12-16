//
//  Math.swift
//
//  Created by Khalid Alotaibi on 11/23/22.
//

import Numerics


extension ShapedArray where Scalar: Real {
    
    public static func sqrt(_ x: Self) -> Self {
        CPU.sqrt(x)
    }
    
    /* Need conformance to SIMD to work
    @inlinable
    @derivative(of: sqrt)
    internal static func _vpjSqrt(
        _ x: ShapedArray
    ) -> (value: ShapedArray, pullback: (ShapedArray<Scalar>.TangentVector) -> ShapedArray<Scalar>.TangentVector) {
        let value = ShapedArray.sqrt(x)
        return (value, {v in v / (2 * value)})
    }
     */
}

