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
    
    /// Read from URL
    public static func read<Config: ParserConfig>(contentsOf url: URL, options: Data.ReadingOptions, _ config: Config? = nil, output: ((Output) -> Void)?) throws -> Self? {
        
        let data = try Data(contentsOf: url, options: options)
        
        if let conf = config {
            return try self.read(data, config: conf, output: output)
        } else {
            return try self.read(data, output: output)
        }
    }
    
    /// Read from Data
    public static func read<Config: ParserConfig>(_ data: Data, config: Config?, output: ((Output) -> Void)?) throws -> Self? {
        
        var context = ParserContext<Config>(dataSize: data.count, config: config, out: output)
        
        return data.withUnsafeBytes { ptr in
            self.init(ptr, context: &context)
        }
    }
    
    /// Read from Data
    public static func read(_ data: Data, output: ((Output) -> Void)?) throws -> Self? {
        
        var context = ParserContext(dataSize: data.count, out: output)
        
        return data.withUnsafeBytes { ptr in
            self.init(ptr, context: &context)
        }
    }
}
