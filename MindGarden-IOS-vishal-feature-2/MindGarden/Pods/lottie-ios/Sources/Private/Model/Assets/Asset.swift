//
//  Asset.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 1/9/19.
//

import Foundation

public class Asset: Codable, DictionaryInitializable {
    // MARK: Lifecycle

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Asset.CodingKeys.self)
        if let id = try? container.decode(String.self, forKey: .id) {
            self.id = id
        } else {
            id = try String(container.decode(Int.self, forKey: .id))
        }
    }

    required init(dictionary: [String: Any]) throws {
        if let id = dictionary[CodingKeys.id.rawValue] as? String {
            self.id = id
        } else if let id = dictionary[CodingKeys.id.rawValue] as? Int {
            self.id = String(id)
        } else {
            throw InitializableError.invalidInput
        }
    }

    // MARK: Public

    /// The ID of the asset
    public let id: String

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case id
    }
}
