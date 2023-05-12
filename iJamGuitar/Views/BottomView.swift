//
//  BottomView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/25/22.
//

import SwiftUI

struct BottomView: View {
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    
    init(width:CGFloat, height:CGFloat) {
        self.width = width
        self.height = height
    }

    var body: some View {
        ZStack() {
            Image("BottomView")
                .resizable()
                .frame(width:width, height:height, alignment:.topLeading)
            VStack() {
                VolumeView()
                    .padding(.horizontal, 40)
            }
        }
    }
}
