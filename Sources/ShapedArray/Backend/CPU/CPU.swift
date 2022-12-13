//
//  CPU.swift
//  
//
//  Created by Khalid Alotaibi on 11/21/22.
//

#if canImport(Differentiation)
import Differentiation
#else
import _Differentiation
#endif
import Numerics

#if os(Linux)
import Glibc
#else
import Foundation
#endif

final class CPU {

    
    @differentiable(reverse)
    static func sqrt<T: ShapedArrayFloatingPoint>(_ x: ShapedArray<T>) -> ShapedArray<T>
    {
        var ret: ShapedArray<T>
        
        switch T.self {
        case is Float.Type:
            ret = ShapedArray<T>(repeating: 0.0, shape: x.shape)
            let ptrToSrc = helperToPointer(src: x) as! UnsafeBufferPointer<Float>
            let ptrToDst = helperToMutatingPointer(dst: &ret) as! UnsafeMutableBufferPointer<Float>
            
            _RawCPU.sqrtf(to: ptrToDst, from: ptrToSrc, count: x.scalarCount)
            
        case is Double.Type:
            ret = ShapedArray<T>(repeating: 0.0 as! T, shape: x.shape)
            let ptrToSrc = helperToPointer(src: x) as! UnsafeBufferPointer<Double>
            let ptrToDst = helperToMutatingPointer(dst: &ret) as! UnsafeMutableBufferPointer<Double>
            
            _RawCPU.sqrt(to: ptrToDst, from: ptrToSrc, count: x.scalarCount)
            
        default:
            fatalError("Not implemented for types other than FloatingPoints")
        }

        return ret
    }

}
