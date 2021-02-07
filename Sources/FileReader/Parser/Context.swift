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

/**
 Parser context
 */
public protocol Context {
    associatedtype Configuration: FileConfiguration
    
    /// global byte offset
    var offset : Int { get set }
    
    /// byte order for teh file to read
    var bigEndian : Bool { get }
    
    /// Handler for providing parser output
    var notify: ((Output) -> Void)? {get}
    
    /// the local configuration
    var config : Configuration { get }
    
    /// Local context for the first `Readable` read in the hierachy
    var root : LocalContext? {get}
    
    /// Local context for the last (current)`Readable`in the hierarchy
    var head : LocalContext? { get set }
    
    /// Local context for the previous (parent)`Readable`in the hierarchy
    var parent : LocalContext? { get  }
    
    /// creating local context for the next `Readable` to read
    func push(_ node: Readable, upperBound: Int?)
    
    /// removing local context for the last `Readable` just read
    func pop() throws -> Readable?
    
    /// searches for a value for the given KeyPath form the head down though all local context
    func seek<Root: Readable,Value>(for path: KeyPath<Root,Value>) -> Value?

    /// default initializer
    init(using configuration: Configuration, out: ((Output) -> Void)?)
}
