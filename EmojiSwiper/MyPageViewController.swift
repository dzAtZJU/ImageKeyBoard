//
//  MyPageViewController.swift
//  Emoer
//
//  Created by zz on 15/04/2017.
//  Copyright © 2017 Zhou Wei Ran. All rights reserved.
//

import Foundation
import UIKit

class MyPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    //<UIPageViewControllerDataSource>
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        return nil
    }

}
