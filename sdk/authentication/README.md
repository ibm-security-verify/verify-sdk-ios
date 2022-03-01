# IBM Security Verify Authentication SDK for iOS

The Authentication SDK enables applications to obtain limited access to an HTTP service by orchestrating an approval interaction between the resource owner and the HTTP service.

## Getting started

### Installation

[Swift Package Manager](https://swift.org/package-manager/) is used for automating the distribution of Swift code and is integrated into the `swift` compiler.  To depend on one or more of the components, you need to declare a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(name: "IBM Security Verify", url: "https://github.com/ibm-security-verify/verify-sdk-ios.git", from: "3.0.3")
]
```

then in the `targets` section of the application/library, add one or more components to your `dependencies`, for example:

```swift
// Target for Swift 5.2
.target(name: "MyExampleApp", dependencies: [
    .product(name: "Authentication", package: "IBM Security Verify")
],
```

Alternatively, you can add the package manually.
1. Select your application project in the **Project Navigator** to display the configuration window.
2. Select your application project under the **PROJECT** heading
3. Select the **Swift Packages** tab.
4. Click on the `+` button.
5. Enter `https://github.com/ibm-security-verify/verify-sdk-ios.git` as the respository URL and follow the remaining steps selecting the components to add to your project.

### API documentation
The Authentication SDK API can be reviewed [here](https://ibm-security-verify.github.io/ios/authentication/docs/).

### Importing the SDK

Add the following import statement to the `.swift` files you want to reference the Core SDK.

```swift
import Autentication
```

## Usage

### Basic Resource Owner Password Credentials (ROPC) grant




## License
This package contains code licensed under the MIT License (the "License"). You may view the License in the [LICENSE](https://github.com/ibm-security-verify/verify-sdk-ios/LICENSE) file within this package.
