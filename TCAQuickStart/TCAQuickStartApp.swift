//
//  TCAQuickStartApp.swift
//  TCAQuickStart
//
//  Created by Javier Etxarri on 14/6/23.
//

import ComposableArchitecture
import SwiftUI

@main
struct TCAQuickStartApp: App {
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            CounterFeatureView(
                store: TCAQuickStartApp.store
            )
        }
    }
}
