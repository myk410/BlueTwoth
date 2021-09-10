//
//  ContentView.swift
//  BlueTwoth
//
//  Created by G. Michael Fortin Jr on 9/10/21.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    
    @EnvironmentObject var CB:CBModel
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack(spacing:10){
                    HStack{
                        Spacer()
                        if CB.isSwitchedOn {
                            Image(systemName: "dot.radiowaves.left.and.right")
                                .foregroundColor(.blue)
                                .padding(.trailing)
                        }
                        else {
                            Image(systemName: "dot.radiowaves.left.and.right")
                                .foregroundColor(.gray)
                                .padding(.trailing)
                        }
                    }
                    Spacer()
                    Text("Bluetooth Devices")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                    List(0..<CB.peripheralObjects.count, id: \.self) { index in
                        
                        NavigationLink(
                            destination: PeripheralView().onAppear(perform: {
                                CB.setSelectedPeripheral(CB.peripheralObjects[index])
                                
                            }),
                            tag: index,
                            selection: $CB.selectedLink,
                            label: {
                                HStack {
                                    Text(CB.peripheralObjects[index].name)
                                    Spacer()
                                    Text(String(CB.peripheralObjects[index].rssi))
                                }
                            })
                        
                        
                    }.frame(height: 300)
                    Spacer()
                    
                    if CB.isConnected {
                        
                        Button(action: {
                            CB.WriteOutgoingValue(data: "N")
                        }, label: {
                            ZStack{
                                RectangleView(color: .yellow)
                                Text("On")
                            }
                        })
                        .accentColor(.black)
                        Button(action: {
                            CB.WriteOutgoingValue(data: "F")
                        }, label: {
                            ZStack{
                                RectangleView(color: .red)
                                Text("Off")
                            }
                        })
                        .accentColor(.black)
                    }
                    
                    Text("STATUS")
                        .font(.headline)
                    
                    // Status goes here
                    
                    
                    if CB.connectedPeripheral == nil {
                        Text("No device connected")
                            .foregroundColor(.red)
                    }else{
                        Text("\(CB.connectedPeripheral!.name) is connected")
                            .foregroundColor(.green)
                        Button(action: {CB.disconnectFromPeripheral()}, label: {
                            ZStack {
                                RectangleView(color: .gray)
                                Text("Disconnect")
                            }
                        })
                        .accentColor(.black)
                    }
                    
                    Spacer()
                    //                HStack {
                    //                    Spacer()
                    if !CB.scanning {
                        Button(action: {
                            print("Scanning Started")
                            CB.startScanning()
                        }) {
                            ZStack{
                                RectangleView(color: .blue)
                                Text("Scan")
                            }
                        }
                        .accentColor(.black)
                    }
                    else{
                        Button(action: {
                            print("Scanning Stopped")
                            CB.stopScanning()
                        }) {
                            ZStack{
                                RectangleView(color: .gray)
                                Text("Stop Scan")
                            }
                        }
                        .accentColor(.black)
                    }
                    
                    
                    
                    
                    //                VStack (spacing: 10) {
                    //                    Button(action: {
                    //                        print("Start Advertising")
                    //                    }) {
                    //                        Text("Start Advertising")
                    //                    }
                    //                    Button(action: {
                    //                        print("Stop Advertising")
                    //                    }) {
                    //                        Text("Stop Advertising")
                    //                    }
                    //                }.padding()
                    //
                    //                }
                }
                .navigationBarTitle("IllummaLlamma")
            }
        }
        Spacer()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CBModel())
    }
}
