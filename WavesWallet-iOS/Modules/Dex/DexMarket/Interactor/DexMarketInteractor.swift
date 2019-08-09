import Foundation
import RxSwift
import DomainLayer

private enum Constants {
    static let maxGeneralAssets = 4
}

final class DexMarketInteractor: DexMarketInteractorProtocol {
    
    private static var allPairs: [DomainLayer.DTO.Dex.SmartPair] = []
    private static var spamURL = ""

    private let searchPairsSubject: PublishSubject<[DomainLayer.DTO.Dex.SmartPair]> = PublishSubject<[DomainLayer.DTO.Dex.SmartPair]>()
    private let disposeBag: DisposeBag = DisposeBag()

    private let dexRealmRepository: DexRealmRepositoryProtocol = UseCasesFactory.instance.repositories.dexRealmRepository
    private let auth = UseCasesFactory.instance.authorization
    
    private let environment = UseCasesFactory.instance.repositories.environmentRepository
    private let orderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository

    private let dexRepository = UseCasesFactory.instance.repositories.dexPairsPriceRepository
    private let assetsInteractor = UseCasesFactory.instance.assets
    
    
    func pairs() -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
            
            guard let self = self else { return Observable.empty() }
            
            return self.environment.walletEnvironment().flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                
                guard let self = self else { return Observable.empty() }
                return self.pairs(wallet: wallet, environment: environment)
            })
        })
    }
    
    func searchPairs() -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        return searchPairsSubject.asObserver()
    }
    
    func checkMark(pair: DomainLayer.DTO.Dex.SmartPair) {
        
        if let index = DexMarketInteractor.allPairs.index(where: {$0.id == pair.id}) {
           
            DexMarketInteractor.allPairs[index] = pair.mutate {

                let needSaveAssetPair = !$0.isChecked
                let pair = $0
                
                $0.isChecked = !$0.isChecked
                
                auth.authorizedWallet().flatMap { [weak self] wallet -> Observable<Bool> in
                        
                    guard let self = self else { return Observable.never() }

                    if needSaveAssetPair {
                        return self.dexRealmRepository.save(pair: pair, accountAddress: wallet.address)
                    }
                    return self.dexRealmRepository.delete(by: pair.id, accountAddress: wallet.address)
                    
                }.subscribe().disposed(by: disposeBag)
            }
        }
    }
    
    func searchPair(searchText: String) {
        
        if searchText.count > 0 {
            
            let searchPairs = DexMarketInteractor.allPairs.filter {
                searchPair(amountName: $0.amountAsset.name,
                           priceName: $0.priceAsset.name,
                           amountShortName: $0.amountAsset.shortName,
                           priceShortName: $0.priceAsset.shortName,
                           searchText: searchText)
            }
            
            searchPairsSubject.onNext(searchPairs)
        }
        else {
            searchPairsSubject.onNext(DexMarketInteractor.allPairs)
        }
    }
    
}

//MARK: - Search

private extension DexMarketInteractor {
    
    func searchPair(amountName: String, priceName: String, amountShortName: String, priceShortName: String, searchText: String) -> Bool {
        
        let searchCompoments = searchText.components(separatedBy: "/")
        if searchCompoments.count == 1 {
            
            let searchWords = searchCompoments[0].components(separatedBy: " ").filter {$0.count > 0}
            
            return isValidSearchAsset(name: amountName, shortName: amountShortName, searchWords: searchWords) ||
                isValidSearchAsset(name: priceName, shortName: priceShortName, searchWords: searchWords)
        }
        else if searchCompoments.count >= 2 {
            
            let searchAmountWords = searchCompoments[0].components(separatedBy: " ").filter {$0.count > 0}
            let searchPriceWords = searchCompoments[1].components(separatedBy: " ").filter {$0.count > 0}

            if searchPriceWords.count > 0 {
                return isValidSearchAsset(name: amountName, shortName: amountShortName, searchWords: searchAmountWords) &&
                    isValidSearchAsset(name: priceName, shortName: priceShortName, searchWords: searchPriceWords)
            }
            return isValidSearchAsset(name: amountName, shortName: amountShortName, searchWords: searchAmountWords)
        }
        
        return false
    }
    
    func isValidSearchAsset(name: String, shortName: String, searchWords: [String]) -> Bool {
        
        for word in searchWords {
            let isValid = isValidSearch(inputText: name, searchText: word) ||
                isValidSearch(inputText: shortName, searchText: word)
            if !isValid {
                return false
            }
        }
        return true
    }
    
    func isValidSearch(inputText: String, searchText: String) -> Bool {
        return (inputText.lowercased() as NSString).range(of: searchText.lowercased()).location != NSNotFound
    }
}

//MARK: - Load data
private extension DexMarketInteractor {
    
    func pairs(wallet: DomainLayer.DTO.SignedWallet, environment: WalletEnvironment) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        
        let spamURL = environment.servers.spamUrl.relativeString
        let firstGeneralAssets = environment.generalAssets.prefix(Constants.maxGeneralAssets)
        
        print(firstGeneralAssets.map {$0.displayName})

        struct Pair {
            let amountAsset: String
            let priceAsset: String
        }
        
        
        var pairs: [Pair] = []
        
        for asset in firstGeneralAssets {
            for nextAsset in firstGeneralAssets {
                if asset.assetId != nextAsset.assetId {
                    pairs.append(.init(amountAsset: asset.assetId, priceAsset: nextAsset.assetId))
                }
            }
        }
        
        
        return assetsInteractor.assets(by: firstGeneralAssets.map { $0.assetId }, accountAddress: wallet.address)
            .flatMap({ [weak self] (assets) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                guard let self = self else { return Observable.empty() }
                
                var domainPairs: [DomainLayer.DTO.Dex.Pair] = []
                for pair in pairs {
                    
                    if let amountAsset = assets.first(where: {$0.id == pair.amountAsset}),
                        let priceAsset = assets.first(where: {$0.id == pair.priceAsset}) {
                        
                        let dexAmountAsset = DomainLayer.DTO.Dex.Asset(id: amountAsset.id,
                                                                       name: amountAsset.displayName,
                                                                       shortName: amountAsset.ticker ?? amountAsset.displayName,
                                                                       decimals: amountAsset.precision)
                        
                        let dexPriceAsset = DomainLayer.DTO.Dex.Asset(id: priceAsset.id,
                                                                      name: priceAsset.displayName,
                                                                      shortName: priceAsset.ticker ?? priceAsset.displayName,
                                                                      decimals: priceAsset.precision)
                        
                        
                        domainPairs.append(.init(amountAsset: dexAmountAsset, priceAsset: dexPriceAsset))
                    }
                }
                
                return self.dexRepository.list(by: wallet.address, pairs: domainPairs)
                    .map({ (pairsPrice) -> [DomainLayer.DTO.Dex.SmartPair] in
                        
                        print(pairsPrice)
//                        for pair in pairsPrice {
//                            
//                        }
                        return []
                    })
            })
        
//        print(pairs.map {$0.amountName + " / " + $0.priceName})
        
        if DexMarketInteractor.allPairs.count > 0 &&
            spamURL == DexMarketInteractor.spamURL {
            return dexRealmRepository.checkmark(pairs: DexMarketInteractor.allPairs, accountAddress: wallet.address)
        }
        
        return orderBookRepository.markets(wallet: wallet)
            .map({ (pairs) -> [DomainLayer.DTO.Dex.SmartPair] in
                
                DexMarketInteractor.allPairs = pairs
                DexMarketInteractor.spamURL = spamURL
                
                return pairs
            })
            .catchError({ (error) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                return Observable.just([])
            })
    }
}


