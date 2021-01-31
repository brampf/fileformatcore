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

extension FixedWidthInteger  {
    
    /// Read `FixedWidthInteger`
    public static func new(_ bytes: UnsafeRawBufferPointer, with context: inout Context, _ name: String?) throws -> Self? {
        
        //print("[\(String(describing: context.offset).padding(toLength: 8, withPad: " ", startingAt: 0))] READ \(name ?? "") : \(type(of: self))")
        
        return try bytes.read(&context.offset, byteSwapped: context.bigEndian, name)
    }
    
    public var byteSize: Int {
        MemoryLayout<Self>.size
    }
}

extension Int64 : ReadableValue {
    
}

extension Int32 : ReadableValue {
    
}

extension Int16 : ReadableValue {
    
}

extension Int8 : ReadableValue {
    
}

extension UInt64 : ReadableValue {
    
}

extension UInt32 : ReadableValue {
    
}

extension UInt16 : ReadableValue {
    
}

extension UInt8 : ReadableValue {
    
}