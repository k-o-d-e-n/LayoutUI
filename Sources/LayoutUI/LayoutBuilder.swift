//
//  LayoutBuilder.swift
//  LayoutUI
//
//  Created by Denis Koryttsev on 26.05.2022.
//

import CoreGraphics

@resultBuilder public struct LayoutBuilder {}

/// MARK: - RectBasedLayout

public struct _ConditionalRectBasedLayout<TrueLayout, FalseLayout>: RectBasedLayout where TrueLayout: RectBasedLayout, FalseLayout: RectBasedLayout {
    @usableFromInline
    let condition: Condition
    @usableFromInline
    enum Condition {
    case first(TrueLayout)
    case second(FalseLayout)
    }
    @usableFromInline
    init(condition: Condition) { self.condition = condition }
    @inlinable
    @inline(__always)
    public func layout(_ rect: inout CGRect, with source: CGRect) {
        switch condition {
        case .first(let layout): layout.layout(&rect, with: source)
        case .second(let layout): layout.layout(&rect, with: source)
        }
    }
}

/// Rect-based layout builders
extension LayoutBuilder {
    @inlinable
    @inline(__always)
    public static func buildBlock() -> Empty<Never> {
        Empty()
    }
    @inlinable
    @inline(__always)
    public static func buildBlock<Content>(_ content: Content) -> Content where Content : RectBasedLayout {
        content
    }
    @inlinable
    @inline(__always)
    public static func buildIf<Content>(_ content: Content?) -> Content? where Content : RectBasedLayout {
        content
    }
    @inlinable
    @inline(__always)
    public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> _ConditionalRectBasedLayout<TrueContent, FalseContent> where TrueContent : RectBasedLayout, FalseContent : RectBasedLayout {
        _ConditionalRectBasedLayout(condition: .first(first))
    }
    @inlinable
    @inline(__always)
    public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> _ConditionalRectBasedLayout<TrueContent, FalseContent> where TrueContent : RectBasedLayout, FalseContent : RectBasedLayout {
        _ConditionalRectBasedLayout(condition: .second(second))
    }
}

/// MARK: - ViewBasedLayout

public struct OptionalViewBasedLayout<Wrapped>: ViewBasedLayout where Wrapped: ViewBasedLayout {
    @usableFromInline
    let wrapped: Wrapped?
    @usableFromInline
    init(wrapped: Wrapped?) { self.wrapped = wrapped }
    @inlinable
    @inline(__always)
    public func layout(_ view: Wrapped.View, in source: CGRect) {
        switch wrapped {
        case .some(let layout): layout.layout(view, in: source)
        case .none: break
        }
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: Wrapped.View, in source: CGRect) {
        switch wrapped {
        case .some(let layout): layout.layout(to: &snap, with: view, in: source)
        case .none: break
        }
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: Wrapped.View) {
        switch wrapped {
        case .some(let layout): layout.apply(snapshot, for: view)
        case .none: break
        }
    }
}
extension OptionalViewBasedLayout: Layout where Wrapped: Layout {}
public struct _ConditionalViewBasedLayout<TrueLayout, FalseLayout>: ViewBasedLayout where TrueLayout: ViewBasedLayout, FalseLayout: ViewBasedLayout, TrueLayout.View == FalseLayout.View {
    @usableFromInline
    let condition: Condition
    @usableFromInline
    enum Condition {
    case first(TrueLayout)
    case second(FalseLayout)
    }
    @usableFromInline
    init(condition: Condition) { self.condition = condition }
    @inlinable
    @inline(__always)
    public func layout(_ view: TrueLayout.View, in source: CGRect) {
        switch condition {
        case .first(let layout): layout.layout(view, in: source)
        case .second(let layout): layout.layout(view, in: source)
        }
    }
    @inlinable
    @inline(__always)
    public func layout(to snap: inout LayoutSnapshot, with view: TrueLayout.View, in source: CGRect) {
        switch condition {
        case .first(let layout): layout.layout(to: &snap, with: view, in: source)
        case .second(let layout): layout.layout(to: &snap, with: view, in: source)
        }
    }
    @inlinable
    @inline(__always)
    public func apply(_ snapshot: LayoutSnapshot, for view: TrueLayout.View) {
        switch condition {
        case .first(let layout): layout.apply(snapshot, for: view)
        case .second(let layout): layout.apply(snapshot, for: view)
        }
    }
}
extension _ConditionalViewBasedLayout: Layout where TrueLayout: Layout, FalseLayout: Layout {}

/// View-based layout builders
extension LayoutBuilder {
    @inlinable
    @inline(__always)
    public static func buildBlock<View>() -> Empty<View> {
        Empty()
    }
    @inlinable
    @inline(__always)
    public static func buildBlock<Content>(_ content: Content) -> Content where Content : ViewBasedLayout {
        content
    }
    @inlinable
    @inline(__always)
    public static func buildIf<Content>(_ content: Content?) -> OptionalViewBasedLayout<Content> where Content : ViewBasedLayout {
        OptionalViewBasedLayout(wrapped: content)
    }
    @inlinable
    @inline(__always)
    public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> _ConditionalViewBasedLayout<TrueContent, FalseContent> where TrueContent : ViewBasedLayout, FalseContent : ViewBasedLayout {
        _ConditionalViewBasedLayout(condition: .first(first))
    }
    @inlinable
    @inline(__always)
    public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> _ConditionalViewBasedLayout<TrueContent, FalseContent> where TrueContent : ViewBasedLayout, FalseContent : ViewBasedLayout {
        _ConditionalViewBasedLayout(condition: .second(second))
    }
}
