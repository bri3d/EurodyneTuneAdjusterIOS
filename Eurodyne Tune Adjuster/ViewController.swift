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
    @IBOutlet var octaneLabel : UILabel?
    @IBOutlet var boostSlider : UISlider?
    @IBOutlet var octaneSlider : UISlider?
    @IBOutlet var boostMinimum : UILabel?
    @IBOutlet var boostMaximum: UILabel?
    @IBOutlet var octaneMinimum : UILabel?
    @IBOutlet var octaneMaximum : UILabel?
    @IBOutlet var saveButton : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromElm()
    }
    
    func updateViewFromElm() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.connectToElm327().then { (connection) -> Void in
            
            connection.eurodyne.getOctaneMinimum().then({ (octaneNumber) -> Void in
                self.octaneMinimum?.text = String(octaneNumber)
                self.octaneSlider?.minimumValue = Float(octaneNumber)
            }).then({ (_) -> Promise<Int> in
                return connection.eurodyne.getOctaneMaximum().then({ (octaneNumber) -> Void in
                    self.octaneMaximum?.text = String(octaneNumber)
                    self.octaneSlider?.maximumValue = Float(octaneNumber)
                })
            }).then({ (_) -> Promise<Int> in
                return connection.eurodyne.getBoostMinimum().then({ (boostNumber) -> Void in
                    self.boostMinimum?.text = String(boostNumber)
                    self.boostSlider?.minimumValue = Float(boostNumber)
                })
            }).then({ (_) -> Promise<Int> in
                return connection.eurodyne.getBoostMaximum().then({ (boostNumber) -> Void in
                    self.boostMaximum?.text = String(boostNumber)
                    self.boostSlider?.maximumValue = Float(boostNumber)
                })
            }).then({ (_) -> Promise<Int> in
                return connection.eurodyne.getOctaneSetting().then({ (octaneNumber) -> Void in
                    self.octaneLabel?.text = String(octaneNumber)
                    self.octaneSlider?.value = Float(octaneNumber)
                    self.octaneSlider?.isEnabled = true
                })
            }).then({ (_) -> Promise<Int> in
                return connection.eurodyne.getBoostSetting().then({ (boostNumber) -> Void in
                    self.boostLabel?.text = String(boostNumber)
                    self.boostSlider?.value = Float(boostNumber)
                    self.boostSlider?.isEnabled = true
                })
            }).then({ (_) -> Void in
                self.saveButton?.isEnabled = true
            })
        }
    }
    
    @IBAction func boostSliderUpdated(sender : UISlider) {
        sender.value = round(sender.value)
        self.boostLabel?.text = String(sender.value)
    }
    
    @IBAction func octaneSliderUpdated(sender: UISlider) {
        sender.value = round(sender.value)
        self.octaneLabel?.text = String(sender.value)
    }
    
    @IBAction func saveBoostAndOctane(sender : UIView) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.saveButton?.isEnabled = false
        self.octaneSlider?.isEnabled = false
        self.boostSlider?.isEnabled = false

        appDelegate.connectToElm327().then { (connection) -> Void in
            connection.eurodyne.setBoost(boost: Int((self.boostSlider?.value)!)).then({ (_) -> Promise<Int> in
                return connection.eurodyne.setOctane(octane: Int((self.octaneSlider?.value)!))
            }).then({ (_) -> Promise<Int> in
                connection.eurodyne.setBoost(boost: Int((self.boostSlider?.value)!))
            }).then({ (_) -> Void in
                self.updateViewFromElm()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

