//
//  RepositoryListener.swift
//  JustSaveIt
//
//  Created by Kristiyan Butev on 26.04.21.
//

import Foundation

protocol RepositoryListener: class {
    // Alerts the listener that the repository changed.
    func onDidChange()
}

struct WeakRepositoryListener {
    weak var value: RepositoryListener?
}
