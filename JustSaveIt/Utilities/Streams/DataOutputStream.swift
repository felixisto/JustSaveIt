//
//  DataOutputStream.swift
//  QuickChatter
//
//  Created by Kristiyan Butev on 25.04.21.
//

import Foundation

class DataOutputStream {
    let stream: OutputStream
    
    init(stream: OutputStream) {
        self.stream = stream
    }
    
    func write(_ buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
        return self.stream.write(buffer, maxLength: len)
    }
    
    func flush() {
        
    }
    
    func close() {
        self.stream.close()
    }
}
