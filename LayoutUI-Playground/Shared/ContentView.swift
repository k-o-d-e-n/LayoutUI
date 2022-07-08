//
//  ContentView.swift
//  Shared
//
//  Created by Denis Koryttsev on 06.07.2022.
//

import SwiftUI

struct ContentView: View {
    @State var swiftUI: Bool = false
    @State var uiKitAppKit: Bool = false
    @State var reusableLayout: Bool = false
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("SwiftUI", isActive: $swiftUI) {
                    SwiftUIView()
                        .ignoresSafeArea()
                }
                NavigationLink("UIKit/AppKit", isActive: $uiKitAppKit) {
                    TestLayoutView()
                        .ignoresSafeArea()
                }
                NavigationLink("Reusable layout", isActive: $reusableLayout) {
                    TestLayoutTableView()
                        .ignoresSafeArea()
                        .navigationTitle("Reusable layout scheme")
                }
                #if os(macOS)
                if swiftUI || uiKitAppKit || reusableLayout {
                    Button("Back") {
                        swiftUI = false
                        uiKitAppKit = false
                        reusableLayout = false
                    }
                }
                #endif
            }
            .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
