//
//  ContentView.swift
//  ristoranti
//
//  Created by Andrea on 06/12/25.
//

import SwiftUI

enum NavigationItem: String, CaseIterable, Hashable {
    case map = "Mappa"
    case list = "Lista"
    case nearest = "Vicino a me"
    case ai = "AI"
    
    var iconName: String {
        switch self {
        case .map: return "map"
        case .list: return "list.bullet"
        case .nearest: return "location.fill"
        case .ai: return "sparkles"
        }
    }
}

struct NavigationFocusedValueKey: FocusedValueKey {
    typealias Value = Binding<NavigationItem?>
}

extension FocusedValues {
    var selectedNavigationItem: Binding<NavigationItem?>? {
        get { self[NavigationFocusedValueKey.self] }
        set { self[NavigationFocusedValueKey.self] = newValue }
    }
}

struct ContentView: View {
    @StateObject private var dataService = DataService()
    @State private var selectedItem: NavigationItem? = .map
    
    var body: some View {
        NavigationSplitView {
            List(NavigationItem.allCases, id: \.self, selection: $selectedItem) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.iconName)
                }
            }
            .navigationTitle("4 Ristoranti")
        } detail: {
            switch selectedItem {
            case .map:
                RestaurantMapView(dataService: dataService)
            case .list:
                EpisodeListView(dataService: dataService)
            case .nearest:
                NearestLocationsView(dataService: dataService)
            case .ai:
                AISuggestionsView(dataService: dataService)
            case .none:
                Text("Seleziona una voce dal menu")
                    .foregroundColor(.secondary)
            }
        }
        .focusedSceneValue(\.selectedNavigationItem, $selectedItem)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dockNavigate"))) { notification in
            if let item = notification.object as? NavigationItem {
                selectedItem = item
            }
        }
        .tint(.cyan)
    }
}

#Preview {
    ContentView()
}
