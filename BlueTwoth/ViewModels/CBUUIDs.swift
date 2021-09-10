import Foundation
import CoreBluetooth

struct CBUUIDs{

    static let kService_UUID = "0xFFE0"
    static let kRxCharacteristic_UUID = "0x1"
    static let kTxCharacteristic_UUID = "Characteristic6"
    static let kCharacteristic_UUID = "0xFFE1"

    static let Service_UUID = CBUUID(string: kService_UUID)
    static let rxCharacteristic_UUID = CBUUID(string: kRxCharacteristic_UUID)
    static let txCharacteristic_UUID = CBUUID(string:kTxCharacteristic_UUID)
    static let characteristic_UUID = CBUUID(string:kCharacteristic_UUID)

}
