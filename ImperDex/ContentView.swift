//
//  ContentView.swift
//  ImperDex
//
//  Created by John Newman on 9/10/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest<Pokemon>(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default
    ) private var pokedex
    
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
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        //design the nav link here
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        VStack (alignment: .leading) {
                            HStack {
                                Text(pokemon.name!.capitalized)
                                    .fontWeight(.bold)
                                if pokemon.favorite {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
                            HStack {
                                ForEach(pokemon.types!, id: \.self) { type in
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
                }
            }
            .navigationDestination(for: Pokemon.self) { pokemon in
                //design the nav destination here
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
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                        getPokemon()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Find a Pokemon")
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredicate
            }
            .onChange(of: filterByFavorites) {
                pokedex.nsPredicate = dynamicPredicate
            }
        }
    }
    
    private func getPokemon() {
        Task {
            for id in 1...151 {
                do {
                    //temporary fetched pokemon type
                    let fetchedPokemon = try await fetcher.fetchPokemon(id)
                    
                    //real pokemon being saved
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefense = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    
                    try viewContext.save()
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
