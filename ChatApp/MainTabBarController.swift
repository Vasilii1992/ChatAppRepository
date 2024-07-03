//
//  MainTabBarController.swift
//  ChatApp
//
//  Created by Василий Тихонов on 15.06.2024.
//

import Foundation
import UIKit
 
final class MainTabBarController: UITabBarController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    func setupTabBar() {
        let conversationViewController = createNavController(vc: ConversationViewController(), itemName: "Chat", itemImage: "message.circle.fill")
        let profileViewController = createNavController(vc: ProfileViewController(), itemName: "Profile", itemImage: "person.crop.circle")
        
        viewControllers = [conversationViewController, profileViewController]
    }
    
    
    func createNavController(vc: UIViewController, itemName: String, itemImage: String) -> UINavigationController {
        
        let item = UITabBarItem(title: itemName, image: UIImage(systemName: itemImage)?.withAlignmentRectInsets(.init(top: 10,
                                                                                                                      left: 0,
                                                                                                                      bottom: 0,
                                                                                                                      right: 0)), tag: 0)
        item.titlePositionAdjustment = .init(horizontal: 0, vertical: 0)
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem = item
        return navController
        
        
    }


}

/*
 

 
 */
