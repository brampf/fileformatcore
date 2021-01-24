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

public typealias FixedChar8 = UInt8
public typealias FixedChar16 = UInt16
public typealias FixedChar32 = UInt32
public typealias FixedChar64 = UInt64

@frozen
public struct FixedChar<F: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral> : ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, LosslessStringConvertible {
    
    private var value : F
    private var encoding : String.Encoding = .utf8
    
    private init(_ value: F){
        self.value = value
    }
    
    public init?(_ from: String, encoding: String.Encoding = .utf8){
        if let v = F.init(from, encoding: encoding) {
            self.value = v
            self.encoding = encoding
        } else {
            return nil
        }
    }
    
    public init(integerLiteral value: F) {
        self.init(value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        
        self.value = value.data(using: .utf8)?.withUnsafeBytes({ ptr in
            ptr.load(as: F.self)
        }) ?? 0
    }
    
    public init?(_ description: String) {
        value = F(description, encoding: .utf8) ?? 0
    }
    
    public var description: String {
        value.string(encoding) ?? ""
    }
}

extension FixedChar : FixedWidthInteger {
    
    public static var bitWidth: Int {
        F.bitWidth
    }
    
    public static var max: FixedChar<F> {
        FixedChar(F.max)
    }
    
    public static var min: FixedChar<F> {
        FixedChar(F.min)
    }
    
    public var nonzeroBitCount: Int {
        value.nonzeroBitCount
    }
    
    public var leadingZeroBitCount: Int {
        value.leadingZeroBitCount
    }
    
    public var byteSwapped: FixedChar<F> {
        FixedChar(value.byteSwapped)
    }
    
    public init<T>(_truncatingBits source: T) where T : BinaryInteger {
        value = F(_truncatingBits: UInt(source))
    }
    
    public func addingReportingOverflow(_ rhs: FixedChar<F>) -> (partialValue: FixedChar<F>, overflow: Bool) {
        let ret = value.addingReportingOverflow(rhs.value)
        return (FixedChar(ret.0),ret.1)
    }
    
    public func subtractingReportingOverflow(_ rhs: FixedChar<F>) -> (partialValue: FixedChar<F>, overflow: Bool) {
        let ret = value.subtractingReportingOverflow(rhs.value)
        return (FixedChar(ret.0),ret.1)
    }
    
    public func multipliedReportingOverflow(by rhs: FixedChar<F>) -> (partialValue: FixedChar<F>, overflow: Bool) {
        let ret = value.multipliedReportingOverflow(by: rhs.value)
        return (FixedChar(ret.0),ret.1)
    }
    
    public func dividedReportingOverflow(by rhs: FixedChar<F>) -> (partialValue: FixedChar<F>, overflow: Bool) {
        let ret = value.dividedReportingOverflow(by: rhs.value)
        return (FixedChar(ret.0),ret.1)
    }
    
    public func remainderReportingOverflow(dividingBy rhs: FixedChar<F>) -> (partialValue: FixedChar<F>, overflow: Bool) {
        let ret = value.remainderReportingOverflow(dividingBy: rhs.value)
        return (FixedChar(ret.0),ret.1)
    }
    
    public func dividingFullWidth(_ dividend: (high: FixedChar<F>, low: F.Magnitude)) -> (quotient: FixedChar<F>, remainder: FixedChar<F>) {
        let ret = value.dividingFullWidth((high: dividend.high.value, low: dividend.low))
        return (FixedChar(ret.0), FixedChar(ret.1))
    }
    
}

extension FixedChar : BinaryInteger {
    
    public typealias Words = F.Words
    
    public static var isSigned: Bool {
        F.isSigned
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.value = F(source)
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        self.value = F(source)
    }
    
    public var words: F.Words {
        value.words
    }
    
    public var bitWidth: Int {
        value.bitWidth
    }
    
    public var trailingZeroBitCount: Int {
        value.trailingZeroBitCount
    }
    
    public static func / (lhs: FixedChar<F>, rhs: FixedChar<F>) -> FixedChar<F> {
        FixedChar(lhs.value / rhs.value)
    }
    
    public static func /= (lhs: inout FixedChar<F>, rhs: FixedChar<F>) {
        lhs.value /= rhs.value
    }
    
    public static func % (lhs: FixedChar<F>, rhs: FixedChar<F>) -> FixedChar<F> {
        FixedChar(lhs.value % rhs.value)
    }
    
    public static func %= (lhs: inout FixedChar<F>, rhs: FixedChar<F>) {
        lhs.value %= rhs.value
    }
    
    public static func &= (lhs: inout FixedChar<F>, rhs: FixedChar<F>) {
        lhs.value &= rhs.value
    }
    
    public static func |= (lhs: inout FixedChar<F>, rhs: FixedChar<F>) {
        lhs.value |= rhs.value
    }
    
    public static func ^= (lhs: inout FixedChar<F>, rhs: FixedChar<F>) {
        lhs.value ^= rhs.value
    }
    
}

extension FixedChar : Numeric {
    
    public typealias Magnitude = F.Magnitude
 
    public var magnitude: F.Magnitude {
        value.magnitude
    }
    
    public init?<T>(exactly: T) where T : BinaryInteger {
        if let v = F(exactly: exactly){
            self.value = v
        } else {
            return nil
        }
    }
    
    public init?<T>(exactly: T) where T : BinaryFloatingPoint {
        if let v = F(exactly: exactly){
            self.value = v
        } else {
            return nil
        }
    }
    
    public static func * (lhs: FixedChar<F>, rhs: FixedChar<F>) -> FixedChar<F> {
        FixedChar(lhs.value * rhs.value)
    }
    
    public static func *= (lhs: inout FixedChar<F>, rhs: FixedChar<F>) {
        lhs.value = lhs.value * rhs.value
    }
}

extension FixedChar : AdditiveArithmetic {
    
    public static var zero : FixedChar<F> {
        FixedChar(F.zero)
    }
    
    
    public static func + (lhs: FixedChar<F>, rhs: FixedChar<F>) -> FixedChar<F> {
        FixedChar(lhs.value + rhs.value)
    }
    
    public static func - (lhs: FixedChar<F>, rhs: FixedChar<F>) -> FixedChar<F> {
        FixedChar(lhs.value - rhs.value)
    }
    
}

extension FixedChar : Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

extension FixedChar : Equatable {
    
    public static func == (lhs: FixedChar, rhs: FixedChar) -> Bool {
        lhs.value == rhs.value
    }
    
    public static func == (lhs: F, rhs: FixedChar) -> Bool {
        lhs == rhs.value
    }
    
    public static func == (lhs: FixedChar, rhs: F) -> Bool {
        lhs.value == rhs
    }
    
}


extension FixedWidthInteger {
    
    public init?(_ from: String, encoding: String.Encoding = .utf8){
        
        if let v = from.data(using: encoding)?.withUnsafeBytes({ ptr in
            ptr.load(as: Self.self)
        }){
            self.init(v)
        } else {
            return nil
        }
    }
    
    public func string(_ encoding: String.Encoding = .utf8) -> String? {
        var me = self
        let data = Data(bytes: &me, count: MemoryLayout<Self>.size)
        return String(data: data, encoding: encoding)
    }
}


extension Array where Element : FixedWidthInteger {
    
    public func string(_ encoding: String.Encoding = .utf8) -> String? {
        var me = self
        let data = Data(bytes: &me, count: self.count * MemoryLayout<Element>.size)
        return String(data: data, encoding: encoding)
    }
    
}
