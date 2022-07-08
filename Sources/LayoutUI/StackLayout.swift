//
//  Created by Denis Koryttsev on 06.07.2022.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import CoreGraphics
#else
import Foundation
#endif

public struct ForEach<Data, Scheme>: ViewBasedLayout where Data: Sequence, Scheme: ViewBasedLayout {
    public typealias View = Scheme.View
    public let id: Int?
    @usableFromInline
    let data: Data
    @usableFromInline
    let scheme: (Data.Element) -> Scheme

    @inlinable
    @inline(__always)
    public init(id: Int? = nil, data: Data, @LayoutBuilder scheme: @escaping (Data.Element) -> Scheme) {
        self.id = id
        self.data = data
        self.scheme = scheme
    }

    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        for element in data {
            scheme(element).layout(view, in: source)
        }
    }
    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: Scheme.View, in source: CGRect) {
        var unionRect = CGRect.null
        for element in data {
            var r = source
            scheme(element).layout(to: &r, with: view, in: source)
            unionRect = unionRect.union(r)
        }
        rect = unionRect
    }
    @inlinable
    @inline(__always)
    public func layout(to snapshot: inout LayoutSnapshot, with view: View, in source: CGRect) {
        /*if let id = id {
            snapshot.completedRects[id] = source
        }*/
        for element in data {
            scheme(element).layout(to: &snapshot, with: view, in: source)
        }
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        for element in data {
            scheme(element).apply(snapshot, for: view)
        }
    }
}
extension ForEach: Layout where Scheme.View == Void {}

///

public protocol CompoundLayout: RandomAccessCollection where Element == Sublayout {
    associatedtype Sublayout: ViewBasedLayout
}
extension CompoundLayout where Index == Int {
    public var startIndex: Index { 0 }
}
public protocol SublayoutProtocol {
    var isFixedWidth: Bool { get }
    var isFixedHeight: Bool { get }
    func rect(in bounds: CGRect) -> CGRect
    func place(in rect: CGRect)
}
public protocol LayoutReducer {
    associatedtype Result
    associatedtype Element
    func reduce<Sublayout>(_ bounds: CGRect, scheme: (Result, Element) -> Sublayout) where Sublayout: SublayoutProtocol
    func forEach(_ next: (Result, Element) -> Void)
}
@usableFromInline
protocol _SublayoutImpl: SublayoutProtocol {
    associatedtype L: ViewBasedLayout
    var scheme: L { get }
    var view: L.View { get }
}
extension _SublayoutImpl {
    @usableFromInline
    var isFixedWidth: Bool { scheme.isFixedWidth }
    @usableFromInline
    var isFixedHeight: Bool { scheme.isFixedHeight }
    @usableFromInline
    func rect(in bounds: CGRect) -> CGRect {
        var r = bounds
        scheme.layout(to: &r, with: view, in: bounds)
        return r
    }
    @usableFromInline
    func place(in rect: CGRect) {
        scheme.apply(rect, for: view)
    }
}

@usableFromInline
struct SublayoutForLayout<L>: _SublayoutImpl where L: ViewBasedLayout {
    @usableFromInline
    let scheme: L
    @usableFromInline
    let view: L.View
    @usableFromInline
    init(scheme: L, view: L.View) {
        self.scheme = scheme
        self.view = view
    }
}
@usableFromInline
struct SublayoutForRectCalculating<L>: _SublayoutImpl where L: ViewBasedLayout {
    @usableFromInline
    let scheme: L
    @usableFromInline
    let view: L.View
    @usableFromInline
    var unionRect: UnsafeMutablePointer<CGRect>
    @usableFromInline
    init(scheme: L, view: L.View, unionRect: UnsafeMutablePointer<CGRect>) {
        self.scheme = scheme
        self.view = view
        self.unionRect = unionRect
    }
    @usableFromInline
    func place(in rect: CGRect) {
        unionRect.pointee = unionRect.pointee.union(rect)
    }
}
@usableFromInline
struct SublayoutForSnapshotting<L>: _SublayoutImpl where L: ViewBasedLayout {
    @usableFromInline
    let scheme: L
    @usableFromInline
    let view: L.View
    @usableFromInline
    var snapshot: UnsafeMutablePointer<LayoutSnapshot>
    @usableFromInline
    init(scheme: L, view: L.View, snapshot: UnsafeMutablePointer<LayoutSnapshot>) {
        self.scheme = scheme
        self.view = view
        self.snapshot = snapshot
    }
    @usableFromInline
    func place(in rect: CGRect) {
        scheme.layout(to: &snapshot.pointee, with: view, in: rect)
    }
}
public struct Reduce<Reducer, Scheme>: ViewBasedLayout where Reducer: LayoutReducer, Scheme: ViewBasedLayout {
    public typealias View = Scheme.View
    public let id: Int?
    @usableFromInline
    let reducer: Reducer
    @usableFromInline
    let scheme: (Reducer.Result, Reducer.Element) -> Scheme

    @inlinable
    @inline(__always)
    public init(
        id: Int? = nil, reducer: Reducer,
        @LayoutBuilder scheme: @escaping (Reducer.Result, Reducer.Element) -> Scheme
    ) {
        self.id = id
        self.reducer = reducer
        self.scheme = scheme
    }

    @inlinable
    @inline(__always)
    public func layout(_ view: View, in source: CGRect) {
        reducer.reduce(source) { result, element -> SublayoutForLayout<Scheme> in
            let l = scheme(result, element)
            return SublayoutForLayout(scheme: l, view: view)
        }
    }
    @inlinable
    @inline(__always)
    public func layout(to rect: inout CGRect, with view: Scheme.View, in source: CGRect) {
        var unionRect = CGRect.null
        reducer.reduce(source) { result, element -> SublayoutForRectCalculating<Scheme> in
            let l = scheme(result, element)
            return SublayoutForRectCalculating(scheme: l, view: view, unionRect: &unionRect)
        }
        rect = unionRect
    }
    @inlinable
    @inline(__always)
    public func layout(to snapshot: inout LayoutSnapshot, with view: View, in source: CGRect) {
        /*if let id = id {
            snapshot.completedRects[id] = source
        }*/
        reducer.reduce(source) { result, element -> SublayoutForSnapshotting<Scheme> in
            let l = scheme(result, element)
            return SublayoutForSnapshotting(scheme: l, view: view, snapshot: &snapshot)
        }
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: View) {
        reducer.forEach { result, element in
            let l = scheme(result, element)
            l.apply(snapshot, for: view)
        }
    }
}
extension Reduce: Layout where Scheme.View == Void {}
extension Reduce where Reducer.Element: ViewBasedLayout, Reducer.Element == Scheme {
    init(id: Int? = nil, reducer: Reducer) {
        self.init(id: id, reducer: reducer, scheme: { _, el in el })
    }
}

public struct EnumeratedReducer<Elements>: LayoutReducer where Elements: Sequence {
    @usableFromInline
    let initialResult: Int
    @usableFromInline
    let data: Elements
    @usableFromInline
    init(_ data: Elements, initial result: Int) {
        self.initialResult = result
        self.data = data
    }
    @inlinable
    @inline(__always)
    public func reduce<Sublayout>(_ bounds: CGRect, scheme: (Int, Elements.Element) -> Sublayout) where Sublayout : SublayoutProtocol {
        var result = 0
        for element in data {
            let l = scheme(result, element)
            let r = l.rect(in: bounds)
            l.place(in: r)
            result += 1
        }
    }
    public func forEach(_ next: (Int, Elements.Element) -> Void) {
        var result = 0
        for element in data {
            next(result, element)
            result += 1
        }
    }
}
extension Reduce {
    @inlinable
    @inline(__always)
    public init<C>(
        id: Int? = nil, enumerated elements: C,
        @LayoutBuilder scheme: @escaping (Int, C.Element) -> Scheme
    ) where Reducer == EnumeratedReducer<C> {
        self.init(id: id, reducer: EnumeratedReducer(elements, initial: id.map { $0 + 1 } ?? 0), scheme: scheme)
    }
}
