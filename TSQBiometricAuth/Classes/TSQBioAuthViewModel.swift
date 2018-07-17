//
//  TSQBioAuthViewModel.swift
//  TSQBiometricAuth
//
//  Created by Kevin on 23/06/18.
//

import RxSwift
import Foundation

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

public enum TSQBioAuthState {
    case success
    case cancelledByUser
    case error
}

public class TSQBioAuthViewModel {
    
    // MARK: Properties
    
    let firstButtonConfig: ButtonConfiguration
    let secondButtonConfig: ButtonConfiguration
    
    weak var internalDelegate: TSQBioAuthenticationInternalDelegate?
    public weak var delegate: TSQBioAuthenticationDelegate?
    public let bioAuthState = PublishSubject<TSQBioAuthState>()
    
    private let reason: String
    private let tsqBioAuth: TSQBioAuth
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    
    public init?(reason: String,
                 firstButtonConfig: ButtonConfiguration = ButtonConfiguration(),
                 secondButtonConfig: ButtonConfiguration = ButtonConfiguration()) {
        self.tsqBioAuth = TSQBioAuth()
        if self.tsqBioAuth.canUseAuthentication() {
            self.reason = reason
            self.firstButtonConfig = firstButtonConfig
            self.secondButtonConfig = secondButtonConfig
        } else {
            return nil
        }
    }
    
    // MARK: Logic
    
    func performBiometricAuthentication() {
        if self.tsqBioAuth.canUseAuthentication() {
            self.tsqBioAuth.authenticate(self.reason).subscribe(onNext: { [weak self] (_) in
                self?.onAuthenticationSuccess()
            }, onError: { [weak self] (_) in
                self?.onAuthenticationError()
            }).disposed(by: self.disposeBag)
        } else {
            self.onAuthenticationError()
        }
    }
    
    private func onAuthenticationSuccess() {
        self.internalDelegate?.authenticationFinishedWithState(state: .success)
        self.delegate?.authenticationSuccess()
        self.bioAuthState.onNext(.success)
    }
    
    private func onAuthenticationError() {
        self.internalDelegate?.authenticationFinishedWithState(state: .error)
        self.bioAuthState.onNext(.error)
    }
    
    func disableBiometricAuthentication() {
        self.internalDelegate?.authenticationFinishedWithState(state: .cancelledByUser)
        self.delegate?.authenticationDisabledByUserChoice()
        self.bioAuthState.onNext(.cancelledByUser)
    }
}
