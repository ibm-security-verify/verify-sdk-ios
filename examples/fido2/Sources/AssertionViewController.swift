//
// Copyright contributors to the IBM Security Verify FIDO2 Sample App for iOS project
//

import Foundation
import UIKit
import FIDO2
import CryptoKit

class AssertionViewController: UIViewController {
    // MARK: Control variables
    @IBOutlet weak var buttonAuthenticate: UIButton!
    @IBOutlet weak var buttonRemove: UIButton!
    @IBOutlet weak var labelDisplayName: UILabel!
    @IBOutlet weak var labelHostName: UILabel!
    @IBOutlet weak var labelNickName: UILabel!
    @IBOutlet weak var labelCreatedDate: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var switchEauthExt: UISwitch!
    
    // Random messages for the user to acknowledge before signing the assertion.
    let reasons = ["Please confirm your pizza order of $49.99",
                   "Please verify that you intended to transfer $2,877.34.",
                   "Please confirm you purchased a new Apple MacBook.",
                   "Are you trying to access to the server room?",
                   "Your confirmation of to access the registration resource on this server is required.",
                   "Please confirm your order of 10 widgets."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        // Populate the stored values.
        if let value = UserDefaults.standard.string(forKey: Store.relyingPartyUrl.rawValue), let url = URL(string: value), let hostname = url.host {
            labelHostName.text = hostname
        }
        
        if let value = UserDefaults.standard.string(forKey: Store.nickname.rawValue) {
            labelNickName.text = value
        }
        
        if let value = UserDefaults.standard.string(forKey: Store.displayName.rawValue) {
            labelDisplayName.text = value
        }
        
        if let value = UserDefaults.standard.string(forKey: Store.createdDate.rawValue) {
            labelCreatedDate.text = value
        }
        
        // Animate the registration logo
        setTraitAppearance()
        animateLogo()
        
        buttonAuthenticate.setCornerRadius()
    }
    
    /// Called when the iOS interface environment changes.
    /// - parameter previousTraitCollection: The `UITraitCollection` object before the interface environment changed.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setTraitAppearance()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? AssertionInfoViewController, let assertion = sender as? PublicKeyCredential<AuthenticatorAssertionResponse> {
            viewController.assertion = assertion
            viewController.isModalInPresentation = true
        }
    }
    
    @IBAction func unwindToAssertionView(sender: UIStoryboardSegue) {
        if let viewController = sender.source as? AssertionInfoViewController {
            imageView.tintColor = viewController.success ? UIColor.systemGreen : UIColor.systemRed
            
            animateLogo {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                    self.setTraitAppearance()
                }
            }
        }
    }
    
    // MARK: Functions
    
    private func animateLogo(completion: (() -> Void)? = nil) {
        // Animate the registration logo
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 1.50
        animation.autoreverses = true
        animation.repeatCount = 1
        animation.initialVelocity = 0.3
        animation.damping = 0.8
        imageView.layer.add(animation, forKey: nil)
        
        completion?()
    }
    
    // Set the appearence based on the device trait appearance
    private func setTraitAppearance() {
        if traitCollection.userInterfaceStyle == .light {
            imageView.tintColor = UIColor.black
        }
        else {
            imageView.tintColor = UIColor.white
        }
    }
    
    // MARK: Control events
    @IBAction func onAuthenticateClick(_ sender: UIButton) {
        guard let accessToken = UserDefaults.standard.string(forKey: Store.accessToken.rawValue), let relyingPartyUrl =  UserDefaults.standard.string(forKey: Store.relyingPartyUrl.rawValue) else {
            let alertController = UIAlertController(title: "FIDO2 Example", message: "Information about the relying party is missing.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alertController, animated: true)
            return
        }
        
        self.buttonAuthenticate.setActivity(true)
        let assertionUrl = "\(relyingPartyUrl)/assertion/options"
        
        var params:[String: Any] = ["userVerification": "required"]
        if UserDefaults.standard.string(forKey: Store.server.rawValue) == isva, let username = UserDefaults.standard.string(forKey: Store.username.rawValue) {
            params.updateValue(username, forKey: "username")
            
            if switchEauthExt.isOn {
                params.updateValue(["credProps": true, "txAuthSimple": reasons.randomElement()!], forKey: "extensions")
            }
        }
       
        // Fetch the attestation options from the relying party.
        FidoService.shared.fetchAssertionOptions(assertionUrl, accessToken: accessToken, params: params) { result in
            switch result {
            case .success(let value):
                let provider = PublicKeyCredentialProvider()
                provider.delegate = self
                provider.createCredentialAssertionRequest(options: value)
            case .failure(let error):
                let alertController = UIAlertController(title: "FIDO2 Example", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                DispatchQueue.main.async {
                    self.buttonAuthenticate.setActivity(false)
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    
    @IBAction func onRemoveClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "FIDO2 Example", message: "Remove FIDO2 authenticator? If you proceed, you will need to remove the authenticator from the relying party.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            
            // Set the parent view controller for the scene.
            let storybaord = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storybaord.instantiateViewController(withIdentifier: "registrationLanding")
            UIApplication.shared.windows.first?.rootViewController = viewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

extension AssertionViewController: PublicKeyCredentialDelegate {
    func publicKeyCredential(provider: PublicKeyCredentialProvider, didCompleteWithError error: Error) {
        let alertController = UIAlertController(title: "FIDO2 Example", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        DispatchQueue.main.async {
            self.buttonAuthenticate.setActivity(false)
            self.present(alertController, animated: true)
        }
    }
    
    func publicKeyCredential(provider: PublicKeyCredentialProvider, didCompleteWithAssertion result: PublicKeyCredential<AuthenticatorAssertionResponse>) {
        // Transition to info view controller
        DispatchQueue.main.async {
            self.buttonAuthenticate.setActivity(false)
        }
        self.performSegue(withIdentifier: "ShowAssertionOptionsInfo", sender: result)
    }
}
