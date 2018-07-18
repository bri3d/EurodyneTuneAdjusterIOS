//
//  Connection.swift
//  Eurodyne Tune Adjuster
//
//  Created by b l on 7/17/18.
//  Copyright © 2018 Brian Ledbetter. All rights reserved.
//

import Foundation

class Connection {
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
}
