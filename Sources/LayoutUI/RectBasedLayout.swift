//
//  RectBasedLayout.swift
//  LayoutUI
//
//  Created by Denis Koryttsev on 26.05.2022.
//

import CoreGraphics

public protocol RectBasedLayout {
    // TODO: Rename to `layout(_ rect: inout CGRect, with other: CGRect)` to avoid semantic conflict with constraint types.
    func layout(_ rect: inout CGRect, with source: CGRect)
}

extension Optional: RectBasedLayout where Wrapped: RectBasedLayout {
    @inlinable
    @inline(__always)
    public func layout(_ rect: inout CGRect, with source: CGRect) {
        switch self {
        case .some(let layout): layout.layout(&rect, with: source)
        case .none: break
        }
    }
}

public struct Print<Base>: RectBasedLayout where Base: RectBasedLayout {
    @usableFromInline
    let base: Base
    @usableFromInline
    init(_ base: Base) { self.base = base }
    @inlinable
    @inline(__always)
    public func layout(_ rect: inout CGRect, with source: CGRect) {
        base.layout(&rect, with: source)
        Swift.print(rect, source)
    }
}
extension RectBasedLayout {
    @inlinable
    @inline(__always)
    public func print() -> Print<Self> { Print(self) }
}
extension Never: RectBasedLayout {
    @inlinable
    @inline(__always)
    public func layout(_ rect: inout CGRect, with source: CGRect) {}
}
public struct Empty<T> {
    @inlinable
    @inline(__always)
    public init() {}
}
extension Empty: RectBasedLayout where T: RectBasedLayout {
    @inlinable
    @inline(__always)
    public func layout(_ rect: inout CGRect, with source: CGRect) {}
}
public struct Equal: RectBasedLayout {
    @inlinable
    @inline(__always)
    public init() {}
    @inlinable
    @inline(__always)
    public func layout(_ rect: inout CGRect, with source: CGRect) {
        rect = source
    }
}

extension Height {
    public struct Ratio: RectBasedLayout { // TODO: 
        @usableFromInline
        let value: CGFloat
        @inlinable
        @inline(__always)
        public init(_ value: CGFloat) { self.value = value }
        @inlinable
        @inline(__always)
        public func layout(_ rect: inout CGRect, with source: CGRect) {
            rect.size.height = rect.size.width * value
        }
    }
}
