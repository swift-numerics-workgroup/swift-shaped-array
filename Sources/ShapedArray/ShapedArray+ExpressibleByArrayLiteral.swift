//
//  ShapedArray+ExpressibleByArrayLiteral.swift
//  
//
//  Created by Jaap Wijnen on 10/08/2022.
//

public struct _ShapedArrayElementLiteral<Scalar> {
    let shapedArray: ShapedArray<Scalar>
}

extension _ShapedArrayElementLiteral: ExpressibleByBooleanLiteral where Scalar: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Scalar.BooleanLiteralType) {
        shapedArray = ShapedArray(Scalar(booleanLiteral: value))
    }
}

extension _ShapedArrayElementLiteral: ExpressibleByIntegerLiteral where Scalar: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Scalar.IntegerLiteralType) {
        shapedArray = ShapedArray(Scalar(integerLiteral: value))
    }
}

extension _ShapedArrayElementLiteral: ExpressibleByFloatLiteral where Scalar: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Scalar.FloatLiteralType) {
        shapedArray = ShapedArray(Scalar(floatLiteral: value))
    }
}

extension _ShapedArrayElementLiteral: ExpressibleByUnicodeScalarLiteral where Scalar: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: Scalar.UnicodeScalarLiteralType) {
        shapedArray = ShapedArray(Scalar(unicodeScalarLiteral: value))
    }
}

extension _ShapedArrayElementLiteral: ExpressibleByExtendedGraphemeClusterLiteral where Scalar: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: Scalar.ExtendedGraphemeClusterLiteralType) {
        shapedArray = ShapedArray(Scalar(extendedGraphemeClusterLiteral: value))
    }
}

extension _ShapedArrayElementLiteral: ExpressibleByStringLiteral where Scalar: ExpressibleByStringLiteral {
    public init(stringLiteral value: Scalar.StringLiteralType) {
        shapedArray = ShapedArray(Scalar(stringLiteral: value))
    }
}

extension _ShapedArrayElementLiteral: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: _ShapedArrayElementLiteral<Scalar>...) {
        self.shapedArray = .init(stacking: elements.map { $0.shapedArray })
    }
}

extension ShapedArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: _ShapedArrayElementLiteral<Scalar>...) {
        precondition(!elements.isEmpty, "Cannot create a 'ShapedArray' with no elements.")
        self = .init(stacking: elements.map { $0.shapedArray })
    }
}

