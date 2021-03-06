//
//  PageViewController.swift
//  InfiniteScrollableTabBarController
//
//  Created by Iraniya Naynesh on 23/03/18.
//  Copyright © 2018 Iraniya Naynesh. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishSwipingViewController viewController: UIViewController, withDirection direction:UIPageViewControllerNavigationDirection, andCurrentIndex: Int)
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    public var totalCount = 0
    var controllerArray = [UIViewController]()
    var currentIndex = 0
    var customDelegate: PageViewControllerDelegate?
    var nextIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalCount = controllerArray.count
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([getViewControllerAtIndex(index: 1)] as? [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard var index = controllerArray.index(of: viewController) else { return nil }
        index = index - 1;
        index = mod(a: index, b: totalCount)
        return getViewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard var index = controllerArray.index(of: viewController) else { return nil }
        index = index + 1;
        index = mod(a: index, b: totalCount)
        if (index == controllerArray.count) { return nil; }
        return getViewControllerAtIndex(index: index)
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> UIViewController? {
        return controllerArray[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let index = controllerArray.index(of: pendingViewControllers[0]) else { fatalError("pageViewController willTransitionTo fatalError") }
        nextIndex = index
    }
    
    func getDirectionFrom(_ currentIndex: Int, andLastIndex lastIndex: Int) -> UIPageViewControllerNavigationDirection {
        if currentIndex == mod(a: lastIndex + 1 , b: totalCount) {
            return UIPageViewControllerNavigationDirection.forward
        } else {
            return UIPageViewControllerNavigationDirection.reverse
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard let index = controllerArray.index(of: previousViewControllers[0]) else { fatalError("didFinishAnimating fatalError") }
            
            let swipeDirection = (getDirectionFrom(nextIndex, andLastIndex: index))
            currentIndex = nextIndex
            customDelegate?.pageViewController(self, didFinishSwipingViewController: previousViewControllers[0], withDirection: swipeDirection, andCurrentIndex: currentIndex)
        } else { /*if swipe fail do things here */}
    }
    
    func mod(a: Int, b: Int) -> Int {
        let r: Int = a % b;
        return r < 0 ? r + b : r;
    }
}
