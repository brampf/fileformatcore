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

extension FixedWidthInteger where Self : AnyReadable {
    
    /// Always initiliazes as Zero
    public static func new<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?) throws -> Self? {
        return .zero
    }
    
    /// Always offset + byteSize
    public static func upperBound<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C) throws -> Int?{
        return context.offset + MemoryLayout<Self>.size
    }
    
    /// Read `FixedWidthInteger`
    public mutating func read<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?, upperBound: Int?) throws {
        
        //print("[\(String(describing: context.offset).padding(toLength: 8, withPad: " ", startingAt: 0))] READ \(name ?? "") : \(type(of: self))")
        
        self = try bytes.read(&context.offset, byteSwapped: context.bigEndian, symbol)
    }
    
    public var byteSize: Int {
        MemoryLayout<Self>.size
    }
    
    public var debugLayout : String {
        self.debugLayout
    }
}

extension Int64 : AnyReadable {
    
}

extension Int32 : AnyReadable {
    
}

extension Int16 : AnyReadable {
    
}

extension Int8 : AnyReadable {
    
}

extension UInt64 : AnyReadable {
    
}

extension UInt32 : AnyReadable {
    
}

extension UInt16 : AnyReadable {
    
}

extension UInt8 : AnyReadable {
    
}
