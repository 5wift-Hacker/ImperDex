//
//  Stats.swift
//  ImperDex
//
//  Created by John Newman on 16/10/2025.
//

import SwiftUI
import Charts

struct Stats: View {
    
    var pokemon: Pokemon
    
    var body: some View {
        Chart(pokemon.stats) { stat in
            BarMark(
                x: .value("Value", stat.value)
                ,
                y: .value("Stat", stat.name)
            )
            .annotation(position: .trailing) {
                Text("\(stat.value)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, -5)
            }
        }
        .frame(height: 200)
        .foregroundStyle(pokemon.typeColor)
        .padding([.horizontal, .bottom])
        .chartXScale(domain: 0...pokemon.highestStat.value + 10)
    }
}

#Preview {
    Stats(pokemon: PersistenceController.previewPokemon)
}
