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

/// A Local context for every indiviudal `Readable`
public final class LocalContext {
    
    /// the `Readable` currently read
    public let readable : AnyReadable
    
    /// the offset of the starting location
    public let startOffset : Int
    
    /// the offset of the upper bound for this readable or `nil` if there is no upper bound
    public let endOffset : Int?
    
    /// a map of local, transient variables
    internal var transients : [AnyKeyPath: Any] = [:]
    
    /// the index in a sequence of elements read
    public var index : Int
    
    /// the local context to use without moving the global context
    public var offset : Int
    
    init(_ readable: AnyReadable, _ start: Int, _ end: Int?) {
        self.readable = readable
        self.startOffset = start
        self.endOffset = end
        
        self.offset = startOffset
        self.index = 0
    }
}

extension LocalContext : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return "[\(startOffset)...\(String(describing: endOffset))] \(type(of: readable))"
    }
    
}


