//
//  LayoutCell.swift
//  LayoutUI-Playground (iOS)
//
//  Created by Denis Koryttsev on 07.07.2022.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import LayoutUI

#if os(macOS)
typealias UITableViewCell = NSTableRowView
#endif

struct FeedItemData {
    let actionText: String
    let posterName: String
    let posterHeadline: String
    let posterTimestamp: String
    let posterComment: String
    let contentTitle: String
    let contentDomain: String
    let actorComment: String

    static let letters = "abcd efgh ijklmno pqrstu vwxyz \nABCDEFG HIJKLMN OPQRSTU VWXYZ01 2345 6789"
    static func generate(count: Int) -> [FeedItemData] {
        var datas = [FeedItemData]()
        for i in 0..<count {
            let range = 0..<200
            let comment = (0 ..< range.randomElement()!).reduce(into: "") { partialResult, i in
                partialResult.append(letters.randomElement()!)
            }
            let data = FeedItemData(
                actionText: "action text \(i)",
                posterName: "poster name \(i)",
                posterHeadline: "poster title \(i) with some longer stuff",
                posterTimestamp: "poster timestamp \(i)",
                posterComment: comment,
                contentTitle: "content title \(i)",
                contentDomain: "content domain \(i)",
                actorComment: "actor comment \(i)"
            )
            datas.append(data)
        }
        return datas
    }
}
final class LayoutCellContent {
    lazy var actionLabel: NSTextField = NSTextField().add(to: contentView)
    lazy var optionsLabel: NSTextField = NSTextField().add(to: contentView) { arg in
        arg.stringValue = "..."
        arg.sizeToFit()
    }
    lazy var posterImageView: NSImageView = NSImageView().add(to: contentView) { arg in
        arg.image = NSImage(systemName: "person")
        arg.sizeToFit()
    }
    lazy var posterNameLabel: NSTextField = NSTextField().add(to: contentView)
    lazy var posterHeadlineLabel: NSTextField = NSTextField().add(to: contentView) { arg in
        arg.numberOfLines = 3
    }
    lazy var posterTimeLabel: NSTextField = NSTextField().add(to: contentView)
    lazy var posterCommentLabel: NSTextField = NSTextField().add(to: contentView) { arg in
        arg.numberOfLines = 0
        arg.alignment = .center
    }
    lazy var contentTitleLabel: NSTextField = NSTextField().add(to: contentView)
    lazy var contentDomainLabel: NSTextField = NSTextField().add(to: contentView)
    lazy var likeLabel: NSTextField = NSTextField().add(to: contentView) { arg in
        arg.backgroundColor = NSColor(red: 0, green: 0.9, blue: 0, alpha: 1)
        arg.stringValue = "Like"
    }
    lazy var commentLabel: NSTextField = NSTextField().add(to: contentView) { arg in
        arg.stringValue = "Comment"
        arg.backgroundColor = NSColor(red: 0, green: 1.0, blue: 0, alpha: 1)
        arg.alignment = .center
    }
    lazy var shareLabel: NSTextField = NSTextField().add(to: contentView) { arg in
        arg.stringValue = "Share"
        arg.backgroundColor = NSColor(red: 0, green: 0.8, blue: 0, alpha: 1)
        arg.alignment = .right
    }
    lazy var actorImageView: NSImageView = NSImageView().add(to: contentView) { arg in
        arg.image = NSImage(systemName: "person")
    }
    lazy var actorCommentLabel: NSTextField = NSTextField().add(to: contentView)
    let contentView: NSView?
    init(contentView: NSView?) {
        self.contentView = contentView
    }
}

final class LayoutCell: UICollectionViewCell {
    lazy var content: LayoutCellContent = LayoutCellContent(contentView: contentView)

    #if os(iOS)
    override func layoutSubviews() {
        super.layoutSubviews()
        LayoutCellContent.scheme.layout(content, in: bounds.insetBy(dx: 8, dy: 4))
    }
    #else
    override func loadView() {
        view = FlippedView()
    }
    var contentView: NSView { view }
    override func viewDidLayout() {
        super.viewDidLayout()
        LayoutCellContent.scheme.layout(content, in: view.bounds.insetBy(dx: 8, dy: 4))
    }
    #endif
}
extension LayoutCell {
    func setData(_ data: FeedItemData) {
        content.setData(data)
    }
}
extension LayoutCellContent {
    func setData(_ data: FeedItemData) {
        actionLabel.stringValue = data.actionText
        posterNameLabel.stringValue = data.posterName
        posterHeadlineLabel.stringValue = data.posterHeadline
        posterTimeLabel.stringValue = data.posterTimestamp
        posterCommentLabel.stringValue = data.posterComment
        contentTitleLabel.stringValue = data.contentTitle
        contentDomainLabel.stringValue = data.contentDomain
        actorCommentLabel.stringValue = data.actorComment
    }
}
extension LayoutCellContent {
    var _bounds: CGRect { contentView?.bounds ?? .zero }
    func height(for data: FeedItemData, width: CGFloat) -> CGFloat {
        var snapshot = LayoutSnapshot(preparedRects: [.max: _bounds])
        let bounds = CGRect(x: 0, y: 0, width: width - 16, height: 1000)
        setData(data)
        Self.scheme.layout(to: &snapshot, with: self, in: bounds)
        return snapshot.unionRect.height + 8
    }
    static let scheme: AnyViewLayout<LayoutCellContent> = AnyViewLayout {
        Group {
        FittingRect(\Self.optionsLabel/*, cache: sizesCache*/, id: 0) {
            Top()
            Right()
        }
        FittingRect(\Self.actionLabel/*, cache: sizesCache*/, id: 1) {
            Top()
            Left()
        }
        }
        Group {
        Rect(\Self.posterImageView.frame/*, cache: sizesCache*/, id: 2) {
            Height.Constant(50)
            Width.Constant(50)
            Top().offset(10)
            Left()
        }.constraints(\Self.actionLabel.frame, viewID: 1) {
            MaxY.Align.MinY()
        }
        FittingRect(\Self.posterNameLabel/*, cache: sizesCache*/, id: 3) {
            Top().offset(-10)
            Left().offset(2)
        }.constraints(\Self.posterImageView.frame, viewID: 2) {
            Top()
            MaxX.Align.MinX()
        }
        FittingRect(\Self.posterHeadlineLabel/*, cache: sizesCache*/, id: 4) {
            Top().offset(1)
            Left()
        }.constraints(\Self.posterNameLabel.frame, viewID: 3) {
            MinX.Align.MinX()
            MaxY.Align.MinY()
        }.constraints {
            Width().inset(50)
        }
        FittingRect(\Self.posterTimeLabel/*, cache: sizesCache*/, id: 5) {
            Top().offset(1)
            Left()
        }.constraints(\Self.posterHeadlineLabel.frame, viewID: 4) {
            MinX.Align.MinX()
            MaxY.Align.MinY()
        }
        }
        FittingRect(\Self.posterCommentLabel/*, cache: sizesCache*/, id: 6) {
            Width()
            Top().offset(1)
            Left()
        }.constraints(\Self.posterImageView.frame, viewID: 2) {
            MaxY.Limit.MinY()
        }.constraints(\Self.posterTimeLabel.frame, viewID: 5) {
            MaxY.Limit.MinY()
        }
        Group {
        FittingRect(\Self.contentTitleLabel/*, cache: sizesCache*/, id: 8) {
            Top().offset(4)
            Left()
        }.constraints(\Self.posterCommentLabel.frame, viewID: 6) {
            MaxY.Align.MinY()
        }
        FittingRect(\Self.contentDomainLabel/*, cache: sizesCache*/, id: 9) {
            Top()
            Left()
        }.constraints(\Self.contentTitleLabel.frame, viewID: 8) {
            MaxY.Align.MinY()
        }
        }
        Group {
        FittingRect(\Self.likeLabel/*, cache: sizesCache*/, id: 10) {
            Top().offset(4)
            Left()
        }.constraints(\Self.contentDomainLabel.frame, viewID: 9) {
            MaxY.Align.MinY()
        }
        FittingRect(\Self.commentLabel/*, cache: sizesCache*/, id: 14) {
            Top().offset(4)
            CenterX()
        }.constraints(\Self.contentDomainLabel.frame, viewID: 9) {
            MaxY.Align.MinY()
        }
        FittingRect(\Self.shareLabel/*, cache: sizesCache*/, id: 11) {
            Top().offset(4)
            Right()
        }.constraints(\Self.contentDomainLabel.frame, viewID: 9) {
            MaxY.Align.MinY()
        }
        }
        Group {
        Rect(\Self.actorImageView.frame/*, cache: sizesCache*/, id: 12) {
            Width.Constant(30)
            Height.Constant(30)
            Top().offset(4)
            Left()
        }.constraints(\Self.likeLabel.frame, viewID: 10) {
            MaxY.Align.MinY()
        }
        FittingRect(\Self.actorCommentLabel/*, cache: sizesCache*/, id: 13) {
            CenterY()
            Left()
        }.constraints(\Self.actorImageView.frame, viewID: 12) {
            CenterY()
            MaxX.Limit.MinX()
        }
        }
    }
}
