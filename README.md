# TSQBiometricAuth

[![CI Status](https://img.shields.io/travis/Kévin Cardoso de Sá/TSQBiometricAuth.svg?style=flat)](https://travis-ci.org/Kévin Cardoso de Sá/TSQBiometricAuth)
[![Version](https://img.shields.io/cocoapods/v/TSQBiometricAuth.svg?style=flat)](https://cocoapods.org/pods/TSQBiometricAuth)
[![License](https://img.shields.io/cocoapods/l/TSQBiometricAuth.svg?style=flat)](https://cocoapods.org/pods/TSQBiometricAuth)
[![Platform](https://img.shields.io/cocoapods/p/TSQBiometricAuth.svg?style=flat)](https://cocoapods.org/pods/TSQBiometricAuth)

## Description

TSBiometricAuth is a library to make biometric authentication simple. It embeds Appple's [LocalAuthentication] framework(https://developer.apple.com/documentation/localauthentication/) and notifies authentication result via a Delegate.

## Requirements

iOS 9.0

Swift 4.1

RxSwift 4.2

## Installation

TSQBiometricAuth is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TSQBiometricAuth'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. Open **ExampleViewController** to see the full code needed to implement biometric authentication.

## Usage

Import the library into your project:

```import TSQBiometricAuth```

Instantiate the TSQBioAuthViewController responsible for handling the authentication, customizing it with its initialization parameters:

```let vc = TSQBioAuth.instantiateTSQBioAuthViewController(...)```

**IMPORTANT**!!! Since this ViewController is presented modally, you **MUST** set the ```vc.delegate = self``` and make sure the current ViewController conforms to **TSQBioAuthenticationDelegate**. Like so:

```
extension CurrentViewController: TSQBioAuthenticationDelegate {
    func authenticationSucceeded() {
        // User authenticated successfully
        // Do something!
    }
    
    func authenticationDisabledByUserChoice() {
        // User disabled biometric authentication (Pressed on leftButton)
        // You should direct him to the default authentication (login/password)
    }
}
```


## Customization



## Author

Kévin Cardoso de Sá, kevin@townsq.com.br

## License

TSQBiometricAuth is available under the MIT license. See the LICENSE file for more info.
