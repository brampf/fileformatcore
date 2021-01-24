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

@propertyWrapper public final class ReadableChildren<R: AnyReadable> {
    
    public var wrappedValue : [R] = []

    
    public init() {
        //
    }
    
    public init(wrappedValue initialValue: [R]){
        self.wrappedValue = initialValue
    }
    
    public var debugDescription: String {
        "\(R.self)[\(wrappedValue.count)]"
    }
}

extension ReadableChildren : ReadableProperty {
    
    public func read(_ data: UnsafeRawBufferPointer, context: inout Context, _ symbol: String?) throws {
        
        while context.offset < data.endIndex {
            if let new = try Self.read(data, context: &context) as? R {
                wrappedValue.append(new)
            }
        }
        
    }
    
    public var byteSize: Int {
        wrappedValue.byteSize
    }
}
