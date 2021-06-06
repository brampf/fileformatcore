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

public enum ReaderError : LocalizedError, CustomStringConvertible {
    
    case internalError(_ Stack: ErrorStack, _ cause: String)
    
    case missalignedData(_ stack: ErrorStack, _ size: Int)

    case invalidMemoryAddress(_ stack: ErrorStack, _ upperBound: Int)
    
    case wrongDataType(_ stack: ErrorStack)
    
    case incompatibleDataFormat(_ stack: ErrorStack)
    
    public var errorDescription: String? {
        
        switch self {
        
        case .internalError(let stack, let cause):
            return "\(cause) at \(stack)"
        case .missalignedData(let stack, let size):
            return "\(stack) exceeds \(size)"
            
        case .invalidMemoryAddress(let stack, let upperBound):
            return "\(stack) outside the bounds of [0...\(upperBound)]"
            
        case .wrongDataType(let stack):
            return "\(stack) not readabel"
        
        case .incompatibleDataFormat(let stack):
            return "\(stack) not readable"
        }
            
    }
    
    public var description: String {
        
        errorDescription ?? Mirror(reflecting: self).description
    }
    
    public var stack : ErrorStack? {
        switch self {
        
        case .internalError(let stack, _):
            return stack
        case .missalignedData(let stack, _):
            return stack
            
        case .invalidMemoryAddress(let stack, _):
            return stack
            
        case .wrongDataType(let stack):
            return stack
            
        case .incompatibleDataFormat(let stack):
            return stack
        }
        
    }
}


public struct ErrorStack : Swift.Error, CustomStringConvertible {

    var name: String
    var type : Any.Type
    
    var offset : Int
    
    var path :  String
    var line : Int
    
    public init(_ symbol: String?, _ type: Any.Type, _ offset: Int, line : Int = #line, file: String = #filePath){
        
        self.name = symbol ?? "_"
        self.type = type
        self.offset = offset
        
        self.path = file
        self.line = line
    }
    
    public init<C: Context>(_ symbol: String?, _ any: Any, _ context: C,  line : Int = #line, file: String = #filePath) {
        
        self.name = symbol ?? "_"
        self.type = Swift.type(of: any)
        
        self.offset = context.offset
        
        self.path = file
        self.line = line
    }
    
    public var description: String {
        
        "\(name) : \(type) at \(offset)"
    }
    
}
