//
//  TSQBioAuthViewModel.swift
//  TSQBiometricAuth
//
//  Created by Kevin on 23/06/18.
//

import Foundation
import LocalAuthentication

public protocol TSQBioAuthenticationDelegate: AnyObject {
    func authenticationFinishedWithState(state: TSQBioAuthState)
}

public enum TSQBioAuthState {
    case success
    case retry
    case cancelled
    case unavailable
    case passcode
    case notSet
}

public class TSQBioAuthViewModel {
    
    // MARK: Properties
    
    public weak var delegate: TSQBioAuthenticationDelegate?
    
    private let reason: String
    
    // MARK: Initialization
    
    public init(reason: String) {
        self.reason = reason
    }
    
    // MARK: Logic
    
    func performBiometricAuthentication() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: self.reason) { (success, error) in
                if success {
                    self.delegate?.authenticationFinishedWithState(state: .success)
                } else {
                    if let errorCode = error?._code {
                        let bioAuthState = self.getBioAuthState(errorCode: errorCode)
                        self.delegate?.authenticationFinishedWithState(state: bioAuthState)
                    }
                    let bioAuthState = self.getBioAuthState(errorCode: LAError.Code.authenticationFailed.rawValue)
                    self.delegate?.authenticationFinishedWithState(state: bioAuthState)
                }
            }
        } else {
            let bioAuthState = self.getBioAuthState(errorCode: LAError.Code.touchIDNotAvailable.rawValue)
            self.delegate?.authenticationFinishedWithState(state: bioAuthState)
        }
    }
    
    func cancelBiometricAuthentication() {
        self.delegate?.authenticationFinishedWithState(state: .cancelled)
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
