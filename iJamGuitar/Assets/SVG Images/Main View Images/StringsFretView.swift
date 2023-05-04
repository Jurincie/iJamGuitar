//
//  StringsFretView.swift
//  iJam 2022
//
//  Created by Ron Jurincie on 5/4/22.
//

import Foundation
import SwiftUI

// each string has a column of 6 frets above them
// each column has either zero or one redBall images
//

struct FretsView: View {
    @Binding var selectedFretNumber: Int

    var body: some View {
        VStack(spacing:0) {
            Button(action: {self.selectedFretNumber = 0}){
                Image(self.selectedFretNumber == 0 ? "RedBall" : "")
                    .resizable()
            }
            Button(action: {self.selectedFretNumber = 1}){
                Image(self.selectedFretNumber == 1 ? "RedBall" : "")
                    .resizable()
            }
            Button(action: {self.selectedFretNumber = 2}){
                Image(self.selectedFretNumber == 2 ? "RedBall" : "")
                    .resizable()
            }
            Button(action: {self.selectedFretNumber = 3}){
                Image(self.selectedFretNumber == 3 ? "RedBall" : "")
                    .resizable()
            }
            Button(action: {self.selectedFretNumber = 4}){
                Image(self.selectedFretNumber == 4 ? "RedBall" : "")
                    .resizable()
            }
            Button(action: {self.selectedFretNumber = 5}){
                Image(self.selectedFretNumber == 5 ? "RedBall" : "")
                    .resizable()
            }
        }
    }
}


struct StringsFretView : View {
    @State private var pressedFret:Int = 3
    
    var body: some View {
        HStack(spacing:0) {
//            FretsView(selectedFretNumber:$pressedFret)
//                .frame(width: trueWidth / 8, height: trueHeight, alignment: .topLeading)
//                .aspectRatio(contentMode: .fit)
//            FretsView(selectedFretNumber:$pressedFret)
//                .frame(width: trueWidth / 8, height: trueHeight, alignment: .topLeading)
//            FretsView(selectedFretNumber:$pressedFret)
//                .frame(width: trueWidth / 8, height: trueHeight, alignment: .topLeading)
//            FretsView(selectedFretNumber:$pressedFret)
//                .frame(width: trueWidth / 8, height: trueHeight, alignment: .topLeading)
//            FretsView(selectedFretNumber:$pressedFret)
//                .frame(width: trueWidth / 8, height: trueHeight, alignment: .topLeading)
//            FretsView(selectedFretNumber:$pressedFret)
//                .frame(width: trueWidth / 8, height: trueHeight, alignment: .topLeading)
        }
    }
}
