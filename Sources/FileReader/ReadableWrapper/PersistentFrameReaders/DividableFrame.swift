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

struct SequentialFrame<R: ReadableElement> : PersistentFrameReader {
    typealias Value = [R]
    
    public var bound : [UInt8]
    public var divider : UInt8
    public var escape : UInt8
    
    public var factory : (Int, Slice<UnsafeRawBufferPointer>) throws -> R
    
    
    func read<C: Context>(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout C) throws -> Value? {
        
        var ret : [R] = .init()
        
        let upperBound = context.head?.endOffset ?? bytes.endIndex
        
        var escaped = false
        var wasescaped = false
        var boundStack = 0
        
        var elementCount = 0
        
        var elementStart = context.offset
        var elementEnd = context.offset
        
        
        for idx in context.offset..<upperBound {
            let char = bytes[idx]
            
            if char == escape {
                
                if escaped {
                    // hitting the trainling escape character
                    elementEnd += 1
                } else {
                    elementEnd += 1
                    elementStart += 1
                    wasescaped = true
                }
                escaped.toggle()
            }
            else if !escaped && char == bound[boundStack] {
                
                if boundStack == bound.count-1 {
                
                    // read last element up until here
                    let new = try factory(elementCount, Slice(base: bytes, bounds: elementStart..<elementEnd))
                    ret.append(new)
                    
                    // move offset to end of the bounding sequence
                    context.offset = elementEnd + bound.count

                    break // we are done here
                    
                } else {
                    
                    // increase the bound stack
                    boundStack += 1
                    //elementStart += 1
                }
            }
            else if !escaped && char == divider {
                
                let end = wasescaped ? elementEnd-1 : elementEnd
                
                // divider found, read element until now
                let new = try factory(elementCount, Slice(base: bytes, bounds: elementStart..<end))
                ret.append(new)
                
                elementCount += 1
                
                // reset offset for next elements
                boundStack = 0
                elementEnd += 1
                elementStart = elementEnd
                wasescaped = false
                
            }
            else { // normal character
            
                elementEnd += 1
                
                // reset bound stack
                boundStack = 0
            }
            
        }
        
        return ret
    }
    
}
