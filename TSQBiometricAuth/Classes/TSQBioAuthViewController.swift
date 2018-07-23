//
//  TSQBioAuthViewController.swift
//  TSQBiometricAuth
//
//  Created by Kevin on 23/06/18.
//

import UIKit
import RxSwift
import RxCocoa

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
    private var firstButton: UIButton?
    private var secondButton: UIButton?
    
    private let disposeBag = DisposeBag()
    
    var viewModel: TSQBioAuthViewModel! {
        didSet {
            viewModel.internalDelegate = self
        }
    }
    
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

        self.logoImageView = UIImageView(frame: CGRect.zero)
        self.logoImageView?.image = self.logoImage

        self.buttonsStackView = UIStackView(frame: CGRect.zero)
        self.buttonsStackView?.backgroundColor = .red
        self.buttonsStackView?.isHidden = true
        
        self.firstButton = UIButton(frame: CGRect.zero)
        self.firstButton?.setTitle(self.viewModel.firstButtonConfig.text, for: .normal)
        self.firstButton?.setTitleColor(self.viewModel.firstButtonConfig.textColor, for: .normal)
        self.firstButton?.titleLabel?.font = self.viewModel.firstButtonConfig.font
        self.firstButton?.layer.cornerRadius = self.viewModel.firstButtonConfig.cornerRadius
        self.firstButton?.layer.borderColor = self.viewModel.firstButtonConfig.borderColor
        self.firstButton?.layer.borderWidth = self.viewModel.firstButtonConfig.borderWidth
        self.firstButton?.backgroundColor = self.viewModel.firstButtonConfig.backgroundColor
        
        self.secondButton = UIButton(frame: CGRect.zero)
        self.secondButton?.setTitle(self.viewModel.secondButtonConfig.text, for: .normal)
        self.secondButton?.setTitleColor(self.viewModel.secondButtonConfig.textColor, for: .normal)
        self.secondButton?.titleLabel?.font = self.viewModel.secondButtonConfig.font
        self.secondButton?.layer.cornerRadius = self.viewModel.secondButtonConfig.cornerRadius
        self.secondButton?.layer.borderColor = self.viewModel.secondButtonConfig.borderColor
        self.secondButton?.layer.borderWidth = self.viewModel.secondButtonConfig.borderWidth
        self.secondButton?.backgroundColor = self.viewModel.secondButtonConfig.backgroundColor
        
        guard let firstButton = self.firstButton,
            let secondButton = self.secondButton,
            let backgroundImageView = self.backgroundImageView,
            let logoImageView = self.logoImageView,
            let buttonsStackView = self.buttonsStackView else {
                return
        }
        self.buttonsStackView?.addArrangedSubview(firstButton)
        self.buttonsStackView?.addArrangedSubview(secondButton)

        self.view.addSubview(backgroundImageView)
        self.view.addSubview(logoImageView)
        self.view.addSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        guard let logoImageView = self.logoImageView,
            let firstButton = self.firstButton,
            let secondButton = self.secondButton else {
            return
        }
        
        self.backgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.backgroundImageView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.backgroundImageView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.backgroundImageView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.logoImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView?.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        self.logoImageView?.widthAnchor.constraint(equalTo: logoImageView.heightAnchor, multiplier: 1.0).isActive = true
        self.logoImageView?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.logoImageView?.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        self.buttonsStackView?.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16.0).isActive = true
        self.buttonsStackView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.0).isActive = true
        self.buttonsStackView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.0).isActive = true
        self.buttonsStackView?.spacing = 16.0

        firstButton.widthAnchor.constraint(equalTo: secondButton.widthAnchor, multiplier: 1.0).isActive = true
        firstButton.heightAnchor.constraint(equalToConstant: self.viewModel.firstButtonConfig.height).isActive = true
        secondButton.heightAnchor.constraint(equalToConstant: self.viewModel.secondButtonConfig.height).isActive = true
    }
    
    private func setupBindings() {
        
        self.firstButton?.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.didPressFirstButton()
        }).disposed(by: self.disposeBag)
        self.secondButton?.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.didPressSecondButton()
        }).disposed(by: self.disposeBag)
    }
    
    // Logic
    
    private func didPressFirstButton() {
        self.viewModel.disableBiometricAuthentication()
    }
    
    private func didPressSecondButton() {
        self.viewModel.performBiometricAuthentication()
    }
}

@available(iOS 9.0, *)
extension TSQBioAuthViewController: TSQBioAuthenticationInternalDelegate {
    func authenticationFinishedWithState(state: TSQBioAuthState) {
        if state == .success || state == TSQBioAuthState.cancelledByUser {
            self.dismiss(animated: true, completion: nil)
        } else {
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
    static public func create(viewModel: TSQBioAuthViewModel,
                              backgroundImage: UIImage? = nil,
                              logoImage: UIImage? = nil,
                              backgroundColor: UIColor = .white) -> UIViewController {
        let viewController = TSQBioAuthViewController()
        viewController.setDependencies(viewModel: viewModel)
        viewController.backgroundImage = backgroundImage
        viewController.logoImage = logoImage
        viewController.view.backgroundColor = backgroundColor
        
        return viewController
    }
    
    private func setDependencies(viewModel: TSQBioAuthViewModel) {
        self.viewModel = viewModel
    }
}
