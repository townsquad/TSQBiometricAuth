# TSQBiometricAuth

[![Version](https://img.shields.io/cocoapods/v/TSQBiometricAuth.svg?style=flat)](https://cocoapods.org/pods/TSQBiometricAuth)
[![License](https://img.shields.io/cocoapods/l/TSQBiometricAuth.svg?style=flat)](https://cocoapods.org/pods/TSQBiometricAuth)
[![Platform](https://img.shields.io/cocoapods/p/TSQBiometricAuth.svg?style=flat)](https://cocoapods.org/pods/TSQBiometricAuth)

![open-cancel](https://github.com/townsquad/TSQBiometricAuth/blob/master/readmeImages/open-cancel.gif)
![open-error-success](https://github.com/townsquad/TSQBiometricAuth/blob/master/readmeImages/open-error-success.gif)

## Description

TSBiometricAuth is a library to make biometric authentication simple. It embeds Apple's [LocalAuthentication](https://developer.apple.com/documentation/localauthentication/) framework and notifies authentication result via a Delegate.

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

- Import the library into your project:

    ```import TSQBiometricAuth```

- Instantiate the **TSQBioAuthViewController**, like so:

    ```let vc = TSQBioAuth.instantiateTSQBioAuthViewController(...)```

- Customize it and choose how you want to "listen" to the authentication state changes.

## Customization

Customize the UI and behaviour of TSQBioAuthViewController through its init parameters, below is a list of them:

| Param name | Type | Description |
| ------ | ------ | ------ |
| displayMessage | String | Message shown to the users while asking for their touchID/faceID. |
| leftButtonConfiguration | TSQButtonConfiguration | Defines the left button configuration. |
| rightButtonConfiguration | TSQButtonConfiguration | Defines the right button configuration. |
| dismissWhenAuthenticationSucceeds | Bool | Defines whether TSQBioAuthViewController should be automatically dismissed when the authentication succeeds. <br> **Default: true** |
| dismissWhenUserCancels | Bool | Defines whether TSQBioAuthViewController should be automatically dismissed when the users choose to cancel the authentication proccess (by tapping on the left button). <br> **Default: true** |
| logoImage | UIImage | Image presented at the center of the screen |
| logoImageConfiguration | TSQImageConfiguration | Defines the logoImage configuration. |
| backgroundImage | UIImage | Background image at ViewController. <br> **Default: nil** |
| backgroundImageConfiguration | TSQImageConfiguration | Defines the backgroundImage configuration. <br> **Default: nil** |
| backgroundColor | UIColor | The ViewController's background color. <br> **Default: nil** |

## Listening to autentication state changes

There are 2 ways to do so, through the delegate or Rx subscription.

**WARNING** Due to Apple's [LAErrors](https://developer.apple.com/documentation/localauthentication/laerror/code) classification, when the user chooses to cancel the authentication it will return an error with code **LAError.Code.userCancel**. However, **TSQBioAuthViewController** doesn't dismiss itself when this occurs, since the apps that have biometric authentication do not dismiss the View Controller responsible for the authentication flow when this happens.
***IF*** you choose to handle the errors by yourself, beware of this specific scenario.

### Delegate

After instantiating **TSQBioAuthViewController**, set its delegate and make sure the current ViewController conforms to *TSQBioAuthenticationDelegate*. Like so:
```
class CurrentViewController: UIViewController {
    ...
    private func setupBiometricAuthentication() {
        let bioAuthVC = TSQBioAuth.instantiateTSQBioAuthViewController(...)
        bioAuthVC.delegate = self
        ...
    }
}

extension CurrentViewController: TSQBioAuthenticationDelegate {
    func authenticationFailed(withErrorCode errorCode: Int) {
        switch errorCode {
        case LAError.Code.userCancel.rawValue:
            print("User cancelled")
        default:
            print("Authentication Failed with error: \(errorCode)")
        }
    }
    
    func authenticationSucceeded() {
        print("Authentication Succeeded")
    }
    
    func authenticationDisabledByUserChoice() {
        print("Authentication Disabled by User Choice")
    }
}
```

### Rx Subscription

After instantiating **TSQBioAuthViewController**, subscribe to *authenticationState* and ***react*** to changes in the state:
```
class CurrentViewController: UIViewController {
    ...
    private let disposeBag = DisposeBag()
    private func setupBiometricAuthentication() {
        let bioAuthVC = TSQBioAuth.instantiateTSQBioAuthViewController(...)
        bioAuthVC.authenticationState.subscribe(onNext: { (state) in
            switch state {
            case .success:
                print("Authentication Succeeded")
            case .error(code: let errorCode):
                switch errorCode {
                case LAError.Code.userCancel.rawValue:
                    print("User cancelled")
                default:
                    print("Authentication Failed with error: \(errorCode)")
                }
            case .disabledByUserChoice:
                print("Authentication Disabled by User Choice")
            }
        }).disposed(by: self.disposeBag)
        ...
    }
}
```

### Error Handling

Since **TSQBioAuthViewController** already handles the errors involved in authentication, there is no obligation to implement ```authenticationFailed(withErrorCode errorCode: Int)``` (delegate) or include the ```case .error(code: let errorCode):``` (Rx subscription).

If you want to handle the errors by yourself, please refer to [LAErrors](https://developer.apple.com/documentation/localauthentication/laerror/code).

## Authors

Kévin Cardoso de Sá, kevin@townsq.com.br

## License

TSQBiometricAuth is available under the MIT license. See the LICENSE file for more info.
