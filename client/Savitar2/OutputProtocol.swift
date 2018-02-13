//
//  OutputProtocol.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/13/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Foundation

// TODO: eventually may want to move this into its own module
enum Result<T, E> {
  case success(T)
  case error(E)
}

typealias OutputResult = Result<String, String>

protocol OutputProtocol {
    func output(result : OutputResult)
}
