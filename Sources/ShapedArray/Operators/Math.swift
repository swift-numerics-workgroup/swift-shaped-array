//
//  Math.swift
//  
//
//  Created by Khalid Alotaibi on 11/23/22.
//

#if canImport(Differentiation)
import Differentiation
#else
import _Differentiation
#endif
import Numerics


extension ShapedArray: ElementaryFunctions where Scalar: ShapedArrayFloatingPoint {
    
    
    @differentiable(reverse)
    public static func sqrt(_ x: Self) -> Self {
        CPU.sqrt(x)
    }
    
    /*   Needs divison operator / to conform to SIMD to work
    @inlinable
    @derivative(of: sqrt)
    internal static func _vpjSqrt(
        _ x: ShapedArray
    ) -> (value: ShapedArray, pullback: (ShapedArray<Scalar>.TangentVector) -> ShapedArray<Scalar>.TangentVector) {
        let value = ShapedArray.sqrt(x)
        return (value, {v in v / (2 * value)})
    }*/
    
    
    @differentiable(reverse)
    public static func cos(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        CPU.cos(x)
    }

    
    public static func exp(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func expMinusOne(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func cosh(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func sinh(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func tanh(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func sin(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func tan(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func log(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func log(onePlus x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func acosh(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func asinh(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func atanh(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func acos(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func asin(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func atan(_ x: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func pow(_ x: ShapedArray<Scalar>, _ y: ShapedArray<Scalar>) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func pow(_ x: ShapedArray<Scalar>, _ n: Int) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
    public static func root(_ x: ShapedArray<Scalar>, _ n: Int) -> ShapedArray<Scalar> {
        fatalError("Not implemented yet")
    }
    
  
}

