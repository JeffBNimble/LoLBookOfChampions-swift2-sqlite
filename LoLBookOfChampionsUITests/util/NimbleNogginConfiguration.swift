//
// Created by Jeffrey Roberts on 2/12/16.
// Copyright (c) 2016 NimbleNoggin.io. All rights reserved.
//

import Foundation
import Quick

public var currentExampleFailed = false

public class NimbleNogginConfiguration : QuickConfiguration {
    static var testCount:Int = 0
    static var passCount:Int = 0
    static var startTime:NSDate!
    static var groups:NSMutableDictionary = NSMutableDictionary()

    override public static func configure(configuration: Configuration) {
        configuration.beforeEach() { (metadata:ExampleMetadata) in
            currentExampleFailed = false
            testCount = testCount + 1
        }

        configuration.afterEach() { (metadata:ExampleMetadata) in
            let segments = metadata.example.name.componentsSeparatedByString(",")

            var currentGroup = groups
            var previousGroup = groups
            var trimmedSegment:String!
            segments.forEach() { segment in
                trimmedSegment = segment.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if currentGroup[trimmedSegment] != nil {
                    currentGroup = currentGroup[trimmedSegment] as! NSMutableDictionary
                } else {
                    previousGroup = currentGroup
                    currentGroup[trimmedSegment] = NSMutableDictionary()
                    currentGroup = currentGroup[trimmedSegment] as! NSMutableDictionary
                }
            }

            previousGroup[trimmedSegment] = currentExampleFailed ? "F" : "P"
            if !currentExampleFailed {
                passCount = passCount + 1
            }
        }

        configuration.beforeSuite() {
            testCount = 0
            passCount = 0
            startTime = NSDate()
        }

        configuration.afterSuite() {
            printTestResults(groups, prefix: "")
            let duration = startTime.timeIntervalSinceNow * -1.0
            var interval:String!

            if duration < 0.1 {
                interval = "\(duration * 1000.0)ms"
            } else if duration < 60.0 {
                interval = "\(duration)s"
            } else if duration >= 60.0 {
                interval = "\(duration / 60.0)m"
            }

            print("\n\n\(testCount) tests run in \(interval)")
            print("\(passCount) pass/\(testCount - passCount) fail")
        }
    }

    private static func printTestResults(results : NSDictionary, prefix : String = "") {
         results.allKeys.forEach() { key in
            if let segment = key as? String {
                var testResult = ""
                let value = results[segment]

                if let result = value as? String {
                    testResult = result == "P" ? "\u{001B}[1m\u{001B}[032;m[PASSED]\u{001B}[0m" : "\u{001B}[1m\u{001B}[031;m[FAILED]\u{001B}[0m"
                }

                print("\(prefix)\(segment) \(testResult)")

                if let segments = value as? NSDictionary {
                    printTestResults(segments, prefix: "\(prefix)\t")
                }
            }
         }
    }

}
