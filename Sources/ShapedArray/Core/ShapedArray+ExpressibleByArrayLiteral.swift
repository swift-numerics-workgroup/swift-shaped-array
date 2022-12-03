// Copyright 2021 The TensorFlow Authors. All Rights Reserved.
// Modified 2022 The Swift Numerics Workgroup.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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

