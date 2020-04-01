//
//  ClassifierView.swift
//  NoMoPromoClassifier
//
//  Created by Jacob Clayden on 23/03/2020.
//  Copyright © 2020 Jacob Clayden. All rights reserved.
//

import SwiftUI

struct ClassifierView: View {
    @ObservedObject var classifier: Classifier
    @State private var showAlert = false
    @State private var alert = Alert.init(title: Text("Alert")) {
        didSet {
            showAlert = true
        }
    }
    
    var post: Post {
        classifier.currentPost ?? .null
    }
    var currentImage: NSImage? {
        guard let imageURL = post.imageURLs[safe: classifier.currentImageIndex], let image = NSImage(contentsOf: imageURL) else {
            return nil
        }
        return image
    }

    var body: some View {
        HStack {
            Group {
                if currentImage != nil {
                    Image(nsImage: currentImage!)
                        .resizable()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .blur(radius: 10)
                        .clipped()
                        .overlay(
                            Image(nsImage: currentImage!)
                                .resizable()
                                .scaledToFit()
                                .shadow(radius: 10)
                        )
                } else {
                    Text("No image 􀏅")
                }
            }
            .frame(width: 360, height: 360)
            .frame(minHeight: 0, maxHeight: .infinity)
            .background(Color(.underPageBackgroundColor))
            .shadow(radius: 2)
            .overlay(imageArrows())
            .overlay(imageDots())
            VStack(spacing: 0) {
                Divider()
                    .padding(.bottom, 10)
                Text("Identifier")
                    .font(.headline)
                    .padding(.bottom, 5)
                Text(post.identifier)
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
                        NSPasteboard.general.setString(self.post.identifier, forType: .string)
                    }
                Divider()
                    .padding(10)
                Text("Caption")
                    .font(.headline)
                    .padding(.bottom, 5)
                ScrollView {
                    Text(post.text)
                        .frame(width: 180)
                        .onTapGesture {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(self.post.text, forType: .string)
                        }
                }
                .frame(height: 100)
                .padding(5)
                .background(Color(.textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black)
                )
                Divider()
                    .padding(10)
                HStack {
                    Text("Classified: ")
                        .font(.footnote)
                        + Text("\(classifier.posts.filter({ $0.isAd != nil }).count)")
                            .font(.system(.footnote, design: .monospaced))
                    Text("Current: ")
                        .font(.footnote)
                        + Text("\((classifier.posts.firstIndex(of: post) ?? -1) + 1)")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(post.isAd == nil ? .primary : post.isAd! ? .green : .red)
                        + Text("/\(classifier.posts.count)")
                            .font(.system(.footnote, design: .monospaced))
                }
                Divider()
                    .padding(10)
                HStack {
                    VStack {
                        HStack {
                            Button("􀆄") {
                                do {
                                    try self.classifier.setisAd(false)
                                } catch {
                                    self.showAlertFromError(error)
                                }
                            }
                            .foregroundColor(.red)
                            Button("􀆅") {
                                do {
                                    try self.classifier.setisAd(true)
                                } catch {
                                    self.showAlertFromError(error)
                                }
                            }
                            .foregroundColor(.green)
                            Button("􀈃") {
                                DispatchQueue.main.async {
                                    self.classifier.export()
                                }
                            }
                        }
                        HStack {
                            Button("􀄦") {
                                do {
                                    try self.classifier.previousPost()
                                } catch {
                                    self.showAlertFromError(error)
                                }
                            }
                            Button("􀄧") {
                                do {
                                    try self.classifier.nextPost()
                                } catch {
                                    self.showAlertFromError(error)
                                }
                            }
                            Button("􀊌") {
                                do {
                                    try self.classifier.nextUnclassifiedPost()
                                } catch {
                                    self.showAlertFromError(error)
                                }
                            }
                        }
                    }
                    Button("􀅳") {
                        self.alert = Alert(title: Text("Information"), message: { () -> Text in
                            Text("• Press ")
                                + Text("􀆄")
                                    .foregroundColor(.red)
                                + Text(" / ")
                                + Text("􀆅")
                                    .foregroundColor(.green)
                                + Text(" to classify the post as being an ad or not.\n• Press 􀄦 / 􀄧 to navigate between posts, or press 􀊌 to jump to the next unclassified post.\n• Press 􀈃 to export the results as a CSV.")
                        }(), primaryButton: .default(Text("Okay")), secondaryButton: .destructive(Text("Reset Classification"), action: {
                            UserDefaults.standard.removeObject(forKey: .kClassifiedDictKey)
                        }))
                    }
                }
            }
            .padding()
        }
        .fixedSize()
        .alert(isPresented: $showAlert, content: {
            self.alert
        })
        .overlay(
            Button("􀆜") {
                do {
                    guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
                        throw RuntimeError(sender: self, description: "AppDelegate not found.")
                    }
                    appDelegate.loadDirectorySelectionView()
                } catch {
                    self.showAlertFromError(error)
                }
            }
            .background(
                Color(.controlBackgroundColor)
                    .opacity(0.75)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.controlDarkShadowColor))
            )
            .shadow(radius: 10)
            .padding(10),
            alignment: .topLeading
        )
    }

    init(instaloaderFeedPath feedPath: String) throws {
        do {
            classifier = try Classifier(instaloaderFeedPath: feedPath)
        } catch {
            throw error
        }
    }

    func imageArrows() -> some View {
        post.imageURLs.count > 1 ? AnyView(
            HStack {
                Button("􀁻") {
                    self.classifier.currentImageIndex -= self.classifier.currentImageIndex > 0 ? 1 : 0
                }
                .background(
                    Color(.controlBackgroundColor)
                        .opacity(0.75)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.controlDarkShadowColor))
                )
                .shadow(radius: 10)
                Spacer()
                Button("􀁽") {
                    self.classifier.currentImageIndex += self.classifier.currentImageIndex < self.post.imageURLs.count - 1 ? 1 : 0
                }
                .background(
                    Color(.controlBackgroundColor)
                        .opacity(0.75)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.controlDarkShadowColor))
                )
                .shadow(radius: 10)
            }
            .padding()
        ) : AnyView(EmptyView())
    }

    func imageDots() -> some View {
        guard post.imageURLs.count > 1 else {
            return AnyView(EmptyView())
        }
        var dots = String(repeating: "􀀀", count: post.imageURLs.count - 1)
        dots.insert(contentsOf: "􀕩", at: dots.index(dots.startIndex, offsetBy: classifier.currentImageIndex))
        return AnyView(
            VStack {
                Spacer()
                Text(dots)
                    .padding(5)
                    .background(
                        Color(.controlBackgroundColor)
                            .opacity(0.75)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.controlDarkShadowColor))
                    )
                    .shadow(radius: 10)
            }
            .padding()
        )
    }
    
    func showAlertFromError(_ error: Error) {
        alert = Alert(title: Text(error.localizedDescription))
    }
}


struct ClassifierView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            return AnyView(try ClassifierView(instaloaderFeedPath: "/Users/jacob/Desktop/Git/NoMoPromo/ML/Scraped/:feed"))
        } catch {
            return AnyView(Text("Error: \(error.localizedDescription)"))
        }
    }
}
