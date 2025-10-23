//
//  FetchService.swift
//  ImperDex
//
//  Created by John Newman on 10/10/2025.
//

import Foundation

struct FetchService {
    //step 1: handle the error with an enum
    
    enum FetchError: Error {
        case badResponse
    }
    
    //step 2: create the baseURL to future proof the URL usage
    let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    //step 3: create the fetch function
    func fetchPokemon(_ id: Int) async throws -> Pokemon {
        //create the fetch URL based on the baseURL,plus the id AS A STRING
        //fetching each pokemon individually
        let fetchURL = baseURL.appending(path: String(id))
        
        //step 4: handle data and response
        //use URLSesson.shared.data and take the data from the fetchURL
        //utilize try await
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        //step 5: handle response returns with a guard let
        //throw the error created in the enum if error
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        //step 6: create decoder
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        //step 7: create pokemon container variable
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        
        print("Pokemon fetched: \(pokemon.id): \(pokemon.name)")
        
        return pokemon
    }
    
}
