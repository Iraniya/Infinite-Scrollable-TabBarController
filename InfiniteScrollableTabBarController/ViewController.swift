//
//  ViewController.swift
//  InfiniteScrollableTabBarController
//
//  Created by Iraniya Naynesh on 23/03/18.
//  Copyright © 2018 Iraniya Naynesh. All rights reserved.
//

import UIKit

extension Tab: InfiniteScollingData {}

class ViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var tabContainerView: UIView!
    
    var viewControllers = [UIViewController]()
    
    var contaierViewController: PageViewController!
    
    var generalVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GeneralViewController") as! GeneralViewController
    var shareVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
    var othersVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OthersViewController") as! OthersViewController
    
    private var infiniteScrollingBehaviour: InfiniteScrollingBehaviour!
    
    private var numPages = 0
    private var selectedIndex = 0
    
    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer?) {
        swipeCollectionViewRight()
        swipeContainerViewRight()
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer?) {
       swipeCollectinViewLeft()
        swipeContainerViewLeft()
    }
    
    func swipeCollectionViewRight() {
        selectedIndex = selectedIndex - 1
        selectedIndex = mod(a: selectedIndex, b: numPages)
        infiniteScrollingBehaviour.scroll(toElementAtIndex: selectedIndex, withCcrollPosition: .left)
        print("right \(selectedIndex)")
        let originalIndex = infiniteScrollingBehaviour.indexInBoundaryDataSet(forIndexInOriginalDataSet: selectedIndex)
        let indexPath = IndexPath(item: originalIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    func swipeCollectinViewLeft() {
        selectedIndex = selectedIndex + 1
        selectedIndex = mod(a: selectedIndex, b: numPages)
        infiniteScrollingBehaviour.scroll(toElementAtIndex: selectedIndex, withCcrollPosition: .right)
        let originalIndex = infiniteScrollingBehaviour.indexInBoundaryDataSet(forIndexInOriginalDataSet: selectedIndex)
        let indexPath = IndexPath(item: originalIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    func swipeContainerViewLeft() {
        //upadte content view
        let incrementOne = mod(a: selectedIndex , b: numPages)
        let viewController = contaierViewController.getViewControllerAtIndex(index: incrementOne)
        contaierViewController.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
    }
    
    func swipeContainerViewRight() {
        //upadte content view
        let incrementOne = mod(a: selectedIndex, b: numPages)
        let viewController = contaierViewController.getViewControllerAtIndex(index: incrementOne)
        contaierViewController.setViewControllers([viewController!], direction: .reverse, animated: true, completion: nil)
    }
    
    
    func mod(a: Int, b: Int) -> Int {
        let r: Int = a % b;
        return r < 0 ? r + b : r;
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let _ = infiniteScrollingBehaviour {}
        else {
            let configuration = CollectionViewConfiguration(layoutType: .numberOfCellOnScreen(3))
            infiniteScrollingBehaviour = InfiniteScrollingBehaviour(withCollectionView: collectionView, andData: Tab.settingsTab, delegate: self, configuration: configuration)
        }
    }
    
    private func addContentPageController() {
        contaierViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as!PageViewController
        
        contaierViewController.controllerArray =  [generalVC, shareVC, othersVC]
        
        contaierViewController.customDelegate = self
        contaierViewController.willMove(toParentViewController: self)
        tabContainerView.addSubview(contaierViewController.view)
        self.addChildViewController(contaierViewController)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [generalVC, shareVC, othersVC]
        numPages = viewControllers.count
        registerCell()
        viewControllers = [generalVC,shareVC, othersVC]
        addContentPageController()
        selectedIndex = 1 // setting selected index 1
    }
    
    private func registerCell() {
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CellID")
    }
}

extension ViewController: InfiniteScrollingBehaviourDelegate {
    
    func configuredCell(forItemAtIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, forInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath)
        if let collectionCell = cell as? CollectionViewCell,
            let tab = data as? Tab {
            collectionCell.titleLabel.text = tab.name
        }
        return cell
    }
    
    func didSelectItem(atIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> Void {
        
        //don't update if selecte index is current index
        if !(originalIndex == selectedIndex) {
            if originalIndex == mod(a: selectedIndex + 1 , b: numPages) {
                // print("right selected")
                //print("originalIndex\(originalIndex), selectedIndex\(selectedIndex)")
                let incrementOne = mod(a: selectedIndex + 1, b: numPages)
                let viewController = contaierViewController.getViewControllerAtIndex(index: incrementOne)
                contaierViewController.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
                contaierViewController.currentIndex = selectedIndex
            } else {
                //print("Left selected")
                //print("originalIndex\(originalIndex), selectedIndex\(selectedIndex)")
                let incrementOne = mod(a: selectedIndex - 1, b: numPages)
                let viewController = contaierViewController.getViewControllerAtIndex(index: incrementOne)
                contaierViewController.setViewControllers([viewController!], direction: .reverse, animated: true, completion: nil)
                contaierViewController.currentIndex = selectedIndex
            }
        }
        selectedIndex = originalIndex
        //print(selectedIndex)
    }
}


extension ViewController : PageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishSwipingViewController viewController: UIViewController, withDirection direction: UIPageViewControllerNavigationDirection, andCurrentIndex: Int) {
        if direction == .forward {
            print("forward")
            swipeCollectinViewLeft()
        } else {
            print("reverse")
            swipeCollectionViewRight()
        }
        
    }
}
