//
//  RawCPU.swift
//  
//
//  Created by Khalid Alotaibi on 11/22/22.
//

//_RawCPU would be based probably like the other libraries such as Accelerate on the BLAS API.

import Foundation



final class _RawCPU {
    
    static func sqrt(
        to dst: UnsafeMutableBufferPointer<Double>,
        from src: UnsafeBufferPointer<Double>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = Darwin.sqrt(src[i])
        }
    }
    
    static func sqrtf(
        to dst: UnsafeMutableBufferPointer<Float>,
        from src: UnsafeBufferPointer<Float>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = Darwin.sqrtf(src[i])
        }
    }

}
