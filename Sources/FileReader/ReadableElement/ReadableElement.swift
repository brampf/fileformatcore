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

/// A `Readable` element whose properties can be read
public protocol ReadableElement : Readable {
    
    /// Factory method to create a new instance without the need for an empty initializer
    static func new() -> Self
    
    /**
    method to read property values of this `Readable` from raw data
     - Parameters:
        -  data: The `UnsafeRawBufferPointer` to read from
        -  context : The `Context` to use for reading the data
     */
    mutating func read<C: Context>(_ bytes: UnsafeRawBufferPointer, context: inout C, _ symbol: String?) throws
    
}

extension ReadableElement {
    
    
    internal func readElement<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String? = nil) throws -> Self?  {
    
        var new = Self.new()
        
        context.push(new, size: nil)
        
        try new.read(bytes, context: &context, symbol)
    
        _ = try context.pop()
        
        return new
    }
    
}
