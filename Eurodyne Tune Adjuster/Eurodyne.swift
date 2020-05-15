//
//  Eurodyne.swift
//  Eurodyne Tune Adjuster
//
//  Created by b l on 7/16/18.
//  Copyright © 2018 Brian Ledbetter. All rights reserved.
//

import Foundation
import Promises

struct FeatureFlags {
    var boostEnabled = false
    var e85Enabled = false
    var octaneEnabled = false
}

protocol Eurodyne {
    func getBoostSetting() -> Promise<Int>
    func getBoostMinimum() -> Promise<Int>
    func getBoostMaximum() -> Promise<Int>
    func getE85() -> Promise<Int>
    func getFeatureFlags() -> Promise<FeatureFlags>
    func getOctaneSetting() -> Promise<Int>
    func getOctaneMinimum() -> Promise<Int>
    func getOctaneMaximum() -> Promise<Int>
    func setE85(e85: Int) -> Promise<Int>
    func setOctane(octane : Int) -> Promise<Int>
    func setBoost(boost : Int) -> Promise<Int>
}

class MQBEurodyne : Eurodyne {
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
    
    func getE85() -> Promise<Int> {
        let localIdentifier = Data([0xF1, 0xFD])
        return iso15765.readLocalIdentifier(localIdentifier: localIdentifier).then { (data) -> Promise<Int> in
            let uint8 = data.first!
            return Promise<Int>(self.calculateE85(e85: uint8))
        }
    }
    
    func getFeatureFlags() -> Promise<FeatureFlags> {
        let localIdentifier = Data([0xF1, 0xFB])
        return iso15765.readLocalIdentifier(localIdentifier: localIdentifier).then { (data) -> Promise<FeatureFlags> in
            let uint8 = data.first!
            let boostEnabled = (uint8 & 0x2) > 0
            let octaneEnabled = (uint8 & 0x4) > 0
            let e85Enabled = (uint8 & 0x20) > 0
            return Promise<FeatureFlags>(FeatureFlags(boostEnabled: boostEnabled, e85Enabled: e85Enabled, octaneEnabled: octaneEnabled))
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
    
    func setE85(e85: Int) -> Promise<Int> {
        let writeE85Byte = calculateWriteE85(e85: e85)
        let localIdentifier = Data([0xF1, 0xFD])
        return iso15765.writeLocalIdentifier(localIdentifier: localIdentifier, value: Data([writeE85Byte])).then { (data) -> Promise<Int> in
            return Promise<Int>(e85)
        }
    }
    
    func setOctane(octane : Int) -> Promise<Int> {
        let writeOctaneByte = UInt8(octane)
        let localIdentifier = Data([0xF1, 0xF9])
        return iso15765.writeLocalIdentifier(localIdentifier: localIdentifier, value: Data([writeOctaneByte])).then { (data) -> Promise<Int> in
            return Promise<Int>(octane)
        }
    }
    
    func setBoost(boost : Int) -> Promise<Int> {
        let writeBoostByte = calculateWriteBoost(psi: boost)
        let localIdentifier = Data([0xF1, 0xF8])
        return iso15765.writeLocalIdentifier(localIdentifier: localIdentifier, value: Data([writeBoostByte])).then { (data) -> Promise<Int> in
            return Promise<Int>(boost)
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
    
    func calculateE85(e85: UInt8) -> Int {
        return Int(Double(e85) / 1.28)
    }
    
    func calculateWriteE85(e85: Int) -> UInt8 {
        let result = Int(Double(e85) * 1.28)
        return UInt8(result)
    }
}
