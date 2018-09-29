//
//  SerialComms.swift
//
//  Created by Thomas Power on 23/09/2018.
//  Copyright © 2018 Birdie Back. All rights reserved.
//

import Foundation


let modes = ["Full Mode ON", "OFF", "Pressure OFF", "Vibe 1 OFF", "Temp OFF", "Temp ON", "Vibe Only", "Pressure Only"]
let temperatureCode = "t"
let pressureCode = "p"
let vibeCode = "v"
let modeCode = "m"

let pressureValues = [80,85,90,95,100,105,110,115,120,125]
let temperatureValues = [20,25,30,35,40,45,50,55,60,65]
let vibeValues = [180,185,190,200,205, 215, 220, 235, 240,255]


var buttonState = "000"
let modeMessages = ["000":"m2", "100":"m6","001":"m7","010":"m8","111":"m1","101":"m3","110":"m4","011":"m5"]


func buttonStateChanged(_ buttonState: String) -> String? {
    
    let message = modeMessages[buttonState]
    print("Mode Message")
    print(message)
    
    return message
}
