//
//  RectangleView.swift
//  BlueTwoth
//
//  Created by G. Michael Fortin Jr on 9/10/21.
//

import SwiftUI

struct RectangleView: View {
    
    var color:Color
    
    var body: some View {

                Rectangle()
                    .frame(height:50)
                    .foregroundColor(color)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)

    }
}

struct RectangleView_Previews: PreviewProvider {
    static var previews: some View {
        RectangleView(color: .gray)
    }
}

