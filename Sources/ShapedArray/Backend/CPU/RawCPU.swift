//
//  RawCPU.swift
//  
//
//  Created by Khalid Alotaibi on 11/22/22.
//

import Foundation


final class _RawCPU {
    
    static func sqrt<T: ShapedArrayFloatingPoint>(
        to dst: UnsafeMutableBufferPointer<T>,
        from src: UnsafeBufferPointer<T>,
        count: Int
    ) {
        switch T.self {
        case is Float.Type:
            for i in 0..<count {
                dst[i] = T(Darwin.sqrtf(Float(src[i])))
            }
        case is Double.Type:
            for i in 0..<count {
                dst[i] = Darwin.sqrt(src[i])
            }
        default:
            fatalError("Only implemented for FloatingPoint types")
        }
    }
 
}
