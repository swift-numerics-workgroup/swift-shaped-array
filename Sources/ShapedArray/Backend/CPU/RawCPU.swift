//
//  RawCPU.swift
//  
//
//  Created by Khalid Alotaibi on 11/22/22.
//

//_RawCPU would be based probably like the other libraries such as Accelerate on the BLAS API.

import Foundation
import RealModule


final class _RawCPU {
    
    static func sqrt<T: Real>(
        to dst: UnsafeMutableBufferPointer<T>,
        from src: UnsafeBufferPointer<T>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = Darwin.sqrt(src[i])
        }
    }

}
