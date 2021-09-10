//
//  PeripheralModel.swift
//  BlueTwoth
//
//  Created by G. Michael Fortin Jr on 9/10/21.
//

import Foundation
import CoreBluetooth

struct PeripheralModel: Identifiable {
    var id:Int
    var name:String
    var rssi:Int
    var peripheral:CBPeripheral
    
}
