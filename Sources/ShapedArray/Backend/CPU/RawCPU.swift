//
//  RawCPU.swift
//  
//
//  Created by Khalid Alotaibi on 11/22/22.
//

import Foundation


final class _RawCPU {
    
    static func sqrtFloat(
        to dst: UnsafeMutableBufferPointer<Float>,
        from src: UnsafeBufferPointer<Float>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = sqrtf(src[i])
        }
    }
    
    static func sqrtDouble(
        to dst: UnsafeMutableBufferPointer<Double>,
        from src: UnsafeBufferPointer<Double>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = sqrt(src[i])
        }
    }
    
    static func cosFloat(
        to dst: UnsafeMutableBufferPointer<Double>,
        from src: UnsafeBufferPointer<Double>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = cos(src[i])
        }
    }
    
    static func cosDouble(
        to dst: UnsafeMutableBufferPointer<Double>,
        from src: UnsafeBufferPointer<Double>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = cos(src[i])
        }
    }
    
    static func addFloatVec(
        lhs: UnsafeBufferPointer<Float>,
        rhs: UnsafeBufferPointer<Float>,
        to dst: UnsafeMutableBufferPointer<Float>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = lhs[i] + rhs[i]
        }
    }
    
    static func addDoubleVec(
        lhs: UnsafeBufferPointer<Double>,
        rhs: UnsafeBufferPointer<Double>,
        to dst: UnsafeMutableBufferPointer<Double>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = lhs[i] + rhs[i]
        }
    }
    
    static func addInt32Vec(
        lhs: UnsafeBufferPointer<Int32>,
        rhs: UnsafeBufferPointer<Int32>,
        to dst: UnsafeMutableBufferPointer<Int32>,
        count: Int
    ) {
        for i in 0..<count {
            dst[i] = lhs[i] + rhs[i]
        }
    }
}
