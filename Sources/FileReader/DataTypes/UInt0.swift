/*
 
 Copyright (c) <2021>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import Foundation

@frozen public struct UInt0 {
    
}

extension UInt0 : UnsignedInteger {
    
    
}

extension UInt0 : FixedWidthInteger {
    
    
    public var byteSwapped: UInt0 {
        return .zero
    }
    
    public var leadingZeroBitCount: Int {
        return .zero
    }
    
    public var nonzeroBitCount: Int {
        return .zero
    }
    
    public static var max: UInt0 {
        return .zero
    }
    
    public static var min: UInt0 {
        return .zero
    }
    
    public static var bitWidth: Int {
        return .zero
    }
    
    public init<T>(_truncatingBits source: T) where T : BinaryInteger {
        // zero
    }
    
    public func addingReportingOverflow(_ rhs: UInt0) -> (partialValue: UInt0, overflow: Bool) {
        return (.zero,false)
    }
    
    public func subtractingReportingOverflow(_ rhs: UInt0) -> (partialValue: UInt0, overflow: Bool) {
        return (.zero,false)
    }
    
    public func multipliedReportingOverflow(by rhs: UInt0) -> (partialValue: UInt0, overflow: Bool) {
        return (.zero,false)
    }
    
    public func dividedReportingOverflow(by rhs: UInt0) -> (partialValue: UInt0, overflow: Bool) {
        return (.zero,false)
    }
    
    public func remainderReportingOverflow(dividingBy rhs: UInt0) -> (partialValue: UInt0, overflow: Bool) {
        return (.zero,false)
    }
    
    public func dividingFullWidth(_ dividend: (high: UInt0, low: UInt)) -> (quotient: UInt0, remainder: UInt0) {
        return (.zero,.zero)
    }
}

extension UInt0 : BinaryInteger {
    
    public typealias Words = [UInt]
    
    public var words: [UInt] {
        return []
    }
    
    public var bitWidth: Int {
        return .zero
    }
    
    public var trailingZeroBitCount: Int {
        return .zero
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        // zero
    }
    
    public static var isSigned: Bool {
        return false
    }
    
    public static func / (lhs: UInt0, rhs: UInt0) -> UInt0 {
        return 0
    }
    
    public static func /= (lhs: inout UInt0, rhs: UInt0) {
        // still zero
    }
    
    public static func % (lhs: UInt0, rhs: UInt0) -> UInt0 {
        return 0
    }
    
    public static func %= (lhs: inout UInt0, rhs: UInt0) {
        // still zero
    }
    
    public static func &= (lhs: inout UInt0, rhs: UInt0) {
        // still zero
    }
    
    public static func |= (lhs: inout UInt0, rhs: UInt0) {
        // still zero
    }
    
    public static func ^= (lhs: inout UInt0, rhs: UInt0) {
        // still zero
    }
    
}

extension UInt0 : Numeric {
    
    public typealias Magnitude = UInt

    public var magnitude: UInt {
        return .zero
    }

    public init?<T>(exactly: T){
        // zero
        self.init()
    }

    public static func *  (lhs: UInt0, rhs: UInt0) -> UInt0 {
        return 0
    }
    
    public static func *= (lhs: inout UInt0, rhs: UInt0) {
        // still zero
    }
    
}

extension UInt0 : ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = UInt
    
    public init(integerLiteral value: UInt) {
        // zero
    }
    
}

extension UInt0 : AdditiveArithmetic {
    
    public static var zero: UInt0 = 0
    
    
    public static func + (lhs: UInt0, rhs: UInt0) -> UInt0 {
        return .zero
    }
    
    public static func - (lhs: UInt0, rhs: UInt0) -> UInt0 {
        return .zero
    }
    
    
}

extension UInt0 : Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
    
}

extension UInt0 : Equatable {
    
    public static func == (lhs: UInt0, rhs: UInt0) -> Bool {
        return true
    }
    
}

extension UInt0 : Codable {
    
    
    
}
