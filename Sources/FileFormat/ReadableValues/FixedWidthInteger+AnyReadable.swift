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

extension FixedWidthInteger where Self : AutoReadable {
    
    public static func new<C>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String?) throws -> Self? where C : Context {
        Self()
    }
    
    /// Always initiliazes as Zero
    public init() {
        self = .zero
    }
    
    /// Read `FixedWidthInteger`
    public mutating func read(_ bytes: UnsafeRawBufferPointer, with reader: FileReader, _ symbol: String?) throws {
        
        //print("[\(String(describing: context.offset).padding(toLength: 8, withPad: " ", startingAt: 0))] READ \(name ?? "") : \(type(of: self))")
        
        self = try bytes.read(&reader.offset, byteSwapped: reader.bigEndian, symbol)
    }
    
    public var byteSize: Int {
        MemoryLayout<Self>.size
    }
}

extension Int64 : AutoReadable {
    
}

extension Int32 : AutoReadable {
    
}

extension Int16 : AutoReadable {
    
}

extension Int8 : AutoReadable {
    
}

extension UInt64 : AutoReadable {
    
}

extension UInt32 : AutoReadable {
    
}

extension UInt16 : AutoReadable {
    
}

extension UInt8 : AutoReadable {
    
}
