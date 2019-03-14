//
//  TokensPresenter.swift
//  SLPWalletDemo
//
//  Created by Jean-Baptiste Dominguez on 2019/03/06.
//  Copyright © 2019 Bitcoin.com. All rights reserved.
//

import Foundation
import RxSwift
import SLPWallet

struct TokenOutput {
    var id: String
    var name: String
    var ticker: String
    var balance: Double
}

extension TokenOutput: Equatable {
    public static func == (lhs: TokenOutput, rhs: TokenOutput) -> Bool {
        return lhs.id == rhs.id
    }
}

class TokensPresenter {
    
    fileprivate var wallet: SLPWallet
    fileprivate var tokens: [String:SLPToken]?
    
    var fetchTokensInteractor: FetchTokensInteractor?
    var router: TokensRouter?
    weak var viewDelegate: TokensViewController?
    
    let bag = DisposeBag()
    
    init() {
        wallet = WalletManager.shared.wallet
    }
    
    func viewDidLoad() {
        // Fetch token on the viewLoad to setup the view
        fetchTokens()
    }
    
    func fetchTokens() {
        
        WalletManager.shared
            .observeTokens()
            .subscribe({ event in
                if let token = event.element,
                    let tokenTicker = token.tokenTicker {
                    guard let tokenId = token.tokenId
                        , let tokenName = token.tokenName
                        , let tokenTicker = token.tokenTicker else {
                            return
                    }
                    
                    let tokenOutput = TokenOutput(id: tokenId, name: tokenName, ticker: tokenTicker, balance: token.getBalance())
                    self.viewDelegate?.onGetToken(tokenOutput: tokenOutput)
                }
            })
            .disposed(by: bag)
        
        fetchTokensInteractor?.fetchTokens()
            .subscribe(onSuccess: { tokens in
                
                // Store my tokens to take action on it later
                self.tokens = tokens
                
                // Prepare the output for my view
                let tokenOutputs = tokens
                    .flatMap({ (key, value) -> TokenOutput? in
                        guard let tokenId = value.tokenId
                            , let tokenName = value.tokenName
                            , let tokenTicker = value.tokenTicker else {
                                return nil
                        }
                                                
                        return TokenOutput(id: tokenId, name: tokenName, ticker: tokenTicker, balance: value.getBalance())
                    })
                
                // Notify my UI
                self.viewDelegate?.onFetchTokens(tokenOutputs: tokenOutputs)
            }, onError: { error in
                // TODO: Do something
            })
            .disposed(by: bag)
    }
    
    func didPushToken(_ tokenId: String) {
        guard let tokens = self.tokens
            , let token = tokens[tokenId] else {
            return
        }
        
        // If token exists transit to the token module
        router?.transitToToken(token: token)
    }
    
    func didRefreshTokens() {
        fetchTokens()
    }
    
    func didPushReceive() {
        // Transit the receive module
        router?.transitToReceive()
    }
    
    func didPushMnemonic() {
        // Transit the receive module
        router?.transitToMnemonic()
    }
}