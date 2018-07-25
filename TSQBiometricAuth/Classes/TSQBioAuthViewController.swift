//
//  TSQBioAuthViewController.swift
//  TSQBiometricAuth
//
//  Created by Kevin on 23/06/18.
//

import UIKit
import RxSwift

@available(iOS 9.0, *)
final public class TSQBioAuthViewController: UIViewController {
    
    // MARK: Properties
    
    public var backgroundImage: UIImage? = nil {
        didSet {
            guard let image = self.backgroundImage else {
                self.backgroundImageView?.isHidden = true
                return
            }
            self.backgroundImageView?.image = image
            self.backgroundImageView?.isHidden = false
        }
    }
    
    public var logoImage: UIImage? = nil {
        didSet {
            guard let image = self.logoImage else {
                self.logoImageView?.isHidden = true
                return
            }
            self.logoImageView?.image = image
            self.logoImageView?.isHidden = false
        }
    }
    
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
        self.view.backgroundColor = .white
        
        self.backgroundImageView = UIImageView(frame: CGRect.zero)
        self.backgroundImageView?.image = self.backgroundImage
        if let backgroundImageConfig = self.viewModel.backgroundImageConfig {
            self.backgroundImageView?.contentMode = backgroundImageConfig.contentMode
        }

        self.logoImageView = UIImageView(frame: CGRect.zero)
        self.logoImageView?.image = self.logoImage
        self.logoImageView?.contentMode = self.viewModel.logoImageConfig.contentMode

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
            let backgroundImageView = self.backgroundImageView,
            let logoImageView = self.logoImageView,
            let buttonsStackView = self.buttonsStackView else {
                return
        }
        self.buttonsStackView?.addArrangedSubview(leftButton)
        self.buttonsStackView?.addArrangedSubview(rightButton)

        self.view.addSubview(backgroundImageView)
        self.view.addSubview(logoImageView)
        self.view.addSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        guard let leftButton = self.leftButton,
            let rightButton = self.rightButton else {
            return
        }
        
        self.backgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.backgroundImageView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.backgroundImageView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.backgroundImageView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.logoImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView?.heightAnchor.constraint(equalToConstant: self.viewModel.logoImageConfig.height).isActive = true
        self.logoImageView?.widthAnchor.constraint(equalToConstant: self.viewModel.logoImageConfig.width).isActive = true
        self.logoImageView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor,
                                                     constant: self.viewModel.logoImageConfig.xOffset).isActive = true
        self.logoImageView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor,
                                                     constant: self.viewModel.logoImageConfig.yOffset).isActive = true

        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16.0).isActive = true
        self.buttonsStackView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.0).isActive = true
        self.buttonsStackView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.0).isActive = true
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
        case .error:
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.buttonsStackView?.isHidden = false
                })
            }
        }
    }
}

@available(iOS 9.0, *)
extension TSQBioAuthViewController {
    static func create(viewModel: TSQBioAuthViewModel,
                              backgroundImage: UIImage? = nil,
                              logoImage: UIImage? = nil,
                              backgroundColor: UIColor?) -> UIViewController {
        let viewController = TSQBioAuthViewController()
        viewController.setDependencies(viewModel: viewModel)
        viewController.backgroundImage = backgroundImage
        viewController.logoImage = logoImage
        viewController.view.backgroundColor = backgroundColor ?? .white
        
        return viewController
    }
    
    private func setDependencies(viewModel: TSQBioAuthViewModel) {
        self.viewModel = viewModel
    }
}
