//
//  Extensions.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/8/22.
//

import Foundation
import CoreData
import SwiftUI

extension NSDictionary {
    var swiftDictionary: Dictionary<String, Any> {
        var swiftDictionary = Dictionary<String, Any>()
        for key : Any in self.allKeys {
            if let stringKey = key as? String,
               let keyValue = self.value(forKey: stringKey) {
                swiftDictionary[stringKey] = keyValue
            }
        }

        return swiftDictionary
    }
}

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

extension StringView {
    func getFretNoteTitle(openNote:String, offset:Int) -> String {
        if let index = self.notes.firstIndex(of: openNote) {
            var finalIndex = index + offset + model.capoPosition
            if finalIndex < 0 {
                finalIndex += 12
            }
            
            return self.notes[finalIndex % 12]
        }
        
        return "C"
    }
}

extension View {
  func readFrame(onChange: @escaping (CGRect) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
              .preference(key: FramePreferenceKey.self, value: geometryProxy.frame(in: .global))
      }
    )
    .onPreferenceChange(FramePreferenceKey.self, perform: onChange)
  }
}
