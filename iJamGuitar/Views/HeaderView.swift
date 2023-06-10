//
//  HeaderView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/30/22.
//

import SwiftUI

struct HeaderView: View {
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0

    var body: some View {
        ZStack() {
            Image("HeaderView")
                .resizable()
                .frame(width: width, height: height)
                .border(Color.gray, width: 4)
            HStack() {
                Spacer()
                TuningPickerView()
                    .frame(alignment: .trailing)
                    .border( .white, width: 3, cornerRadius: 7)
                Spacer()
                ChordGroupPickerView()
                    .frame(alignment: .leading)
                    .border( .white, width: 3, cornerRadius: 7)
                Spacer()
            }
        }
    }
}

struct Previews_HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(width: 300.0, height: 75.0)
            .previewLayout(.sizeThatFits)
    }
}
