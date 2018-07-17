//
//  Eurodyne.swift
//  Eurodyne Tune Adjuster
//
//  Created by b l on 7/16/18.
//  Copyright © 2018 Brian Ledbetter. All rights reserved.
//

import Foundation
import Promises

class Eurodyne {
    let iso15765 : ISO15765
    
    init(iso15765 : ISO15765) {
        self.iso15765 = iso15765
    }
    
    func getBoostSetting() -> Promise<Int> {
        let localIdentifier = Data([0xF1, 0xF8])
        return iso15765.readLocalIdentifier(localIdentifier: localIdentifier).then { (data) -> Promise<Int> in
            let uint8 = data.first!
            return Promise<Int>(self.calculateBoost(boost: uint8))
        }
    }
    
    func calculateBoost(boost: UInt8) -> Int {
        let num = Int(Double(boost) / 0.047110065099374217)
        let num2 = Int(Double(num) * 0.014503773773)
        return num2 - 15
    }
}
