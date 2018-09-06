//
//  TSQBioAuthViewController.swift
//  TSQBiometricAuth
//
//  Created by Kevin on 23/06/18.
//

import UIKit
import RxSwift
import LocalAuthentication

@available(iOS 9.0, *)
final public class TSQBioAuthViewController: UIViewController {
    
    // MARK: Properties
    
    public var backgroundImage: UIImage? {
        didSet {
            guard let image = self.backgroundImage else {
                self.backgroundImageView?.isHidden = true
                return
            }
            self.backgroundImageView?.image = image
            self.backgroundImageView?.isHidden = false
        }
    }
    
    public var logoImage: UIImage? {
        didSet {
            guard let image = self.logoImage else {
                self.logoImageView?.isHidden = true
                return
            }
            self.logoImageView?.image = image
            self.logoImageView?.isHidden = false
        }
    }
    
    public var blurEffect: UIBlurEffect? {
        didSet {
            self.blurView?.effect = self.blurEffect
        }
    }
    
    public var blurAlpha: CGFloat = 1.0 {
        didSet {
            self.blurView?.alpha = self.blurAlpha
        }
    }
    
    private var blurView: UIVisualEffectView?
    private var backgroundImageView: UIImageView?
    private var logoImageView: UIImageView?
    
    private var buttonsStackView: UIStackView?
    private var leftButton: UIButton?
    private var rightButton: UIButton?
    
    private let disposeBag = DisposeBag()
    
    private var viewModel: TSQBioAuthViewModel! {
        didSet {
            self.viewModel.internalDelegate = self
        }
    }
    public var delegate: TSQBioAuthenticationDelegate? {
        didSet {
            self.viewModel.delegate = self.delegate
        }
    }
    public lazy var authenticationState: Observable<TSQBioAuthState> = self.viewModel.bioAuthState.asObservable()
    
    // MARK: Initialization
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupConstraints()
        self.setupBindings()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.performBiometricAuthentication()
    }
    
    private func setupUI() {
        self.blurView = UIVisualEffectView()
        self.blurView?.effect = self.blurEffect
        self.blurView?.alpha = self.blurAlpha
        
        self.backgroundImageView = UIImageView(frame: CGRect.zero)
        self.backgroundImageView?.image = self.backgroundImage
        if let backgroundImageConfig = self.viewModel.backgroundImageConfig {
            self.backgroundImageView?.contentMode = backgroundImageConfig.contentMode
        }

        self.logoImageView = UIImageView(frame: CGRect.zero)
        self.logoImageView?.image = self.logoImage
        if let logoImageConfig = self.viewModel.logoImageConfig {
            self.logoImageView?.contentMode = logoImageConfig.contentMode
        }

        self.buttonsStackView = UIStackView(frame: CGRect.zero)
        self.buttonsStackView?.backgroundColor = .red
        self.buttonsStackView?.isHidden = true
        
        self.leftButton = UIButton(frame: CGRect.zero)
        self.leftButton?.setTitle(self.viewModel.leftButtonConfig.text, for: .normal)
        self.leftButton?.setTitleColor(self.viewModel.leftButtonConfig.textColor, for: .normal)
        self.leftButton?.titleLabel?.font = self.viewModel.leftButtonConfig.font
        self.leftButton?.layer.cornerRadius = self.viewModel.leftButtonConfig.cornerRadius
        self.leftButton?.layer.borderColor = self.viewModel.leftButtonConfig.borderColor
        self.leftButton?.layer.borderWidth = self.viewModel.leftButtonConfig.borderWidth
        self.leftButton?.backgroundColor = self.viewModel.leftButtonConfig.backgroundColor
        
        self.rightButton = UIButton(frame: CGRect.zero)
        self.rightButton?.setTitle(self.viewModel.rightButtonConfig.text, for: .normal)
        self.rightButton?.setTitleColor(self.viewModel.rightButtonConfig.textColor, for: .normal)
        self.rightButton?.titleLabel?.font = self.viewModel.rightButtonConfig.font
        self.rightButton?.layer.cornerRadius = self.viewModel.rightButtonConfig.cornerRadius
        self.rightButton?.layer.borderColor = self.viewModel.rightButtonConfig.borderColor
        self.rightButton?.layer.borderWidth = self.viewModel.rightButtonConfig.borderWidth
        self.rightButton?.backgroundColor = self.viewModel.rightButtonConfig.backgroundColor
        
        guard let leftButton = self.leftButton,
            let rightButton = self.rightButton,
            let blurView = self.blurView,
            let backgroundImageView = self.backgroundImageView,
            let logoImageView = self.logoImageView,
            let buttonsStackView = self.buttonsStackView else {
                return
        }
        self.buttonsStackView?.addArrangedSubview(leftButton)
        self.buttonsStackView?.addArrangedSubview(rightButton)

        self.view.addSubview(blurView)
        self.view.addSubview(backgroundImageView)
        self.view.addSubview(logoImageView)
        self.view.addSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        guard let leftButton = self.leftButton,
            let rightButton = self.rightButton else {
            return
        }
        let layoutGuide: UILayoutGuide
        if #available(iOS 11.0, *) {
            layoutGuide = self.view.safeAreaLayoutGuide
        } else {
            layoutGuide = self.view.layoutMarginsGuide
        }
        
        self.blurView?.translatesAutoresizingMaskIntoConstraints = false
        self.blurView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.blurView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.blurView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.blurView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.backgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView?.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        self.backgroundImageView?.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        self.backgroundImageView?.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        self.backgroundImageView?.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true

        self.logoImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView?.heightAnchor.constraint(equalToConstant: self.viewModel.logoImageConfig?.height ?? 0).isActive = true
        self.logoImageView?.widthAnchor.constraint(equalToConstant: self.viewModel.logoImageConfig?.width ?? 0).isActive = true
        self.logoImageView?.centerXAnchor.constraint(equalTo: layoutGuide.centerXAnchor,
                                                     constant: self.viewModel.logoImageConfig?.xOffset ?? 0).isActive = true
        self.logoImageView?.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor,
                                                     constant: self.viewModel.logoImageConfig?.yOffset ?? 0).isActive = true

        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor,
                                                       constant: -16.0).isActive = true
        self.buttonsStackView?.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor,
                                                        constant: 16.0).isActive = true
        self.buttonsStackView?.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -16.0).isActive = true
        self.buttonsStackView?.spacing = 16.0

        leftButton.widthAnchor.constraint(equalTo: rightButton.widthAnchor, multiplier: 1.0).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: self.viewModel.leftButtonConfig.height).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: self.viewModel.rightButtonConfig.height).isActive = true
    }
    
    private func setupBindings() {
        self.leftButton?.addTarget(self, action: #selector(self.didPressLeftButton), for: .touchUpInside)
        self.rightButton?.addTarget(self, action: #selector(self.didPressRightButton), for: .touchUpInside)
    }
    
    // Logic
    
    @objc private func didPressLeftButton() {
        self.viewModel.disableBiometricAuthentication()
    }
    
    @objc private func didPressRightButton() {
        self.viewModel.performBiometricAuthentication()
    }
}

@available(iOS 9.0, *)
extension TSQBioAuthViewController: TSQBioAuthenticationInternalDelegate {
    func authenticationFinishedWithState(state: TSQBioAuthState) {
        switch state {
        case .success:
            if self.viewModel.dismissSuccess {
                self.dismiss(animated: true, completion: nil)
                return
            }
        case .disabledByUserChoice:
            if self.viewModel.dismissCancelled {
                self.dismiss(animated: true, completion: nil)
                return
            }
        case .error(code: let errorCode):
            let authType = self.viewModel.tsqBioAuth.getAuthenticationType()
            if errorCode == LAError.Code.userFallback.rawValue && authType == .biometricOnly {
                self.viewModel.disableBiometricAuthentication()
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.buttonsStackView?.isHidden = false
                    })
                }
            }
        }
    }
}

@available(iOS 9.0, *)
extension TSQBioAuthViewController {
    static func create(viewModel: TSQBioAuthViewModel,
                       backgroundImage: UIImage?,
                       logoImage: UIImage?,
                       backgroundColor: UIColor?,
                       blurEffect: UIBlurEffect?,
                       blurAlpha: CGFloat) -> UIViewController {
        let viewController = TSQBioAuthViewController()
        viewController.setDependencies(viewModel: viewModel)
        viewController.backgroundImage = backgroundImage
        viewController.logoImage = logoImage
        viewController.view.backgroundColor = backgroundColor
        viewController.blurEffect = blurEffect
        viewController.blurAlpha = blurAlpha
        viewController.modalPresentationStyle = .overFullScreen
        
        return viewController
    }
    
    private func setDependencies(viewModel: TSQBioAuthViewModel) {
        self.viewModel = viewModel
    }
}
