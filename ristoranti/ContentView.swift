//
//  ContentView.swift
//  ristoranti
//
//  Created by Andrea on 06/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataService = DataService()
    
    var body: some View {
        TabView {
            RestaurantMapView(dataService: dataService)
                .tabItem {
                    Label("Mappa", systemImage: "map")
                }
            
            EpisodeListView(dataService: dataService)
                .tabItem {
                    Label("Lista", systemImage: "list.bullet")
                }
            
            NearestLocationsView(dataService: dataService)
                .tabItem {
                    Label("Vicino a me", systemImage: "location.fill")
                }

            AISuggestionsView(dataService: dataService)
                .tabItem {
                    Label("AI", systemImage: "sparkles")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
