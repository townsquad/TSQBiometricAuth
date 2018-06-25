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
            viewModel.delegate = self
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
        self.firstButton.layer.cornerRadius = 5.0
        self.firstButton.layer.borderColor = UIColor.white.cgColor
        self.firstButton.layer.borderWidth = 1.0
        self.firstButton.backgroundColor = UIColor.purple
        
        self.secondButton = UIButton(frame: CGRect.zero)
        self.secondButton.layer.cornerRadius = 5.0
        self.secondButton.layer.borderColor = UIColor.white.cgColor
        self.secondButton.layer.borderWidth = 1.0
        self.secondButton.backgroundColor = UIColor.orange
        
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
        self.buttonsStackView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        self.buttonsStackView.spacing = 16.0

        self.firstButton.widthAnchor.constraint(equalTo: self.secondButton.widthAnchor, multiplier: 1.0).isActive = true
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
        self.viewModel.cancelBiometricAuthentication()
    }
    
    private func didPressSecondButton() {
        self.viewModel.performBiometricAuthentication()
    }
    
    // Alert
    
    private func showAlert(withTitle title: String, withMessage message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            self.buttonsStackView.isHidden = false
        }
        alertVC.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
}

@available(iOS 9.0, *)
extension TSQBioAuthViewController: TSQBioAuthenticationDelegate {
    public func authenticationFinishedWithState(state: TSQBioAuthState) {
        switch state {
        case .success:
            self.dismiss(animated: true, completion: nil)
        case .cancelled:
            self.showAlert(withTitle: "Cancelled", withMessage: "cancelled")
        case .notSet:
            self.showAlert(withTitle: "Not Set", withMessage: "not set")
        case .passcode:
            self.showAlert(withTitle: "Passcode", withMessage: "passcode")
        case .retry:
            self.showAlert(withTitle: "Retry", withMessage: "retry")
        case .unavailable:
            self.showAlert(withTitle: "Unavailable", withMessage: "unavailable")
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
