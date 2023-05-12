//
//  ContentView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/24/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var vm = iJamGuitarViewModel()
    var x = 0.0
    var body: some View {
        GeometryReader { geo in
            let height      = geo.size.height
            let width       = geo.size.width
            let centered    = CGPoint(x:width / 2.0, y:height / 2.0)
            
            VStack(spacing: 0) {
                HeaderView(width: width, height: height * 0.10 )
                    .aspectRatio(contentMode: .fit)
                TopView(width:width, height:height * 0.25)
                    .aspectRatio(contentMode: .fit)
                StringsAndFretsAreaView(width:width, height:height * 0.50)
                    .aspectRatio(contentMode: .fit)
                BottomView(width: width, height:height * 0.15)
                    .aspectRatio(contentMode: .fit)
            }
            .cornerRadius(16.0)
            .frame(width:width, height:height)
            .position(centered)
        }
        .background(Color.black)
        .environmentObject(vm)  // inject iJamGuitarViewModel into environment
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
