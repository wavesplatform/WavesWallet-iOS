//
//  MonkeyTest.swift
//  MonkeyTest
//
//  Created by rprokofev on 27/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import XCTest
import SwiftMonkey

final class MonkeyTest: XCTestCase {

    private var application: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        
        application = XCUIApplication()
        application.launchArguments.append("--MONKEY_TEST")
        
        application.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    
    func testMonkey() {
        guard let application = application else { return }
        
        sleep(10)
        // Workaround for bug in Xcode 7.3. Snapshots are not properly updated
        // when you initially call app.frame, resulting in a zero-sized rect.
        // Doing a random query seems to update everything properly.
        // TODO: Remove this when the Xcode bug is fixed!
        _ = application.descendants(matching: .any).element(boundBy: 0).frame
        
        // Initialise the monkey tester with the current device
        // frame. Giving an explicit seed will make it generate
        // the same sequence of events on each run, and leaving it
        // out will generate a new sequence on each run.
        let monkey = Monkey(frame: application.frame)
        //let monkey = Monkey(seed: 123, frame: application.frame)
        
        // Add actions for the monkey to perform. We just use a
        // default set of actions for this, which is usually enough.
        // Use either one of these, but maybe not both.
        // XCTest private actions seem to work better at the moment.
        // UIAutomation actions seem to work only on the simulator.
        monkey.addDefaultXCTestPrivateActions()
        //monkey.addDefaultUIAutomationActions()
        
        // Occasionally, use the regular XCTest functionality
        // to check if an alert is shown, and click a random
        // button on it.
        monkey.addXCTestTapAlertAction(interval: 100, application: application)
        
        // Run the monkey test indefinitely.
        monkey.monkeyAround()
    }
}
