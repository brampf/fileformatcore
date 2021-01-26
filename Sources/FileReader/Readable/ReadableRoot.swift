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

public protocol ReadableRoot : Readable {
    associatedtype Configuration: FileConfiguration
    
    init()
}


extension ReadableRoot {
    
    /**
     Read file from `URL`
     
     - Parameters:
     -  url: `URL` of the file to read
     - options: `Data.ReadingOptions`
     - config: `Configuration` (optional) file configuration
     - output: Handler for messages about non-critical problems
     */
    public static func read(contentsOf url: URL, options: Data.ReadingOptions, using config: Configuration? = nil, output: ((Output) -> Void)? = nil) throws -> Self? {
        
        let data = try Data(contentsOf: url, options: options)
        
        return try self.read(data, config: config, output: output)
        
    }
    
    /**
     Read file from `URL`
     
     - Parameters:
     -  url: `URL` of the file to read
     - config: `Configuration` (optional) file configuration
     - output: Handler for messages about non-critical problems
     */
    public static func read(contentsOf url: URL, using config: Configuration? = nil, output: ((Output) -> Void)? = nil) throws -> Self? {
        
        let data = try Data(contentsOf: url)
        
        return try self.read(data, config: config, output: output)
        
    }
    
    /**
     Read file from `Data`
     
     - Parameters:
     -  data: `Data` of the file to read
     - options: `Data.ReadingOptions`
     - config: `Configuration` (optional) file configuration
     - output: Handler for messages about non-critical problems
     */
    public static func read(_ data: Data, config: Configuration? = nil, output: ((Output) -> Void)? = nil) throws -> Self? {
        
        var context : Context = ReaderContext(using: config ?? Configuration(), out: output)
        
        return try data.withUnsafeBytes { ptr in
            
            // create new root node
            var root = Self()
            
            // push the next node on the stack
            context.push(root, size: data.endIndex)
            
            try root.read(ptr, context: &context, "\(type(of: root))")
            
            // popping should ideally be irrelevant as there is nothing else to do here
            _ = try context.pop()
            
            // return the just read node
            return root
        }
    }
    
    public var debugSymbol: String {
        "\(type(of: self))"
    }
    
}

