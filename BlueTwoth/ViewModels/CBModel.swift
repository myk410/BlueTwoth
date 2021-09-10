//
//  CBModel.swift
//  BlueTwoth
//
//  Created by G. Michael Fortin Jr on 9/10/21.
//

import Foundation
import CoreBluetooth

class CBModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    
    private var CBManager: CBCentralManager!
    private var rxCharacteristic: CBCharacteristic!
    @Published var txCharacteristic: CBCharacteristic!
    @Published var isSwitchedOn = false
    @Published var peripherals:[CBPeripheral]? = nil
    @Published var peripheralObjects = [PeripheralModel]()
    @Published var selectedPeripheral:PeripheralModel? = nil
    @Published var connectedPeripheral:PeripheralModel? = nil
    @Published var isConnected = false
    @Published var allServices:[CBService]? = nil
    @Published var selectedLink:Int?=nil
    @Published var scanning = false
    @Published var connectedService: CBService? = nil
    @Published var readValue:String? = nil
    
    override init() {
        super.init()
        
        CBManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            print("Bluetooth is powered on!")
            isSwitchedOn=true
            startScanning()
        case .poweredOff:
            print("Bluetooth is turned off.")
            isSwitchedOn=false
        case .unknown:
            print("Bluetooth status is currently unknown.")
        case .resetting:
            print("Bluetooth connection was temperarily lost. Resetting.")
        case .unsupported:
            print("Device does not support BLE.")
        case .unauthorized:
            print("App is not authorized to use Bluetooth. Please change in your phones settings.")
        @unknown default:
            print("Unknown Bluetooth state")
        }
    }
    
    func startScanning(){
        peripherals = []
        print("Scanning for peripherals.")
        CBManager.scanForPeripherals(withServices: nil, options: nil)
        scanning=true
    }
    
    func stopScanning(){
        print("Scanning stopped.")
        CBManager.stopScan()
        scanning=false
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var peripheralName: String!
        
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else{
            peripheralName = "unknown"
        }
        
        peripheralName = String(peripheralName.filter { !"\r\n".contains($0) }) // Removes \r\n from the Peripheral Name
        
        if peripheralName == "IllummaLlamma" {
            peripherals = (peripherals ?? [])+[peripheral]
            peripheralObjects.append(PeripheralModel(id: peripheralObjects.count, name: peripheralName, rssi: RSSI.intValue, peripheral: peripheral))
            stopScanning()
        }
    }
    
    func setSelectedPeripheral(_ peripheral:PeripheralModel){
        selectedPeripheral = peripheral
    }
    
    func connectToPeripheral() -> Void {
        connectedPeripheral = selectedPeripheral
        connectedPeripheral!.peripheral.delegate = self
//        guard connectedPeripheral != nil else {
//            print("connectedPeripheral = nil")
//            return
//        }
        CBManager.connect(connectedPeripheral!.peripheral, options: nil)
        isConnected=true
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral")
        connectedPeripheral!.peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print("Error connecting to peripheral: \(error!.localizedDescription)")
        }
    }
    
    func disconnectFromPeripheral() -> Void {
        if selectedPeripheral?.peripheral != nil {
            CBManager.cancelPeripheralConnection(connectedPeripheral!.peripheral)
            connectedPeripheral = nil
            isConnected = false
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else{
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else{
            return
        }
        
        services.forEach{ service in
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        for service in services{
            allServices = (allServices ?? []) + [service]
            if service.uuid == CBUUIDs.Service_UUID{
                self.connectedService = service
                print("\(self.connectedService!.uuid) service is connected")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else{
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else{
            return
        }
        
        for characteristic in characteristics{
//            if characteristic.uuid.isEqual(CBUUIDs.characteristic_UUID){
//                rxCharacteristic = characteristic
//                peripheral.setNotifyValue(true, for: rxCharacteristic)
//                peripheral.readValue(for: characteristic)
//                print("rxCharacteristic = \(rxCharacteristic.uuid)")
//            }
            if characteristic.uuid.isEqual(CBUUIDs.characteristic_UUID){
                txCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: txCharacteristic)
                peripheral.readValue(for: txCharacteristic)
                
                print("txCharacteristic = \(CBUUIDs.characteristic_UUID)")
            }
//            if characteristic.uuid.isEqual(CBUUIDs.rxCharacteristic_UUID){
//                rxCharacteristic = characteristic
//                peripheral.setNotifyValue(true, for: rxCharacteristic)
//                peripheral.readValue(for: characteristic)
//                print("rxCharacteristic = \(rxCharacteristic.uuid)")
//            }
//            if characteristic.uuid.isEqual(CBUUIDs.txCharacteristic_UUID){
//                txCharacteristic = characteristic
//                print("txCharacteristic = \(CBUUIDs.txCharacteristic_UUID)")
//            }
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral Is Powered On.")
        case .unsupported:
            print("Peripheral Is Unsupported.")
        case .unauthorized:
            print("Peripheral Is Unauthorized.")
        case .unknown:
            print("Peripheral Unknown")
        case .resetting:
            print("Peripheral Resetting")
        case .poweredOff:
            print("Peripheral Is Powered Off.")
        @unknown default:
            print("Error")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        var characteristicACSIIValue = NSString()

        guard characteristic == txCharacteristic,
              let characteristicValue = characteristic.value,
              let ASCIIString = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else {return}
        
        characteristicACSIIValue = ASCIIString
        print("Value Recieved: \((characteristicACSIIValue as String))")
    }
    
    func WriteOutgoingValue(data:String){
        
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        // Check if it has the write property
        if txCharacteristic.properties.contains(.writeWithoutResponse) && connectedPeripheral?.peripheral != nil {

            connectedPeripheral?.peripheral.writeValue(valueString!, for: txCharacteristic, type: .withoutResponse)

                    }
        
//        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
//        print("\(valueString!)")
//        if connectedPeripheral != nil{
//            if txCharacteristic != nil {
//                connectedPeripheral?.peripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
//            }
//        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        var characteristicACSIIValue = NSString()
        guard characteristic == txCharacteristic,
              let characteristicValue = characteristic.value,
              let ASCIIString = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else {return}
        
        characteristicACSIIValue = ASCIIString
        print("Value sent: \((characteristicACSIIValue as String))")
        
        guard error != nil else {
            print("Error writing data: \(error!.localizedDescription)")
            return
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil{
            print("Disconnected from peripheral: \(error!.localizedDescription)")
        }
    }
}
