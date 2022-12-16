//
//  Math.swift
//
//  Created by Khalid Alotaibi on 11/23/22.
//

import Numerics


extension ShapedArray where Scalar: Real {
    
    public static func sqrt(_ x: Self) -> Self {
        CPU.sqrt(x)
    }
    
}

