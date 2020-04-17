//
//  Connection.swift
//  Eurodyne Tune Adjuster
//
//  Created by b l on 7/17/18.
//  Copyright © 2018 Brian Ledbetter. All rights reserved.
//

import Foundation

enum ConnectionType {
    case Mock, ELM327
}

protocol Connection {
    var eurodyne : Eurodyne { get }
    func isConnected() -> Bool
    func lostConnection() -> Bool
}

class ELMConnection : Connection {
    let elm327 : ELM327
    let eurodyne : Eurodyne
    let iso15765 : ISO15765
    
    init(elm327 : ELM327, eurodyne : Eurodyne, iso15765 : ISO15765) {
        self.elm327 = elm327
        self.eurodyne = eurodyne
        self.iso15765 = iso15765
    }
    
    func isConnected() -> Bool {
        return self.elm327.state == ELM327.State.Connected
    }
    
    func lostConnection() -> Bool {
        return self.elm327.state == ELM327.State.LostConnection
    }
}

class MockConnection : Connection {
    let eurodyne : Eurodyne
    
    init() {
        self.eurodyne = MockEurodyne()
    }
    
    func isConnected() -> Bool {
        return true
    }
    
    func lostConnection() -> Bool {
        return false
    }
}
