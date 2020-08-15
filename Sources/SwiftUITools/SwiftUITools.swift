//
//  SwiftUITools.swift
//
//
//  Created by Oliver Epper on 15.08.20.
//
//  Thanks to: https://finestructure.co/blog/2020/1/20/swiftui-equal-widths-view-constraints


import SwiftUI


public protocol Preference {}

public struct AppendValue<T: Preference>: PreferenceKey {
    public static var defaultValue: [CGFloat] { [] }

    public static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

public struct GeometryPreferenceReader<K: PreferenceKey, V> where K.Value == V {
    public let key: K.Type
    public let value: (GeometryProxy) -> V

    public init(key: K.Type, value: @escaping (GeometryProxy) -> V) {
        self.key = key
        self.value = value
    }
}

extension GeometryPreferenceReader: ViewModifier {
    public func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: self.key, value: self.value(proxy))
            }
        )
    }
}

extension View {
    func read<K: PreferenceKey, V>(_ preference: GeometryPreferenceReader<K, V>) -> some View {
        self.modifier(preference)
    }

    func assignMaxPreference<K: PreferenceKey>(for key: K.Type, to binding: Binding<CGFloat?>) -> some View where K.Value == [CGFloat] {
        return self.onPreferenceChange(key.self) { preferences in
            binding.wrappedValue = preferences.max() ?? CGFloat.zero
        }
    }
}
