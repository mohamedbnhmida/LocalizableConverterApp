//
//  SearchView.swift
//  LocalizableConverter
//
//  Created by Mohamed Ben Hmida on 2024/12/17.
//

import SwiftUI
import Foundation
import SwiftUI
 

struct SearchView: View {
    @Binding var selectedFilePath: URL?  // Binding to pass selected file path
    @Binding var selectedTab: Int       // Binding to change the tab

    @State private var searchText: String = ""
    @State private var searchResults: [SearchResultItem] = []
    @State private var selectedResult: SearchResultItem? = nil // Track the selected result
    @State private var fileContent: String? = nil
    @State private var projectFolder: URL? = nil
    @State private var podsFolder: URL? = nil
    @State private var isSearching: Bool = false
    @State private var highlightedRanges: [NSRange] = [] // Store the ranges of highlighted text

    var body: some View {
        VStack(spacing: 20) {
            Text("Search Strings")
                .font(.title)
                .padding()

            TextField("Enter search text", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
        
            HStack {
                Button(action: browseProjectFolder) {
                    Text("Browse Project Folder")
                }
                .buttonStyle(.borderedProminent)

                Button(action: performSearch) {
                    Text("Search")
                }
                .buttonStyle(.borderedProminent)
                .disabled(searchText.isEmpty || podsFolder == nil || isSearching)
            }

            if let projectFolder = projectFolder {
                Text("Selected Project Folder: \(projectFolder.lastPathComponent)")
                    .foregroundColor(.green)
            } else {
                Text("No project folder selected")
                    .foregroundColor(.gray)
            }

            if let podsFolder = podsFolder {
                Text("Pods Directory: \(podsFolder.path)")
                    .foregroundColor(.blue)
            } else {
                Text("Pods directory not found")
                    .foregroundColor(.red)
            }
            
            if isSearching {
                ProgressView("Searching...")
                    .padding()
            }

            HStack {
                VStack  (alignment: .leading){
                    ScrollView  {
                        ForEach(searchResults) { result in
                            HStack{
                                Text(result.displayText).multilineTextAlignment(.leading)
                                    .foregroundColor(result.id == selectedResult?.id ? .yellow : .primary) // Highlight only the selected result
                                    .onTapGesture {
                                        selectedResult = result
                                        loadFileContent(for: result.filePath)
                                    }
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .frame(maxWidth: selectedResult != nil ? 500 : Double.infinity).padding()

                }

                if let fileContent = fileContent {
                    ScrollView {
                        VStack(alignment: .leading) {
                            displayHighlightedText(from: fileContent)
                        }
                    }
                    .padding()
                    .border(Color.gray, width: 1)
                } else {
                    Divider()
                    Text("Select a file to preview its content.")
                        .foregroundColor(.gray).padding()
                }
            }
            
            if selectedResult != nil {
                Button("Select") {
                    if let selectedResult = selectedResult {
                        selectedFilePath = URL(fileURLWithPath: selectedResult.filePath)
                        selectedTab = 1 // Navigate to the Convert tab
                    }
                }.padding()
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    func browseProjectFolder() {
        let panel = NSOpenPanel()
        panel.title = "Choose the Project Folder"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false

        if panel.runModal() == .OK, let selectedFolder = panel.url {
            projectFolder = selectedFolder
            let potentialPodsPath = selectedFolder.appendingPathComponent("Pods")
            if FileManager.default.fileExists(atPath: potentialPodsPath.path) {
                podsFolder = potentialPodsPath
            } else {
                podsFolder = nil
            }
        }
    }

    func performSearch() {
        guard let podsFolder = podsFolder else { return }
        fileContent = nil
        isSearching = true
        searchResults = []
        selectedResult = nil
        highlightedRanges = [] // Reset the highlighted ranges
        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            let pipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/usr/bin/grep")
            process.arguments = ["-r", self.searchText, "--include=*.strings", podsFolder.path]
            process.standardOutput = pipe

            do {
                try process.run()
                process.waitUntilExit()

                let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: outputData, encoding: .utf8) {
                    let matches = output.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                    let cleanMatches = matches.map { match in
                        var cleanedMatch = match.replacingOccurrences(of: "Binary file ", with: "")
                        if let range = cleanedMatch.range(of: ".strings") {
                            cleanedMatch = String(cleanedMatch[..<range.upperBound])
                        }
                        return SearchResultItem(filePath: cleanedMatch, displayText: cleanedMatch)
                    }

                    // Ensure files appear once by filtering duplicates
                    let uniqueResults = Array(Set(cleanMatches.map { $0.filePath }).map { filePath in
                        cleanMatches.first { $0.filePath == filePath }!
                    })

                    DispatchQueue.main.async {
                        self.searchResults = uniqueResults
                        self.isSearching = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isSearching = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isSearching = false
                }
            }
        }
    }

    func loadFileContent(for filePath: String) {
        let fileURL = URL(fileURLWithPath: filePath)

        do {
            let data = try Data(contentsOf: fileURL)
            if let content = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.fileContent = content
                    self.highlightedRanges = findSearchTextOccurrences(in: content, with: searchText) // Find exact occurrences
                }
            } else {
                let lossyContent = String(decoding: data, as: UTF8.self)
                DispatchQueue.main.async {
                    self.fileContent = lossyContent
                    self.highlightedRanges = findSearchTextOccurrences(in: lossyContent, with: searchText)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.fileContent = "Unable to read file content. Error: \(error.localizedDescription)"
            }
        }
    }

    func displayHighlightedText(from text: String) -> Text {
        var resultText = Text("")
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)

        // Search for exact occurrences of the search text and highlight it
        let searchRange = NSRange(location: 0, length: nsText.length)
        var lastRangeEnd = 0

        while true {
            let range = nsText.range(of: searchText, options: .caseInsensitive, range: NSRange(location: lastRangeEnd, length: nsText.length - lastRangeEnd))
            
            if range.location == NSNotFound {
                break // No more occurrences found
            }

            if lastRangeEnd < range.location {
                let beforeMatch = nsText.substring(with: NSRange(location: lastRangeEnd, length: range.location - lastRangeEnd))
                resultText = resultText + Text(beforeMatch).foregroundColor(.primary)
            }

            let match = nsText.substring(with: range)
            resultText = resultText + Text(match).foregroundColor(.yellow)

            lastRangeEnd = range.location + range.length
        }

        if lastRangeEnd < nsText.length {
            let remainingText = nsText.substring(from: lastRangeEnd)
            resultText = resultText + Text(remainingText).foregroundColor(.primary)
        }

        return resultText
    }

    func findSearchTextOccurrences(in text: String, with searchText: String) -> [NSRange] {
        var ranges: [NSRange] = []
        let nsText = text as NSString
        let range = NSRange(location: 0, length: nsText.length)

        var lastRangeEnd = 0

        while true {
            let range = nsText.range(of: searchText, options: .caseInsensitive, range: NSRange(location: lastRangeEnd, length: nsText.length - lastRangeEnd))
            
            if range.location == NSNotFound {
                break // No more occurrences found
            }

            ranges.append(range)
            lastRangeEnd = range.location + range.length
        }

        return ranges
    }
}

