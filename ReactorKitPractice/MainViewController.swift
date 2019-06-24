//
//  ViewController.swift
//  ReactorKitPractice
//
//  Created by richard oh on 2019/06/24.
//  Copyright © 2019 richard oh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import RxViewController

final class MainViewController: UIViewController, ReactorKit.View {
    
    typealias Reactor = MainReactor
    var disposeBag = DisposeBag()
    
    private let questionLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.textAlignment = .center
        lb.layer.borderColor = UIColor.black.cgColor
        lb.layer.borderWidth = 3.0
        lb.font = UIFont.systemFont(ofSize: 30)
        return lb
    }()
    
    private let answerField: UITextField = {
        let lb = UITextField()
        lb.textColor = .black
        lb.textAlignment = .center
        lb.layer.borderColor = UIColor.black.cgColor
        lb.layer.borderWidth = 3.0
        lb.font = UIFont.systemFont(ofSize: 30)
        return lb
    }()
    
    private let button: UIButton = {
        let btn = UIButton()
        btn.setTitle("정답확인", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        btn.layer.borderWidth = 3.0
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()
    
    private let answerCheck: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 30)
        return lb
    }()
    
    init(reactor: Reactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        view.backgroundColor = .white
        udpateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func bind(reactor: MainReactor) {
    
        // Input
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.quizStarted }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        button.rx.controlEvent(UIControlEvents.touchUpInside)
            .map { [weak self] in
                self?.answerField.resignFirstResponder()
                if self?.answerField.text?.isEmpty != true {
                    return Reactor.Action.userDidEnterAnswer(self?.answerField.text)
                } else {
                    return Reactor.Action.userDidEnterAnswerWithoutText
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Output
        reactor.state
            .map { $0.quizString }
            .bind(to: questionLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isCorrectAnswer }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isCorrect in
                print(isCorrect)
                if isCorrect == true {
                   self?.answerCheck.text = "정답"
                } else {
                   self?.answerCheck.text = "오답"
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.answerIsEmtpy }
            .subscribe(onNext: { [weak self] answerIsEmpty in
                print(answerIsEmpty)
                if answerIsEmpty == true {
                    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                    let alertVC = UIAlertController(title: "입력내용없음", message: "입력된 답이 없습니다", preferredStyle: .alert)
                    alertVC.addAction(action)
                    self?.present(alertVC, animated: true , completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }

    private func udpateLayout() {
        
        view.addSubview(questionLabel)
        view.addSubview(answerField)
        view.addSubview(button)
        view.addSubview(answerCheck)
        
        questionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.width.equalToSuperview().offset(-20)
            make.height.equalTo(55)
        }
        
        answerField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(questionLabel.snp.bottom).offset(10)
            make.width.equalToSuperview().offset(-20)
            make.height.equalTo(55)
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(answerField.snp.bottom).offset(20)
            make.width.equalToSuperview().offset(-20)
            make.height.equalTo(55)
        }
        
        answerCheck.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(button.snp.bottom).offset(20)
            make.width.equalToSuperview().offset(-20)
            make.height.equalTo(55)
        }
    }
}

