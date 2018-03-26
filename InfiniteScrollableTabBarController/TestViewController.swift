//
//  TestViewController.swift
//  InfiniteScrollableTabBarController
//
//  Created by Iraniya Naynesh on 27/03/18.
//  Copyright © 2018 Iraniya Naynesh. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customTabBar = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        let generalVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GeneralViewController") as! GeneralViewController
        
         let shareVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        
         let otherVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OthersViewController") as! OthersViewController
        
        
        customTabBar.viewControllers = [generalVC, shareVC, otherVC]
        customTabBar.data =  Tab.settingsTab
        
        self.addChildViewController(customTabBar)
        self.view.addSubview(customTabBar.view)
        customTabBar.willMove(toParentViewController: self)
    }
}
