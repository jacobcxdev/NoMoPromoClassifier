//
//  Classifier.swift
//  NoMoPromoClassifier
//
//  Created by Jacob Clayden on 23/03/2020.
//  Copyright © 2020 Jacob Clayden. All rights reserved.
//

import AppKit

class Classifier: ObservableObject {
    @Published var currentImageIndex = 0
    @Published var currentPost: Post? {
        didSet {
            currentImageIndex = 0
        }
    }
    var posts = [Post]()

    var currentPostIndex: Int {
        if let post = currentPost, let index = posts.firstIndex(of: post) {
            return index
        }
        return -1
    }

    init(instaloaderFeedPath feedPath: String) throws {
        do {
            let feedURL = URL(fileURLWithPath: feedPath)
            guard let urls = FileManager.default.enumerator(at: feedURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)?.allObjects as? [URL] else {
                throw RuntimeError(sender: self, description: "Error reading directory.")
            }
            try urls.filter({ $0.pathExtension == "txt" }).forEach {
                let identifier = String($0.deletingPathExtension().lastPathComponent)
                let text = try String(contentsOf: $0)
                posts.append(Post(identifier: identifier, text: text))
            }
            urls.filter({ $0.pathExtension == "jpg" }).forEach {
                let identifier = String($0.deletingPathExtension().lastPathComponent)
                if let post = posts.first(where: { identifier.contains($0.identifier) }) {
                    post.imageURLs.append($0)
                    post.imageURLs.sort { $0.absoluteString < $1.absoluteString }
                }
            }
            guard !posts.isEmpty else {
                throw RuntimeError(sender: self, description: "No posts found.")
            }
            try nextPost()
        } catch {
            throw error
        }
    }

    func setisAd(_ isAd: Bool) throws {
        guard let post = currentPost else {
            throw RuntimeError(sender: self, description: "No post selected.")
        }
        post.isAd = isAd
        do {
            try nextUnclassifiedPost()
        } catch {
            throw error
        }
    }

    func nextUnclassifiedPost() throws {
        let unclassifiedPosts = posts.filter { $0.isAd == nil }
        guard let post = unclassifiedPosts.first else {
            throw RuntimeError(sender: self, description: "No unclassified posts found.")
        }
        currentPost = post
    }

    func previousPost() throws {
        guard let post = posts[safe: currentPostIndex - 1] else {
            throw RuntimeError(sender: self, description: "No previous posts.")
        }
        currentPost = post
    }

    func nextPost() throws {
        if let post = posts[safe: currentPostIndex + 1] {
            currentPost = post
        } else {
            do {
                try nextUnclassifiedPost()
            } catch {
                throw error
            }
        }
    }

    func export() {
        var output = "Text,isAd\n"
        posts.forEach {
            let text = $0.text.asciiString().replacingOccurrences(of: "\"", with: "\\\"").condensedWhitespace
            if let isAd = $0.isAd, !text.isEmpty {
                output += "\"\(text)\",\(isAd)\n"
            }
        }
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "ClassifierOutput"
        savePanel.allowedFileTypes = ["csv"]
        savePanel.begin {
            guard $0 == .OK, let url = savePanel.url else {
                return
            }
            do {
                try output.write(to: url, atomically: true, encoding: .ascii)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
