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

public protocol BaseFile : ReadableFrame {
    associatedtype Configuration : FileConfiguration
    
    init()
}


extension BaseFile {
    
    public static func read(data: Data) throws -> Self? {
        
        let config = Configuration()
        var context : Context = ReaderContext(using: config) { out in
            print(out.msg)
        }
        
        return try data.withUnsafeBytes { ptr in
            try new(ptr, with: &context, "\(type(of: self))")
        }
        
    }
    
}

extension BaseFile {
    
    public static func size(_ data: UnsafeRawBufferPointer, with context: inout Context) -> Int? {
        
        return data.endIndex
    }
}
