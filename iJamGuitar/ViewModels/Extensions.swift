//
//  Extensions.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/8/22.
//

import Foundation
import CoreData
import SwiftUI

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

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

extension iJamGuitarModel {
    func convertToSetOfChords(dict: Dictionary<String,String>, parentTuning: Tuning) -> NSSet {
        // create a NSMutableSet of Chord managed Objects
        let set = NSMutableSet()
        
        for entry in dict {
            let chord       = Chord(context:context)
            chord.name      = entry.key
            chord.fretMap   = entry.value
            chord.tuning    = parentTuning
            set.add(chord)
        }
        
        return set
    }

    func convertToSetOfChordGroups(dict: Dictionary<String,String>, parentTuning: Tuning) -> NSSet {
        // build NSMutableSet of ChordGroups
        let chordGroupsSet = NSMutableSet()
        var activeChordGroupIsSet = false
        
        for entry in dict {
            // create new group
            let chordGroup                  = ChordGroup(context: self.context)
            chordGroup.name                 = entry.key
            chordGroup.availableChordNames  = entry.value
            chordGroup.availableChords      = setGroupsChords(chordGroup: chordGroup, tuning: parentTuning)
            chordGroup.tuning               = parentTuning
            chordGroupsSet.add(chordGroup)
            if activeChordGroupIsSet == false {
                parentTuning.activeChordGroup = chordGroup
                activeChordGroupIsSet = true
            }
        }
        
        return chordGroupsSet
    }
    
    func setGroupsChords(chordGroup: ChordGroup?, tuning: Tuning?) -> NSMutableSet {
        let chordGroupSet = NSMutableSet()
        var activeChordIsSet = false
        if let chordNames = chordGroup?.availableChordNames?.components(separatedBy: "-") {
            for chordName in chordNames {
                if let chord = getChord(name: chordName, parentTuning: tuning) {
                    chordGroupSet.add(chord)
                    if activeChordIsSet == false {
                        chordGroup?.activeChord = chord
                        activeChordIsSet = true
                    }
                }
            }
        }
        
        return chordGroupSet
    }
    
    func getChord(name: String, parentTuning: Tuning?) -> Chord? {
        if let chordArray: [Chord] = parentTuning?.chords?.allObjects as? [Chord] {
            for chord in chordArray {
                if chord.name == name {
                    return chord
                }
            }
        }
        
        return nil
    }
}

extension StringView {
    func getFretNoteTitle(openNote:String, offset:Int) -> String {
        let notes = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
        if let index = notes.firstIndex(of: openNote) {
            var finalIndex = index + offset + vm.capoPosition
            if finalIndex < 0 {
                finalIndex += 12
            }
            
            return notes[finalIndex % 12]
        }
        
        return "C"
    }
}

extension NSManagedObjectContext
{
    func deleteAllData()
    {
        guard let persistentStore = persistentStoreCoordinator?.persistentStores.last else {
            return
        }

        guard let url = persistentStoreCoordinator?.url(for: persistentStore) else {
            return
        }

        performAndWait { () -> Void in
            self.reset()
            do
            {
                try self.persistentStoreCoordinator?.remove(persistentStore)
                try FileManager.default.removeItem(at: url)
                try self.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            }
            catch { debugPrint("Error in Persistent Store") }
        }
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
