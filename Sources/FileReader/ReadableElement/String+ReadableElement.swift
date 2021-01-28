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


extension String : ReadableElement {
    
    /// Read `FixedWidthInteger`
    public static func new(_ bytes: UnsafeRawBufferPointer, with context: inout Context, _ name: String?) throws -> Self? {
     
        print("[\(String(describing: context.offset).padding(toLength: 8, withPad: " ", startingAt: 0))] READ \(name ?? "") : \(type(of: self))")
        
        let end = context.head?.endOffset ?? bytes.endIndex
        
        // make sure that the offset is within the allowed bounds
        guard context.offset >= 0 && context.offset < end else {
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, String.self, context.offset),end)
        }
        
        let data = Data(bytes[context.offset..<end])
        
        // move the pointer beyond the null but not beyond the bounds
        context.offset += data.count
        return String(data: data, encoding: .utf8)
    }
    
    public var byteSize: Int {
        self.count * MemoryLayout<Self.Element>.size
    }
}
