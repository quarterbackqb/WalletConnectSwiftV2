import Foundation

// PublicKeyFetcher class
class PublicKeyFetcher {
    struct VerifyServerPublicKey: Codable {
        let publicKey: String
        let expiresAt: TimeInterval
    }

    private let urlString = "https://verify.walletconnect.org/v2/public-key"

    func fetchPublicKey() async throws -> VerifyServerPublicKey {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let publicKeyResponse = try JSONDecoder().decode(VerifyServerPublicKey.self, from: data)
        return publicKeyResponse
    }
}

#if DEBUG
class MockPublicKeyFetcher: PublicKeyFetcher {
    var publicKey: VerifyServerPublicKey?
    var error: Error?

    override func fetchPublicKey() async throws -> VerifyServerPublicKey {
        if let error = error {
            throw error
        }
        return publicKey!
    }
}
#endif
