//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import Foundation
import DC

/// Controls the save and retrieval of Wallet
struct DataManager {
    /// The  file system location of the `wallet.json` file.
    private let fileURL = URL.documentsDirectory
        .appendingPathComponent("wallet")
        .appendingPathExtension("json")
    
    /// Load the wallet from the file system.
    func load() -> Wallet? {
        guard let data = try? Data(contentsOf: fileURL) else {
            print("Unable to resolve data from \(fileURL)")
            return nil
        }
        
        guard let wallet = try? JSONDecoder().decode(Wallet.self, from: data) else {
            print("Unable to deserialize data from \(fileURL)")
            return nil
        }
        
        print("Wallet loaded\n - Credentials: \(wallet.credentials.count)")
        return wallet
    }
    
    /// Checks to see if the file exist
    /// - Returns `true` is the file is present, otherwise `false`.
    func exists() -> Bool {
        do {
            return try fileURL.checkResourceIsReachable()
        }
        catch let error {
            print("Unable to determine resource at \(fileURL)\n\(error.localizedDescription)")
            return false
        }
    }
    
    /// Saves the wallet to the file system.
    /// - Parameters
    ///   - wallet: An instance of the `Wallet`.
    func save(_ wallet: Wallet?) {
        do {
            let data = try JSONEncoder().encode(wallet)
            try data.write(to: fileURL)
            
            print("Wallet saved\n - Credentials: \(wallet!.credentials.count)")
        }
        catch let error {
            print("Error occured in save. \(error.localizedDescription)")
        }
    }
    
    /// Removes the saved wallet file from the file system.
    func reset() {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Reset wallet")
        }
        catch let error {
            print("Error occured in reset. \(error.localizedDescription)")
        }
    }
}

