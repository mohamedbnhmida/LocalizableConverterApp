//
//  ConvertView.swift
//  LocalizableConverter
//
//  Created by Mohamed Ben Hmida on 2024/12/17.
//

import SwiftUI
import Foundation
import SwiftUI
 
// MARK: - Convert View
struct ConvertView: View {
    @Binding var filePath: URL?  // Use @Binding to link the filePath
    @State private var conversionStatus: String = ""
    @State private var showSaveAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Localizable Strings Converter")
                .font(.title)
                .padding()
            
            if let filePath = filePath {
                Text("Selected File: \(filePath.lastPathComponent)")
                    .foregroundColor(.green)
            } else {
                Text("No file selected")
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 20) {
                Button(action: browseFile) {
                    Text("Browse File")
                        .frame(maxWidth: 200)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: convertAndSaveToCustomLocation) {
                    Text("Convert & Save")
                        .frame(maxWidth: 200)
                }
                .buttonStyle(.borderedProminent)
                .disabled(filePath == nil)
            }
            .padding(.horizontal)
            
            Text(conversionStatus)
                .foregroundColor(.blue)
                .padding()
        }
        .frame(minWidth: 400, minHeight: 300)
        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
            handleDrop(providers)
        }
        .alert("Conversion Successful", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The file has been successfully converted and saved to your selected location.")
        }
    }
    
    func browseFile() {
        let panel = NSOpenPanel()
        panel.title = "Choose a Localizable.strings file"
        panel.allowedFileTypes = ["strings"]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            filePath = panel.url
            conversionStatus = "File selected: \(panel.url?.lastPathComponent ?? "")"
        }
    }
    
    func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                    DispatchQueue.main.async {
                        if let urlData = urlData as? Data, let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                            if url.pathExtension == "strings" {
                                self.filePath = url
                                self.conversionStatus = "File selected: \(url.lastPathComponent)"
                            } else {
                                self.conversionStatus = "Invalid file type. Please select a .strings file."
                            }
                        }
                    }
                }
                return true
            }
        }
        return false
    }
    
    func convertAndSaveToCustomLocation() {
        guard let filePath = filePath else { return }
        
        do {
            let savePanel = NSSavePanel()
            savePanel.title = "Save Converted File"
            savePanel.allowedFileTypes = ["strings"]
            savePanel.nameFieldStringValue = "ConvertedLocalizable.strings"
            
            let response = savePanel.runModal()
            
            if response == .OK, let outputPath = savePanel.url {
                try FileManager.default.copyItem(at: filePath, to: outputPath)
                
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/plutil")
                process.arguments = ["-convert", "xml1", outputPath.path]
                try process.run()
                process.waitUntilExit()
                
                if process.terminationStatus == 0 {
                    if let data = try? Data(contentsOf: outputPath),
                       let xmlDoc = try? XMLDocument(data: data) {
                        
                        var localizableContent = ""
                        
                        if let dictElements = xmlDoc.rootElement()?.elements(forName: "dict") {
                            for dictElement in dictElements {
                                let keys = dictElement.elements(forName: "key")
                                let values = dictElement.elements(forName: "string")
                                
                                for (key, value) in zip(keys, values) {
                                    if let keyText = key.stringValue, let valueText = value.stringValue {
                                        localizableContent += "\"\(keyText)\" = \"\(valueText)\";\n"
                                    }
                                }
                            }
                        }
                        
                        try localizableContent.write(toFile: outputPath.path, atomically: true, encoding: .utf8)
                        showSaveAlert = true
                        conversionStatus = "File successfully converted and saved."
                    }
                } else {
                    throw NSError(domain: "com.example.plutil", code: 1, userInfo: [NSLocalizedDescriptionKey: "plutil conversion failed."])
                }
            }
        } catch {
            conversionStatus = "Error during conversion: \(error.localizedDescription)"
        }
    }
}
