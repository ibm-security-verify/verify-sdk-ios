# IBM Security Verify SDK for iOS 

[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/5625/badge)](https://bestpractices.coreinfrastructure.org/projects/5625)

This repository is for active development of the IBM Security Verify SDK ("Software Development Kit") for iOS.

## Getting started

For your convenience, each component is separate for you to choose from instead of one large IBM Security Verify SDK package.  To get started with a specific component, see the **README.md** file located in each component's project folder.

### Prerequisites

- The components are written for Swift 5 which requires Xcode 10.2 or higher
- To use the multi-factor component a valid IBM Security Verify tenant or IBM Security Verify Access is required.

### Components

Releases of all packages are available here: [Releases](https://github.com/ibm-security-verify/verify-sdk-ios/releases)

The following components are currently offered in the package.
| Component | Description |
| ----------- | ----------- |
| [FIDO2](Sources/fido2) | The FIDO2™ component is a native implementation of attestation and assertion ceremonies.  Essentially providing the equivalent of WebAuthn's `navigator.credentials.create()` and `navigator.credentials.get()` for native mobile apps.|
| [Adaptive](Sources/adaptive) | The IBM Security Verify Adaptive SDK provides device assessment. Based on cloud risk policies, authentication and authorization challenges can be evaluated.|
| [Core](Sources/core) | The IBM Security Verify Core SDK provides common Keychain and networking functionality across the other components in the IBM Security Verify SDK offering.|
| [Authentication](Sources/authentication) | The IBM Security Verify Authentication SDK is an implementation of OAuth 2.0 and OIDC targeting mobile use cases.|
| [MFA](Sources/mfa) | The IBM Security Verify MFA SDK provides multi-factor authentication support for creating authenticators and processing transactions.|


### Installation

[Swift Package Manager](https://swift.org/package-manager/) is used for automating the distribution of Swift code and is integrated into the `swift` compiler.  To depend on one or more of the components, you need to declare a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(name: "IBM Security Verify", url: "https://github.com/ibm-security-verify/verify-sdk-ios.git", from: "3.0.8")
]
```

then in the `targets` section of the application/library, add one or more components to your `dependencies`. For example:

```switft
// Target for Swift 5.7
.target(name: "MyExampleApp", dependencies: [
    .product(name: "FIDO2", package: "IBM Security Verify")
],
```

Alternatively, you can add the package manually.
1. Select your application project in the **Project Navigator** to display the configuration window.
2. Select your application project under the **PROJECT** heading
3. Select the **Swift Packages** tab.
4. Click on the `+` button.
5. Enter `https://github.com/ibm-security-verify/verify-sdk-ios.git` as the respository URL and follow the remaining steps for selecting the components to add to your project.
