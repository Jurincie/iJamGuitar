//
//  TopView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/25/22.
//

import SwiftUI

struct TopView: View {

     var width:CGFloat = 0.0
     var height:CGFloat = 0.0
    
    var body: some View {
        ChordButtonsView()
            .frame(width: width, height: height, alignment: .center)
            .background( Image("TopView")
                .resizable()
                .frame(width: width, height: height, alignment: .topLeading))
    }
    
}
