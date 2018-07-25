//
//  TSQBioAuth.swift
//  TSQBiometricAuth
//
//  Created by Kevin Cardoso de Sa on 17/07/18.
//

import RxSwift
import Foundation
import LocalAuthentication

public class TSQBioAuth {
    
    private let context = LAContext()
    private var error: NSError?
    private let authenticationType = LAPolicy.deviceOwnerAuthentication
    
    public init() {}
    
    public class func instantiateTSQBioAuthViewController(displayMessage: String,
                                                    leftButtonConfiguration: TSQButtonConfiguration,
                                                    rightButtonConfiguration: TSQButtonConfiguration,
                                                    dismissWhenAuthenticationSucceeds: Bool = true,
                                                    dismissWhenUserCancels: Bool = true,
                                                    logoImage: UIImage,
                                                    logoImageConfiguration: TSQImageConfiguration,
                                                    backgroundImage: UIImage? = nil,
                                                    backgroundImageConfiguration: TSQImageConfiguration? = nil,
                                                    backgroundColor: UIColor? = nil) -> TSQBioAuthViewController? {
        
        guard let viewModel = TSQBioAuthViewModel.init(reason: displayMessage,
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
                                                                   backgroundColor: backgroundColor)
            as? TSQBioAuthViewController else {
            return nil
        }
        
        return viewController
    }
    
    public func canUseAuthentication() -> Bool {
        if self.context.canEvaluatePolicy(self.authenticationType, error: &self.error) {
            return true
        }
        return false
    }
    
    public func authenticate(_ message: String) -> Observable<Bool> {
        let observable: Observable<Bool> = Observable.create { [weak self] (observer) -> Disposable in
            guard let authenticationType = self?.authenticationType else {
                observer.onError(NSError(domain: "TSQBioAuth", code: 1, userInfo: nil))
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
}
