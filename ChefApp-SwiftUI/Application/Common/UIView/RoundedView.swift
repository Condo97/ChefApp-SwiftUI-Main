//
//  RoundedView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 1/9/23.
//

import UIKit

class RoundedView: UIView {
    
    @IBInspectable open var borderWidth: CGFloat = Constants.UI.borderWidth
    @IBInspectable open var borderColor: UIColor = UIColor(Colors.elementBackground)
    @IBInspectable open var cornerRadius: CGFloat = Constants.UI.cornerRadius
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
    }
}
