//
//  StringsAndFretsAreaView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/5/22.
//

import SwiftUI

// This view covers the area with the FretBoard and the Strings
//  The 6 centered string images go from top to bottom
//  The FretNumber images are to left and right of strings in TOP (frets) part
//  There are empty images to left and right of strings in BOTTOM part


struct StringsAndFretsAreaView : View {
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    var body: some View {
        ZStack() {
            // BOTTOM layer
            VStack(spacing:0) {
                // display frets in Top half
                HStack(spacing:0) {
                    FretNumbersView(width: width * 0.12, height: height / 2)
                    FretBoardView(width: width * 0.76, height: height / 2)
                    FretNumbersView(width: width * 0.12, height: height / 2)
                }
                // display StringAreaView in Bottom half
                Image("StringAreaView")
                    .resizable()
                    .frame(width: width, height: height / 2, alignment: .top)
            }
            // TOP layer
            // Notice that height covers both the above
            StringsView(height: height)
        }
    }
}
