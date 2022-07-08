//
//  TestLayoutTableController.swift
//  LayoutUI-Playground (iOS)
//
//  Created by Denis Koryttsev on 07.07.2022.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
typealias UICollectionView = NSCollectionView
typealias UICollectionViewCell = NSCollectionViewItem
typealias UICollectionViewLayout = NSCollectionViewLayout
typealias UICollectionViewFlowLayout = NSCollectionViewFlowLayout
typealias UICollectionViewDelegateFlowLayout = NSCollectionViewDelegateFlowLayout
extension NSCollectionView {
    func register(_ _class: AnyObject.Type, forCellWithReuseIdentifier id: String) {
        register(_class, forItemWithIdentifier: NSUserInterfaceItemIdentifier(id))
    }
    func dequeueReusableCell(withReuseIdentifier id: String, for indexPath: IndexPath) -> UICollectionViewCell {
        makeItem(withIdentifier: NSUserInterfaceItemIdentifier(id), for: indexPath)
    }
}
class UICollectionViewController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource {
    lazy var collectionView: UICollectionView = UICollectionView()
    var collectionViewLayout: UICollectionViewLayout
    init(collectionViewLayout: NSCollectionViewLayout) {
        self.collectionViewLayout = collectionViewLayout
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        let sv = NSScrollView()
        sv.documentView = collectionView
        view = sv
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    func numberOfSections(in collectionView: NSCollectionView) -> Int { 0 }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { 0 }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { fatalError() }
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        self.collectionView(collectionView, cellForItemAt: indexPath)
    }
}
#endif

final class TestLayoutTableController: UICollectionViewController {
    let items: [FeedItemData] = FeedItemData.generate(count: 20)
    let cellHeightCalculator = LayoutCellContent(contentView: nil)

    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(LayoutCell.self, forCellWithReuseIdentifier: "cell")
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LayoutCell
        cell.setData(items[indexPath.item])
        return cell
    }
}
extension TestLayoutTableController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = cellHeightCalculator.height(for: items[indexPath.item], width: collectionView.frame.width)
        return CGSize(width: collectionView.frame.width, height: height)
    }
}

import SwiftUI

#if os(iOS)
struct TestLayoutTableView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        TestLayoutTableController()
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
#else
struct TestLayoutTableView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> TestLayoutTableController {
        TestLayoutTableController()
    }
    func updateNSViewController(_ uiViewController: TestLayoutTableController, context: Context) {}
}
#endif
