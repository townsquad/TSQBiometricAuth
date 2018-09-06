//
//  TSQBioAuth.swift
//  TSQBiometricAuth
//
//  Created by Kevin Cardoso de Sa on 17/07/18.
//

import RxSwift
import Foundation
import LocalAuthentication

public enum TSQBioAuthType {
    case biometricOnly
    case biometricAndPasscode
    
    fileprivate func convertToLAPolicy() -> LAPolicy {
        switch self {
        case .biometricOnly:
            return LAPolicy.deviceOwnerAuthenticationWithBiometrics
        case .biometricAndPasscode:
            return LAPolicy.deviceOwnerAuthentication
        }
    }
    
    fileprivate static func fromLAPolicy(policy: LAPolicy) -> TSQBioAuthType {
        switch policy {
        case .deviceOwnerAuthenticationWithBiometrics:
            return .biometricOnly
        case .deviceOwnerAuthentication:
            return .biometricAndPasscode
        }
    }
}

public class TSQBioAuth {
    
    private let context = LAContext()
    private var error: NSError?
    
    private let authenticationType: LAPolicy
    private let authenticationMessage: String
    
    public init(authenticationType: TSQBioAuthType,
                authenticationMessage: String,
                fallbackTitle: String? = nil,
                cancelTitle: String? = nil) {
        self.authenticationType = authenticationType.convertToLAPolicy()
        self.authenticationMessage = authenticationMessage
        self.context.localizedFallbackTitle = fallbackTitle
        if #available(iOS 10.0, *) {
            self.context.localizedCancelTitle = cancelTitle
        }
    }
    
    //
    // Instantiates and returns the ViewController responsible for handling the authentication
    //
    public func instantiateTSQBioAuthViewController(leftButtonConfiguration: TSQButtonConfiguration,
                                                    rightButtonConfiguration: TSQButtonConfiguration,
                                                    dismissWhenAuthenticationSucceeds: Bool = true,
                                                    dismissWhenUserCancels: Bool = true,
                                                    logoImage: UIImage? = nil,
                                                    logoImageConfiguration: TSQImageConfiguration? = nil,
                                                    backgroundImage: UIImage? = nil,
                                                    backgroundImageConfiguration: TSQImageConfiguration? = nil,
                                                    backgroundColor: UIColor? = nil,
                                                    blurEffect: UIBlurEffect? = nil,
                                                    blurAlpha: CGFloat = 0.7) -> TSQBioAuthViewController? {
        guard let viewModel = TSQBioAuthViewModel.init(tsqBioAuth: self,
                                                       leftButtonConfig: leftButtonConfiguration,
                                                       rightButtonConfig: rightButtonConfiguration,
                                                       dismissSuccess: dismissWhenAuthenticationSucceeds,
                                                       dismissCancelled: dismissWhenUserCancels,
                                                       logoImageConfig: logoImageConfiguration,
                                                       backgroundImageConfig: backgroundImageConfiguration) else {
                                                        return nil
        }
        
        guard let viewController = TSQBioAuthViewController.create(viewModel: viewModel,
                                                                   backgroundImage: backgroundImage,
                                                                   logoImage: logoImage,
                                                                   backgroundColor: backgroundColor,
                                                                   blurEffect: blurEffect,
                                                                   blurAlpha: blurAlpha)
            as? TSQBioAuthViewController else {
            return nil
        }
        
        return viewController
    }
    
    //
    // Verifies if a authenticationType can be performed
    //
    public func canUseAuthentication(authenticationType: TSQBioAuthType? = nil) -> Bool {
        let authenticationTypeToEvaluate: LAPolicy
        if let authenticationType = authenticationType {
            authenticationTypeToEvaluate = authenticationType.convertToLAPolicy()
        } else {
            authenticationTypeToEvaluate = self.authenticationType
        }
        if self.context.canEvaluatePolicy(authenticationTypeToEvaluate, error: &self.error) {
            return true
        }
        return false
    }
    
    //
    // Perform the authentication based on the authenticationType sent in this class' initializer
    //
    public func authenticate() -> Observable<Bool> {
        let observable: Observable<Bool> = Observable.create { [weak self] (observer) -> Disposable in
            guard let authenticationType = self?.authenticationType,
                let message = self?.authenticationMessage else {
                observer.onError(NSError(domain: "Authentication Failed",
                                         code: 1,
                                         userInfo: nil))
                return Disposables.create()
            }
            
            self?.context.evaluatePolicy(authenticationType, localizedReason: message) { (success, error) in
                if success {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: error?.localizedDescription ?? "Authentication Failed",
                                             code: error?._code ?? 0,
                                             userInfo: nil))
                }
            }
            return Disposables.create()
        }
        return observable
    }
    
    func getAuthenticationType() -> TSQBioAuthType {
        return TSQBioAuthType.fromLAPolicy(policy: self.authenticationType)
    }
}
