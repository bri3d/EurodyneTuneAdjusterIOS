//
//  ISO15765.swift
//  Eurodyne Tune Adjuster
//
//  Created by b l on 7/16/18.
//  Copyright © 2018 Brian Ledbetter. All rights reserved.
//

import Foundation
import Promises

class ISO15765 {
    var elm327 : ELM327
    
    init(elm327 : ELM327) {
       self.elm327 = elm327
    }
    
    func readLocalIdentifier(localIdentifier: Data) -> Promise<Data> {
        var dataToSend = Data()
        dataToSend.append(0x22)
        dataToSend.append(localIdentifier)
        return elm327.sendMessageDataAndGetData(data: dataToSend).then({ (returnData) -> Promise<Data> in
            return Promise<Data>(returnData.dropFirst(3))
        })
    }
    
    func writeLocalIdentifier(localIdentifier: Data, value: Data) -> Promise<Data> {
        var dataToSend = Data()
        dataToSend.append(0x2E)
        dataToSend.append(localIdentifier)
        dataToSend.append(value)
        return elm327.sendMessageDataAndGetData(data: dataToSend).then({ (returnData) -> Promise<Data> in
            return Promise<Data>(returnData.dropFirst(3))
        })
    }
    
    
}
