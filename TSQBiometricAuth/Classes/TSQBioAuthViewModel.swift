//
//  TSQBioAuthViewModel.swift
//  TSQBiometricAuth
//
//  Created by Kevin on 23/06/18.
//

import RxSwift
import Foundation
import LocalAuthentication

public protocol TSQBioAuthenticationDelegate: AnyObject {
    func authenticationSucceeded()
    func authenticationDisabledByUserChoice()
    func authenticationFailed(withErrorCode errorCode: Int)
}

public extension TSQBioAuthenticationDelegate {
    func authenticationFailed(withErrorCode errorCode: Int) {}
}

protocol TSQBioAuthenticationInternalDelegate: AnyObject {
    func authenticationFinishedWithState(state: TSQBioAuthState)
}

public enum TSQBioAuthState {
    case success
    case disabledByUserChoice
    case error(code: Int)
}

class TSQBioAuthViewModel {
    
    // MARK: Properties
    
    let leftButtonConfig: TSQButtonConfiguration
    let rightButtonConfig: TSQButtonConfiguration
    let logoImageConfig: TSQImageConfiguration
    let backgroundImageConfig: TSQImageConfiguration?
    let dismissSuccess: Bool
    let dismissCancelled: Bool
    
    weak var internalDelegate: TSQBioAuthenticationInternalDelegate?
    weak var delegate: TSQBioAuthenticationDelegate?
    let bioAuthState = PublishSubject<TSQBioAuthState>()
    
    private let reason: String
    private let tsqBioAuth: TSQBioAuth
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    
    public init?(reason: String,
                 leftButtonConfig: TSQButtonConfiguration = TSQButtonConfiguration(),
                 rightButtonConfig: TSQButtonConfiguration = TSQButtonConfiguration(),
                 dismissSuccess: Bool,
                 dismissCancelled: Bool,
                 logoImageConfig: TSQImageConfiguration = TSQImageConfiguration(),
                 backgroundImageConfig: TSQImageConfiguration? = nil) {
        self.tsqBioAuth = TSQBioAuth()
        if self.tsqBioAuth.canUseAuthentication() {
            self.reason = reason
            self.leftButtonConfig = leftButtonConfig
            self.rightButtonConfig = rightButtonConfig
            self.logoImageConfig = logoImageConfig
            self.backgroundImageConfig = backgroundImageConfig
            self.dismissSuccess = dismissSuccess
            self.dismissCancelled = dismissCancelled
        } else {
            return nil
        }
    }
    
    // MARK: Logic
    
    func performBiometricAuthentication() {
        if self.tsqBioAuth.canUseAuthentication() {
            self.tsqBioAuth.authenticate(self.reason).subscribe(onNext: { [weak self] (_) in
                self?.onAuthenticationSuccess()
            }, onError: { [weak self] (error) in
                let errorCode = error._code
                self?.onAuthenticationFail(withErrorCode: errorCode)
            }).disposed(by: self.disposeBag)
        } else {
            self.onAuthenticationFail(withErrorCode: LAError.Code.authenticationFailed.rawValue)
        }
    }
    
    private func onAuthenticationSuccess() {
        self.internalDelegate?.authenticationFinishedWithState(state: .success)
        self.delegate?.authenticationSucceeded()
        self.bioAuthState.onNext(.success)
    }
    
    private func onAuthenticationFail(withErrorCode errorCode: Int) {
        self.internalDelegate?.authenticationFinishedWithState(state: .error(code: errorCode))
        self.delegate?.authenticationFailed(withErrorCode: errorCode)
        self.bioAuthState.onNext(.error(code: errorCode))
    }
    
    func disableBiometricAuthentication() {
        self.internalDelegate?.authenticationFinishedWithState(state: .disabledByUserChoice)
        self.delegate?.authenticationDisabledByUserChoice()
        self.bioAuthState.onNext(.disabledByUserChoice)
    }
}
