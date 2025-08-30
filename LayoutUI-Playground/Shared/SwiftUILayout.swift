//
//  SwiftUILayout.swift
//  LayoutUI-Playground
//
//  Created by Denis Koryttsev on 06.07.2022.
//

import SwiftUI
import LayoutUI

@available(macOS 12.0, iOS 13, *)
struct SwiftUIView: View {
    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 100) {
                Rectangle()
                Rectangle()
                    .basicLayout {
                        Height().scaled(0.5)
                        Bottom()
                    }
            }
            .foregroundColor(.red)
            .opacity(0.5)
            .basicLayout {
                Width()
                Height().scaled(0.5)
                CenterY()
                Right()
            }
            .background(.gray)
            .basicLayout {
                Width().scaled(0.5)
                Right()
            }
            VStack {
                Text("Hello")
                    .font(.largeTitle)
                    .background(.green)
                Text("World")
            }
            .basicLayout(.bottomLeading) {
                Width().scaled(0.5)
                Left().offset(70)
                Bottom().offset(-40)
            }
            .border(Color.green, width: 10)
            #if compiler(>=5.7)
            if #available(macOS 13.0, iOS 16, *) {
                Color.red.opacity(0.5)
                    .layout {
                        Width().scaled(0.25).between(100 ... 300)
                        Height().scaled(0.5)
                        CenterX().offset(multiplier: -0.25)
                        CenterY()
                    }
                Text("Custom layout")
                    .background(Color.yellow)
                    .fittingLayout {
                        CenterX()
                        Top().offset(30)
                    }
                (ConstraintBasedLayout()) {
                    Text("Text #1+").constrainedLayout { Left().offset(20) }
                    Text("Text #2/").constrainedLayout {
                        Constraint(viewID: 0) { MinY.Align.MaxY().offset(20) }
                    }
                    Text("Text #3\\").zIndex(50).constrainedLayout {
                        Constraint(viewID: 1) {
                            MinY.Align.MaxY()
                            MinX.Align.MaxX().offset(10)
                        }
                    }
                    Color.red.border(Color.yellow, width: 2).constrainedLayout {
                        Constraint(viewID: 2) {
                            Equal()
                        }
                    }
                    Color.brown.constrainedLayout {
                        Constraint(viewID: 1) { MinY.Limit.MaxY() }
                        Constraint(viewID: 2) { MaxX.Limit.MinX() }
                    }
                }
            }
            #endif
        }
    }
}

#Preview {
    SwiftUIView()
}
