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
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var tabBarView: UIView!
    
    var viewControllers = [UIViewController]()
    var contaierViewController: PageViewController!
    private var infiniteScrollingBehaviour: InfiniteScrollingBehaviour!
    private var numPages = 0
    private var selectedIndex = 0
    var data: [Tab]?
    
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
        infiniteScrollingBehaviour.scroll(toElementAtIndex: selectedIndex, withScrollPosition: .left)
        let originalIndex = infiniteScrollingBehaviour.indexInBoundaryDataSet(forIndexInOriginalDataSet: selectedIndex)
        let indexPath = IndexPath(item: originalIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
    
    func swipeCollectinViewLeft() {
        selectedIndex = selectedIndex + 1
        selectedIndex = mod(a: selectedIndex, b: numPages)
        infiniteScrollingBehaviour.scroll(toElementAtIndex: selectedIndex, withScrollPosition: .right)
        let originalIndex = infiniteScrollingBehaviour.indexInBoundaryDataSet(forIndexInOriginalDataSet: selectedIndex)
        let indexPath = IndexPath(item: originalIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        collectionView.reloadData()
    }
    
    func swipeContainerViewLeft() {
        //upadte content view
        let viewController = contaierViewController.getViewControllerAtIndex(index: selectedIndex)
        contaierViewController.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
    }
    
    func swipeContainerViewRight() {
        //upadte content view
        let viewController = contaierViewController.getViewControllerAtIndex(index: selectedIndex)
        contaierViewController.setViewControllers([viewController!], direction: .reverse, animated: true, completion: nil)
    }
    
    func mod(a: Int, b: Int) -> Int {
        let r: Int = a % b;
        return r < 0 ? r + b : r;
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initInfiniteCollectionView()
    }
    
    func initInfiniteCollectionView() {
        if let _ = infiniteScrollingBehaviour {}
        else {
            let configuration = CollectionViewConfiguration(layoutType: .numberOfCellOnScreen(3))
            infiniteScrollingBehaviour = InfiniteScrollingBehaviour(withCollectionView: collectionView, andData: data!, delegate: self, configuration: configuration)
        }
    }
    
    private func addContentPageController() {
        
        contaierViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as!PageViewController
        contaierViewController.controllerArray =  viewControllers
        contaierViewController.customDelegate = self
        self.addChildViewController(contaierViewController)
        contaierViewController.view.frame = mainContainerView.bounds
        mainContainerView.addSubview(contaierViewController.view)
        contaierViewController.willMove(toParentViewController: self)
    }
    
//    func configTabContainerUI() {
//        let markPath = UIBezierPath(roundedRect: tabBarView.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 15.0, height: 15.0))
//        
//        let shape = CAShapeLayer()
//        shape.path = markPath.cgPath
//        tabBarView.layer.mask = shape
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
       // configTabContainerUI()
        numPages = viewControllers.count
        initInfiniteCollectionView()
        addContentPageController()
        selectedIndex = 1
    }
    
    private func registerCell() {
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
    }
}

extension ViewController: InfiniteScrollingBehaviourDelegate {
    
    func configuredCell(forItemAtIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, forInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        if let collectionCell = cell as? CollectionViewCell,
            let tab = data as? Tab {
            collectionCell.titleLabel.text = tab.name
            if originalIndex == selectedIndex {
                collectionCell.titleLabel.textColor = #colorLiteral(red: 0.05882352941, green: 0.8941176471, blue: 0.9176470588, alpha: 1)
                collectionCell.titleLabel.font = UIFont.systemFont(ofSize: 22)
            } else {
                collectionCell.titleLabel.textColor = .white
                collectionCell.titleLabel.font = UIFont.systemFont(ofSize: 15)
            }
        }
        
        return cell
    }
    
    func didSelectItem(atIndexPath indexPath: IndexPath, originalIndex: Int, andData data: InfiniteScollingData, inInfiniteScrollingBehaviour behaviour: InfiniteScrollingBehaviour) -> Void {
        
        if !(originalIndex == selectedIndex) {
            if originalIndex == mod(a: selectedIndex + 1 , b: numPages) {
                // print("right selected")
                //print("originalIndex\(originalIndex), selectedIndex\(selectedIndex)")
                //let incrementOne = mod(a: selectedIndex + 1, b: numPages)
                let viewController = contaierViewController.getViewControllerAtIndex(index: originalIndex)
                contaierViewController.setViewControllers([viewController!], direction: .forward, animated: true, completion: nil)
                contaierViewController.currentIndex = originalIndex
            } else {
                //print("Left selected")
                //print("originalIndex\(originalIndex), selectedIndex\(selectedIndex)")
                //let incrementOne = mod(a: selectedIndex - 1, b: numPages)
                let viewController = contaierViewController.getViewControllerAtIndex(index: originalIndex)
                contaierViewController.setViewControllers([viewController!], direction: .reverse, animated: true, completion: nil)
                contaierViewController.currentIndex = originalIndex
            }
            selectedIndex = originalIndex
            collectionView.reloadData()
        }
    }
}


extension ViewController : PageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishSwipingViewController viewController: UIViewController, withDirection direction: UIPageViewControllerNavigationDirection, andCurrentIndex: Int) {
        if direction == .forward {
            //print("forward")
            swipeCollectinViewLeft()
        } else {
            //print("reverse")
            swipeCollectionViewRight()
        }
        
    }
}
