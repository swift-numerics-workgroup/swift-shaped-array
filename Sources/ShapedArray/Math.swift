// MARK: - Numeric Reductions

extension ShapedArray where Scalar: Numeric {
    @inlinable
    func op(_ op: (_ lhs: Scalar, _ rhs: Scalar) -> Scalar, identity: Scalar, reductionAxes axes: [Int], keepDims: Bool = false) -> ShapedArray {
        let axes = axes.map { $0 < 0 ? $0 + self.rank : $0 }
        self.ensureValid(axes: axes)
        let axesSet: Set<Int> = Set(axes)
        let reductionAxesAndShape = self.shape.enumerated().filter { axesSet.contains($0.0) }
        let remainingAxesAndShape = self.shape.enumerated().filter { !axesSet.contains($0.0) }
        if reductionAxesAndShape.count == 0 || remainingAxesAndShape.count == 0 {
            if keepDims {
                return ShapedArray(shape: [1], scalars: [self.scalars.reduce(identity, op)])
            }
            else {
                return ShapedArray(self.scalars.reduce(identity, op))
            }
        }

        let newShape = remainingAxesAndShape.map { $0.1 }
        let totalScalars = newShape.reduce(1, *)
        // Iterate positions of remaining dimension.
        // Iterate positions of old dimensions.
        // sum over old dimensions given a position in remaining dimensions.
        let newScalars = Array<Scalar>(unsafeUninitializedCapacity: totalScalars) { buffer, initializedCount in
            // Initialize buffer with indentity element since we're going to perform ops.
            for i in 0..<totalScalars { buffer[i] = identity }

            // TODO: Should use arithmetic or for-loops over remaining&reduction rather than set.
            let remainingAxes = Set(remainingAxesAndShape.map { $0.0 })
            let remainingAxesSkipLength = ShapedArray.stride(forShape: remainingAxesAndShape.map { $0.1 })

            // Keep track of positions in the shaped array. Like shaped array
            // these iters keep track of higher dimensions first.
            var oldAxesIterators = [Int](repeating: 0, count: self.shape.count)
            for (i, scalar) in self.scalars.enumerated() {
                // This converts the position of the scalar represented by `oldAxesIterators`
                // to the position it will be summed into the new buffer.
                // E.g. if `self` is rank 4 and we have iterated [0, 3, 2, 4] and we're reducing
                // axis [1, 3] then we should get [0, 2] `newPosition`, yet converted to an array
                // index because our data is stored in an array.
                let newPosition = oldAxesIterators.enumerated().reduce((0, 0), {
                    let (newDimensionsIter, newPosition) = $0
                    let (oldAxis, oldAxisIter) = $1
                    // The only axis we want to include in our new array are the remaining
                    // ones.
                    guard remainingAxes.contains(oldAxis) else {
                        return (newDimensionsIter, newPosition)
                    }

                    let updatedNewPosition = newPosition + oldAxisIter * remainingAxesSkipLength[newDimensionsIter]
                    return (newDimensionsIter + 1, updatedNewPosition)
                })
                .1

                buffer[newPosition] = op(scalar, buffer[newPosition])

                if i < self.scalars.count - 1 {
                    // Bump our iterator over our old shaped array, don't go over an
                    // axis shape/size.
                    // Highest dimension is first so need to start accordingly.
                    var bumpAxisIter = self.shape.count - 1
                    while oldAxesIterators[bumpAxisIter] + 1 >= self.shape[bumpAxisIter] {
                        oldAxesIterators[bumpAxisIter] = 0
                        bumpAxisIter -= 1
                    }
                    oldAxesIterators[bumpAxisIter] += 1
                }
            }
            initializedCount = totalScalars
        }
        
        let finalShape = keepDims ? {
            var newShape = self.shape
            for (axis, _) in reductionAxesAndShape {
                newShape[axis] = 1
            }
            return newShape
        }() : newShape
        return ShapedArray(shape: finalShape, scalars: newScalars)
    }

    // MARK: - Sum

    /// Returns the sum along the specified axes. The reduced dimensions are removed.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    public func sum(squeezingAxes axes: ShapedArray<Int32>) -> ShapedArray {
        self.sum(squeezingAxes: axes.scalars.map { Int($0) })
    }

    /// Returns the sum along the specified axes. The reduced dimensions are removed.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    public func sum(squeezingAxes axes: [Int]) -> ShapedArray {
        self.op(+, identity: 0, reductionAxes: axes)
    }

    /// Returns the sum along the specified axes. The reduced dimensions are removed.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    public func sum(squeezingAxes axes: Int...) -> ShapedArray {
        self.sum(squeezingAxes: axes)
    }

    @inlinable
    public func sum() -> ShapedArray {
        self.flattened().sum(squeezingAxes: 0)
    }

    /// Returns the sum along the specified axes. The reduced dimensions are retained with value 1.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank..<rank`.
    @inlinable
    public func sum(alongAxes axes: ShapedArray<Int32>) -> ShapedArray {
        self.sum(alongAxes: axes.scalars.map { Int($0) })
    }

    /// Returns the sum along the specified axes. The reduced dimensions are retained with value 1.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank..<rank`.
    @inlinable
    public func sum(alongAxes axes: [Int]) -> ShapedArray {
        self.op(+, identity: 0, reductionAxes: axes, keepDims: true)
    }

    /// Returns the sum along the specified axes. The reduced dimensions are retained with value 1.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank..<rank`.
    @inlinable
    public func sum(alongAxes axes: Int...) -> ShapedArray {
        self.sum(alongAxes: axes)
    }

    // MARK: - Product

    /// Returns the product along the specified axes. The reduced dimensions are removed.
    ///
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    public func product(squeezingAxes axes: ShapedArray<Int32>) -> ShapedArray {
        self.product(squeezingAxes: axes.scalars.map { Int($0) })
    }

    /// Returns the product along the specified axes. The reduced dimensions are removed.
    ///
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    public func product(squeezingAxes axes: [Int]) -> ShapedArray {
        self.op(*, identity: 1, reductionAxes: axes)
    }

    /// Returns the product along the specified axes. The reduced dimensions are removed.
    ///
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    public func product(squeezingAxes axes: Int...) -> ShapedArray {
        self.product(squeezingAxes: axes)
    }

    @inlinable
    public func product() -> ShapedArray {
        self.flattened().product(squeezingAxes: 0)
    }

    /// Returns the product along the specified axes. The reduced dimensions are retained with
    /// value 1.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank..<rank`.
    @inlinable
    public func product(alongAxes axes: ShapedArray<Int32>) -> ShapedArray {
        self.product(alongAxes: axes.scalars.map { Int($0) })
    }

    /// Returns the product along the specified axes. The reduced dimensions are retained with
    /// value 1.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank..<rank`.
    @inlinable
    public func product(alongAxes axes: [Int]) -> ShapedArray {
        self.op(*, identity: 1, reductionAxes: axes, keepDims: true)
    }

    /// Returns the product along the specified axes. The reduced dimensions are retained with
    /// value 1.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank..<rank`.
    @inlinable
    public func product(alongAxes axes: Int...) -> ShapedArray {
        self.product(alongAxes: axes)
    }
}

// Would be nice if we could operate over all `Numerics`, but `Numeric / Int`
// has no natural overload:
// "binary operator '/' cannot be applied to operands of type 'Scalar' and 'Int'"
// Possible way to fix would be to convert `Numeric` to `BinaryFloatingPoint`
// at the end:
// `https://forums.swift.org/t/convert-numeric-to-binaryfloatingpoint/63368`
extension ShapedArray where Scalar: BinaryFloatingPoint {
    // MARK: - Mean

    /// Returns the arithmetic mean along the specified axes. The reduced dimensions are removed.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    public func mean(squeezingAxes axes: ShapedArray<Int32>) -> ShapedArray {
        self.mean(squeezingAxes: axes.scalars.map { Int($0) })
    }

    /// Returns the arithmetic mean along the specified axes. The reduced dimensions are removed.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    func mean(reductionAxes axes: [Int], keepDims: Bool = false) -> ShapedArray {
        let sum = keepDims ? self.sum(alongAxes: axes) : self.sum(squeezingAxes: axes)
        let axes = Set(axes.map { $0 < 0 ? $0 + self.rank : $0 })
        let numberDimensionsSqueezed = self.shape.enumerated().reduce(1) { acc, shapeIter in
            let (i, size) = shapeIter
            guard axes.contains(i) else { return acc }
            return acc * size
        }
        // TODO: Once we have `/` just use that operator.
        return ShapedArray(shape: sum.shape, scalars: sum.scalars.map { $0 / Scalar(numberDimensionsSqueezed) })
    }

    /// Returns the arithmetic mean along the specified axes. The reduced dimensions are removed.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    public func mean(squeezingAxes axes: [Int]) -> ShapedArray {
        self.mean(reductionAxes: axes, keepDims: false)
    }

    /// Returns the arithmetic mean along the specified axes. The reduced dimensions are removed.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank...rank`.
    @inlinable
    public func mean(squeezingAxes axes: Int...) -> ShapedArray {
        self.mean(squeezingAxes: axes)
    }

    @inlinable
    public func mean() -> ShapedArray {
        self.flattened().mean(squeezingAxes: [0])
    }

    /// Returns the arithmetic mean along the specified axes. The reduced dimensions are retained
    /// with value 1.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank..<rank`.
    @inlinable
    public func mean(alongAxes axes: ShapedArray<Int32>) -> ShapedArray {
        self.mean(alongAxes: axes.scalars.map { Int($0) })
    }

    /// Returns the arithmetic mean along the specified axes. The reduced dimensions are retained
    /// with value 1.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank..<rank`.
    @inlinable
    public func mean(alongAxes axes: [Int]) -> ShapedArray {
        self.mean(reductionAxes: axes, keepDims: true)
    }

    /// Returns the arithmetic mean along the specified axes. The reduced dimensions are retained
    /// with value 1.
    /// - Parameter axes: The dimensions to reduce.
    /// - Precondition: Each value in `axes` must be in the range `-rank..<rank`.
    @inlinable
    public func mean(alongAxes axes: Int...) -> ShapedArray {
        self.mean(alongAxes: axes)
    }
}
