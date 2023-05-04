//
//  StringAreaView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 4/25/22.
//

import Foundation
import SwiftUI

struct StringAreaView: View {
    var trueWidth:CGFloat = 0.0
    var trueHeight:CGFloat = 0.0
    
    // ture height is parents trueHeight / 2
    // since this covers bottom half of parent (StringsAndFretsAreaView)
    
    init(width: CGFloat, height: CGFloat) {
        trueHeight = height
        trueWidth = width
    }

    var body: some View {

        ZStack() {
            Image("StringAreaView")
                .resizable()
                .frame(width:trueWidth, height:trueHeight, alignment:.top)
            
            StringsView(width: trueWidth, height: trueHeight)
        }
    }
}
