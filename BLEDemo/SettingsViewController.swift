//
//  SettingsViewController.swift
//
//
//  Created by Thomas Power on 04/09/2018.
//  Copyright © 2018 Birdie Back. All rights reserved.
//

import UIKit
import CoreBluetooth

class SettingsViewController: UIViewController, CBPeripheralDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var ModePickerView: UIPickerView!
    
    let BLEService = "DFB0"
    let BLECharacteristic = "DFB1"
    //    Switches
    @IBOutlet weak var temperatureSwitch: UISwitch!
    @IBAction func tempSwitchPressed(_ sender: UISwitch) {
        
//        sendMessage(sender.isOn ? "1" : "0")

    }
    @IBAction func pressureSwitchPressed(_ sender: UISwitch) {
//        sendMessage(sender.isOn ? "1" : "0")

    }
    @IBAction func forceSwitchPressed(_ sender: UISwitch) {
//        sendMessage(sender.isOn ? "1" : "0")

    }
    
    //    Labels
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var forceLabel: UILabel!
    
//    Sliders
    @IBOutlet weak var tempSlider: VerticalSlider!
    @IBOutlet weak var pressureSlider: VerticalSlider!
    @IBOutlet weak var forceSlider: VerticalSlider!
    
   
    
//    Functions on end editing
    @IBAction func tempSliderEditEnd(_ sender: VerticalSlider) {
        let message = temperatureCode + String(Int(tempSlider.value))
        print(message)
        print(temperatureValues[Int(tempSlider.value)])
        sendMessage(temperatureCode + String(Int(tempSlider.value)))
        temperatureLabel.text = String(temperatureValues[Int(tempSlider.value)]) + " ˚C"
    }
    
   
    
    @IBAction func pressureEditEnd(_ sender: VerticalSlider) {
        let message = pressureCode + String(Int(pressureSlider.value))
        sendMessage(pressureCode + String(Int(pressureSlider.value)))

        pressureLabel.text = String(pressureValues[Int(pressureSlider.value)]) + "Pa"
    }

    @IBAction func forceEditEnd(_ sender: VerticalSlider) {
        let message = vibeCode + String(Int(forceSlider.value))
        sendMessage(vibeCode + String(Int(forceSlider.value)))
        forceLabel.text = String(vibeValues[Int(forceSlider.value)]) + "N"

    }
    
    @IBAction func tempSliderDidChange(_ sender: VerticalSlider) {
//        temperatureLabel.text = String(temperatureValues[Int(tempSlider.value)]) + " ˚C"
    }
    
    
    
    @IBAction func pressureDidChange(_ sender: VerticalSlider) {
//        pressureLabel.text = String(format: "%.2f",pressureSlider.value) + "Pa"
    }
    
    @IBAction func forceEditDidChange(_ sender: VerticalSlider) {
//        forceLabel.text = String(format: "%.2f",forceSlider.value) + "N"
        
    }
    
    var mainPeripheral:CBPeripheral? = nil
    var mainCharacteristic:CBCharacteristic? = nil
    var manager:CBCentralManager? = nil
    var parentView:HomeViewController? = nil
    
    
//    MODES for mode picker
    


    override func viewDidLoad() {
        super.viewDidLoad()
        tempSlider.value = 10
        print(mainPeripheral)
        ModePickerView.delegate = self
        ModePickerView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    

    func sendMessage(_ message:String) {
//        let helloWorld = "Hello"
        let dataToSend = message.data(using: String.Encoding.utf8)
        
        if (mainPeripheral != nil) {
            mainPeripheral?.writeValue(dataToSend!, for: mainCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
        } else {
            print("haven't discovered device yet")
        }
    }
    
    
    
    // MARK: CBPeripheralDelegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            
            print("Service found with UUID: " + service.uuid.uuidString)
            
            //device information service
            if (service.uuid.uuidString == "180A") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            //GAP (Generic Access Profile) for Device Name
            // This replaces the deprecated CBUUIDGenericAccessProfileString
            if (service.uuid.uuidString == "1800") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            //Bluno Service
            if (service.uuid.uuidString == BLEService) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //get device name
        if (service.uuid.uuidString == "1800") {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.uuid.uuidString == "2A00") {
                    peripheral.readValue(for: characteristic)
                    print("Found Device Name Characteristic")
                }
                
            }
            
        }
        
        if (service.uuid.uuidString == "180A") {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.uuid.uuidString == "2A29") {
                    peripheral.readValue(for: characteristic)
                    print("Found a Device Manufacturer Name Characteristic")
                } else if (characteristic.uuid.uuidString == "2A23") {
                    peripheral.readValue(for: characteristic)
                    print("Found System ID")
                }
                
            }
            
        }
        
        if (service.uuid.uuidString == BLEService) {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.uuid.uuidString == BLECharacteristic) {
                    //we'll save the reference, we need it to write data
                    mainCharacteristic = characteristic
                    
                    //Set Notify is useful to read incoming data async
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Found Bluno Data Characteristic")
                }
                
            }
            
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        
        if (characteristic.uuid.uuidString == "2A00") {
            //value for device name recieved
            let deviceName = characteristic.value
            print(deviceName ?? "No Device Name")
        } else if (characteristic.uuid.uuidString == "2A29") {
            //value for manufacturer name recieved
            let manufacturerName = characteristic.value
            print(manufacturerName ?? "No Manufacturer Name")
        } else if (characteristic.uuid.uuidString == "2A23") {
            //value for system ID recieved
            let systemID = characteristic.value
            print(systemID ?? "No System ID")
        } else if (characteristic.uuid.uuidString == BLECharacteristic) {
            //data recieved
            if(characteristic.value != nil) {
                let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)
                print(stringValue)
            }
        }
        
        
    }
    
    
    
//    PickerView Delegates
    
 
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
   
            return modes.count

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        Send Mode Message
        print(modes[row])
    
        sendMessage(modeCode + String(row))
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return modes[row]
    }
    
}
