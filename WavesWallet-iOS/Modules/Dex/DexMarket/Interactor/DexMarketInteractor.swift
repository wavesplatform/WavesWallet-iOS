import Foundation
import RxSwift
import DomainLayer
import DataLayer
import Extensions
import WavesSDK

private enum Constants {
    static let firstGeneralAssets = 4
    
    static let liquidToken = "7FzrHF1pueRFrPEupz6oiVGTUZqe8epvC7ggWUx8n1bd"
    static let wctToken = "DHgwrRvVyqJsepd32YbBqUeDH4GJ1N984X8QoekjgH8J"
    static let mrtToken = "4uK8i4ThRGbehENwa6MxyLtxAjAo1Rj9fduborGExarC"
}

final class DexMarketInteractor: DexMarketInteractorProtocol {
    
    private static var allPairs: [DomainLayer.DTO.Dex.SmartPair] = []
    private static var spamURL = ""

    private let disposeBag: DisposeBag = DisposeBag()

    private let dexRealmRepository: DexRealmRepositoryProtocol = UseCasesFactory.instance.repositories.dexRealmRepository
    private let auth = UseCasesFactory.instance.authorization
    
    private let environment = UseCasesFactory.instance.repositories.environmentRepository
    private let orderBookRepository = UseCasesFactory.instance.repositories.dexOrderBookRepository

    private let dexPairsPriceRepository: DexPairsPriceRepositoryProtocol = UseCasesFactory.instance.repositories.dexPairsPriceRepository
    private let assetsInteractor: AssetsUseCaseProtocol = UseCasesFactory.instance.assets
    private let assetsRepository: AssetsRepositoryProtocol = UseCasesFactory.instance.repositories.assetsRepositoryRemote
    private let correctionPairsUseCase: CorrectionPairsUseCaseProtocol = UseCasesFactory.instance.correctionPairsUseCase
    
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
        
        var words = searchWord.components(separatedBy: "/").filter {$0.count > 0}
            .map{$0.trimmingCharacters(in: .whitespaces)}

        if words.count <= 1 {
            words = searchWord.replacingOccurrences(of: "/", with: "")
                .components(separatedBy: "\\").filter {$0.count > 0}
                .map{$0.trimmingCharacters(in: .whitespaces)}
        }

        return Observable.zip(auth.authorizedWallet(), environment.walletEnvironment())
            .flatMap{ [weak self] (wallet, environment) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                guard let self = self else { return Observable.empty() }
                
                if words.count == 1 {
                
                    var generalIds = environment.generalAssets.map { $0.assetId }
                    generalIds.append(Constants.wctToken)
                    generalIds.append(Constants.mrtToken)
                    generalIds.append(Constants.liquidToken)

                    let generalAssetsObserver = self.assetsInteractor.assets(by: generalIds, accountAddress: wallet.address)
                    let assetsObserver = self.assetsRepository.searchAssets(search: words[0], accountAddress: wallet.address)
                  
                    return self.searchPairs(firstSearchAssets: assetsObserver, secondSearchAssets: generalAssetsObserver, address: wallet.address)
                }
                else if words.count > 1 {
                    let firstAssetsObserver = self.assetsRepository.searchAssets(search: words[0], accountAddress: wallet.address)
                    let secondsAssetsObserver = self.assetsRepository.searchAssets(search: words[1], accountAddress: wallet.address)

                    return self.searchPairs(firstSearchAssets: firstAssetsObserver, secondSearchAssets: secondsAssetsObserver, address: wallet.address)
                }
                return Observable.just([])
            }
            .catchError({ (error) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                return Observable.just([])
            })

    }
    
    func checkMark(pair: DomainLayer.DTO.Dex.SmartPair) {
        
        var newPair = pair
        newPair.isChecked = !pair.isChecked
                
        auth.authorizedWallet().flatMap { [weak self] wallet -> Observable<Bool> in
            
            guard let self = self else { return Observable.never() }

            if newPair.isChecked {
                return self.dexRealmRepository.save(pair: .init(id: newPair.id,
                                                                isGeneral: newPair.isGeneral,
                                                                amountAsset: newPair.amountAsset,
                                                                priceAsset: newPair.priceAsset),
                                                    accountAddress: wallet.address)
            }
            return self.dexRealmRepository.delete(by: newPair.id, accountAddress: wallet.address)
            
        }.subscribe().disposed(by: disposeBag)
    }
}

//MARK: - Load data
private extension DexMarketInteractor {
    
    func searchPairs(firstSearchAssets: Observable<[DomainLayer.DTO.Asset]>, secondSearchAssets: Observable<[DomainLayer.DTO.Asset]>, address: String) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
    
        return Observable.zip(firstSearchAssets, secondSearchAssets)
            .flatMap{ [weak self] (firstAssets, secondAssets) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                guard let self = self else { return Observable.empty() }
                
                return self.correctionAndSearchPairs(firstAssets: firstAssets.filter {$0.isSpam == false},
                                                     secondAssets: secondAssets.filter {$0.isSpam == false},
                                                     address: address)
            }
    }
    
    func correctionAndSearchPairs(firstAssets: [DomainLayer.DTO.Asset], secondAssets: [DomainLayer.DTO.Asset], address: String) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        
        var pairs: [DomainLayer.DTO.CorrectionPairs.Pair] = []
        let allAssets = firstAssets + secondAssets
        
        for asset in firstAssets {
            for secondAsset in secondAssets {
                if asset.id != secondAsset.id {
                    pairs.append(.init(amountAsset: asset.id, priceAsset: secondAsset.id))
                }
            }
        }
        
        return self.correctionPairsUseCase.correction(pairs: pairs)
            .flatMap{ [weak self] correctionPairs -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                guard let self = self else { return Observable.empty() }
                
                let searchQueryPairs = correctionPairs.map{ DomainLayer.Query.Dex.SearchPairs.Pair(amountAsset: $0.amountAsset,
                                                                                                   priceAsset: $0.priceAsset) }
                
                let searchPairsObserver = self.dexPairsPriceRepository.searchPairs(.init(kind: .pairs(searchQueryPairs)))
                let localPairsObserver = self.dexRealmRepository.list(by: address)
                
                return Observable.zip(searchPairsObserver, localPairsObserver)
                    .map{ pairsSearch, localPairs -> [DomainLayer.DTO.Dex.SmartPair] in
                        
                        struct SmartVolumePair {
                            let smartPair: DomainLayer.DTO.Dex.SmartPair
                            let volume: Double
                        }
                        var smartPairs: [SmartVolumePair] = []
                        
                        for (index, queryPair) in searchQueryPairs.enumerated() {
                            
                            guard let amountAsset = allAssets.first(where: {$0.id == queryPair.amountAsset}) else { break }
                            guard let priceAsset = allAssets.first(where: {$0.id == queryPair.priceAsset}) else { break }
                           
                            guard index < pairsSearch.pairs.count else { continue }
                            
                            let volume = pairsSearch.pairs[index]?.volumeWaves ?? 0
                            let localPair = localPairs.first(where: {$0.amountAssetId == amountAsset.id &&
                                $0.priceAssetId == priceAsset.id})
                            
                            let isGeneralAmount = allAssets.first(where: {$0.id == amountAsset.id})?.isGeneral ?? false
                            let isGeneralPrice = allAssets.first(where: {$0.id == priceAsset.id})?.isGeneral ?? false
                            let isGeneral = isGeneralAmount && isGeneralPrice
                            
                            smartPairs.append(.init(smartPair: .init(amountAsset: amountAsset.dexAsset,
                                                                     priceAsset: priceAsset.dexAsset,
                                                                     isChecked: localPair != nil,
                                                                     isGeneral: isGeneral,
                                                                     sortLevel: localPair?.sortLevel ?? 0),
                                                                     volume: volume))

                        }
                        
                      
                        smartPairs.sort(by: {$0.volume > $1.volume})
                        
                        return smartPairs.map {$0.smartPair}
                }
        }
    }
    
    func defaultPairs(wallet: DomainLayer.DTO.SignedWallet, environment: WalletEnvironment) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        
        let spamURL = environment.servers.spamUrl.relativeString

        if DexMarketInteractor.allPairs.count > 0 &&
            spamURL == DexMarketInteractor.spamURL {
            return dexRealmRepository.checkmark(pairs: DexMarketInteractor.allPairs, accountAddress: wallet.address)
        }
        
        let allGeneralAssets = environment.generalAssets
        let firstGeneralAssets = environment.generalAssets.prefix(Constants.firstGeneralAssets)

        var searchPairs: [DomainLayer.DTO.Dex.SimplePair] = []
        
        for asset in allGeneralAssets {
            for nextAsset in firstGeneralAssets {
                if asset.assetId != nextAsset.assetId {
                    searchPairs.append(.init(amountAsset: asset.assetId, priceAsset: nextAsset.assetId))
                }
            }
        }

        return assetsInteractor.assets(by: allGeneralAssets.map { $0.assetId }, accountAddress: wallet.address)
            .flatMap({ [weak self] (assets) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                guard let self = self else { return Observable.empty() }
                
                var dexPairs: [DomainLayer.DTO.Dex.Pair] = []
                for pair in searchPairs {
                    
                    if let amountAsset = assets.first(where: {$0.id == pair.amountAsset}),
                        let priceAsset = assets.first(where: {$0.id == pair.priceAsset}) {
                        
                        dexPairs.append(.init(amountAsset: amountAsset.dexAsset, priceAsset: priceAsset.dexAsset))
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


