//
//  AZTagsView.swift
//  TagsView
//
//  Created by Alex Zimin on 02/05/15.
//  Copyright (c) 2015 Alex. All rights reserved.
//

import UIKit

// MARK: - Keys

private let cellIdentifierKey = "AZTagCollectionViewCell"

// MARK: - AZTagsViewDataSource

@objc
protocol AZTagsViewDataSource: NSObjectProtocol {
    func numberOfTagsInTagsView(tagsView: AZTagsView) -> Int
    func tagsView(tagsView: AZTagsView, tagAtIndex index: Int) -> String
    optional func tagsViewWithAttributesString(tagsView: AZTagsView, tagAtIndex index: Int) -> NSAttributedString?
}

@objc
protocol AZTagsViewDelegate: NSObjectProtocol {
    optional func tagsView(tagsView: AZTagsView, didChangeSizeToSize size: CGSize)
    optional func tagsView(tagsView: AZTagsView, didSelectItemAtIndex index: Int)
}


// MARK: - Base

class AZTagsView: UIView {
    
    // MARK: - Public
    
    @IBOutlet var dataSource: AZTagsViewDataSource? {
        didSet {
            reloadData()
        }
    }
    var delegate: AZTagsViewDelegate?
    
    // MARK: - Private
    
    private var collectionView: AZTagsViewCollectionView!
    private var _dataSourceContainer = _DataSourceContainer()

    
    // MARK: - Init and setup
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        collectionView = AZTagsViewCollectionView(frame: self.bounds, collectionViewLayout: FSQCollectionViewAlignedLayout())
        
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.additinalDelegate = self
        collectionView.backgroundColor = UIColor.clearColor()
        
        collectionView.registerClass(AZTagCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifierKey)
        self.addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
        collectionView.performBatchUpdates(nil, completion: nil)
    }

}

// MARK: - Actions

extension AZTagsView {
    func performBatchUpdates(updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        collectionView.performBatchUpdates({ () -> Void in
            updates?()
        }, completion: { (success) -> Void in
            completion?(success)
        })
    }
    
    func deleteItemAtIndex(index: Int) {
        deleteItemsAtIndexes([index])
    }
    
    func deleteItemsAtIndexes(indexes: [Int]) {
        _dataSourceContainer.numberOfTags -= indexes.count
        
        let indexPathes = indexes.map({ NSIndexPath(forRow: $0, inSection: 0) })
        collectionView.deleteItemsAtIndexPaths(indexPathes)
    }
    
    func insertItemAtIndex(index: Int) {
        insertItemsAtIndexes([index])
    }
    
    func insertItemsAtIndexes(indexes: [Int]) {
        _dataSourceContainer.numberOfTags += indexes.count
        
        let indexPathes = indexes.map({ NSIndexPath(forRow: $0, inSection: 0) })
        collectionView.insertItemsAtIndexPaths(indexPathes)
    }
    
    func updateAtIndex(index: Int) {
        updateAtIndexes([index])
    }
    
    func updateAtIndexes(indexes: [Int]) {
        let indexPathes = indexes.map({ NSIndexPath(forRow: $0, inSection: 0) })
        collectionView.reloadItemsAtIndexPaths(indexPathes)
    }
}

// MARK: - DataSource

extension AZTagsView {
    struct _DataSourceContainer {
        var numberOfTags: Int = 0
    }
    
    func reloadData() {
        updateDataSource()
        collectionView.reloadData()
    }
    
    private func updateDataSource() {
        _dataSourceContainer.numberOfTags = dataSource?.numberOfTagsInTagsView(self) ?? 0
    }
}

// MARK: - UICollectionViewDataSource

extension AZTagsView: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _dataSourceContainer.numberOfTags
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifierKey, forIndexPath: indexPath) as! AZTagCollectionViewCell
        
        if let attributedString = dataSource?.tagsViewWithAttributesString?(self, tagAtIndex: indexPath.row) {
            cell.label.attributedText = attributedString
        } else {
            cell.label.attributedText = nil
            cell.label.text = dataSource?.tagsView(self, tagAtIndex: indexPath.row) ?? ""
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension AZTagsView: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.tagsView?(self, didSelectItemAtIndex: indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: getSizeOfText(dataSource?.tagsView(self, tagAtIndex: indexPath.row) ?? ""), height: 30)
    }
}

// MARK: - UICollectionViewDelegate

extension AZTagsView {
    private func getSizeOfText(text: String) -> CGFloat {
        let attributes = AZTextFrameAttributes(string: text, font: UIFont.systemFontOfSize(14))
        return min(AZTextFrame(attributes: attributes).width + AZTagCollectionViewCell.space.x * 4, self.bounds.width - AZTagCollectionViewCell.space.x * 2)
    }
}

extension AZTagsView: AZTagsViewCollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didChangeSizeToSize size: CGSize) {
        delegate?.tagsView?(self, didChangeSizeToSize: size)
    }
    
}

extension AZTagsView: FSQCollectionViewDelegateAlignedLayout {
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: FSQCollectionViewAlignedLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!, remainingLineSpace: CGFloat) -> CGSize {
        let text: String
        
        if let attributedString = dataSource?.tagsViewWithAttributesString?(self, tagAtIndex: indexPath.row) {
            text = attributedString.string
        } else {
            text = dataSource?.tagsView(self, tagAtIndex: indexPath.row) ?? ""
        }
        
        return CGSize(width: getSizeOfText(text) - 2, height: 30)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: FSQCollectionViewAlignedLayout!, attributesForSectionAtIndex sectionIndex: Int) -> FSQCollectionViewAlignedLayoutSectionAttributes! {
        return FSQCollectionViewAlignedLayoutSectionAttributes.centerCenterAlignment()
    }
}

// MARK: - Helpers

protocol AZTagsViewCollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didChangeSizeToSize size: CGSize)
}

class AZTagsViewCollectionView: UICollectionView {
    var additinalDelegate: AZTagsViewCollectionViewDelegate?
    var oldSize: CGSize = CGSizeZero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if oldSize != self.contentSize {
            oldSize = self.contentSize
            self.additinalDelegate?.collectionView(self, didChangeSizeToSize: oldSize)
        }
    }
}






