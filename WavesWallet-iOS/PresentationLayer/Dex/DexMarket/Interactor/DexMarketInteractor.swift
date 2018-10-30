import Foundation
import RxSwift
import SwiftyJSON
import RealmSwift

final class DexMarketInteractor: DexMarketInteractorProtocol {
    
    private static var allPairs: [DexMarket.DTO.Pair] = []

    private let searchPairsSubject: PublishSubject<[DexMarket.DTO.Pair]> = PublishSubject<[DexMarket.DTO.Pair]>()
    private let disposeBag: DisposeBag = DisposeBag()

    private let repository: DexRepositoryProtocol = DexRepository()
    private let authorizationInteractor = FactoryInteractors.instance.authorization
    private let account: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance

    func pairs() -> Observable<[DexMarket.DTO.Pair]> {

        return authorizationInteractor.authorizedWallet().flatMap({ [weak self] (wallet) -> Observable<[DexMarket.DTO.Pair]> in
            
            guard let owner = self else { return Observable.empty() }
            return owner.allPairs(accountAddress: wallet.wallet.address)
        })
    }
    
    func searchPairs() -> Observable<[DexMarket.DTO.Pair]> {
        return searchPairsSubject.asObserver()
    }
    
    func checkMark(pair: DexMarket.DTO.Pair) {
        
        if let index = DexMarketInteractor.allPairs.index(where: {$0.id == pair.id}) {
           
            DexMarketInteractor.allPairs[index] = pair.mutate {

                let needSaveAssetPair = !$0.isChecked
                let pair = $0
                
                $0.isChecked = !$0.isChecked
                
                authorizationInteractor.authorizedWallet().flatMap { [weak self] wallet -> Observable<Bool> in
                        
                    guard let owner = self else { return Observable.never() }

                    if needSaveAssetPair {
                        return owner.repository.save(pair: pair, accountAddress: wallet.wallet.address)
                    }
                    return owner.repository.delete(by: pair.id, accountAddress: wallet.wallet.address)
                    
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
            
            return isValidSearchAsset(name: amountName, shortName: amountShortName, searchWords: searchWords)
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
            if isValid {
                return true
            }
        }
        return false
    }
    
    func isValidSearch(inputText: String, searchText: String) -> Bool {
        return (inputText.lowercased() as NSString).range(of: searchText.lowercased()).location != NSNotFound
    }
}

//MARK: - Load data
private extension DexMarketInteractor {
    
    func allPairs(accountAddress: String) -> Observable<[DexMarket.DTO.Pair]> {
        
        if DexMarketInteractor.allPairs.count > 0 {
            
            let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)
            
            for (index, pair) in DexMarketInteractor.allPairs.enumerated() {
                DexMarketInteractor.allPairs[index] = pair.mutate {
                    $0.isChecked = realm.object(ofType: DexAssetPair.self, forPrimaryKey: pair.id) != nil
                }
            }
            
            return Observable.just(DexMarketInteractor.allPairs)
        }
        else {
            return Observable.create({ [weak self] (subscribe) -> Disposable in
                
                guard let owner = self else { return Disposables.create() }
                owner.getAllPairs(accountAddress: accountAddress, complete: { (pairs) in
                    DexMarketInteractor.allPairs = pairs
                    subscribe.onNext(pairs)
                    subscribe.onCompleted()
                })
                return Disposables.create()
            })
        }
    }
    
    func getAllPairs(accountAddress: String, complete:@escaping(_ pairs: [DexMarket.DTO.Pair]) -> Void) {
      
        //TODO: need change to Observer network
        NetworkManager.getRequestWithUrl(GlobalConstants.Matcher.orderBook, parameters: nil, complete: { (info, error) in
            
            var pairs: [DexMarket.DTO.Pair] = []
            
            if let info = info {
                
                let realm = try! WalletRealmFactory.realm(accountAddress: accountAddress)

                for item in info["markets"].arrayValue {
                    pairs.append(DexMarket.DTO.Pair(item, realm: realm))
                }
                
                pairs = self.sort(pairs: pairs, realm: realm)
            }
            
            complete(pairs)
        })

    }
}


//MARK: - Sort
private extension DexMarketInteractor {
    
    func sort(pairs: [DexMarket.DTO.Pair], realm: Realm) -> [DexMarket.DTO.Pair] {
        
        var sortedPairs: [DexMarket.DTO.Pair] = []
        let generalBalances = realm.objects(AssetBalance.self).filter(NSPredicate(format: "asset.isGeneral == true"))
        
        for balance in generalBalances {
            sortedPairs.append(contentsOf: pairs.filter({$0.amountAsset.id == balance.assetId && $0.isGeneral == true }))
        }
        
        var sortedIds = sortedPairs.map {$0.id}
        sortedPairs.append(contentsOf: pairs.filter { $0.isGeneral == true && !sortedIds.contains($0.id) } )

        sortedIds = sortedPairs.map {$0.id}
        sortedPairs.append(contentsOf: pairs.filter { !sortedIds.contains($0.id) } )

        return sortedPairs
    }
}
