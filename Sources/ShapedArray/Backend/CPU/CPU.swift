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
        
        switch T.self {
        case is Float.Type:
            var ret = ShapedArray<T>(repeating: 0.0, shape: x.shape)
            var ptrToSrc: UnsafePointer<Float> = helperToPointer(src: x)
            var ptrToDst: UnsafeMutablePointer<Float> = helperToMutatingPointer(dst: &ret)
            
            #if canImport(Accelerate)
            vvsqrtf(ptrToDst, ptrToSrc, [Int32(x.count)])
            #else
            _RawCPU.sqrtFloat(to: ptrToDst, from: ptrToSrc, count: x.count)
            #endif
            
            return ret
        case is Double.Type:
            var ret = ShapedArray<T>(repeating: 0.0, shape: x.shape)
            var ptrToSrc: UnsafePointer<Double> = helperToPointer(src: x)
            var ptrToDst: UnsafeMutablePointer<Double> = helperToMutatingPointer(dst: &ret)
            
            #if canImport(Accelerate)
            vvsqrt(ptrToDst, ptrToSrc, [Int32(x.count)])
            #else
            _RawCPU.sqrtDouble(to: ptrToDst, from: ptrToSrc, count: x.count)
            #endif
            
            return ret
        default:
            fatalError("Not Defined for types other than Float and Double")
        }
    }
    
    @differentiable(reverse)
    static func cos<T: ShapedArrayFloatingPoint>(_ x: ShapedArray<T>) -> ShapedArray<T> {
        switch T.self {
        case is Float.Type:
            var ret = ShapedArray<T>(repeating: 0.0, shape: x.shape)
            var ptrToSrc: UnsafePointer<Float> = helperToPointer(src: x)
            var ptrToDst: UnsafeMutablePointer<Float> = helperToMutatingPointer(dst: &ret)
            
            #if canImport(Accelerate)
            vvcosf(ptrToDst, ptrToSrc, [Int32(x.count)])
            #else
            _RawCPU.cosFloat(to: ptrToDst, from: ptrToSrc, count: x.count)
            #endif
            
            return ret
        case is Double.Type:
            var ret = ShapedArray<T>(repeating: 0.0, shape: x.shape)
            var ptrToSrc: UnsafePointer<Double> = helperToPointer(src: x)
            var ptrToDst: UnsafeMutablePointer<Double> = helperToMutatingPointer(dst: &ret)
            
            #if canImport(Accelerate)
            vvcos(ptrToDst, ptrToSrc, [Int32(x.count)])
            #else
            _RawCPU.cosDouble(to: ptrToDst, from: ptrToSrc, count: x.count)
            #endif
            
            return ret
        default:
            fatalError("Not Defined for types other than Float and Double")
        }
    }
    
    static func add<T: Numeric & ShapedArrayFloatingPoint>(_ lhs: ShapedArray<T>, _ rhs: ShapedArray<T>) -> ShapedArray<T> {
        switch T.self {
        case is Float.Type:
            precondition(lhs.count == rhs.count, "Seems src and dst are different")
            var ret = ShapedArray<T>(repeating: 0.0, shape: lhs.shape)
            var lhsPtr: UnsafePointer<Float> = helperToPointer(src: lhs)
            var rhsPtr: UnsafePointer<Float> = helperToPointer(src: rhs)
            var ptrToDst: UnsafeMutablePointer<Float> = helperToMutatingPointer(dst: &ret)
            
            #if canImport(Accelerate)
            vDSP_vadd(lhsPtr, 1, rhsPtr, 1, ptrToDst, 1, UInt(ret.count))
            #else
            _RawCPU.addFloatVec(lhs: lhsPtr, rhs: rhsPtr, to: ptrToDst, count: ptrToDst.count)
            #endif
    
            return ret
        case is Double.Type:
            precondition(lhs.count == rhs.count, "Seems src and dst are different")
            var ret = ShapedArray<T>(repeating: 0.0, shape: lhs.shape)
            var lhsPtr: UnsafePointer<Double> = helperToPointer(src: lhs)
            var rhsPtr: UnsafePointer<Double> = helperToPointer(src: rhs)
            var ptrToDst: UnsafeMutablePointer<Double> = helperToMutatingPointer(dst: &ret)
            
            #if canImport(Accelerate)
            vDSP_vaddD(lhsPtr, 1, rhsPtr, 1, ptrToDst, 1, UInt(ret.count))
            #else
            _RawCPU.addDoubleVec(lhs: lhsPtr, rhs: rhsPtr, to: ptrToDst, count: ptrToDst.count)
            #endif
            
            return ret
        case is Int32.Type:
            precondition(lhs.count == rhs.count, "Seems src and dst are different")
            var ret = ShapedArray<T>(repeating: 0, shape: lhs.shape)
            var lhsPtr: UnsafePointer<Int32> = helperToPointer(src: lhs)
            var rhsPtr: UnsafePointer<Int32> = helperToPointer(src: rhs)
            var ptrToDst: UnsafeMutablePointer<Int32> = helperToMutatingPointer(dst: &ret)
            
            
            #if canImport(Accelerate)
            vDSP_vaddi(lhsPtr, 1, rhsPtr, 1, ptrToDst, 1, UInt(lhs.count))
            #else
            _RawCPU.addInt32Vec(lhs: lhsPtr, rhs: rhsPtr, to: ptrToDst, count: ret.count)
            #endif
            
            return ret
        default:
            fatalError("Not Defined for types other than Float, Double, and Int32")
        }
    }
}
