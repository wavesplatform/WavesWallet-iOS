//
//  DomainLayerTests.swift
//  DomainLayerTests
//
//  Created by rprokofev on 21.06.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import XCTest
import DomainLayer

class DomainLayerTests: XCTestCase {

    private let correctionPairsUseCase: CorrectionPairsUseCaseLogicProtocol = CorrectionPairsUseCaseLogic()
    
    private let settingsIdsPairs: [String] = ["Ft8X1v1LTa1ABafufpaCWyVj8KkaxUWE6xBhW6sNFJck",
                                              "DG2xFkPdDwKUoBkzGAhQtLpSGzfXLiCYPEzeKH2Ad24p",
                                              "34N9YcEETLWn93qYQ64EsP1x89tSruJU44RrEMSXXEPJ",
                                              "Gtb1WRznfchDnTh37ezoDTJ4wcoKaRsKqKjJjy7nm2zU",
                                              "2mX5DzVKWrAJw8iwdJnV2qtoeVG9h5nTDpTqC1wb1WEN",
                                              "8LQW8f7P5d5PZM7GtZEBgaqRPGSzS3DfPuiXrURJ4AJS",
                                              "WAVES",
                                              "474jTeYx2r2Va35794tCScAXWJG9hU2HcgxzMowaZUnu",
                                              "zMFqXuoyrn5w17PFurTqxB7GsS71fp9dfk6XFwxbPCy",
                                              "62LyMjcr2DtiyF5yVXFhoQ2q414VPPJXjsNYp72SuDCH",
                                              "HZk1mbfuJpmxU1Fs4AX5MWLVYtctsNcg6e2C6VKqK8zk",
                                              "B3uGHFRpSUuGEDWjqB9LWWxafQj8VTvpMucEyoxzws5H",
                                              "5WvPKSJXzVE2orvbkJ8wsQmmQKqTv9sGBPksV4adViw3",
                                              "BrjUWjndUanm5VsJkbUip8VRYy6LWJePtxya3FNv4TQa",
                                              "4LHHvYGNKJUg5hj65aGD5vgScvCBmLpdRFtjokvCjSL8"
                                            ]
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPepperCoinBancor() {
        
        let result = CorrectionPairsUseCaseLogic.mapCorrectPairs(settingsIdsPairs: settingsIdsPairs,
                                                                 pairs: [.init(amountAsset: "3taHxaAB5oPdkY4geikcFGd4m4wisBPukSnD8V5Nz7LF",
                                                                               priceAsset: "F81SdfzBZr5ce8JArRWLPJEDg1V8yT257ohbcHk75yCp")])
        
        
        let amount =  result.first?.amountAsset ?? ""
        let price =  result.first?.priceAsset ?? ""
        
        assert(amount == "F81SdfzBZr5ce8JArRWLPJEDg1V8yT257ohbcHk75yCp")
        assert(price == "3taHxaAB5oPdkY4geikcFGd4m4wisBPukSnD8V5Nz7LF")
    }
    
    func testPepperCoinErgo() {
        
        let result = CorrectionPairsUseCaseLogic.mapCorrectPairs(settingsIdsPairs: settingsIdsPairs,
                                                                 pairs: [.init(amountAsset: "3taHxaAB5oPdkY4geikcFGd4m4wisBPukSnD8V5Nz7LF",
                                                                               priceAsset: "5dJj4Hn9t2Ve3tRpNGirUHy4yBK6qdJRAJYV21yPPuGz")])
        
        
        let amount =  result.first?.amountAsset ?? ""
        let price =  result.first?.priceAsset ?? ""
        
        assert(amount == "5dJj4Hn9t2Ve3tRpNGirUHy4yBK6qdJRAJYV21yPPuGz")
        assert(price == "3taHxaAB5oPdkY4geikcFGd4m4wisBPukSnD8V5Nz7LF")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
