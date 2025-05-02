// ViewModels/DreamListViewModel.swift
import Foundation
import SwiftUI

class DreamListViewModel: ObservableObject {
    @Published var dreams: [Dream] = [] {
        didSet {
            saveDreams()
        }
    }

    private let saveKey = "dreams_data"

    init() {
        loadDreams()
    }

    func addDream(_ dream: Dream) {
        dreams.append(dream)
    }

    func updateDream(_ dream: Dream) {
        if let index = dreams.firstIndex(where: { $0.id == dream.id }) {
            dreams[index] = dream
            saveDreams()
            
            // ✅ 强制触发视图刷新
            dreams = dreams
        }
    }


    func deleteDream(at offsets: IndexSet) {
        dreams.remove(atOffsets: offsets)
    }

    private func saveDreams() {
        if let encoded = try? JSONEncoder().encode(dreams) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    func loadDreams() {
        for family in UIFont.familyNames {
            print("▶️ Font family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("    🔹 Font: \(name)")
            }
        }
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Dream].self, from: savedData) {
            dreams = decoded
        }
    }
}
