//
//  MockEurodyne.swift
//  Eurodyne Tune Adjuster
//
//  Created by Brian Ledbetter on 4/17/20.
//  Copyright © 2020 Brian Ledbetter. All rights reserved.
//

import Foundation
import Promises

class MockEurodyne : Eurodyne {
    func getBoostSetting() -> Promise<Int> {
        return Promise<Int>(28)
    }
    
    func getBoostMinimum() -> Promise<Int> {
        return Promise<Int>(10)
    }
    
    func getBoostMaximum() -> Promise<Int> {
        return Promise<Int>(30)
    }
    
    func getE85() -> Promise<Int> {
        return Promise<Int>(50)
    }
    
    func getFeatureFlags() -> Promise<FeatureFlags> {
        return Promise<FeatureFlags>(FeatureFlags(boostEnabled: true, e85Enabled: true, octaneEnabled: true))
    }
    
    func getOctaneSetting() -> Promise<Int> {
      return Promise<Int>(89)
    }
    
    func getOctaneMinimum() -> Promise<Int> {
        return Promise<Int>(87)
    }
    
    func getOctaneMaximum() -> Promise<Int> {
        return Promise<Int>(100)
    }
    
    func setE85(e85: Int) -> Promise<Int> {
        return Promise<Int>(e85)
    }
    
    func setOctane(octane : Int) -> Promise<Int> {
       return Promise<Int>(octane)
    }
    
    func setBoost(boost : Int) -> Promise<Int> {
       return Promise<Int>(boost)
    }
}
