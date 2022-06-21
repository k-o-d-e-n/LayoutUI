//
//  ViewBasedLayout.swift
//  LayoutUI
//
//  Created by Denis Koryttsev on 26.05.2022.
//

import CoreGraphics

public struct LayoutSnapshot {
    @usableFromInline
    var completedRects: [Int: CGRect]
    @inlinable
    @inline(__always)
    public var unionRect: CGRect {
        guard completedRects.count > 0 else { return .zero }
        return completedRects.values.reduce(into: completedRects.values.first!, { $0 = $0.union($1) })
    }
    @inlinable
    @inline(__always)
    public init(preparedRects: [Int: CGRect] = [:]) {
        self.completedRects = preparedRects
    }
}
public protocol ViewBasedLayout {
    associatedtype View
    var id: Int? { get }
    func layout(_ view: View, in source: CGRect)
    func layout(to snapshot: inout LayoutSnapshot, with view: View, in source: CGRect)
    func apply(_ snapshot: LayoutSnapshot, for view: View)
    /// func setCurrentLayout(to snapshot: inout LayoutSnapshot, for view: View)
}
extension ViewBasedLayout {
    @inlinable
    @inline(__always)
    public var id: Int? { nil }
    @inlinable
    @inline(__always)
    public func snapshot(_ view: View, in source: CGRect) -> LayoutSnapshot {
        var snap = LayoutSnapshot()
        layout(to: &snap, with: view, in: source)
        return snap
    }
}
extension ViewBasedLayout where View == Void {
    @inlinable
    @inline(__always)
    public func layout(in source: CGRect) {
        layout((), in: source)
    }
}
public protocol Layout: ViewBasedLayout where View == Void {}

extension Empty: ViewBasedLayout {
    public typealias View = T
    @inlinable
    @inline(__always)
    public func layout(_ _: View, in _: CGRect) {}
    @inlinable
    @inline(__always)
    public func layout(to _: inout LayoutSnapshot, with _: View, in _: CGRect) {}
    @inlinable
    @inline(__always)
    public func apply(_ _: LayoutSnapshot, for _: View) {}
}
extension Empty: Layout where T == Void {}

public struct AnyViewLayout<View>: ViewBasedLayout {
    @usableFromInline
    let _impl0: (View, CGRect) -> Void
    @usableFromInline
    let _impl1: (inout LayoutSnapshot, View, CGRect) -> Void
    @usableFromInline
    let _impl2: (LayoutSnapshot, View) -> Void

    @inlinable
    @inline(__always)
    public init<Scheme>(@LayoutBuilder schemeBuilder: () -> Scheme) where Scheme: ViewBasedLayout, Scheme.View == View {
        let scheme = schemeBuilder()
        self._impl0 = { scheme.layout($0, in: $1) }
        self._impl1 = { scheme.layout(to: &$0, with: $1, in: $2) }
        self._impl2 = { scheme.apply($0, for: $1) }
    }
    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        _impl0(view, source)
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: View, in source: CGRect) {
        _impl1(&snap, view, source)
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        _impl2(snapshot, view)
    }
}
extension AnyViewLayout: Layout where View == Void {}

public struct Rect<Mutator, Scheme>: ViewBasedLayout where Mutator: RectMutator, Scheme: RectBasedLayout {
    public typealias View = Mutator.View
    public let id: Int?
    @usableFromInline
    let mutator: Mutator
    @usableFromInline
    let scheme: Scheme

    @inlinable
    @inline(__always)
    public init(_ mutator: Mutator, id: Int? = nil, @LayoutBuilder schemeBuilder: () -> Scheme) {
        self.id = id
        self.mutator = mutator
        self.scheme = schemeBuilder()
    }
    @inlinable
    @inline(__always)
    public init(_ mutator: Mutator, id: Int? = nil) where Scheme == Equal {
        self.id = id
        self.mutator = mutator
        self.scheme = Equal()
    }

    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        var rect = mutator[view]
        scheme.layout(&rect, with: source)
        mutator[view] = rect
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: View, in source: CGRect) {
        var r = mutator[view]
        scheme.layout(&r, with: source)
        if let id = id {
            snap.completedRects[id] = r
        }
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        mutator[view] = snapshot.completedRects[id!]!
    }
}
extension Rect: Layout where Mutator.View == Void {}
extension Rect {
    @inlinable
    @inline(__always)
    public init<View>(_ keyPath: ReferenceWritableKeyPath<View, CGRect>, id: Int? = nil, @LayoutBuilder schemeBuilder: () -> Scheme) where Mutator == _KeyPathRectMutator<View> {
        self.id = id
        self.mutator = _KeyPathRectMutator(keyPath: keyPath)
        self.scheme = schemeBuilder()
    }
}

public struct FittingRect<Mutator, Scheme>: ViewBasedLayout where Mutator: FittingSizeMutator, Scheme: RectBasedLayout {
    public typealias View = Mutator.View
    public let id: Int?
    @usableFromInline
    let mutator: Mutator
    @usableFromInline
    let scheme: Scheme

    @inlinable
    @inline(__always)
    public init(_ mutator: Mutator, id: Int? = nil, @LayoutBuilder schemeBuilder: () -> Scheme) {
        self.id = id
        self.mutator = mutator
        self.scheme = schemeBuilder()
    }
    @inlinable
    @inline(__always)
    public init(_ mutator: Mutator, id: Int? = nil) where Scheme == Equal {
        self.id = id
        self.mutator = mutator
        self.scheme = Equal()
    }

    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        let preRect = mutator[view]
        let size = mutator.fittingSize(for: view, with: source.size)
        var rect = CGRect(origin: preRect.origin, size: size)
        scheme.layout(&rect, with: source)
        mutator[view] = rect
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: View, in source: CGRect) {
        let size = mutator.fittingSize(for: view, with: source.size)
        var r = mutator[view]
        r.size = size
        scheme.layout(&r, with: source)
        if let id = id {
            snap.completedRects[id] = r
        }
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        mutator[view] = snapshot.completedRects[id!]!
    }
}
extension FittingRect: Layout where Mutator.View == Void {}
