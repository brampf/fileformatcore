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
    
    var head : StackElement? { get }
    
    func push(_ node: AnyReadable, size: Int?)
    
    func pop() throws -> AnyReadable?
    
    /// factory method ot create new instances based on information readable somewhere in the raw data.
    func next(_ data: UnsafeRawBufferPointer) throws -> (new: AnyReadable?, upperBound: Int?)
}

open class ReaderContext<Configuration: FileConfiguration> : Context {
    
    var config : Configuration
    
    /// Node Stack
    var stack : [StackElement] = []
    
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
    
    /// factory method ot create new instances based on information readable somewhere in the raw data.
    public func next(_ data: UnsafeRawBufferPointer) throws -> (new: AnyReadable?, upperBound: Int?){
        try config.next(data, context: self)
    }
    
    public func push(_ node: AnyReadable, size: Int?){
        
        if let size = size {
            stack.append(.init(node, offset, offset+size))
        } else {
            stack.append(.init(node, offset, nil))
        }
    }
    
    public func pop() throws -> AnyReadable? {
        
        if let element = stack.popLast(){
            
            if let end = element.endOffset {
                
                // end was expected
                
                if offset < end {
                    
                    // offset before expected end - that is recoverable
                    if !config.ignoreRecoverableErrors {
                        // throw error as we are missing data
                        throw ReaderError.missalignedData(ErrorStack(element.readable.debugSymbol, type(of: element.readable), offset), end)
                        
                    } else {
                        notify?(Warning("Offset \(offset) too small", element.startOffset, element.endOffset, node: type(of: element.readable)))
                        print("WARN: Offset \(offset) < \(end) on \(type(of: element.readable))")
                        // move offset to expected end of box
                        offset = end
                    }
                }
                
                if offset > end {
                    // offset behind expected end - that is never good
                    throw ReaderError.missalignedData(ErrorStack(element.readable.debugSymbol, type(of: element.readable), offset), end)
                }
                
            } else {
                // no end was expected, so just keep the offset where it is

                print("Offset: \(offset)")
            }
            

            return element.readable
        } else {
            return nil
        }
    }
    
    public var head : StackElement? {
        return stack.last
    }
    
}
