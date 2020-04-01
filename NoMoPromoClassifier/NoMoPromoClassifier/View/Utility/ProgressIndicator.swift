//
//  ProgressIndicator.swift
//  NoMoPromoClassifier
//
//  Created by Jacob Clayden on 24/03/2020.
//  Copyright © 2020 Jacob Clayden. All rights reserved.
//

import SwiftUI

struct ProgressIndicator: NSViewRepresentable {
    @Binding var isAnimating: Bool
    let style: NSProgressIndicator.Style
    let controlSize: NSControl.ControlSize

    func makeNSView(context: NSViewRepresentableContext<ProgressIndicator>) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        indicator.style = style
        indicator.controlSize = controlSize
        return indicator
    }

    func updateNSView(_ NSView: NSProgressIndicator, context: NSViewRepresentableContext<ProgressIndicator>) {
        isAnimating ? NSView.startAnimation(nil) : NSView.stopAnimation(nil)
    }

    init(style: NSProgressIndicator.Style, controlSize: NSControl.ControlSize = .regular, isAnimating: Binding<Bool> = .constant(true)) {
        self.style = style
        self.controlSize = controlSize
        self._isAnimating = isAnimating
    }
}

struct ProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ProgressIndicator(style: .spinning)
    }
}
