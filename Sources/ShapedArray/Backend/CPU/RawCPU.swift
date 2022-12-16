//
//  RawCPU.swift
//  
//
//  Created by Khalid Alotaibi on 11/22/22.
//


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
