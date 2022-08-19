//
//  BasicOperations.swift
//  
//
//  Created by Jaap Wijnen on 10/08/2022.
//

extension ShapedArray {
    internal static func pack(_ values: [ShapedArray], axis: Int = 0) -> ShapedArray {

        precondition(!values.isEmpty, "Cannot pack empty array of ShapedArrays.")
        let shape = values.first!.shape
        precondition(axis >= 0 && axis <= shape.count, "axis = \(axis) is not within [0, \(shape.count)]")
        assert(!values.map { $0.shape }.contains { $0 != shape }, "Shapes of all inputs must match: \(shape).")
        let scalarCount = values.first!.scalarCount
        let totalScalars = scalarCount * values.count
        
        let rowLengthForAxis = shape[axis..<shape.count].reduce(1, *)
        let combinedRowLength = rowLengthForAxis * values.count
        
        let elements = Array<Scalar>(unsafeUninitializedCapacity: totalScalars) { buffer, initializedCount in
            for (i, value) in values.enumerated() {
                for j in 0..<scalarCount {
                    let mod = j % rowLengthForAxis
                    let finishedRows = j / rowLengthForAxis
                    let offset = i * rowLengthForAxis
                    let newIndex = mod + offset + finishedRows * combinedRowLength
                    
                    buffer[newIndex] = value.scalars[j]
                }
            }
            initializedCount = totalScalars
        }
        
        var newShape = shape
        newShape.insert(values.count, at: axis)
        
        return ShapedArray(shape: newShape, scalars: elements)
    }
}
