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
    
    func getBoostMinimum() -> Promise<Int> {
        let localIdentifier = Data([0xFD, 0x30])
        return iso15765.readLocalIdentifier(localIdentifier: localIdentifier).then { (data) -> Promise<Int> in
            let uint8 = data.first!
            return Promise<Int>(self.calculateBoost(boost: uint8))
        }
    }
    
    func getBoostMaximum() -> Promise<Int> {
        let localIdentifier = Data([0xFD, 0x31])
        return iso15765.readLocalIdentifier(localIdentifier: localIdentifier).then { (data) -> Promise<Int> in
            let uint8 = data.first!
            return Promise<Int>(self.calculateBoost(boost: uint8))
        }
    }
    
    func getOctaneSetting() -> Promise<Int> {
        let localIdentifier = Data([0xF1, 0xF9])
        return iso15765.readLocalIdentifier(localIdentifier: localIdentifier).then { (data) -> Promise<Int> in
            let uint8 = data.first!
            return Promise<Int>(self.calculateOctane(octane: uint8))
        }
    }
    
    func getOctaneMinimum() -> Promise<Int> {
        let localIdentifier = Data([0xFD, 0x32])
        return iso15765.readLocalIdentifier(localIdentifier: localIdentifier).then { (data) -> Promise<Int> in
            let uint8 = data.first!
            return Promise<Int>(self.calculateOctane(octane: uint8))
        }
    }
    
    func getOctaneMaximum() -> Promise<Int> {
        let localIdentifier = Data([0xFD, 0x33])
        return iso15765.readLocalIdentifier(localIdentifier: localIdentifier).then { (data) -> Promise<Int> in
            let uint8 = data.first!
            return Promise<Int>(self.calculateOctane(octane: uint8))
        }
    }
    
    func setOctane(octane : Int) -> Promise<Int> {
        let writeOctaneByte = UInt8(octane)
        let localIdentifier = Data([0xF1, 0xF9])
        return iso15765.writeLocalIdentifier(localIdentifier: localIdentifier, value: Data([writeOctaneByte])).then { (data) -> Promise<Int> in
            let uint8 = data.first!
            return Promise<Int>(Int(uint8))
        }
    }
    
    func setBoost(boost : Int) -> Promise<Int> {
        let writeBoostByte = calculateWriteBoost(psi: boost)
        let localIdentifier = Data([0xF1, 0xF8])
        return iso15765.writeLocalIdentifier(localIdentifier: localIdentifier, value: Data([writeBoostByte])).then { (data) -> Promise<Int> in
            let uint8 = data.first!
            return Promise<Int>(self.calculateBoost(boost: uint8))
        }
    }
    
    func calculateBoost(boost: UInt8) -> Int {
        let num = Int(Double(boost) / 0.047110065099374217)
        let num2 = Int(Double(num) * 0.014503773773)
        return num2 - 15
    }
    
    func calculateWriteBoost(psi : Int) -> UInt8 {
        let offsetPsi = psi + 16
        let num = Int(Double(offsetPsi) / 0.014503773773)
        let num2 = Int(Double(num) * 0.047110065099374217)
        return UInt8(num2)
    }
    
    func calculateOctane(octane: UInt8) -> Int {
        return Int(octane)
    }
}
