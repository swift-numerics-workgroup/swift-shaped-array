//
//  ShapedArrayFloatingPoint.swift
//  
//
//  Created by Khalid Alotaibi on 11/25/22.
//

#if canImport(Differentiation)
import Differentiation
#else
import _Differentiation
#endif
import Numerics
import os


public protocol ShapedArrayScalar: Numeric {}

public protocol ShapedArrayFloatingPoint:
    ShapedArrayScalar & BinaryFloatingPoint & Differentiable & ElementaryFunctions
where Self.RawSignificand: FixedWidthInteger, Self == Self.TangentVector {}

extension Float: ShapedArrayFloatingPoint {}
extension Double: ShapedArrayFloatingPoint {}

extension Int32: ShapedArrayScalar {}

