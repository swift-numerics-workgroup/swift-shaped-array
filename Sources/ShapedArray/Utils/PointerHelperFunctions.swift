//
//  PointerHelperFunctions.swift
//  
//
//  Created by Khalid Alotaibi on 11/27/22.
//


//Mark:- PointerHelperFunctions
func helperToPointer<T: ShapedArrayScalar>(
    src: ShapedArray<T>
) -> UnsafePointer<T>
{
    src.withUnsafeBufferPointer { (tempSrc: UnsafeBufferPointer<T>) in
        tempSrc.withMemoryRebound(to: T.self) { tempSrc in
            return UnsafePointer<T>(tempSrc.baseAddress!) //tempSrc.baseAddress!
        }
    }
}

func helperToMutatingPointer<T: ShapedArrayScalar>(
    dst: inout ShapedArray<T>
) -> UnsafeMutablePointer<T>
{
    dst.withUnsafeBufferPointer { (tempDst: UnsafeBufferPointer<T>) in
        tempDst.withMemoryRebound(to: T.self) { tempDst in
            return UnsafeMutablePointer<T>(mutating: tempDst.baseAddress!)
        }
    }
}
