//
//  PressedModifier.swift
//  
//
//  Created by Oliver Epper on 04.12.22.
//

import SwiftUI

public struct PressedModifier: ViewModifier {
    enum ButtonState {
        case pressed
        case notPressed
    }

    @GestureState private var isPressed = false
    let onChange: (ButtonState) -> Void

    public func body(content: Content) -> some View {
        let drag = DragGesture(minimumDistance: 0)
            .updating($isPressed) { value, gestureState, transition in
                gestureState = true
            }

        return content
            .gesture(drag)
            .onChange(of: isPressed) { pressed in
                if pressed {
                    self.onChange(.pressed)
                } else {
                    self.onChange(.notPressed)
                }
            }
    }
}
