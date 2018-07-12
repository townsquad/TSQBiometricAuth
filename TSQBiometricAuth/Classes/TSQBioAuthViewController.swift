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
    
    var backgroundImageView: UIImageView!
    var logoImageView: UIImageView!
    
    var buttonsStackView: UIStackView!
    var firstButton: UIButton!
    var secondButton: UIButton!
    
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
        self.backgroundImageView.backgroundColor = .blue

        self.logoImageView = UIImageView(frame: CGRect.zero)
        self.logoImageView.backgroundColor = .green
        
        self.buttonsStackView = UIStackView(frame: CGRect.zero)
        self.buttonsStackView.backgroundColor = .red
        self.buttonsStackView.isHidden = true
        
        self.firstButton = UIButton(frame: CGRect.zero)
        self.firstButton.setTitle(self.viewModel.firstButtonConfig.text, for: .normal)
        self.firstButton.setTitleColor(self.viewModel.firstButtonConfig.textColor, for: .normal)
        self.firstButton.titleLabel?.font = self.viewModel.firstButtonConfig.font
        self.firstButton.layer.cornerRadius = self.viewModel.firstButtonConfig.cornerRadius
        self.firstButton.layer.borderColor = self.viewModel.firstButtonConfig.borderColor
        self.firstButton.layer.borderWidth = self.viewModel.firstButtonConfig.borderWidth
        self.firstButton.backgroundColor = self.viewModel.firstButtonConfig.backgroundColor
        
        self.secondButton = UIButton(frame: CGRect.zero)
        self.secondButton.setTitle(self.viewModel.secondButtonConfig.text, for: .normal)
        self.secondButton.setTitleColor(self.viewModel.secondButtonConfig.textColor, for: .normal)
        self.secondButton.titleLabel?.font = self.viewModel.secondButtonConfig.font
        self.secondButton.layer.cornerRadius = self.viewModel.secondButtonConfig.cornerRadius
        self.secondButton.layer.borderColor = self.viewModel.secondButtonConfig.borderColor
        self.secondButton.layer.borderWidth = self.viewModel.secondButtonConfig.borderWidth
        self.secondButton.backgroundColor = self.viewModel.secondButtonConfig.backgroundColor
        
        self.buttonsStackView.addArrangedSubview(self.firstButton)
        self.buttonsStackView.addArrangedSubview(self.secondButton)

        self.view.addSubview(self.backgroundImageView)
        self.view.addSubview(self.logoImageView)
        self.view.addSubview(self.buttonsStackView)
    }
    
    private func setupConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        self.logoImageView.widthAnchor.constraint(equalTo: self.logoImageView.heightAnchor, multiplier: 1.0).isActive = true
        self.logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.logoImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16.0).isActive = true
        self.buttonsStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.0).isActive = true
        self.buttonsStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.0).isActive = true
        self.buttonsStackView.spacing = 16.0

        self.firstButton.widthAnchor.constraint(equalTo: self.secondButton.widthAnchor, multiplier: 1.0).isActive = true
        self.firstButton.heightAnchor.constraint(equalToConstant: self.viewModel.firstButtonConfig.height).isActive = true
        self.secondButton.heightAnchor.constraint(equalToConstant: self.viewModel.secondButtonConfig.height).isActive = true
    }
    
    private func setupBindings() {
        self.firstButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.didPressFirstButton()
        }).disposed(by: self.disposeBag)
        self.secondButton.rx.tap.subscribe(onNext: { [weak self] _ in
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
        if state == .success {
            self.dismiss(animated: true, completion: nil)
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    self.buttonsStackView.isHidden = false
                })
            }
        }
    }
}

@available(iOS 9.0, *)
extension TSQBioAuthViewController {
    static public func create(viewModel: TSQBioAuthViewModel) -> UIViewController {
        let viewController = TSQBioAuthViewController()
        viewController.setDependencies(viewModel: viewModel)
        
        return viewController
    }
    
    private func setDependencies(viewModel: TSQBioAuthViewModel) {
        self.viewModel = viewModel
    }
}
