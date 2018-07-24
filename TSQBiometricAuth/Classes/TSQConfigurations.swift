//
//  TSQConfigurations.swift
//  TSQBiometricAuth
//
//  Created by Kevin Cardoso de Sa on 24/07/18.
//

import Foundation

public struct TSQImageConfiguration {
    let height: CGFloat
    let width: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    let contentMode: UIViewContentMode
    
    public init(height: CGFloat = 80,
                width: CGFloat = 80,
                xOffset: CGFloat = 0,
                yOffset: CGFloat = 0,
                contentMode: UIViewContentMode = .scaleToFill) {
        self.height = height
        self.width = width
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.contentMode = contentMode
    }
}

public struct TSQButtonConfiguration {
    let cornerRadius: CGFloat
    let borderColor: CGColor
    let borderWidth: CGFloat
    let backgroundColor: UIColor
    let height: CGFloat
    let text: String
    let textColor: UIColor
    let font: UIFont
    
    public init(cornerRadius: CGFloat = 5.0,
                borderColor: UIColor = UIColor.white,
                borderWidth: CGFloat = 1.0,
                backgroundColor: UIColor = UIColor.white,
                height: CGFloat = 40.0,
                text: String = "",
                textColor: UIColor = UIColor.black,
                font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor.cgColor
        self.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
        self.height = height
        self.text = text
        self.textColor = textColor
        self.font = font
    }
}
