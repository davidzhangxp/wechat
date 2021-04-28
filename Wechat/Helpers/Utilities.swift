//
//  Utilities.swift
//  Wechat
//
//  Created by Max Wen on 12/25/20.
//

import Foundation
import UIKit

class Utilities {
    static func styleTextField(_ textfield:UITextField) {
  
        //create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.height - 2, width: textfield.width, height: 3)

        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
//        
        textfield.borderStyle = .none
        textfield.layer.addSublayer(bottomLine)
        
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        textfield.returnKeyType = .continue

        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textfield.leftViewMode = .always
        textfield.backgroundColor = .white
    }
    
    static func styleLoginButton(_ button:UIButton) {
        
//        button.backgroundColor = UIColor.init(red: 248/255, green: 73/255, blue: 99/255, alpha: 1)
        button.layer.cornerRadius = 12.0
        button.tintColor = UIColor.white
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        
    }
    
    static func styleHelloButton(_ button:UIButton) {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
        
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }

    
}

