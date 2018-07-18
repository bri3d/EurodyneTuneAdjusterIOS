//
//  ELM327.swift
//  Eurodyne Tune Adjuster
//
//  Created by b l on 7/15/18.
//  Copyright © 2018 Brian Ledbetter. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import Promises

class ELM327 : NSObject, GCDAsyncSocketDelegate {
    enum State {
        case Connected
        case NotConnected
        case Connecting
        case LostConnection
        case WaitingForData
    }
    
    enum ByteMatchingResult {
        case OK
        case Searching
        case Data(data: Data)
        case None
        case Prompt
    }
    
    enum GenericError: Error {
        case runtimeError(String)
    }

    var socket : GCDAsyncSocket?
    var state = State.NotConnected

    var dataPromise : Promise<Data>?
    var okayPromise : Promise<Bool>?
    var connectionPromise : Promise<Bool>?
    
    func connectTo(ip : String) -> Promise<Bool> {
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.global())
        do {
            print("Connecting to \(ip) on port 35000")
            try socket!.connect(toHost: ip, onPort: 35000)
            state = State.Connecting
            connectionPromise = Promise<Bool>.pending()
            return connectionPromise!
        }
        catch let error {
            print("Socket connection failed \(error)")
            return Promise<Bool>(false)
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Successfully connected to \(host) on \(port)")
        state = State.Connected
        connectionPromise?.fulfill(true)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Lost Connection! \(err)")
        state = State.LostConnection
        socket = nil
    }
    
    func getNextData() -> Promise<Data> {
        state = State.WaitingForData
        dataPromise = Promise<Data>.pending()
        socket?.readData(to: ">".data(using: String.Encoding.ascii)!, withTimeout: 5, tag: 1)
        return dataPromise!
    }
    
    func getNextOkay() -> Promise<Bool> {
        state = State.WaitingForData
        okayPromise = Promise<Bool>.pending()
        socket?.readData(to: ">".data(using: String.Encoding.ascii)!, withTimeout: 5, tag: 1)
        return okayPromise!
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        switch(state) {
        case State.WaitingForData:
            state = State.Connected
            let returnedData = parseByteLines(byteLines: String(data: data, encoding: String.Encoding.ascii)!)
            returnedData.forEach { (byteResult) in
                print("Parsed data line: \(byteResult)")
                switch(byteResult) {
                case let .Data(receivedData):
                    dataPromise?.fulfill(receivedData)
                    break
                case .OK:
                    okayPromise?.fulfill(true)
                    break
                case .Searching:
                    break
                case .None:
                    dataPromise?.reject(GenericError.runtimeError("Could not decode bytes!"))
                    break
                case .Prompt:
                    break
                }
            }
            break
        default:
            break
        }
    }
    
    func initializeELM() -> Promise<Bool> {
            self.sendMessageASCII(message: "AT E0") // No Echo
            return self.getNextOkay().then { (_) -> Promise<Bool> in
                self.sendMessageASCII(message: "AT AL") // Allow Long
                return self.getNextOkay()
            }.then { (_) -> Promise<Bool> in
                self.sendMessageASCII(message: "AT ST FF") // Long Timeout
                return self.getNextOkay()
            }.then { (_) -> Promise<Bool> in
                self.sendMessageASCII(message: "AT SP 0") // Autodetect
                return self.getNextOkay()
            }.then { (_) -> Promise<Bool> in
                self.sendMessageASCII(message: "AT SH 7E0") // Set ISO15765-4 ECU header
                return self.getNextOkay()
            }
    }
    
    func sendMessageASCII(message : String) {
        print("Sending: \(message)")
        let data = message.appending("\r\n").data(using: String.Encoding.ascii)!
        socket?.write(data, withTimeout: 0.1, tag: 1)
    }
    
    func sendMessageDataAndGetData(data : Data) -> Promise<Data> {
        sendMessageASCII(message: data.hexEncodedString(options: Data.HexEncodingOptions.upperCase))
        return self.getNextData()
    }
    
    func parseByteLines(byteLines: String) -> [ByteMatchingResult] {
        let strippedByteLines = byteLines.replacingOccurrences(of: " ", with: "").split(separator: "\r")
        return strippedByteLines.map { (byteLine) -> ByteMatchingResult in
            print("Got line: \(byteLine.uppercased())")
            switch(byteLine.uppercased()) {
            case Regex(pattern: "OK"):
                return ByteMatchingResult.OK
            case Regex(pattern: "SEARCHING"):
                return ByteMatchingResult.Searching
            case Regex(pattern: "([0-9A-F])+"):
                return ByteMatchingResult.Data(data: byteLine.uppercased().hexadecimal()!)
            case Regex(pattern: ">"):
                return ByteMatchingResult.Prompt
            default:
                return ByteMatchingResult.None
            }
        }
    }
}
