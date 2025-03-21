//
//  RegistryHelper.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 3/23/23.
//

import Foundation
import UIKit

class RegistryHelper {
    
    static func instantiateAsView(nibName: String, owner: UIViewController) -> UIView? {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: owner)[0] as? UIView
    }
    
    static func instantiateInitialViewControllerFromStoryboard(storyboardName: String) -> UIViewController? {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController()
    }
    
}
