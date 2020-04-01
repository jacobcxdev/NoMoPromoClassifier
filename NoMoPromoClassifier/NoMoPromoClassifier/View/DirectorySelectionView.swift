//
//  DirectorySelectionView.swift
//  NoMoPromoClassifier
//
//  Created by Jacob Clayden on 24/03/2020.
//  Copyright © 2020 Jacob Clayden. All rights reserved.
//

import SwiftUI

struct DirectorySelectionView: View {
    @State var path = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alert = Alert.init(title: Text("Alert")) {
        didSet {
            showAlert = true
        }
    }
    
    let command = [
        ("instaloader", Color("function")),
        (":feed", Color("keyword")),
        ("-l", Color("option")),
        ("<your_username>", Color("string")),
        ("-V", Color("option")),
        ("--no-metadata-json", Color("attribute")),
        ("--no-profile-pic", Color("attribute"))
    ]
    let instaloaderURL = URL(string: "https://instaloader.github.io/")!

    var body: some View {
        VStack(spacing: 0) {
            Text("Instructions:")
                .font(.largeTitle)
            Divider()
                .padding(10)
            VStack(alignment: .leading) {
                Group {
                    Text("1)\tInstall ")
                        + Text("Instaloader")
                            .bold()
                        + Text(" in accordance with the instructions at ")
                        + Text(instaloaderURL.absoluteString)
                            .underline()
                            .foregroundColor(.blue)
                        + Text(".")
                }
                .onTapGesture {
                    NSWorkspace.shared.open(self.instaloaderURL)
                }
                .padding(.bottom)
                Group {
                    Text("2)\tRun the command below in Terminal, replacing ")
                        + Text(command[3].0)
                            .foregroundColor(command[3].1)
                        + Text(" with your Instagram username.\n\tYou may press 􀆍C to exit early.")
                }
                .padding(.bottom)
                VStack(alignment: .center) {
                    commandTextView()
                        .font(.system(.caption, design: .monospaced))
                        .padding(5)
                        .background(Color(.textBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black)
                    )
                        .onTapGesture {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(self.command.map(\.0).joined(separator: " "), forType: .string)
                    }
                    .padding(.bottom)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                Text("3)\tAfter the command above has completed, input the path of the output directory below.")
                    .padding(.bottom)
                HStack {
                    TextField("Instaloader Output Directory Path", text: $path) {
                        self.enter()
                    }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                    Button("􀈅") {
                        DispatchQueue.main.async {
                            let openPanel = NSOpenPanel()
                            openPanel.allowsMultipleSelection = false
                            openPanel.canChooseDirectories = true
                            openPanel.canChooseFiles = false
                            openPanel.begin {
                                guard $0 == .OK, let url = openPanel.url else {
                                    return
                                }
                                self.path = url.path
                            }
                        }
                    }
                }
            }
            .padding()
            Divider()
                .padding()
            VStack {
                if isLoading {
                    ProgressIndicator(style: .spinning)
                } else {
                    Button("􀅇") {
                        self.enter()
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .font(.subheadline)
        .fixedSize()
        .padding()
        .disabled(isLoading)
        .alert(isPresented: $showAlert, content: {
            self.alert
        })
    }

    func commandTextView() -> Text {
        var text = Text("")
        command.enumerated().forEach {
            text = text + Text(($0 == 0 ? "" : " ") + $1.0)
                .foregroundColor($1.1)
        }
        return text
    }

    func enter() {
        isLoading = true
        DispatchQueue.global().async {
            do {
                UserDefaults.standard.set(self.path, forKey: .kLastUsedPathKey)
                guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
                    throw RuntimeError(sender: self, description: "AppDelegate not found")
                }
                try appDelegate.loadClassifierView(instaloaderFeedPath: self.path)
            } catch {
                DispatchQueue.main.async {
                    self.showAlertFromError(error)
                    self.isLoading = false
                }
            }
        }
    }

    func showAlertFromError(_ error: Error) {
        alert = Alert(title: Text(error.localizedDescription))
    }
}

struct DirectorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DirectorySelectionView()
    }
}
