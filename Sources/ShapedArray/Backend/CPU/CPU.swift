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
            var ptrToSrc = helperToPointer(src: x) as! UnsafePointer<Float>
            var ptrToDst = helperToMutatingPointer(dst: &ret) as! UnsafeMutablePointer<Float>
            
            #if canImport(Accelerate)
            vvsqrtf(ptrToDst, ptrToSrc, [Int32(x.count)])
            #else
            _RawCPU.sqrtFloat(to: ptrToDst, from: ptrToSrc, count: x.count)
            #endif
            
            return ret
        case is Double.Type:
            var ret = ShapedArray<T>(repeating: 0.0, shape: x.shape)
            var ptrToSrc = helperToPointer(src: x) as! UnsafePointer<Double>
            var ptrToDst = helperToMutatingPointer(dst: &ret) as! UnsafeMutablePointer<Double>
            
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
            var ptrToSrc = helperToPointer(src: x) as! UnsafePointer<Float>
            var ptrToDst = helperToMutatingPointer(dst: &ret) as! UnsafeMutablePointer<Float>
            
            #if canImport(Accelerate)
            vvcosf(ptrToDst, ptrToSrc, [Int32(x.count)])
            #else
            _RawCPU.cosFloat(to: ptrToDst, from: ptrToSrc, count: x.count)
            #endif
            
            return ret
        case is Double.Type:
            var ret = ShapedArray<T>(repeating: 0.0, shape: x.shape)
            var ptrToSrc = helperToPointer(src: x) as! UnsafePointer<Double>
            var ptrToDst = helperToMutatingPointer(dst: &ret) as! UnsafeMutablePointer<Double>
            
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
    
    static func add<T: ShapedArrayScalar>(_ lhs: ShapedArray<T>, _ rhs: ShapedArray<T>) -> ShapedArray<T> {
        switch T.self {
        case is Float.Type:
            precondition(lhs.count == rhs.count, "Seems src and dst are different")
            var ret = ShapedArray<T>(repeating: 0.0 as! T, shape: lhs.shape)
            var lhsPtr: UnsafePointer<Float> = helperToPointer(src: lhs) as! UnsafePointer<Float>
            var rhsPtr: UnsafePointer<Float> = helperToPointer(src: rhs) as! UnsafePointer<Float>
            var ptrToDst: UnsafeMutablePointer<Float> = helperToMutatingPointer(dst: &ret) as! UnsafeMutablePointer<Float>
            
            #if canImport(Accelerate)
            vDSP_vadd(lhsPtr, 1, rhsPtr, 1, ptrToDst, 1, UInt(ret.count))
            #else
            _RawCPU.addFloatVec(lhs: lhsPtr, rhs: rhsPtr, to: ptrToDst, count: ptrToDst.count)
            #endif
    
            return ret
        case is Double.Type:
            precondition(lhs.count == rhs.count, "Seems src and dst are different")
            var ret = ShapedArray<T>(repeating: 0.0 as! T, shape: lhs.shape)
            var lhsPtr: UnsafePointer<Double> = helperToPointer(src: lhs) as! UnsafePointer<Double>
            var rhsPtr: UnsafePointer<Double> = helperToPointer(src: rhs) as! UnsafePointer<Double>
            var ptrToDst: UnsafeMutablePointer<Double> = helperToMutatingPointer(dst: &ret) as! UnsafeMutablePointer<Double>
            
            #if canImport(Accelerate)
            vDSP_vaddD(lhsPtr, 1, rhsPtr, 1, ptrToDst, 1, UInt(ret.count))
            #else
            _RawCPU.addDoubleVec(lhs: lhsPtr, rhs: rhsPtr, to: ptrToDst, count: ptrToDst.count)
            #endif
            
            return ret
        case is Int32.Type:
            precondition(lhs.count == rhs.count, "Seems src and dst are different")
            var ret = ShapedArray<T>(repeating: 0 as! T, shape: lhs.shape)
            var lhsPtr: UnsafePointer<Int32> = helperToPointer(src: lhs) as! UnsafePointer<Int32>
            var rhsPtr: UnsafePointer<Int32> = helperToPointer(src: rhs) as! UnsafePointer<Int32>
            var ptrToDst: UnsafeMutablePointer<Int32> = helperToMutatingPointer(dst: &ret) as! UnsafeMutablePointer<Int32>
            
            
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
