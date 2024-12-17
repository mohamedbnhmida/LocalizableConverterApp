//
//  LocalizableConverterApp.swift
//  LocalizableConverter
//
//  Created by Mohamed Ben Hmida on 2024/12/11.
//

import SwiftUI
@main
struct LocalizableConverter: App {
    @State private var selectedFilePath: URL? = nil  // Declare the filePath as @State
    @State private var selectedTab: Int = 0  // State to track the selected tab

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                
                SearchView(selectedFilePath: $selectedFilePath, selectedTab: $selectedTab)
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(0)  // Assign tag for Search tab
                
                ConvertView(filePath: $selectedFilePath)
                    .tabItem {
                        Label("Convert", systemImage: "arrow.2.circlepath")
                    }
                    .tag(1)  // Assign tag for Convert tab
            }
        }
    }
}
