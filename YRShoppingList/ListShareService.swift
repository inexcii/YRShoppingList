//
//  ListShareService.swift
//  YRShoppingList
//
//  Created by Yuan Zhou on 2020/05/05.
//  Copyright © 2020 ZhouyuanWork, Inc. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ListShareServiceDelegate: class {

    func didConnectWithPeerDeviceToSend(names: [String])
    func didConnectWithPeerDevice(names: [String])
    func didReceiveData(_ data: Data)
}

class ListShareService: NSObject {

    private let ListServiceType = "inexcii-list"

    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser

    weak var delegate: ListShareServiceDelegate?

    var isSender: Bool = false
    var isReceiver: Bool = false

    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()

    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ListServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ListServiceType)

        super.init()

        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self

        self.serviceAdvertiser.startAdvertisingPeer()
    }
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    func searchForPeer() {
        self.serviceBrowser.startBrowsingForPeers()
    }

    func send(list data: Data) {
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
}

extension ListShareService: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
        isReceiver = true
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
}

extension ListShareService: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        NSLog("%@", "did invite peer: \(peerID)")
        isSender = true
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
}

extension ListShareService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")

        switch state {
        case .connected:
            print("connected")
            if isSender {
                self.delegate?.didConnectWithPeerDeviceToSend(names: session.connectedPeers.map{ $0.displayName })
            } else {
                self.delegate?.didConnectWithPeerDevice(names: session.connectedPeers.map{ $0.displayName })
            }
        case . connecting:
            print("connecting with \(peerID)")
        case .notConnected:
            print("not connecting with \(peerID)")
        @unknown default:
            print("unknown default")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        self.delegate?.didReceiveData(data)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
}
