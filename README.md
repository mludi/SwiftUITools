# SwiftUITools

Code that makes my life in SwiftUI easier:

- read and assign geometry preferences (https://finestructure.co/blog/2020/1/20/swiftui-equal-widths-view-constraints)

  Usage:

  ```Swift
  import SwiftUI
  import SwiftUITools
  
  struct ContentView: View {
      enum LeftColumnWidth: Preference {}
      let leftColumnWidth = GeometryPreferenceReader(
          key: AppendValue<LeftColumnWidth>.self,
          value: { [$0.size.width] }
      )
      
      @State private var minWidth: CGFloat? = nil
  
      var body: some View {
          VStack {
              HStack {
                  Text("a very long")
                      .frame(minWidth: minWidth)
                      .read(leftColumnWidth)
                  Text("text")
              }
              HStack {
                  Text("short")
                      .frame(minWidth: minWidth)
                      .read(leftColumnWidth)
                  Text("text")
              }
          }
          .assignMaxPreference(for: leftColumnWidth.key, to: $minWidth)
      }
  }
  ```

  This will give you:

  ![leftColumnWidth](leftColumnWidth.png)