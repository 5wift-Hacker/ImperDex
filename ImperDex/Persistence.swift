//
//  Persistence.swift
//  ImperDex
//
//  Created by John Newman on 9/10/2025.
//

import Foundation
import SwiftData

@MainActor
struct PersistenceController {
    
    static var previewPokemon: Pokemon {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let pokemonData = try! Data(contentsOf: Bundle.main.url(forResource: "samplepokemon", withExtension: "json")!)
        let pokemon = try! decoder.decode(Pokemon.self, from: pokemonData)
        return pokemon
    }

    //our sample preview database
    static let preview: ModelContainer = {
        let container = try! ModelContainer(for: Pokemon.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        container.mainContext.insert(previewPokemon)
        return container
    }()
}
