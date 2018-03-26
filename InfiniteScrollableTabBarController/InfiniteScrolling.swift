//
//  InfiniteScrolling.swift
//  InfiniteScrollableTabBarController
//
//  Created by Iraniya Naynesh on 23/03/18.
//  Copyright © 2018 Iraniya Naynesh. All rights reserved.
//


import UIKit

public protocol InfiniteScrollingBehaviourDelegate: class {
    
    func configuredCell(forItemAtIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, forInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> UICollectionViewCell
    
    func didSelectItem(atIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> Void
    
    func didEndScrolling(inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour)
}

public extension InfiniteScrollingBehaviourDelegate {
    func didSelectItem(atIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> Void { }
    func didEndScrolling(inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) { }
}

public protocol InfiniteScollingData { }

public enum LayoutType {
    case fixedSize(sizeValue: CGFloat, lineSpacing: CGFloat)
    case numberOfCellOnScreen(Double)
}

public struct CollectionViewConfiguration {
    public var layoutType: LayoutType
    public static let `default` = CollectionViewConfiguration(layoutType: .numberOfCellOnScreen(3))
    
    public init(layoutType: LayoutType) {
        self.layoutType = layoutType
    }
}

class SnappingCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left
        //print("horizontalOffset \(horizontalOffset)")
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        //print("targetRect \(targetRect)")
        
        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        
        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            //print("itemOffset \(itemOffset)")
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
                //print("offsetAdjustment \(offsetAdjustment)")
            }
        })
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}


public class InfiniteScrollingBehaviour: NSObject {
    fileprivate var cellSize: CGFloat = 0.0
    fileprivate var padding: CGFloat = 0.0
    fileprivate var numberOfBoundaryElements = 0
    fileprivate(set) public weak var collectionView: UICollectionView!
    fileprivate(set) public weak var delegate: InfiniteScrollingBehaviourDelegate?
    fileprivate(set) public var dataSet: [InfiniteScollingData]
    fileprivate(set) public var dataSetWithBoundary: [InfiniteScollingData] = []
    
    fileprivate var collectionViewBoundsValue: CGFloat {
        get {
            return collectionView.bounds.size.width
        }
    }
    
    fileprivate var scrollViewContentSizeValue: CGFloat {
        get {
            return collectionView.contentSize.width
        }
    }
    
    fileprivate(set) public var collectionConfiguration: CollectionViewConfiguration
    
    public init(withCollectionView collectionView: UICollectionView, andData dataSet: [InfiniteScollingData],
                delegate: InfiniteScrollingBehaviourDelegate, configuration: CollectionViewConfiguration = .default) {
        self.collectionView = collectionView
        self.dataSet = dataSet
        self.collectionConfiguration = configuration
        self.delegate = delegate
        super.init()
        configureBoundariesForInfiniteScroll()
        configureCollectionView()
        scrollToFirstElement()
    }
    
    
    private func configureBoundariesForInfiniteScroll() {
        dataSetWithBoundary = dataSet
        calculateCellWidth()
        let absoluteNumberOfElementsOnScreen = ceil(collectionViewBoundsValue/cellSize)
        numberOfBoundaryElements = Int(absoluteNumberOfElementsOnScreen)
        addLeadingBoundaryElements()
        addTrailingBoundaryElements()
    }
    
    private func calculateCellWidth() {
        switch collectionConfiguration.layoutType {
        case .fixedSize(let sizeValue, let padding):
            cellSize = sizeValue
            self.padding = padding
        case .numberOfCellOnScreen(let numberOfCellsOnScreen):
            cellSize = (collectionViewBoundsValue/numberOfCellsOnScreen.cgFloat)
            padding = 0
        }
    }
    
    private func addLeadingBoundaryElements() {
        for index in stride(from: numberOfBoundaryElements, to: 0, by: -1) {
            let indexToAdd = (dataSet.count - 1) - ((numberOfBoundaryElements - index)%dataSet.count)
            let data = dataSet[indexToAdd]
            dataSetWithBoundary.insert(data, at: 0)
        }
    }
    
    private func addTrailingBoundaryElements() {
        for index in 0..<numberOfBoundaryElements {
            let data = dataSet[index%dataSet.count]
            dataSetWithBoundary.append(data)
        }
    }
    
    let flowLayout = SnappingCollectionViewLayout()
    
    private func configureCollectionView() {
        guard let _ = self.delegate else { return }
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.isScrollEnabled = false
    }
    
    private func scrollToFirstElement() {
        scroll(toElementAtIndex: 1, withScrollPosition: .left)
    }
    
    
    public func scroll(toElementAtIndex index: Int, withScrollPosition scrollPosition: UICollectionViewScrollPosition) {
        let boundaryDataSetIndex = indexInBoundaryDataSet(forIndexInOriginalDataSet: index)
        let indexPath = IndexPath(item: boundaryDataSetIndex, section: 0)
        //        let scrollPosition: UICollectionViewScrollPosition = scrollPosition
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
    }
    
    public func indexInOriginalDataSet(forIndexInBoundaryDataSet index: Int) -> Int {
        let difference = index - numberOfBoundaryElements
        if difference < 0 {
            let originalIndex = dataSet.count + difference
            return abs(originalIndex % dataSet.count)
        } else if difference < dataSet.count {
            return difference
        } else {
            return abs((difference - dataSet.count) % dataSet.count)
        }
    }
    
    public func indexInBoundaryDataSet(forIndexInOriginalDataSet index: Int) -> Int {
        return index + numberOfBoundaryElements
    }
    
    
    public func reload(withData dataSet: [InfiniteScollingData]) {
        self.dataSet = dataSet
        configureBoundariesForInfiniteScroll()
        collectionView.reloadData()
        scrollToFirstElement()
    }
    
    public func updateConfiguration(configuration: CollectionViewConfiguration) {
        collectionConfiguration = configuration
        configureBoundariesForInfiniteScroll()
        configureCollectionView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.collectionView.reloadData()
            self.scrollToFirstElement()
        }
    }
}

extension InfiniteScrollingBehaviour: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: cellSize, height: collectionView.bounds.size.height)
        //print("collectionView indexPath\(indexPath)")
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let originalIndex = indexInOriginalDataSet(forIndexInBoundaryDataSet: indexPath.item)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        delegate?.didSelectItem(atIndexPath: indexPath, originalIndex: originalIndex, andData: dataSetWithBoundary[indexPath.item], inInfiniteScrollingBehaviour: self)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let boundarySize = numberOfBoundaryElements.cgFloat * cellSize + (numberOfBoundaryElements.cgFloat * padding)
        let contentOffsetValue = scrollView.contentOffset.x
        if contentOffsetValue >= (scrollViewContentSizeValue - boundarySize) {
            let offset = boundarySize - padding
            let updatedOffsetPoint = CGPoint(x: offset, y: 0)
            scrollView.contentOffset = updatedOffsetPoint
        } else if contentOffsetValue <= 0 {
            let boundaryLessSize = dataSet.count.cgFloat * cellSize + (dataSet.count.cgFloat * padding)
            let updatedOffsetPoint = CGPoint(x: boundaryLessSize, y: 0)
            scrollView.contentOffset = updatedOffsetPoint
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.didEndScrolling(inInfiniteScrollingBehaviour: self)
    }
    
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.didEndScrolling(inInfiniteScrollingBehaviour: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        //print("shouldUpdateFocusIn")
        return true
    }
    
    func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        //print("didUpdateFocus")
    }
}

extension InfiniteScrollingBehaviour: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSetWithBoundary.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = self.delegate else {
            return UICollectionViewCell()
        }
        let originalIndex = indexInOriginalDataSet(forIndexInBoundaryDataSet: indexPath.item)
        return delegate.configuredCell(forItemAtIndexPath: indexPath, originalIndex: originalIndex, andData: dataSetWithBoundary[indexPath.item], forInfiniteScrollingBehaviour: self)
    }
}

extension Double {
    var cgFloat: CGFloat {
        get { return CGFloat(self) }
    }
}

extension Int {
    var cgFloat: CGFloat {
        get { return CGFloat(self) }
    }
}



