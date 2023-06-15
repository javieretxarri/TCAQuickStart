//
//  CounterFeature.swift
//  TCAQuickStart
//
//  Created by Javier Etxarri on 14/6/23.
//

import ComposableArchitecture
import SwiftUI

struct CounterFeature: ReducerProtocol {
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }

    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case factResponse(String)
        case toggleTimerButtonTapped
        case timerTick
    }

    enum CancelID { case timer }
    @Dependency(\.continuousClock) var clock
    @Dependency(\.numberFact) var numberFact

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .decrementButtonTapped:
            state.count = state.count == 0 ? 0 : state.count - 1
            state.fact = nil
            return .none

        case .incrementButtonTapped:
            state.count += 1
            state.fact = nil
            return .none

        case .factButtonTapped:
            state.fact = nil
            state.isLoading = true

            return .run { [count = state.count] send in
                try await send(.factResponse(self.numberFact.fetch(count)))

//                let (data, _) = try await URLSession.shared.data(from: URL(string: "http://numbersapi.com/\(count)")!)
//                let fact = String(decoding: data, as: UTF8.self)
//                await send(.factResponse(fact))
            }

        case let .factResponse(fact):
            state.fact = fact
            state.isLoading = false
            return .none

        case .timerTick:
            state.count += 1
            state.fact = nil
            return .none

        case .toggleTimerButtonTapped:
            state.isTimerRunning.toggle()
            if state.isTimerRunning {
                return .run { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
            } else {
                return .cancel(id: CancelID.timer)
            }
        }
    }
}

extension CounterFeature.Action: Equatable {}
