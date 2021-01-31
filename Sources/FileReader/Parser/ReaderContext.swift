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

public protocol Context {
    
    var offset : Int { get set }
    
    var bigEndian : Bool { get }
    
    var notify: ((Output) -> Void)? {get}
    
    var root : StackElement? {get}
    
    var head : StackElement? { get set }
    
    func push(_ node: ReadableElement, size: Int?)
    
    func pop() throws -> ReadableElement?
    
    func seek<Root: Readable,Value>(for path: KeyPath<Root,Value>) -> Value?
}

open class ReaderContext<Configuration: FileConfiguration> : Context {
    
    var config : Configuration
    
    /// Node Stack
    var stack : [StackElement] = []
    /// Stack of transient values
    var transients : [UUID: Any] = [:]
    
    /// reader position in the raw data
    public var offset: Int = 0
    
    public var bigEndian: Bool {
        return config.bigEndian
    }
    
    public var notify: ((Output) -> Void)? = nil
    
    public init(using configuration: Configuration, out: ((Output) -> Void)?){
        self.config = configuration
        self.notify = out
        
    }
    
    public func push(_ node: ReadableElement, size: Int?){
        
        if let size = size {
            stack.append(.init(node, offset, offset+size))
        } else {
            stack.append(.init(node, offset, nil))
        }
    }
    
    public func pop() throws -> ReadableElement? {
        
        if let element = stack.popLast(){
            
            if let end = element.endOffset {
                
                // end was expected
                
                if offset < end {
                    
                    // offset before expected end - that is recoverable
                    if !config.ignoreRecoverableErrors {
                        // throw error as we are missing data
                        throw ReaderError.missalignedData(ErrorStack(nil, type(of: element.readable), offset), end)
                        
                    } else {
                        notify?(Warning("Offset \(offset) too small", element.startOffset, element.endOffset, node: type(of: element.readable)))
                        print("WARN: Offset \(offset) < \(end) on \(type(of: element.readable))")
                        // move offset to expected end of box
                        offset = end
                    }
                }
                
                if offset > end {
                    // offset behind expected end - that is never good
                    throw ReaderError.missalignedData(ErrorStack(nil, type(of: element.readable), offset), end)
                }
                
            } else {
                // no end was expected, so just keep the offset where it is
            }
            

            return element.readable
        } else {
            return nil
        }
    }

    public var root : StackElement? {
        return stack.first
    }
    
    public var head : StackElement? {
        get {
            return stack.last
        }
        set {
            stack.removeLast()
            if let new = newValue {
                stack.append(new)
            }
        }
    }
    
    /// seeks for a specific, previously read value in the file hierachy by looking for the first match for the `Root.Type` from top to down of the reader stack
    public func seek<Root: Readable,Value>(for path: KeyPath<Root,Value>) -> Value? {
        
        for idx in stride(from: stack.count-1, through: 0, by: -1) {
            if let root = stack[idx].readable as? Root {
                
                // First try to find as transient
                if let val = stack[idx].transients[path] as? Value {
                    return val
                } else {
                    return root[keyPath: path]
                }
            }
        }
        return nil
    }
    
    /// stored the provided value as transient
    public func transientStore<Root: Readable,Value>(for path: KeyPath<Root,Value>) -> Value? {
        
        for idx in stride(from: stack.count-1, through: 0, by: -1) {
            
            if let root = stack[idx].readable as? Root {
                
                return root[keyPath: path]
            }
        }
        return nil
    }
    
    public subscript<Root, Value>(path: KeyPath<Root,Value>) -> Value? {
        
        for idx in stride(from: stack.count-1, through: 0, by: -1) {
            
            if stack[idx].readable is Root {
                
                return stack[idx].transients[path] as? Value
            }
        }
        // not found
        return nil
    }
    
    
}

extension ReaderContext where Configuration == DefaultConfiguration {
    
    public convenience init(out: ((Output) -> Void)? = nil){
        self.init(using: DefaultConfiguration(), out: out)
    }
}
