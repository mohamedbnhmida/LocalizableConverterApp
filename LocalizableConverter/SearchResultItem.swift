//
//  SearchResultItem.swift
//  LocalizableConverter
//
//  Created by Mohamed Ben Hmida on 2024/12/17.
//
import SwiftUI
import Foundation
import SwiftUI
struct SearchResultItem: Identifiable {
    let id = UUID()  // Unique identifier for each result
    let filePath: String
    let displayText: String
} 
