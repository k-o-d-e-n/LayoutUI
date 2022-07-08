//
//  Constraints.swift
//  LayoutUI
//
//  Created by Denis Koryttsev on 26.05.2022.
//

import CoreGraphics

public struct ViewConstraints<Accesor, RectConstraints, Layout>: ViewBasedLayout
where Accesor: RectAccessor, RectConstraints: RectBasedLayout, Layout: ViewBasedLayout, Layout.View == Accesor.View {
    public typealias View = Accesor.View
    @usableFromInline
    let viewID: Int
    @usableFromInline
    let accessor: Accesor
    @usableFromInline
    let constraints: RectConstraints
    @usableFromInline
    let layout: Layout

    @usableFromInline
    init(_ accessor: Accesor, viewID: Int, constraints: RectConstraints, layout: Layout) {
        self.viewID = viewID
        self.accessor = accessor
        self.constraints = constraints
        self.layout = layout
    }

    @inlinable
    @inline(__always)
    public var isFixedWidth: Bool { layout.isFixedWidth }
    @inlinable
    @inline(__always)
    public var isFixedHeight: Bool { layout.isFixedHeight }
    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        var sourceRect = source
        constraints.layout(&sourceRect, with: accessor[view])
        layout.layout(view, in: sourceRect)
    }
    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: Accesor.View, in source: CGRect) {
        var sourceRect = source
        constraints.layout(&sourceRect, with: accessor[view])
        layout.layout(to: &rect, with: view, in: sourceRect)
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: View, in source: CGRect) {
        var sourceRect = source
        constraints.layout(&sourceRect, with: snap.completedRects[viewID]!)
        layout.layout(to: &snap, with: view, in: sourceRect)
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        layout.apply(snapshot, for: view)
    }
}
extension ViewConstraints: LayoutUI.Layout where Accesor.View == Void {}
extension ViewBasedLayout {
    @inlinable
    @inline(__always)
    public func constraints<RectConstraints>(_ keyPath: KeyPath<View, CGRect>, viewID: Int, @LayoutBuilder constraints: () -> RectConstraints) -> ViewConstraints<_KeyPathRectAccessor<View>, RectConstraints, Self> {
        ViewConstraints(_KeyPathRectAccessor(keyPath: keyPath), viewID: viewID, constraints: constraints(), layout: self)
    }
    @inlinable
    @inline(__always)
    public func constraints(_ keyPath: KeyPath<View, CGRect>, viewID: Int) -> ViewConstraints<_KeyPathRectAccessor<View>, Equal, Self> {
        ViewConstraints(_KeyPathRectAccessor(keyPath: keyPath), viewID: viewID, constraints: Equal(), layout: self)
    }
    // TODO: Constraint on source? for size fitting
}
extension ViewBasedLayout {
    @inlinable
    @inline(__always) // TODO: viewID, when snapshot will crash
    public func constraints<RectConstraints>(_ rect: CGRect, viewID: Int, @LayoutBuilder constraints: () -> RectConstraints) -> ViewConstraints<_ConstantRect<View>, RectConstraints, Self> {
        ViewConstraints(_ConstantRect(value: rect), viewID: viewID, constraints: constraints(), layout: self)
    }
    @inlinable
    @inline(__always) // TODO: viewID is unnecessary
    public func constraints(_ rect: CGRect, viewID: Int) -> ViewConstraints<_ConstantRect<View>, Equal, Self> {
        ViewConstraints(_ConstantRect(value: rect), viewID: viewID, constraints: Equal(), layout: self)
    }
}

public struct Constraints<RectConstraints, Layout>: ViewBasedLayout
where RectConstraints: RectBasedLayout, Layout: ViewBasedLayout {
    public typealias View = Layout.View
    @usableFromInline
    let constraints: RectConstraints
    @usableFromInline
    let layout: Layout

    @usableFromInline
    init(constraints: RectConstraints, layout: Layout) {
        self.constraints = constraints
        self.layout = layout
    }

    @inlinable
    @inline(__always)
    public var isFixedWidth: Bool { layout.isFixedWidth }
    @inlinable
    @inline(__always)
    public var isFixedHeight: Bool { layout.isFixedHeight }
    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        var sourceRect = source
        constraints.layout(&sourceRect, with: source)
        layout.layout(view, in: sourceRect)
    }
    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: Layout.View, in source: CGRect) {
        var sourceRect = source
        constraints.layout(&sourceRect, with: source)
        layout.layout(to: &rect, with: view, in: sourceRect)
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: View, in source: CGRect) {
        var sourceRect = source
        constraints.layout(&sourceRect, with: source)
        layout.layout(to: &snap, with: view, in: sourceRect)
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        layout.apply(snapshot, for: view)
    }
}
extension Constraints: LayoutUI.Layout where Layout.View == Void {}

extension ViewBasedLayout {
    @inlinable
    @inline(__always)
    public func constraints<RectConstraints>(@LayoutBuilder _ constraints: () -> RectConstraints) -> Constraints<RectConstraints, Self> {
        Constraints(constraints: constraints(), layout: self)
    }
}
