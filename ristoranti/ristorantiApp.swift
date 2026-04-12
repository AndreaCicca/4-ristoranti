//
//  ristorantiApp.swift
//  ristoranti
//
//  Created by Andrea on 06/12/25.
//

import SwiftUI

#if os(macOS)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        
        // Add items to the macOS Dock Menu
        let mapItem = NSMenuItem(title: "Mappa", action: #selector(navigateToMap), keyEquivalent: "")
        mapItem.target = self
        let listItem = NSMenuItem(title: "Lista", action: #selector(navigateToList), keyEquivalent: "")
        listItem.target = self
        let nearestItem = NSMenuItem(title: "Vicino a me", action: #selector(navigateToNearest), keyEquivalent: "")
        nearestItem.target = self
        let aiItem = NSMenuItem(title: "AI", action: #selector(navigateToAI), keyEquivalent: "")
        aiItem.target = self
        
        menu.addItem(mapItem)
        menu.addItem(listItem)
        menu.addItem(nearestItem)
        menu.addItem(aiItem)
        
        return menu
    }
    
    @objc func navigateToMap() { NotificationCenter.default.post(name: Notification.Name("dockNavigate"), object: NavigationItem.map) }
    @objc func navigateToList() { NotificationCenter.default.post(name: Notification.Name("dockNavigate"), object: NavigationItem.list) }
    @objc func navigateToNearest() { NotificationCenter.default.post(name: Notification.Name("dockNavigate"), object: NavigationItem.nearest) }
    @objc func navigateToAI() { NotificationCenter.default.post(name: Notification.Name("dockNavigate"), object: NavigationItem.ai) }
}
#endif

@main
struct ristorantiApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) { } // Rimuove "New Item" non pertinente
            CommandGroup(after: .sidebar) {
                Divider()
                NavigationViewCommands()
            }
        }
    }
}

struct NavigationViewCommands: View {
    @FocusedBinding(\.selectedNavigationItem) var selectedItem
    
    var body: some View {
        Picker("Navigazione", selection: $selectedItem) {
            Text("Mappa")
                .tag(NavigationItem?.some(.map))
                .keyboardShortcut("1", modifiers: .command)
            
            Text("Lista")
                .tag(NavigationItem?.some(.list))
                .keyboardShortcut("2", modifiers: .command)
            
            Text("Vicino a me")
                .tag(NavigationItem?.some(.nearest))
                .keyboardShortcut("3", modifiers: .command)
            
            Text("AI")
                .tag(NavigationItem?.some(.ai))
                .keyboardShortcut("4", modifiers: .command)
        }
        .pickerStyle(.inline)
    }
}

