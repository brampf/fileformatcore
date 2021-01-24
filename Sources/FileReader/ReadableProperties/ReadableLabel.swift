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
import DataTypes

@propertyWrapper public final class ReadableLabel<F: FixedWidthInteger & _ExpressibleByBuiltinIntegerLiteral> : LosslessStringConvertible , ExpressibleByIntegerLiteral {
    
    public var encoding : String.Encoding = .utf8
    
    public var wrappedValue : String {
        get {
            trueValue?.string(encoding) ?? ""
        }
        set {
            trueValue = F(newValue.padding(toLength: 4, withPad: " ", startingAt: 0), encoding: encoding)
        }
    }
    
    private var trueValue : F? = nil

    
    public init(){
        //
    }
    
    public init(wrappedValue initialValue : String) {
        trueValue = F.init(initialValue, encoding: .utf8)
    }
    
    
    public init?(_ description: String) {
        
        if let v = F(description, encoding: .utf8){
            trueValue = v
        } else {
            return nil
        }
    }
    
    public init(integerLiteral value: F) {
        self.trueValue = value
    }
    

    public var description: String {
        trueValue?.string(encoding) ?? ""
    }
    
    public var debugDescription: String {
        String(describing: wrappedValue)
    }
}

extension ReadableLabel : ReadableProperty {
    
    public func read(_ data: UnsafeRawBufferPointer, context: inout Context, _ symbol: String?) throws {
        
        trueValue = try data.read(&context.offset, byteSwapped: false, symbol)
    }
 
    public var byteSize: Int {
        return MemoryLayout<F>.size
    }
}
