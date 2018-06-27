//
//  TSQBioAuthViewModel.swift
//  TSQBiometricAuth
//
//  Created by Kevin on 23/06/18.
//

import Foundation
import LocalAuthentication

public struct ButtonConfiguration {
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

public protocol TSQBioAuthenticationDelegate: AnyObject {
    func authenticationSuccess()
    func authenticationDisabledByUserChoice()
}

protocol TSQBioAuthenticationInternalDelegate: AnyObject {
    func authenticationFinishedWithState(state: TSQBioAuthState)
}

enum TSQBioAuthState {
    case success
    case retry
    case cancelled
    case unavailable
    case passcode
    case notSet
}

public class TSQBioAuthViewModel {
    
    // MARK: Properties
    
    let firstButtonConfig: ButtonConfiguration
    let secondButtonConfig: ButtonConfiguration
    
    weak var internalDelegate: TSQBioAuthenticationInternalDelegate?
    public weak var delegate: TSQBioAuthenticationDelegate?
    
    private let context = LAContext()
    private var error: NSError?
    private let reason: String
    
    // MARK: Initialization
    
    public init?(reason: String,
                 firstButtonConfig: ButtonConfiguration = ButtonConfiguration(),
                 secondButtonConfig: ButtonConfiguration = ButtonConfiguration()) {
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            self.reason = reason
            self.firstButtonConfig = firstButtonConfig
            self.secondButtonConfig = secondButtonConfig
        } else {
            return nil
        }
    }
    
    // MARK: Logic
    
    func performBiometricAuthentication() {
        if self.context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &self.error) {
            self.context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: self.reason) { (success, error) in
                if success {
                    self.internalDelegate?.authenticationFinishedWithState(state: .success)
                    self.delegate?.authenticationSuccess()
                } else {
                    if let errorCode = error?._code {
                        let bioAuthState = self.getBioAuthState(errorCode: errorCode)
                        self.internalDelegate?.authenticationFinishedWithState(state: bioAuthState)
                    }
                    let bioAuthState = self.getBioAuthState(errorCode: LAError.Code.authenticationFailed.rawValue)
                    self.internalDelegate?.authenticationFinishedWithState(state: bioAuthState)
                }
            }
        } else {
            let bioAuthState = self.getBioAuthState(errorCode: LAError.Code.touchIDNotAvailable.rawValue)
            self.internalDelegate?.authenticationFinishedWithState(state: bioAuthState)
        }
    }
    
    func disableBiometricAuthentication() {
        self.internalDelegate?.authenticationFinishedWithState(state: .cancelled)
        self.delegate?.authenticationDisabledByUserChoice()
    }

    func getBioAuthState(errorCode: Int) -> TSQBioAuthState {
        switch errorCode {
        case LAError.appCancel.rawValue:
            return .retry
        case LAError.authenticationFailed.rawValue:
            return .retry
        case LAError.invalidContext.rawValue:
            return .cancelled
        case LAError.passcodeNotSet.rawValue:
            return .notSet
        case LAError.systemCancel.rawValue:
            return .cancelled
        case LAError.touchIDLockout.rawValue:
            return .cancelled
        case LAError.touchIDNotAvailable.rawValue:
            return .unavailable
        case LAError.userCancel.rawValue:
            return .cancelled
        case LAError.userFallback.rawValue:
            return .passcode
        default:
            return .retry
        }
    }
}
