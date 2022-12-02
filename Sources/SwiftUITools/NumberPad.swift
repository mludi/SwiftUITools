//
//  NumberPad.swift
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

        public var description: String {
            switch self {
            case .isLongPress:
                return "long press"
            }
        }
    }

    public let key: String
    public let modifier: Modifier?

    init(key: String, modifier: Modifier? = nil) {
        self.key = key
        self.modifier = modifier
    }
}


struct NumberPadButton: View {
    @State private var pressed = false

    let key: String
    let title: String
    let subtitle: String?
    let onPress: (ButtonEvent) -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Self.Radius).stroke(Color.accentColor)
            VStack {
                Text(verbatim: title).font(.headline)
                if let subtitle {
                    Text(verbatim: subtitle).font(.subheadline)
                }
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: Self.Radius))
        .modifier(PressedModifier(onChange: { state in
            if state == .pressed {
                pressed = true
            } else {
                withAnimation(.easeOut(duration: 0.1)) {
                    pressed = false
                }
            }
        }))
        .simultaneousGesture(TapGesture().onEnded({ _ in
            onPress(.init(key: key))
        }))
        .simultaneousGesture(LongPressGesture().onEnded({ _ in
            onPress(.init(key: key, modifier: .isLongPress))
        }))
        .scaleEffect(pressed ? 0.9 : 1)
    }

    static let Radius: CGFloat = 12
}

public struct NumberPad: View {
    var showDeleteButton: Bool
    var onPress: (ButtonEvent) -> Void

    var keys = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["*", "0", "#"]
    ]

    public var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 20) {
            ForEach(keys, id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { button in
                        view(for: button)
                    }
                }
            }
            GridRow {
                Spacer()
                Spacer()
                if showDeleteButton {
                    view(for: "delete")
                } else {
                    view(for: "delete").hidden()
                }
            }
        }
    }

    private func view(for key: String) -> some View {
        let (title, subtitle) = Self.ButtonDefaults[key] ?? (key, nil)
        return NumberPadButton(key: key, title: title, subtitle: subtitle) { evt in
            onPress(evt)
        }
    }

    static var ButtonDefaults: [String: (String, String?)] = [
        "delete"    : ("⌫", nil),
        "1"         : ("1", ""),
        "2"         : ("2", "ABC"),
        "3"         : ("3", "DEF"),
        "4"         : ("4", "GHI"),
        "5"         : ("5", "JKL"),
        "6"         : ("6", "MNO"),
        "7"         : ("7", "PQRS"),
        "8"         : ("8", "TUV"),
        "9"         : ("9", "WXYZ"),
        "*"         : ("*", nil),
        "0"         : ("0", "+"),
        "#"         : ("#", nil),
    ]
}

extension NumberPad {
    public init(showDeleteButton: Bool = false, onPress: @escaping (ButtonEvent) -> Void) {
        self.showDeleteButton = showDeleteButton
        self.onPress = onPress
    }
}
