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

#if canImport(Accelerate)
import Accelerate
#endif

#if os(Linux)
import Glibc
#else
import Foundation
#endif


final class CPU {

    
    @differentiable(reverse)
    static func sqrt<T: ShapedArrayFloatingPoint>(_ x: ShapedArray<T>) -> ShapedArray<T>
    {
        var ret = ShapedArray<T>(repeating: 0.0, shape: x.shape)
        let ptrToSrc = helperToPointer(src: x)
        let ptrToDst = helperToMutatingPointer(dst: &ret)
        
        _RawCPU.sqrt(to: ptrToDst, from: ptrToSrc, count: x.scalarCount)

        return ret
    }

}
