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

/**
  The root Frame of the the whole file structure, offering convenience inistializers a
 */
public protocol BaseFile : AutoReadable {
    associatedtype Context : FileReader.Context
    
    init()
}


extension BaseFile {
    
    /**
     Reads a `BaseFile` from the bytes provided
     
     - Parameters:
        -  data: the raw data to read from
        -  configuration: the `FileConfiguraiton`to use
        -  out: the output handler to use
     
     */
    public static func read(from data: ContiguousBytes, with configuration: Context.Configuration = Context.Configuration(), out: ((Output) -> ())? = nil) throws -> Self? {
        
        var context = Context.init(using: configuration, out: out)
        
        return try data.withUnsafeBytes { ptr in
            try Self.read(ptr, with: &context, "\(type(of: self))")
        }
        
    }
    
    /**
     Reads ta `BaseFile` from the url provided
     
     - Parameters:
        -  url: the file ULR to read the raw data from
        -  configuration: the `FileConfiguraiton`to use
        -  out: the output handler to use
     
     */
    public static func read(from url: URL, with configuration: Context.Configuration = Context.Configuration(), out: ((Output) -> ())? = nil) throws -> Self? {
        
        let data = try Data(contentsOf: url)
        var context = Context.init(using: configuration, out: out)
        
        return try data.withUnsafeBytes { ptr in
            try Self.read(ptr, with: &context, "\(type(of: self))")
        }
        
    }
    
}

extension BaseFile {
    
    /// Size of the `BaseFile`is the whole byte array for obvious reasons
    public static func size(_ data: UnsafeRawBufferPointer, with context: inout Context) -> Int? {
        
        return data.endIndex
    }
}
