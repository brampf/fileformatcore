/*
 
 Copyright (c) <2020>
 
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

/// Root Node in the Abstract Syntax Tree
public protocol Root : Node {
    
}

extension Root {
    
    /**
     Read file from `URL`
     
     - Parameters:
        -  url: `URL` of the file to read
        - options: `Data.ReadingOptions`
        - config: `Configuration` (optional) file configuration
        - output: Handler for messages about non-critical problems
     */
    public static func read(contentsOf url: URL, options: Data.ReadingOptions, using config: Context.Configuration? = nil, output: ((Output) -> Void)? = nil) throws -> Self? {
        
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
    public static func read(contentsOf url: URL, using config: Context.Configuration? = nil, output: ((Output) -> Void)? = nil) throws -> Self? {
        
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
    public static func read(_ data: Data, config: Context.Configuration? = nil, output: ((Output) -> Void)? = nil) throws -> Self? {
        
        var context = Self.Context.init(using: config ?? .default, out: output)
        
        return try data.withUnsafeBytes { ptr in
            try self.init(ptr, context: &context)
        }
    }
}
