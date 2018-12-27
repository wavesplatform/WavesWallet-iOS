import Foundation
import RxSwift
import RealmSwift
import Alamofire
import Moya

final class DexMarketInteractor: DexMarketInteractorProtocol {
    
    private static var allPairs: [DomainLayer.DTO.Dex.AssetPair] = []
    private static var isEnableSpam = false
    private static var spamURL = ""

    private let searchPairsSubject: PublishSubject<[DomainLayer.DTO.Dex.AssetPair]> = PublishSubject<[DomainLayer.DTO.Dex.AssetPair]>()
    private let disposeBag: DisposeBag = DisposeBag()

    private let dexRealmRepository: DexRealmRepositoryProtocol = FactoryRepositories.instance.dexRealmRepository
    private let auth = FactoryInteractors.instance.authorization
    private let accountSettings: AccountSettingsRepositoryProtocol = FactoryRepositories.instance.accountSettingsRepository
    private let environment = FactoryRepositories.instance.environmentRepository
    private let orderBookRepository = FactoryRepositories.instance.dexOrderBookRepository

    func pairs() -> Observable<[DomainLayer.DTO.Dex.AssetPair]> {

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.Dex.AssetPair]> in
            
            guard let owner = self else { return Observable.empty() }
            return owner.accountSettings.accountSettings(accountAddress: wallet.address).flatMap({ [weak self] (accountSettings) -> Observable<[DomainLayer.DTO.Dex.AssetPair]> in
                
                guard let owner = self else { return Observable.empty() }
                let isEnableSpam = accountSettings?.isEnabledSpam ?? DexMarketInteractor.isEnableSpam

                return owner.environment.accountEnvironment(accountAddress: wallet.address).flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Dex.AssetPair]> in
                    
                    guard let owner = self else { return Observable.empty() }
                    return owner.pairs(accountAddress: wallet.address, isEnableSpam: isEnableSpam, spamURL: environment.servers.spamUrl.relativeString)
                })
            })
        })
    }
    
    func searchPairs() -> Observable<[DomainLayer.DTO.Dex.AssetPair]> {
        return searchPairsSubject.asObserver()
    }
    
    func checkMark(pair: DomainLayer.DTO.Dex.AssetPair) {
        
        if let index = DexMarketInteractor.allPairs.index(where: {$0.id == pair.id}) {
           
            DexMarketInteractor.allPairs[index] = pair.mutate {

                let needSaveAssetPair = !$0.isChecked
                let pair = $0
                
                $0.isChecked = !$0.isChecked
                
                auth.authorizedWallet().flatMap { [weak self] wallet -> Observable<Bool> in
                        
                    guard let owner = self else { return Observable.never() }

                    if needSaveAssetPair {
                        return owner.dexRealmRepository.save(pair: pair, accountAddress: wallet.address)
                    }
                    return owner.dexRealmRepository.delete(by: pair.id, accountAddress: wallet.address)
                    
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
    
    func pairs(accountAddress: String, isEnableSpam: Bool, spamURL: String) -> Observable<[DomainLayer.DTO.Dex.AssetPair]> {
        
        if DexMarketInteractor.allPairs.count > 0 &&
            isEnableSpam == DexMarketInteractor.isEnableSpam &&
            spamURL == DexMarketInteractor.spamURL {
            
            return Observable.create({ (subscribe) -> Disposable in
                
                let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
                
                for (index, pair) in DexMarketInteractor.allPairs.enumerated() {
                    DexMarketInteractor.allPairs[index] = pair.mutate {
                        $0.isChecked = realm.object(ofType: DexAssetPair.self, forPrimaryKey: pair.id) != nil
                    }
                }
                
                subscribe.onNext(DexMarketInteractor.allPairs)
                subscribe.onCompleted()
                return Disposables.create()
            })
        }
        
        return getPairsFromRepository(accountAddress: accountAddress, isEnableSpam: isEnableSpam)
            .map({ (pairs) -> [DomainLayer.DTO.Dex.AssetPair] in
                
                DexMarketInteractor.allPairs = pairs
                DexMarketInteractor.isEnableSpam = isEnableSpam
                DexMarketInteractor.spamURL = spamURL
                
                return pairs
            })
            .catchError({ (error) -> Observable<[DomainLayer.DTO.Dex.AssetPair]> in
                return Observable.just([])
            })
    }
    
    func getPairsFromRepository(accountAddress: String, isEnableSpam: Bool) -> Observable<[DomainLayer.DTO.Dex.AssetPair]> {
      
        return orderBookRepository.markets(isEnableSpam: isEnableSpam)
            .map({ [weak self] (markets) -> [DomainLayer.DTO.Dex.AssetPair] in
                
                guard let owner = self else { return [] }
                
                let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
                
                var pairs: [DomainLayer.DTO.Dex.AssetPair] = []
                for market in markets {
                    pairs.append(DomainLayer.DTO.Dex.AssetPair(market, realm: realm))
                }
                pairs = owner.sort(pairs: pairs, realm: realm)

                return pairs
            })
    }
}


//MARK: - Sort
private extension DexMarketInteractor {
    
    func sort(pairs: [DomainLayer.DTO.Dex.AssetPair], realm: Realm) -> [DomainLayer.DTO.Dex.AssetPair] {

        var sortedPairs: [DomainLayer.DTO.Dex.AssetPair] = []

        let generalBalances = realm
            .objects(Asset.self)
            .filter(NSPredicate(format: "isGeneral == true"))
            .toArray()
            .reduce(into: [String: Asset](), { $0[$1.id] = $1 })

        let settingsList = realm
            .objects(AssetBalanceSettings.self)
            .toArray()
            .filter { (asset) -> Bool in
                return generalBalances[asset.assetId]?.isGeneral == true
            }
            .sorted(by: { $0.sortLevel < $1.sortLevel })

        for settings in settingsList {
            sortedPairs.append(contentsOf: pairs.filter({$0.amountAsset.id == settings.assetId && $0.isGeneral == true }))
        }

        var sortedIds = sortedPairs.map {$0.id}
        sortedPairs.append(contentsOf: pairs.filter { $0.isGeneral == true && !sortedIds.contains($0.id) } )

        sortedIds = sortedPairs.map {$0.id}
        sortedPairs.append(contentsOf: pairs.filter { !sortedIds.contains($0.id) } )

        return sortedPairs
    }
}
