//
//  AppDelegate.swift
//  NoMoPromoClassifier
//
//  Created by Jacob Clayden on 23/03/2020.
//  Copyright © 2020 Jacob Clayden. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var classifiedDict = UserDefaults.standard.dictionary(forKey: .kClassifiedDictKey) as? [String: Bool] ?? [String: Bool]()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 675, height: 380),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.setFrameAutosaveName("Main Window")

        loadDirectorySelectionView()
        DispatchQueue.global().async { [weak self] in
            try? self?.loadClassifierView(instaloaderFeedPath: UserDefaults.standard.string(forKey: .kLastUsedPathKey) ?? "")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        UserDefaults.standard.set(classifiedDict, forKey: .kClassifiedDictKey)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func loadDirectorySelectionView() {
        let contentView = NSHostingView(rootView: DirectorySelectionView(path: UserDefaults.standard.string(forKey: .kLastUsedPathKey) ?? ""))
        switchContentView(to: contentView)
    }

    func loadClassifierView(instaloaderFeedPath feedPath: String) throws {
        do {
            let contentView = NSHostingView(rootView: try ClassifierView(instaloaderFeedPath: feedPath))
            self.switchContentView(to: contentView)
        } catch {
            throw error
        }
    }

    private func switchContentView(to contentView: NSView) {
        DispatchQueue.main.async { [weak self] in
            contentView.alphaValue = 0
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                self?.window.contentView?.animator().alphaValue = 0
            }) { [weak self] in
                self?.window.contentView = contentView
                self?.window.makeKeyAndOrderFront(nil)
                NSAnimationContext.runAnimationGroup { [weak self] context in
                    context.duration = 0.5
                    self?.window.contentView?.animator().alphaValue = 1
                }
            }
        }
    }
}
