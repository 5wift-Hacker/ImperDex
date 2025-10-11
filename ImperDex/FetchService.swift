//
//  FetchService.swift
//  ImperDex
//
//  Created by John Newman on 10/10/2025.
//

import Foundation

struct FetchService {
    //handle the error with an enum
    
    enum FetchError: Error {
        case badResponse
    }
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    //fetch function to fetch pokemon from decoded FetchedPokemon file
    
    func fetchPokemon(_ id: Int) async throws -> FetchedPokemon {
        let fetchURL = baseURL.appending(path: String(id))
        
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemon = try decoder.decode(FetchedPokemon.self, from: data)
        
        print("Fetched Pokemon: \(pokemon.id), \(pokemon.name.capitalized)")
        
        return pokemon
    }
    
}
