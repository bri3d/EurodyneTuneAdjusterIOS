//
//  ViewController.swift
//  Eurodyne Tune Adjuster
//
//  Created by b l on 7/15/18.
//  Copyright © 2018 Brian Ledbetter. All rights reserved.
//

import UIKit
import Promises

class ViewController: UIViewController {
    @IBOutlet var boostLabel : UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        let elm327 = ELM327()
        elm327.connectTo(ip: "192.168.0.10").then { (success) -> Promise<Int> in
            let isoIO = ISO15765(elm327 : elm327)
            let edIO = Eurodyne(iso15765: isoIO)
            return elm327.initializeELM().then { (_) in
                return edIO.getBoostSetting()
                }.then { (boostSetting) -> Void in
                    self.boostLabel?.text = String(boostSetting)
                    print("Boost is set to \(boostSetting) PSI")
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

