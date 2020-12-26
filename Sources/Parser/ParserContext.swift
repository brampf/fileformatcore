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

public protocol ParserConfig {
    
}

struct Empty: ParserConfig {
}


open class ParserContext<Config: ParserConfig> {
    
    /// current postion in the raw data
    final var offset : Int = 0
    
    /// absolute number of bytes in file
    final let bytes : Int
    
    final let config : Config?
    
    final var notify: ((Output) -> Void)? = nil
    
    init(dataSize: Int, config: Config?, out: ((Output) -> Void)? = nil){
        self.bytes = dataSize
        self.config = config
        self.notify = out
    }

}

extension ParserContext where Config == Empty {
    
    convenience init(dataSize: Int, out: ((Output) -> Void)? = nil){
        self.init(dataSize: dataSize, config: nil, out: out)
    }
    
}
