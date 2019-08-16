import Foundation
import RxSwift
import DomainLayer
import DataLayer
import Extensions

private enum Constants {
    static let maxGeneralAssets = 4
}

final class DexMarketInteractor: DexMarketInteractorProtocol {
    
    private static var allPairs: [DomainLayer.DTO.Dex.SmartPair] = []
    private static var spamURL = ""

    private let disposeBag: DisposeBag = DisposeBag()

    private let dexRealmRepository: DexRealmRepositoryProtocol = UseCasesFactory.instance.repositories.dexRealmRepository
    private let auth = UseCasesFactory.instance.authorization
    
    private let environment = UseCasesFactory.instance.repositories.environmentRepository
    private let orderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository

    private let dexPairsPriceRepository = UseCasesFactory.instance.repositories.dexPairsPriceRepository
    private let assetsInteractor = UseCasesFactory.instance.assets
    
    func pairs() -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
            
            guard let self = self else { return Observable.empty() }
            
            return self.environment.walletEnvironment().flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                
                guard let self = self else { return Observable.empty() }
                return self.defaultPairs(wallet: wallet, environment: environment)
            })
        })
    }
    
    func searchPairs(searchWord: String) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.Dex.SmartPair]>  in
            guard let self = self else { return Observable.empty() }
            return self.dexPairsPriceRepository.search(by: wallet.address, searchText: searchWord)
                .flatMap({ [weak self] (pairs) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                    
                    guard let self = self else { return Observable.empty() }
                    
                    var assetsIds: [String] = []
                    for pair in pairs {
                        if !assetsIds.contains(pair.amountAsset) {
                            assetsIds.append(pair.amountAsset)
                        }
                        
                        if !assetsIds.contains(pair.priceAsset) {
                            assetsIds.append(pair.priceAsset)
                        }
                    }
                    
                    return self.assetsInteractor.assets(by: assetsIds, accountAddress: wallet.address)
                        .flatMap({ (assets) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                            
                            var dexPairs: [DomainLayer.DTO.Dex.Pair] = []
                            
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
                                    dexPairs.append(.init(amountAsset: dexAmountAsset, priceAsset: dexPriceAsset))
                                }
                            }
                            
                            return self.dexRealmRepository.list(by: wallet.address)
                                .map({ (localSmartPairs) -> [DomainLayer.DTO.Dex.SmartPair] in
                                    
                                    var newSmartPairs: [DomainLayer.DTO.Dex.SmartPair] = []
                                    
                                    for pair in dexPairs {
                                        
                                        let localPair = localSmartPairs.first(where: {$0.amountAsset.id == pair.amountAsset.id &&
                                            $0.priceAsset.id == pair.priceAsset.id})
                                        
                                        let isGeneralAmount = assets.first(where: {$0.id == pair.amountAsset.id})?.isGeneral ?? false
                                        let isGeneralPrice = assets.first(where: {$0.id == pair.priceAsset.id})?.isGeneral ?? false
                                        let isGeneral = isGeneralAmount && isGeneralPrice

                                        newSmartPairs.append(.init(amountAsset: pair.amountAsset,
                                                                   priceAsset: pair.priceAsset,
                                                                   isChecked: localPair?.isChecked ?? false,
                                                                   isGeneral: isGeneral,
                                                                   sortLevel: localPair?.sortLevel ?? 0))
                                    }
                                    
                                    return newSmartPairs
                                })
                        })
                })
        })
        .catchError({ _ -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
            return Observable.just([])
        })
    }
    
    func checkMark(pair: DomainLayer.DTO.Dex.SmartPair) {
        
        if let index = DexMarketInteractor.allPairs.firstIndex(where: {$0.id == pair.id}) {
           
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
}

//MARK: - Load data
private extension DexMarketInteractor {
    
    func defaultPairs(wallet: DomainLayer.DTO.SignedWallet, environment: WalletEnvironment) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        
        let spamURL = environment.servers.spamUrl.relativeString

        if DexMarketInteractor.allPairs.count > 0 &&
            spamURL == DexMarketInteractor.spamURL {
            return dexRealmRepository.checkmark(pairs: DexMarketInteractor.allPairs, accountAddress: wallet.address)
        }
        
        let firstGeneralAssets = environment.generalAssets.prefix(Constants.maxGeneralAssets)

        var searchPairs: [DomainLayer.DTO.Dex.SimplePair] = []

        for asset in firstGeneralAssets {
            for nextAsset in firstGeneralAssets {
                if asset.assetId != nextAsset.assetId {
                    searchPairs.append(.init(amountAsset: asset.assetId, priceAsset: nextAsset.assetId))
                }
            }
        }

        return assetsInteractor.assets(by: firstGeneralAssets.map { $0.assetId }, accountAddress: wallet.address)
            .flatMap({ [weak self] (assets) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                guard let self = self else { return Observable.empty() }
                
                var dexPairs: [DomainLayer.DTO.Dex.Pair] = []
                for pair in searchPairs {
                    
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
                        
                        
                        dexPairs.append(.init(amountAsset: dexAmountAsset, priceAsset: dexPriceAsset))
                    }
                }

                return self.orderBookRepository.markets(wallet: wallet, pairs: dexPairs)
                    .map({ (smartPairs) -> [DomainLayer.DTO.Dex.SmartPair] in
                        
                        DexMarketInteractor.allPairs = smartPairs
                        DexMarketInteractor.spamURL = spamURL

                        return smartPairs
                    })
            })
            .catchError({ (error) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                return Observable.just([])
            })
    }
}


