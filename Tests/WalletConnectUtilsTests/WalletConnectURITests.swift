import XCTest
@testable import WalletConnectUtils

private func stubURI(includeMethods: Bool = true) -> (uri: WalletConnectURI, string: String) {
    let topic = Data.randomBytes(count: 32).toHexString()
    let symKey = Data.randomBytes(count: 32).toHexString()
    let protocolName = "irn"
    var uriString = "wc:\(topic)@2?symKey=\(symKey)&relay-protocol=\(protocolName)"
    let methods = ["wc_sessionPropose", "wc_sessionAuthenticated"]
    if includeMethods {
        let methodsString = methods.joined(separator: ",")
        uriString.append("&methods=\(methodsString)")
    }
    let uri = WalletConnectURI(
        topic: topic,
        symKey: symKey,
        relay: RelayProtocolOptions(protocol: protocolName, data: nil),
        methods: includeMethods ? methods : nil)
    return (uri, uriString)
}

final class WalletConnectURITests: XCTestCase {

    // MARK: - Init URI with string

    func testInitURIToString() {
        let input = stubURI()
        let uriString = input.uri.absoluteString
        let outputURI = WalletConnectURI(string: uriString)
        XCTAssertEqual(input.uri, outputURI)
        XCTAssertEqual(input.string, outputURI?.absoluteString)
    }

    func testInitStringToURI() {
        let inputURIString = stubURI().string
        let uri = WalletConnectURI(string: inputURIString)
        let outputURIString = uri?.absoluteString
        XCTAssertEqual(inputURIString, outputURIString)
    }

    func testInitStringToURIAlternate() {
        let expectedString = stubURI().string
        let inputURIString = expectedString.replacingOccurrences(of: "wc:", with: "wc://")
        let uri = WalletConnectURI(string: inputURIString)
        let outputURIString = uri?.absoluteString
        XCTAssertEqual(expectedString, outputURIString)
    }

    // MARK: - Init URI failure cases

    func testInitFailsBadScheme() {
        let inputURIString = stubURI().string.replacingOccurrences(of: "wc:", with: "")
        let uri = WalletConnectURI(string: inputURIString)
        XCTAssertNil(uri)
    }

    func testInitFailsMalformedURL() {
        let inputURIString = "wc://<"
        let uri = WalletConnectURI(string: inputURIString)
        XCTAssertNil(uri)
    }

    func testInitFailsNoSymKeyParam() {
        let input = stubURI()
        let inputURIString = input.string.replacingOccurrences(of: "symKey=\(input.uri.symKey)", with: "")
        let uri = WalletConnectURI(string: inputURIString)
        XCTAssertNil(uri)
    }

    func testInitFailsNoRelayParam() {
        let input = stubURI()
        let inputURIString = input.string.replacingOccurrences(of: "&relay-protocol=\(input.uri.relay.protocol)", with: "")
        let uri = WalletConnectURI(string: inputURIString)
        XCTAssertNil(uri)
    }

    func testInitURIWithStringIncludingMethods() {
        let (expectedURI, uriStringWithMethods) = stubURI()
        guard let uri = WalletConnectURI(string: uriStringWithMethods) else {
            XCTFail("Initialization of URI failed")
            return
        }
        XCTAssertEqual(uri.methods, expectedURI.methods)
        XCTAssertEqual(uri.topic, expectedURI.topic)
        XCTAssertEqual(uri.symKey, expectedURI.symKey)
        XCTAssertEqual(uri.relay.protocol, expectedURI.relay.protocol)
        XCTAssertEqual(uri.absoluteString, expectedURI.absoluteString)
    }

    func testInitURIWithStringExcludingMethods() {
        let (expectedURI, uriStringWithoutMethods) = stubURI(includeMethods: false)
        guard let uri = WalletConnectURI(string: uriStringWithoutMethods) else {
            XCTFail("Initialization of URI failed")
            return
        }

        XCTAssertNil(uri.methods)
        XCTAssertEqual(uri.topic, expectedURI.topic)
        XCTAssertEqual(uri.symKey, expectedURI.symKey)
        XCTAssertEqual(uri.relay.protocol, expectedURI.relay.protocol)
        XCTAssertEqual(uri.absoluteString, expectedURI.absoluteString)
    }
}
