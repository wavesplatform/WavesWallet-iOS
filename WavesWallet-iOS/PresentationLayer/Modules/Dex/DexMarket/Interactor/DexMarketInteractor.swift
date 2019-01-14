import Foundation
import RxSwift
import RealmSwift
import Alamofire
import Moya

final class DexMarketInteractor: DexMarketInteractorProtocol {
    
    private static var allPairs: [DomainLayer.DTO.Dex.SmartPair] = []
    private static var isEnableSpam = false
    private static var spamURL = ""

    private let searchPairsSubject: PublishSubject<[DomainLayer.DTO.Dex.SmartPair]> = PublishSubject<[DomainLayer.DTO.Dex.SmartPair]>()
    private let disposeBag: DisposeBag = DisposeBag()

    private let dexRealmRepository: DexRealmRepositoryProtocol = FactoryRepositories.instance.dexRealmRepository
    private let auth = FactoryInteractors.instance.authorization
    private let accountSettings: AccountSettingsRepositoryProtocol = FactoryRepositories.instance.accountSettingsRepository
    private let environment = FactoryRepositories.instance.environmentRepository
    private let orderBookRepository = FactoryRepositories.instance.dexOrderBookRepository

    func pairs() -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {

        return auth.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
            
            guard let owner = self else { return Observable.empty() }
            return owner.accountSettings.accountSettings(accountAddress: wallet.address).flatMap({ [weak self] (accountSettings) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                
                guard let owner = self else { return Observable.empty() }
                let isEnableSpam = accountSettings?.isEnabledSpam ?? DexMarketInteractor.isEnableSpam

                return owner.environment.accountEnvironment(accountAddress: wallet.address).flatMap({ [weak self] (environment) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                    
                    guard let owner = self else { return Observable.empty() }
                    return owner.pairs(wallet: wallet,
                                       isEnableSpam: isEnableSpam,
                                       spamURL: environment.servers.spamUrl.relativeString)
                })
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
    
    func pairs(wallet: DomainLayer.DTO.SignedWallet, isEnableSpam: Bool, spamURL: String) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> {
        
        if DexMarketInteractor.allPairs.count > 0 &&
            isEnableSpam == DexMarketInteractor.isEnableSpam &&
            spamURL == DexMarketInteractor.spamURL {
            
            return Observable.create({ (subscribe) -> Disposable in
                
                let realm = try! WalletRealmFactory.realm(accountAddress: wallet.address)
                
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
        
        return orderBookRepository.markets(wallet: wallet, isEnableSpam: isEnableSpam)
            .map({ (pairs) -> [DomainLayer.DTO.Dex.SmartPair] in
                
                DexMarketInteractor.allPairs = pairs
                DexMarketInteractor.isEnableSpam = isEnableSpam
                DexMarketInteractor.spamURL = spamURL
                
                return pairs
            })
            .catchError({ (error) -> Observable<[DomainLayer.DTO.Dex.SmartPair]> in
                return Observable.just([])
            })
    }
}


