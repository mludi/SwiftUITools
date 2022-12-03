//
//  NumberPadButton.swift
//  
//
//  Created by Oliver Epper on 01.12.22.
//
import SwiftUI

struct PressedModifier: ViewModifier {
    enum ButtonState {
        case pressed
        case notPressed
    }

    @GestureState private var isPressed = false
    let onChange: (ButtonState) -> Void

    func body(content: Content) -> some View {
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

public struct ButtonEvent {
    public enum Modifier: CustomStringConvertible {
        case isLongPress
        case control

        public var description: String {
            switch self {
            case .isLongPress:
                return "long press"
            case .control:
                return "control"
            }
        }
    }

    public let key: String
    public let modifier: Modifier?

    public init(key: String, modifier: Modifier? = nil) {
        self.key = key
        self.modifier = modifier
    }
}


public struct NumberPadButton<T: View>: View {
    @resultBuilder
    public struct ButtonContent {
        public static func buildBlock<T: View>(_ content: T) -> T { content }
    }

    @State private var pressed = false
    @State private var disableShortTap = false

    let key: String
    let content: T
    let onPress: (ButtonEvent) -> Void

    let radius: CGFloat = 12

    public init(key: String, onPress: @escaping (ButtonEvent) -> Void, @ButtonContent builder: () -> T) {
        self.key = key
        self.onPress = onPress
        self.content = builder()
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius).fill(.clear)
            content
        }
        .contentShape(RoundedRectangle(cornerRadius: radius))
        .modifier(PressedModifier(onChange: { state in
            if state == .pressed {
                pressed = true
            } else {
                withAnimation(.easeOut(duration: 0.1)) {
                    pressed = false
                }
            }
        }))
#if os(iOS)
        .simultaneousGesture(TapGesture().exclusively(before: LongPressGesture(minimumDuration: 0.1)).onEnded({ value in
            switch value {
            case .first:
                onPress(.init(key: key))
            default:
                onPress(.init(key: key, modifier: .isLongPress))
            }
        }))
#endif
#if os(macOS)
        .simultaneousGesture(TapGesture().modifiers(.control).exclusively(before: TapGesture()).onEnded({ value in
            switch value {
            case .first:
                onPress(.init(key: key, modifier: .control))
            default:
                if (!disableShortTap) { onPress(.init(key: key)) }
            }
        }))
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.1)
                .onEnded({ _ in
                    disableShortTap = true
                    onPress(.init(key: key, modifier: .isLongPress))
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                        disableShortTap = false
                    }
                }))
#endif
        .scaleEffect(pressed ? 0.9 : 1)
    }

    let Radius: CGFloat = 12
}
