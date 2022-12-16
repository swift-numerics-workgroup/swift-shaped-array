//
//  CPU.swift
//  
//
//  Created by Khalid Alotaibi on 11/21/22.
//


import Foundation
import RealModule

final class CPU {

    static func sqrt<T: Real>(_ x: ShapedArray<T>) -> ShapedArray<T>
    {
        
        var ret = ShapedArray<T>(repeating: 0, shape: x.shape)
        let ptrToSrc = helperToPointer(src: x)
        let ptrToDst = helperToMutatingPointer(dst: &ret)
        
        _RawCPU.sqrt(to: ptrToDst, from: ptrToSrc, count: x.scalarCount)
        
        return ret
    }

}
