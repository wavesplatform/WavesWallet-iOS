import Foundation
import RxSwift
import SwiftyJSON

final class DexMarketInteractor: DexMarketInteractorProtocol {
    
    private static var allPairs: [DexMarket.DTO.Pair] = []

    private let searchPairsSubject: PublishSubject<[DexMarket.DTO.Pair]> = PublishSubject<[DexMarket.DTO.Pair]>()
    private let disposeBag: DisposeBag = DisposeBag()
    
    func pairs() -> Observable<[DexMarket.DTO.Pair]> {
        return Observable.create({ [weak self] (subscribe) -> Disposable in
            
            guard let strongSelf = self else { return Disposables.create() }

            if DexMarketInteractor.allPairs.count > 0 {
                subscribe.onNext(DexMarketInteractor.allPairs)
                return Disposables.create()
            }
            
            let account: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance
            account.balances(isNeedUpdate: false).subscribe(onNext: { [weak self] (balances) in
                
                self?.getAllPairs(balances: balances, complete: { (pairs) in
                   
                    DexMarketInteractor.allPairs = pairs
                    subscribe.onNext(pairs)
                })
        
            }).disposed(by: strongSelf.disposeBag)
           
            
            return Disposables.create()
        })
    }
    
    func searchPairs() -> Observable<[DexMarket.DTO.Pair]> {
        return searchPairsSubject.asObserver()
    }
    
    func checkMark(pair: DexMarket.DTO.Pair) {
        if let index = DexMarketInteractor.allPairs.index(where: {$0.amountAsset == pair.amountAsset && $0.priceAsset == pair.priceAsset}) {
            DexMarketInteractor.allPairs[index] = pair.mutate { $0.isChecked = !$0.isChecked }
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
    
    func getAllPairs(balances: [DomainLayer.DTO.AssetBalance], complete:@escaping(_ pairs: [DexMarket.DTO.Pair]) -> Void) {
      
        NetworkManager.getRequestWithUrl(GlobalConstants.Matcher.orderBook, parameters: nil, complete: { (info, error) in
            
            var pairs: [DexMarket.DTO.Pair] = []

            if let info = info {
                
                for item in info["markets"].arrayValue {
                    
                    let amountAssetId = item["amountAsset"].stringValue
                    var amountAssetName = item["amountAssetName"].stringValue
                    var amountAssetShortName = item["amountAssetName"].stringValue
                    
                    if let asset = balances.first(where: {$0.assetId == amountAssetId})?.asset {
                        amountAssetName = asset.displayName
                        if let ticker = asset.ticker {
                            amountAssetShortName = ticker
                        }
                    }
                    
                    let priceAssetId = item["priceAsset"].stringValue
                    var priceAssetName = item["priceAssetName"].stringValue
                    var priceAssetShortName = item["priceAssetName"].stringValue
                    
                    if let asset = balances.first(where: {$0.assetId == priceAssetId})?.asset {
                        priceAssetName = asset.displayName
                        if let ticker = asset.ticker {
                            priceAssetShortName = ticker
                        }
                    }
                    
                    let amountAsset = DexMarket.DTO.Asset(id: amountAssetId,
                                                          name: amountAssetName,
                                                          shortName: amountAssetShortName,
                                                          decimals: item["amountAssetInfo"]["decimals"].intValue)
                    
                    let priceAsset = DexMarket.DTO.Asset(id: priceAssetId,
                                                         name: priceAssetName,
                                                         shortName: priceAssetShortName,
                                                         decimals: item["priceAssetInfo"]["decimals"].intValue)
                    
                    pairs.append(DexMarket.DTO.Pair(amountAsset: amountAsset,
                                                    priceAsset: priceAsset,
                                                    isChecked: false,
                                                    isHidden: false))
                }
                
            }
            
            complete(pairs)
        })
        
    }
}
