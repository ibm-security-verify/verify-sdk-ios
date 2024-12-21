//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import UIKit
import Core

/// Invitations represent a way for one agent to exchange its endpoint information with another agent.
public struct InvitationInfo: Identifiable {
    /// A unique identifier for this invitation.
    public let id: String
    
    /// The invitation URL.
    public let url: URL
    
    /// Shortened version of the invitation URL.
    public let shortURL: URL?
    
    /// A key created by the recipient
    public let recipientKey: String

    /// Timestamps associated with states of the invitation
    public var timestamps: (created: Date, updated: Date?)?
    
    /// Additional properties associated with the invitation.
    public let properties: [String: AnyCodable]
}

extension InvitationInfo: Codable {
    // MARK: Enums

    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case id
        case url
        case shortURL = "short_url"
        case recipientKey = "recipient_key"
        case timestamps
        case properties
    }
    
    private enum TimestampCodingKeys: Int, CodingKey {
        case created
        case updated
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.url = try container.decode(URL.self, forKey: .url)
        self.shortURL = try container.decodeIfPresent(URL.self, forKey: .shortURL)
        self.recipientKey = try container.decode(String.self, forKey: .recipientKey)
        
        // Timestamp structure
        if container.contains(.timestamps) {
            let timestampContainer = try container.nestedContainer(keyedBy: TimestampCodingKeys.self, forKey: .timestamps)
            
            // Convert the value from seconds to a Date.
            let created = try timestampContainer.decode(Int.self, forKey: .created)
            let createDate = Date(timeIntervalSince1970: TimeInterval(created))
            
            var updatedDate: Date? = nil
            if let updated = try timestampContainer.decodeIfPresent(Int.self, forKey: .updated) {
                updatedDate = Date(timeIntervalSince1970: TimeInterval(updated))
            }
            
            self.timestamps = (created: createDate, updated: updatedDate)
        }
            
        // Additional properties
        self.properties = try container.decodeIfPresent([String: AnyCodable].self, forKey: .properties) ?? [:]
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(shortURL, forKey: .shortURL)
        try container.encode(recipientKey, forKey: .recipientKey)
        
        // Additional properties
        try container.encode(properties, forKey: .properties)
        
        // Timestamp structure
        if let timestamps = self.timestamps {
            var timestampContainer = container.nestedContainer(keyedBy: TimestampCodingKeys.self, forKey: .timestamps)
            
            try timestampContainer.encode((timestamps.created.timeIntervalSince1970), forKey: .created)
            if let updated = self.timestamps?.updated {
                try timestampContainer.encode(updated.timeIntervalSince1970, forKey: .updated)
            }
        }
    }
}
