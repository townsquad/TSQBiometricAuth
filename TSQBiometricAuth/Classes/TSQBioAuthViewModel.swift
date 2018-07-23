//
//  TSQBioAuthViewModel.swift
//  TSQBiometricAuth
//
//  Created by Kevin on 23/06/18.
//

import RxSwift
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
    
    let firstButtonConfig: TSQButtonConfiguration
    let secondButtonConfig: TSQButtonConfiguration
    let logoConfig: TSQImageConfiguration
    
    weak var internalDelegate: TSQBioAuthenticationInternalDelegate?
    public weak var delegate: TSQBioAuthenticationDelegate?
    public let bioAuthState = PublishSubject<TSQBioAuthState>()
    
    private let reason: String
    private let tsqBioAuth: TSQBioAuth
    private let disposeBag = DisposeBag()
    
    // MARK: Initialization
    
    public init?(reason: String,
                 firstButtonConfig: TSQButtonConfiguration = TSQButtonConfiguration(),
                 secondButtonConfig: TSQButtonConfiguration = TSQButtonConfiguration(),
                 logoConfig: TSQImageConfiguration = TSQImageConfiguration()) {
        self.tsqBioAuth = TSQBioAuth()
        if self.tsqBioAuth.canUseAuthentication() {
            self.reason = reason
            self.firstButtonConfig = firstButtonConfig
            self.secondButtonConfig = secondButtonConfig
            self.logoConfig = logoConfig
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
