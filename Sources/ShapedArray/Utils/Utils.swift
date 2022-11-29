//
//  utils.swift
//  
//
//  Created by Khalid Alotaibi on 11/27/22.
//


//Mark:- HelperFunctions
func helperToPointer<T: ShapedArrayFloatingPoint>(
    src: ShapedArray<T>
) -> UnsafePointer<Float>
{
    
    src.withUnsafeBufferPointer { (tempSrc: UnsafeBufferPointer<T>) in
        tempSrc.withMemoryRebound(to: Float.self) { tempSrc in
            return tempSrc.baseAddress!
        }
    }
}

func helperToMutatingPointer<T: ShapedArrayFloatingPoint>(
    dst: inout ShapedArray<T>
) -> UnsafeMutablePointer<Float>
{
    dst.withUnsafeBufferPointer { (tempDst: UnsafeBufferPointer<T>) in
        tempDst.withMemoryRebound(to: Float.self) { tempDst in
            return UnsafeMutablePointer<Float>(mutating: tempDst.baseAddress!)
        }
    }
}

func helperToPointer<T: ShapedArrayFloatingPoint>(
    src: ShapedArray<T>
) -> UnsafePointer<Double>
{
    
    src.withUnsafeBufferPointer { (tempSrc: UnsafeBufferPointer<T>) in
        tempSrc.withMemoryRebound(to: Double.self) { tempSrc in
            return tempSrc.baseAddress!
        }
    }
}

func helperToMutatingPointer<T: ShapedArrayFloatingPoint>(
    dst: inout ShapedArray<T>
) -> UnsafeMutablePointer<Double>
{
    dst.withUnsafeBufferPointer { (tempDst: UnsafeBufferPointer<T>) in
        tempDst.withMemoryRebound(to: Double.self) { tempDst in
            return UnsafeMutablePointer<Double>(mutating: tempDst.baseAddress!)
        }
    }
}

func helperToPointer<T: Numeric>(
    src: ShapedArray<T>
) -> UnsafePointer<Int32>
{
    
    src.withUnsafeBufferPointer { (tempSrc: UnsafeBufferPointer<T>) in
        tempSrc.withMemoryRebound(to: Int32.self) { tempSrc in
            return tempSrc.baseAddress!
        }
    }
}

func helperToMutatingPointer<T: Numeric>(
    dst: inout ShapedArray<T>
) -> UnsafeMutablePointer<Int32>
{
    dst.withUnsafeBufferPointer { (tempDst: UnsafeBufferPointer<T>) in
        tempDst.withMemoryRebound(to: Int32.self) { tempDst in
            return UnsafeMutablePointer<Int32>(mutating: tempDst.baseAddress!)
        }
    }
}
