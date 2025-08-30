//
//  SwiftUI.swift
//  LayoutUI
//
//  Created by Denis Koryttsev on 07.06.2022.
//

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct BasicLayout<Layout>: ViewModifier where Layout: RectBasedLayout {
    @usableFromInline
    let alignment: Alignment
    @usableFromInline
    let coordinateSpace: CoordinateSpace
    @usableFromInline
    let layout: Layout
    @usableFromInline
    init(alignment: Alignment, coordinateSpace: CoordinateSpace, @LayoutBuilder layout: () -> Layout) {
        self.alignment = alignment
        self.coordinateSpace = coordinateSpace
        self.layout = layout()
    }
    @inlinable
    @inline(__always)
    public func body(content: Content) -> some View {
        GeometryReader { proxy in
            let frame = rect(with: proxy)
            content
                .frame(width: frame.width, height: frame.height, alignment: alignment)
                .offset(x: frame.minX, y: frame.minY)
        }
    }
    @usableFromInline
    func rect(with proxy: GeometryProxy) -> CGRect {
        let source = proxy.frame(in: coordinateSpace)
        var rect: CGRect = source
        layout.layout(&rect, with: source)
        return rect
    }
}
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension View {
    @inlinable
    @inline(__always)
    public func basicLayout<L>(_ alignment: Alignment = .center, coordinateSpace: CoordinateSpace = .local, @LayoutBuilder _ layout: () -> L) -> some View where L: RectBasedLayout {
        modifier(BasicLayout(alignment: alignment, coordinateSpace: coordinateSpace, layout: layout))
    }
}

#if compiler(>=5.7)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct iOS16Layout<L>: SwiftUI.Layout where L: RectBasedLayout {
    @usableFromInline
    let layout: L
    @inlinable
    @inline(__always)
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
    }
    @inlinable
    @inline(__always)
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var rect = bounds
        layout.layout(&rect, with: bounds)
        subviews[0].place(at: rect.origin, proposal: ProposedViewSize(rect.size))
    }
}
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct iOS16FittingLayout<L>: SwiftUI.Layout where L: RectBasedLayout {
    @usableFromInline
    let layout: L
    @inlinable
    @inline(__always)
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions(by: subviews[0].sizeThatFits(proposal))
    }
    @inlinable
    @inline(__always)
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var rect = CGRect(origin: bounds.origin, size: subviews[0].sizeThatFits(proposal))
        layout.layout(&rect, with: bounds)
        subviews[0].place(at: rect.origin, proposal: ProposedViewSize(rect.size))
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ConstraintBasedLayout: SwiftUI.Layout {
    @inlinable
    @inline(__always)
    public init() {}
    @inlinable
    @inline(__always)
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
    }
    @inlinable
    @inline(__always)
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var rects: [CGRect] = []
        for subview in subviews {
            var subviewBounds = bounds
            let rect: CGRect
            if let layout = subview[ConstrainedLayoutKey.self] {
                for constraint in layout.constraints {
                    constraint.layout.layout(&subviewBounds, with: rects[constraint.viewID])
                }
                var _rect = CGRect(origin: subviewBounds.origin, size: subview.sizeThatFits(ProposedViewSize(subviewBounds.size)))
                layout.layout.layout(&_rect, with: subviewBounds)
                rect = _rect
            } else {
                rect = CGRect(origin: subviewBounds.origin, size: subview.sizeThatFits(proposal))
            }
            subview.place(at: rect.origin, proposal: ProposedViewSize(rect.size))
            rects.append(rect)
        }
    }
}

public struct Constraint {
    @usableFromInline
    let viewID: Int // TODO: use swiftui id
    @usableFromInline
    let layout: RectBasedLayout
}
extension Constraint {
    @inlinable
    @inline(__always)
    public init<C>(viewID: Int, @LayoutBuilder layout: () -> C) where C: RectBasedLayout {
        self.viewID = viewID
        self.layout = layout()
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@usableFromInline
struct ConstrainedLayoutKey: LayoutValueKey {
    @usableFromInline
    static var defaultValue: Layout? = nil
    @usableFromInline
    struct Layout {
        @usableFromInline
        let layout: RectBasedLayout
        @usableFromInline
        let constraints: [Constraint]
        @usableFromInline
        init(layout: RectBasedLayout, constraints: [Constraint]) {
            self.layout = layout
            self.constraints = constraints
        }
    }
}
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    @inlinable
    @inline(__always)
    public func constrainedLayout<L>(@LayoutBuilder _ layout: () -> L) -> some View where L: RectBasedLayout {
        layoutValue(key: ConstrainedLayoutKey.self, value: ConstrainedLayoutKey.Layout(layout: layout(), constraints: []))
    }
    @inlinable
    @inline(__always)
    public func constrainedLayout<L>(
        @LayoutBuilder _ layout: () -> L,
        @LayoutBuilder _ constraints: () -> [Constraint]
    ) -> some View where L: RectBasedLayout {
        layoutValue(key: ConstrainedLayoutKey.self, value: ConstrainedLayoutKey.Layout(
            layout: layout(),
            constraints: constraints()
        ))
    }
    @inlinable
    @inline(__always)
    public func constrainedLayout(
        @LayoutBuilder _ constraints: () -> [Constraint]
    ) -> some View {
        layoutValue(key: ConstrainedLayoutKey.self, value: ConstrainedLayoutKey.Layout(
            layout: Empty<Never>(),
            constraints: constraints()
        ))
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@usableFromInline
struct iOS16LayoutModifier<L>: ViewModifier where L: RectBasedLayout {
    let layout: L
    @usableFromInline
    init(layout: L) {
        self.layout = layout
    }
    @usableFromInline
    func body(content: Content) -> some View {
        iOS16Layout(layout: layout) { content }
    }
}
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    @inlinable
    @inline(__always)
    public func layout<L>(@LayoutBuilder _ layout: () -> L) -> some View where L: RectBasedLayout {
        modifier(iOS16LayoutModifier(layout: layout()))
    }
}
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@usableFromInline
struct iOS16FittingLayoutModifier<L>: ViewModifier where L: RectBasedLayout {
    let layout: L
    @usableFromInline
    init(layout: L) {
        self.layout = layout
    }
    @usableFromInline
    func body(content: Content) -> some View {
        iOS16FittingLayout(layout: layout) { content }
    }
}
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    @inlinable
    @inline(__always)
    public func fittingLayout<L>(@LayoutBuilder _ layout: () -> L) -> some View where L: RectBasedLayout {
        modifier(iOS16FittingLayoutModifier(layout: layout()))
    }
}

extension LayoutBuilder {
    @inlinable
    @inline(__always)
    public static func buildBlock(_ components: Constraint...) -> [Constraint] {
        components
    }
}
#endif

#endif
