//
//  PeripheralView.swift
//  BlueTwoth
//
//  Created by G. Michael Fortin Jr on 9/10/21.
//

import SwiftUI

struct PeripheralView: View {
    
    @EnvironmentObject var CB:CBModel

    var body: some View {
        VStack {
            
            
            if CB.connectedPeripheral == nil {
                Text("\(CB.selectedPeripheral?.name ?? "") Selected")
                Button(action: {
                    CB.connectToPeripheral()
                    CB.selectedLink = nil
                }, label: {
                    ZStack {
                        RectangleView(color: .green)
                        Text("Connect")
                    }
                    .accentColor(.black)
                })
                
                
            }
            else{
                Text("\(CB.connectedPeripheral?.name ?? "") Connected")
                Button(action: {CB.disconnectFromPeripheral()}, label: {
                    ZStack {
                        RectangleView(color: .gray)
                        Text("Disconnect")
                    }
                    .accentColor(.black)
                })
            }
            
//            HStack{
//                if CB.connectedService != nil{
//                    Text("Services:")
//                    Text("\(CB.connectedService!)")
//                }
//            }
        }
    }

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        PeripheralView()
            .environmentObject(CBModel())
    }
}
}
