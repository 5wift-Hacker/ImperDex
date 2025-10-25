//
//  ContentView.swift
//  ImperDex
//
//  Created by John Newman on 9/10/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Pokemon.id, animation: .default) private var pokedex: [Pokemon]
    
    @State private var searchText = ""
    @State private var filterByFavorites = false
    
    let fetcher = FetchService()
    
    private var dynamicPredicate: NSPredicate {
        var predicates: [NSPredicate] = []
        
        //Search predicate
        if !searchText.isEmpty {
            //code is 'filter by name, and only include names that contain searchText
            // [c] means don't worry about case sensitivity
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        //Filter by favorite predicate
        if filterByFavorites {
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        //Combine predicates and return
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    var body: some View {
        
        if pokedex.count < 2 {
            ContentUnavailableView {
                Label("No Pokémon", image: .nopokemon)
            } description: {
                Text("There aren't any Pokémon yet. \nFetch some Pokémon to get started!")
            } actions: {
                Button("Fetch Pokémon", systemImage: "antenna.radiowaves.left.and.right") {
                    getPokemon(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }

        }else {
            NavigationStack {
                List {
                    Section {
                        ForEach(pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                //design the nav link here
                                if pokemon.sprite == nil {
                                    AsyncImage(url: pokemon.spriteURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 100, height: 100)
                                }else {
                                    pokemon.spriteImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                }
                                
                                VStack (alignment: .leading) {
                                    HStack {
                                        Text(pokemon.name.capitalized)
                                            .fontWeight(.bold)
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                    HStack {
                                        ForEach(pokemon.types, id: \.self) { type in
                                            Text(type.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.black)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 5)
                                                .background(Color(type.capitalized))
                                                .clipShape(.capsule)
                                        }
                                    }
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(pokemon.favorite ? "Remove from Favorites" : "Add to Favorites", systemImage: "star") {
                                    pokemon.favorite.toggle()
                                    do {
                                        try modelContext.save()
                                    }catch {
                                        print(error)
                                    }
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    } footer: {
                        if pokedex.count < 151 {
                            ContentUnavailableView {
                                Label("Missing Pokémon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!\nFetch the rest of the pokemon.")
                            } actions: {
                                Button("Fetch Pokémon", systemImage: "antenna.radiowaves.left.and.right") {
                                    getPokemon(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
                            }

                        }
                    }
                }
                .navigationDestination(for: Pokemon.self) { pokemon in
                    //design the nav destination here
                    PokemonDetail(pokemon: pokemon)
                        
                }
                .navigationTitle("Pokedex")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            filterByFavorites.toggle()
                        } label: {
                            Label("Filter By Favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
                .searchable(text: $searchText, prompt: "Find a Pokemon")
                
            }
        }
    }
    
    private func getPokemon(from id: Int) {
        Task {
            for i in id...151 {
                do {
                    //temporary fetched pokemon type
                    let fetchedPokemon = try await fetcher.fetchPokemon(i)
                    
                    modelContext.insert(fetchedPokemon)
                    
                } catch {
                    print(error)
                }
            }
            
            storeSprites()
            
        }
    }
    
    private func storeSprites() {
        Task {
            do {
                for pokemon in pokedex {
                    pokemon.sprite = try await URLSession.shared.data(from: pokemon.spriteURL).0
                    pokemon.shiny = try await URLSession.shared.data(from: pokemon.shinyURL).0
                    
                    try modelContext.save()
                    
                    print("Sprites stored: \(pokemon.id): \(pokemon.name.capitalized)")
                }
            } catch {
                print(error)
            }
        }
    }
    
}

#Preview {
    ContentView()
        .modelContainer(PersistenceController.preview)
}
