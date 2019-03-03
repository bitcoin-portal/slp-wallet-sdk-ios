//
//  SLPToken.swift
//  SLPWallet
//
//  Created by Jean-Baptiste Dominguez on 2019/03/02.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import RxSwift

public class SLPToken {
    public var tokenId: String?
    public var tokenTicker: String?
    public var tokenName: String?
    public var utxos = [SLPTokenUTXO]() {
        willSet {
            // If decimal == 0, replace per the rawTokenQty
            newValue.forEach { $0._tokenQty = (decimal > 0 ? (Double($0._rawTokenQty) / pow(Double(10), Double(decimal))) : Double($0._rawTokenQty)) }
        }
    }
    public var decimal: Int = 0 {
        willSet {
            // If decimal == 0, replace per the rawTokenQty
            utxos.forEach { $0._tokenQty = (newValue > 0 ? (Double($0._rawTokenQty) / pow(Double(10), Double(newValue))) : Double($0.rawTokenQty)) }
        }
    }
    
    public init() {
    }
    
    public init(_ tokenId: String) {
        self.tokenId = tokenId
    }
    
    func addUTXO(_ utxo: SLPTokenUTXO) {
        utxo._tokenQty = decimal > 0 ? (Double(utxo._rawTokenQty) / pow(Double(10), Double(decimal))) : Double(utxo._rawTokenQty)
        utxos.append(utxo)
    }
    
    func addUTXOs(_ utxos: [SLPTokenUTXO]) {
        utxos.forEach({ self.addUTXO($0) })
    }
    
    public func getGas() -> Int {
        return utxos.reduce(0, { $0 + $1.satoshis })
    }
    
    public func getBalance() -> Double {
        return utxos.reduce(0, { $0 + ($1.tokenQty ?? 0) })
    }
}
