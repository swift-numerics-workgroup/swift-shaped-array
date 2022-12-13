//
//  PointerHelperFunctions.swift
//  
//
//  Created by Khalid Alotaibi on 11/27/22.
//


//Mark:- PointerHelperFunctions
func helperToPointer<T: ShapedArrayScalar>(
    src: ShapedArray<T>
) -> UnsafeBufferPointer<T>
{
    src.withUnsafeBufferPointer { tempSrc in
        return tempSrc
    }
}

func helperToMutatingPointer<T: ShapedArrayScalar>(
    dst: inout ShapedArray<T>
) -> UnsafeMutableBufferPointer<T>
{
    dst.withUnsafeMutableBufferPointer { tempDst in
        return tempDst
    }
}
