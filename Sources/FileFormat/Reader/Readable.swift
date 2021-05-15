//
//  File.swift
//  
//
//  Created by May on 15.05.21.
//

import Foundation

public protocol Readable : NodeDescriptor {
    
    static func read(_ bytes: UnsafeRawBufferPointer, _ context: ReaderContext) -> Target
    
}
