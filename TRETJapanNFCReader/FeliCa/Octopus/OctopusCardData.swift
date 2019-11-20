//
//  OctopusCardData.swift
//  TRETJapanNFCReader
//
//  Created by treastrain on 2019/09/20.
//  Copyright © 2019 treastrain / Tanaka Ryoga. All rights reserved.
//

import Foundation

/// Octopus Card Data
public struct OctopusCardData: FeliCaCardData {
    public var type: FeliCaCardType = .octopus
    public let primaryIDm: String
    public let primarySystemCode: FeliCaSystemCode
    public var contents: [FeliCaSystemCode : FeliCaSystem] = [:] {
        didSet {
            self.convert()
        }
    }
    
    /// The real balance is (`balance` - Offset) / 10
    /// (e.g.  (4557 - 350) / 10 = HK$420.7 )
    public var balance: Int?
    
    @available(iOS 13.0, *)
    public init(idm: String, systemCode: FeliCaSystemCode) {
        self.primaryIDm = idm
        self.primarySystemCode = systemCode
    }
    
    public mutating func convert() {
        for (systemCode, system) in self.contents {
            switch systemCode {
            case self.primarySystemCode:
                let services = system.services
                for (serviceCode, blockData) in services {
                    switch OctopusCardItemType(serviceCode) {
                    case .balance:
                        self.convertToBalance(blockData)
                    case .none:
                        break
                    }
                }
            default:
                break
            }
        }
    }
    
    private mutating func convertToBalance(_ blockData: [Data]) {
        let data = blockData.first!
        var balance = 0
        balance += Int(UInt32(data[0]) << 24)
        balance += Int(UInt32(data[1]) << 16)
        balance += Int(UInt32(data[2]) << 8)
        balance += Int(data[3])
        self.balance = balance
    }
    
    
    @available(*, unavailable, renamed: "primaryIDm")
    public var idm: String { return "" }
    @available(*, unavailable, renamed: "primarySystemCode")
    public var systemCode: FeliCaSystemCode { return 0xFFFF }
    @available(*, unavailable)
    public var data: [FeliCaServiceCode : [Data]] { return [:] }
}
