//
//  NumberPadButton.swift
//  
//
//  Created by Oliver Epper on 01.12.22.
//
import SwiftUI

extension View {
    func pressed(onChange: @escaping (PressedModifier.ButtonState) -> Void) -> some View {
        modifier(PressedModifier(onChange: onChange))
    }
}

public enum ProgrammableButton {

    public struct Key: Identifiable, Hashable {
        public let id: String

        public init(id: String) {
            self.id = id
        }
    }

    public struct Event {
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

        public let key: Key
        public let modifier: Modifier?

        public init(key: Key, modifier: Modifier? = nil) {
            self.key = key
            self.modifier = modifier
        }
    }

    public struct Button<T: View>: View {
        @ViewBuilder var content: T
        @State private var pressed = false
        @State private var disableShortTap = false

        let key: Key
        let onPress: (Event) -> Void

        let radius: CGFloat = 12

        public init(key: Key, onPress: @escaping (Event) -> Void, @ViewBuilder builder: () -> T) {
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
            .pressed(onChange: { state in
                if state == .pressed {
                    pressed = true
                } else {
                    withAnimation(.easeOut(duration: 0.1)) {
                        pressed = false
                    }
                }
            })
#if os(iOS)
            .simultaneousGesture(TapGesture().exclusively(before: LongPressGesture()).onEnded({ value in
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
                LongPressGesture(minimumDuration: 0.3)
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
}
