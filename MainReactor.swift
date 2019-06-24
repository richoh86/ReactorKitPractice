//
//  MainReactor.swift
//  ReactorKitPractice
//
//  Created by richard oh on 2019/06/24.
//  Copyright © 2019 richard oh. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

final class MainReactor: ReactorKit.Reactor {
    
    enum Action {
        case quizStarted
        case userDidEnterAnswer(String?)
        case userDidEnterAnswerWithoutText
        case none
    }
    
    enum Mutation {
        case prepareQuizString(Int)
        case prepareQuizAnswer(Int)
        case checkAnswer(Int)
        case checkAnswerText
        case none
    }
    
    struct State {
        var quizString = ""
        var answer: Int = 0
        var answerIsEmtpy = false
        var isCorrectAnswer = false
    }
    
    let initialState = MainReactor.State()
    
    func mutate(action: MainReactor.Action) -> Observable<MainReactor.Mutation> {
        
        switch action {
        case .quizStarted:
            let num: Int = Int.random(in: 1..<10)
            let answer: Int = num * num
            return Observable.concat([Observable.just(Mutation.prepareQuizString(num)),
                Observable.just(Mutation.prepareQuizAnswer(answer)),])
        case .userDidEnterAnswer(let inputText):
            guard let text = inputText, let inputInt = Int(text) else {
                return Observable.just(Mutation.none) }
            return Observable.just(Mutation.checkAnswer(inputInt))
        case .userDidEnterAnswerWithoutText:
            return Observable.just(Mutation.checkAnswerText)
        case .none:
            return Observable.just(Mutation.none)
        }
        
    }
    
    func reduce(state: MainReactor.State, mutation: MainReactor.Mutation) -> MainReactor.State {
        
        var state = state
        
        switch mutation {
        case .prepareQuizString(let num):
            state.quizString = String(num) + " X " + String(num) + "=??"
        case .prepareQuizAnswer(let num):
            state.answer = num
        case .checkAnswer(let inputAnswer):
            state.answerIsEmtpy = false
            if state.answer == inputAnswer {
                state.isCorrectAnswer = true
            }else {
                state.isCorrectAnswer = false
            }
        case .checkAnswerText:
            state.answerIsEmtpy = true
        case .none:
            break
        }
        return state
    }
}
