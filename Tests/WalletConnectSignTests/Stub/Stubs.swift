@testable import WalletConnectSign
import Foundation
import JSONRPC
import WalletConnectKMS
import WalletConnectUtils
import TestingUtils
import WalletConnectPairing

extension Pairing {
    static func stub(expiryDate: Date = Date(timeIntervalSinceNow: 10000), topic: String = String.generateTopic()) -> Pairing {
        Pairing(topic: topic, peer: nil, expiryDate: expiryDate)
    }
}

extension WCPairing {
    static func stub(expiryDate: Date = Date(timeIntervalSinceNow: 10000), isActive: Bool = true, topic: String = String.generateTopic()) -> WCPairing {
        WCPairing(topic: topic, relay: RelayProtocolOptions.stub(), peerMetadata: AppMetadata.stub(), isActive: isActive, expiryDate: expiryDate)
    }
}

extension ProposalNamespace {
    static func stubDictionary() -> [String: ProposalNamespace] {
        return [
            "eip155": ProposalNamespace(
                chains: [Blockchain("eip155:1")!],
                methods: ["method"],
                events: ["event"],
                extensions: nil)
        ]
    }
}

extension SessionNamespace {
    static func stubDictionary() -> [String: SessionNamespace] {
        return [
            "eip155": SessionNamespace(
                accounts: [Account("eip155:1:0xab16a96d359ec26a11e2c2b3d8f8b8942d5bfcdb")!],
                methods: ["method"],
                events: ["event"],
                extensions: nil)
        ]
    }
}

extension RelayProtocolOptions {
    static func stub() -> RelayProtocolOptions {
        RelayProtocolOptions(protocol: "", data: nil)
    }
}

extension Participant {
    static func stub(publicKey: String = AgreementPrivateKey().publicKey.hexRepresentation) -> Participant {
        Participant(publicKey: publicKey, metadata: AppMetadata.stub())
    }
}

extension AgreementPeer {
    static func stub(publicKey: String = AgreementPrivateKey().publicKey.hexRepresentation) -> AgreementPeer {
        AgreementPeer(publicKey: publicKey)
    }
}

extension RPCRequest {

    static func stubUpdateNamespaces(namespaces: [String: SessionNamespace] = SessionNamespace.stubDictionary()) -> RPCRequest {
        return RPCRequest(method: SignProtocolMethod.sessionUpdate.method, params: SessionType.UpdateParams(namespaces: namespaces))
    }

    static func stubUpdateExpiry(expiry: Int64) -> RPCRequest {
        return RPCRequest(method: SignProtocolMethod.sessionExtend.method, params: SessionType.UpdateExpiryParams(expiry: expiry))
    }

    static func stubSettle() -> RPCRequest {
        return RPCRequest(method: SignProtocolMethod.sessionSettle.method, params: SessionType.SettleParams.stub())
    }

    static func stubRequest(method: String, chainId: Blockchain) -> RPCRequest {
        let params = SessionType.RequestParams(
            request: SessionType.RequestParams.Request(method: method, params: AnyCodable(EmptyCodable())),
            chainId: chainId)
        return RPCRequest(method: SignProtocolMethod.sessionRequest.method, params: params)
    }
}

extension SessionProposal {
    static func stub(proposerPubKey: String = "") -> SessionProposal {
        let relayOptions = RelayProtocolOptions(protocol: "irn", data: nil)
        return SessionType.ProposeParams(
            relays: [relayOptions],
            proposer: Participant(publicKey: proposerPubKey, metadata: AppMetadata.stub()),
            requiredNamespaces: ProposalNamespace.stubDictionary())
    }
}

extension RPCResponse {
    static func stubError(forRequest request: RPCRequest) -> RPCResponse {
        return RPCResponse(matchingRequest: request, result: RPCResult.error(JSONRPCError(code: 0, message: "")))
    }
}
