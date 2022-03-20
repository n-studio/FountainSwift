//
//  Font.swift
//  FountainSwift
//
//  Created by Matthew Nguyen on 3/19/22.
//

import Foundation

#if os(macOS)
import AppKit
typealias Font = NSFont
#else
import UIKit
typealias Font = UIFont
#endif
