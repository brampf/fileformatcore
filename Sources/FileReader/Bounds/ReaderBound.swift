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

protocol ReaderBound {
    
}

struct EOF : ReaderBound {
    
}

struct Offset : ReaderBound {
    
    var position : Int
    
    init(_ position: Int){
        self.position = position
    }
}

struct ByteSequence : ReaderBound {
    
    var bytes : [UInt8]
    
    init(_ bytes: UInt8...){
        self.bytes = bytes
    }
}

struct Property<R: ReadableRoot, Value> : ReaderBound {
    
    var path: KeyPath<R,Value>
    var value: Value
    
    init(_ path: KeyPath<R,Value>, _ value: Value){
        self.path = path
        self.value = value
    }
    
}
