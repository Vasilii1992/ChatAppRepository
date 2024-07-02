//
//  Extentions.swift
//  ChatApp
//
//  Created by Василий Тихонов on 14.06.2024.
//

import Foundation
import UIKit

extension UITextField {
    
    func createTextField(holder: String, isSecureText: Bool, returnKeyType: UIReturnKeyType) {
        
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.returnKeyType = returnKeyType
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.placeholder = holder
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        self.leftViewMode = .always
        self.backgroundColor = .secondarySystemBackground
        self.isSecureTextEntry = isSecureText
   
    }
    
}

extension UIView {
    
    public var  width: CGFloat {
        return self.frame.size.width
    }
    
    public var  height: CGFloat {
        return self.frame.size.height
    }
    
    public var  top: CGFloat {
        return self.frame.origin.y
    }
    
    public var  botton: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    
    public var  left: CGFloat {
        return self.frame.origin.x
    }
    
    public var  right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
}

extension Notification.Name {
    
    static let didLogInNotification = Notification.Name("didLogInNotification")
}
