//
//  ViewController.swift
//  Eurodyne Tune Adjuster
//
//  Created by b l on 7/15/18.
//  Copyright © 2018 Brian Ledbetter. All rights reserved.
//

import UIKit
import Promises
import SwiftSpinner

func promiseOrItem<T>(returnPromise: Bool, item: T, promise: Promise<T>) -> Promise<T> {
       if (returnPromise) {
           return promise
       } else {
           return Promise<T>(item)
       }
}

class ViewController: UIViewController {
    @IBOutlet var boostLabel : UILabel?
    @IBOutlet var octaneLabel : UILabel?
    @IBOutlet var boostSlider : UISlider?
    @IBOutlet var e85Label: UILabel?
    @IBOutlet var e85Slider: UISlider?
    @IBOutlet var octaneSlider : UISlider?
    @IBOutlet var boostMinimum : UILabel?
    @IBOutlet var boostMaximum: UILabel?
    @IBOutlet var octaneMinimum : UILabel?
    @IBOutlet var octaneMaximum : UILabel?
    @IBOutlet var saveButton : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewFromSource(connectionAttempt: 0)
    }
    
    func updateViewFromSource(connectionAttempt: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        SwiftSpinner.useContainerView(self.view)
        SwiftSpinner.show("Connecting...")
        
        appDelegate.getConnection(connectionType: appDelegate.connectionType).then({ (connection) -> Void in
            SwiftSpinner.show("Fetching data...")
            connection.eurodyne.getFeatureFlags().then({ (featureFlags) -> Promise<FeatureFlags> in
                if (featureFlags.octaneEnabled) {
                    return connection.eurodyne.getOctaneMinimum().then { (octaneNumber) -> FeatureFlags in
                        self.octaneMinimum?.text = String(octaneNumber)
                        self.octaneSlider?.minimumValue = Float(octaneNumber)
                        return featureFlags
                    }.then { (featureFlags) -> Promise<FeatureFlags> in
                        connection.eurodyne.getOctaneMaximum().then({ (octaneNumber) -> FeatureFlags in
                            self.octaneMaximum?.text = String(octaneNumber)
                            self.octaneSlider?.maximumValue = Float(octaneNumber)
                            return featureFlags
                        })
                    }.then { (featureFlags) -> Promise<FeatureFlags> in
                        connection.eurodyne.getOctaneSetting().then({ (octaneNumber) -> FeatureFlags in
                            self.octaneLabel?.text = String(octaneNumber)
                            self.octaneSlider?.value = Float(octaneNumber)
                            self.octaneSlider?.isEnabled = true
                            return featureFlags
                        })
                    }
                } else {
                    return Promise<FeatureFlags>(featureFlags)
                }
            }).then({ (featureFlags) -> Promise<FeatureFlags> in
                if (featureFlags.boostEnabled) {
                    return connection.eurodyne.getBoostMinimum().then { (boostNumber) -> FeatureFlags in
                        self.boostMinimum?.text = String(boostNumber)
                        self.boostSlider?.minimumValue = Float(boostNumber)
                        return featureFlags
                    }.then { (featureFlags) -> Promise<FeatureFlags> in
                        connection.eurodyne.getBoostMaximum().then({ (boostNumber) -> FeatureFlags in
                            self.boostMaximum?.text = String(boostNumber)
                            self.boostSlider?.maximumValue = Float(boostNumber)
                            return featureFlags
                        })
                    }.then { (featureFlags) -> Promise<FeatureFlags> in
                      connection.eurodyne.getBoostSetting().then({ (boostNumber) -> FeatureFlags in
                            self.boostLabel?.text = String(boostNumber)
                            self.boostSlider?.value = Float(boostNumber)
                            self.boostSlider?.isEnabled = true
                            return featureFlags
                        })
                    }
                } else {
                    return Promise<FeatureFlags>(featureFlags)
                }
            }).then({ (featureFlags) -> Promise<FeatureFlags> in
                if (featureFlags.e85Enabled) {
                    return connection.eurodyne.getE85().then({ (e85Number) -> FeatureFlags in
                        self.e85Label?.text = String(e85Number)
                        self.e85Slider?.value = Float(e85Number)
                        self.e85Slider?.isEnabled = true
                        return featureFlags
                    })
                } else {
                    return Promise<FeatureFlags>(featureFlags)
                }
            }).then({ (_) -> Void in
                SwiftSpinner.hide()
                self.saveButton?.isEnabled = true
            }).recover { (error) -> FeatureFlags in
                SwiftSpinner.show(progress: 0, title: "Couldn't fetch data.").addTapHandler({
                    self.updateViewFromSource(connectionAttempt: connectionAttempt + 1)
                }, subtitle: "Tap to retry.")
                return FeatureFlags()
            }
        }).recover({ (error) -> Void in
            SwiftSpinner.show(progress: 0, title: "Couldn't connect to ELM327.").addTapHandler({
                if (connectionAttempt > 2) {
                    appDelegate.connectionType = .Mock
                    self.updateViewFromSource(connectionAttempt: 0)
                } else {
                    self.updateViewFromSource(connectionAttempt: connectionAttempt + 1)
                }
            }, subtitle: connectionAttempt > 2 ? "Tap to enter demo mode." : "Tap to retry.")
        })
    }
    
    @IBAction func boostSliderUpdated(sender : UISlider) {
        sender.value = round(sender.value)
        self.boostLabel?.text = String(format: "%.0f", sender.value)
    }
    
    @IBAction func octaneSliderUpdated(sender: UISlider) {
        sender.value = round(sender.value)
        self.octaneLabel?.text = String(format: "%.0f", sender.value)
    }
    
    @IBAction func e85SliderUpdated(sender: UISlider) {
        sender.value = round(sender.value)
        self.e85Label?.text = String(format: "%.0f", sender.value)
    }
    
    @IBAction func saveBoostAndOctane(sender : UIView) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.saveButton?.isEnabled = false
        self.octaneSlider?.isEnabled = false
        self.boostSlider?.isEnabled = false
        self.e85Slider?.isEnabled = false
        
        SwiftSpinner.show("Connecting...")
        
        struct SliderValues {
            var e85 : Int = 0
            var octane : Int = 0
            var boost : Int = 0
            var featureFlags = FeatureFlags()
        }

        appDelegate.getConnection(connectionType: appDelegate.connectionType).then { (connection) -> Void in
            SwiftSpinner.show("Saving data...")
            let featureFlags = FeatureFlags(boostEnabled: self.boostSlider?.isEnabled ?? false, e85Enabled: self.e85Slider?.isEnabled ?? false, octaneEnabled: self.octaneSlider?.isEnabled ?? false)
            let sliderValues = SliderValues(e85 : Int(self.e85Slider!.value), octane: Int(self.octaneSlider!.value), boost: Int(self.boostSlider!.value), featureFlags: featureFlags)
            
            Promise<SliderValues>(sliderValues).then({ (sliderValues) -> Promise<SliderValues> in
                if (sliderValues.featureFlags.octaneEnabled) {
                    return connection.eurodyne.setOctane(octane: sliderValues.octane).then { (_) -> Promise<SliderValues> in
                        return Promise<SliderValues>(sliderValues)
                    }
                } else {
                    return Promise<SliderValues>(sliderValues)
                }
            }).then({ (sliderValues) -> Promise<SliderValues> in
                if (sliderValues.featureFlags.boostEnabled) {
                    return connection.eurodyne.setBoost(boost: sliderValues.boost).then { (_) -> Promise<SliderValues> in
                        return Promise<SliderValues>(sliderValues)
                    }
                } else {
                    return Promise<SliderValues>(sliderValues)
                }
            }).then({ (sliderValues) -> Promise<SliderValues> in
                if (sliderValues.featureFlags.e85Enabled) {
                    return connection.eurodyne.setE85(e85: sliderValues.e85).then { (_) -> Promise<SliderValues> in
                        return Promise<SliderValues>(sliderValues)
                    }
                } else {
                    return Promise<SliderValues>(sliderValues)
                }
            }).then({ (sliderValues) -> SliderValues in
                self.updateViewFromSource(connectionAttempt: 0)
                return sliderValues
            }).recover({ (error) -> SliderValues in
                SwiftSpinner.show(progress: 0, title: "Failed to save data.").addTapHandler({
                    self.updateViewFromSource(connectionAttempt: 0)
                }, subtitle: "Tap to reload data from ECU.")
                return SliderValues()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

