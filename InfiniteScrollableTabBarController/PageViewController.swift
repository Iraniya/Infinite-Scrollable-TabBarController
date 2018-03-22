//
//  PageViewController.swift
//  InfiniteScrollableTabBarController
//
//  Created by Iraniya Naynesh on 23/03/18.
//  Copyright © 2018 Iraniya Naynesh. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishSwipingViewController viewController: UIViewController, withlastIndex index: Int)
}

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    public var totalCount = 0
    var controllerArray = [UIViewController]()
    var currentIndex = 0
    var customDelegate: PageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalCount = controllerArray.count
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([getViewControllerAtIndex(index: 1)] as? [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard var index = controllerArray.index(of: viewController) else {
            return nil
        }
        
        index = index - 1;
        
        index = mod(a: index, b: totalCount)
        return getViewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        
        guard var index = controllerArray.index(of: viewController) else {
            return nil
        }
        
        index = index + 1;
        index = mod(a: index, b: totalCount)
        if (index == controllerArray.count) {
            return nil;
        }
        return getViewControllerAtIndex(index: index)
    }
    
    func getViewControllerAtIndex(index: NSInteger) -> UIViewController? {
        
        switch index {
        case 0:
            
            //            let generaVC = self.storyboard?.instantiateViewController(withIdentifier: "GeneralViewController") as! GeneralViewController
            let generaVC = controllerArray[0] as! GeneralViewController
            generaVC.pageIndex = index
            return generaVC
        case 1:
            let shareVC = controllerArray[1] as! ShareViewController //self.storyboard?.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
            shareVC.pageIndex = index
            return shareVC
        case 2:
            let otherVC = controllerArray[2] as! OthersViewController //self.storyboard?.instantiateViewController(withIdentifier: "OthersViewController") as! OthersViewController
            otherVC.pageIndex = index
            return otherVC
        default: break
            
        }
        return nil
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            // print(currentIndex)
            
            guard var index = controllerArray.index(of: previousViewControllers[0]) else {
                fatalError("error")
            }
            customDelegate?.pageViewController(self, didFinishSwipingViewController: previousViewControllers[0], withlastIndex: index)
        }
    }
    
    func mod(a: Int, b: Int) -> Int {
        let r: Int = a % b;
        return r < 0 ? r + b : r;
    }
}
