//
//  FretbBoardView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/25/22.
//

import SwiftUI

struct FretBoardView: View {
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    
    var body: some View {
        // width coming in is 78% of parent (StringsAndFretsAreaView)
        // height is parents trueHeight / 2
        // since this covers bottom half of parent (StringsAndFretsAreaView)
        VStack() {
            Image("Nut")
                .resizable()
                .frame(width: width, height: height / 6, alignment: .top)
    
            Spacer()
        }
        .background( Image("FretBoard")
            .resizable()
            .frame(width: width, height: height, alignment: .top))
    }
}
