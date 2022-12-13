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

public protocol ShapedArrayFloatingPoint: BinaryFloatingPoint & Differentiable & ElementaryFunctions where Self.RawSignificand: FixedWidthInteger, Self == Self.TangentVector {}

extension Float: ShapedArrayFloatingPoint {}
extension Double: ShapedArrayFloatingPoint {}
