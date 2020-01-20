//
//  ViewController.swift
//  RubyFull
//
//  Created by takahashi kouichi on 2020/01/16.
//  Copyright © 2020 kouichi. All rights reserved.
//

import UIKit
import Combine
import IBAnimatable
import APIKit

class ViewController: UIViewController {
    
    
    ///
    @IBOutlet weak var titleLabel: UILabel!
    
    /// カードView
    @IBOutlet weak var cardView: AnimatableView!
    /// 入力テキストフィールド
    @IBOutlet weak var inputTextField: AnimatableTextField!
    /// 入力された文字列の表示ラベル
    @IBOutlet weak var inputStringLabel: UILabel!
    /// ひらがな変換後の文字列表示ラベル
    @IBOutlet weak var hiraganaLabel: UILabel!
    /// 結果表示View
    @IBOutlet weak var resultStackView: UIStackView!
    /// インジケーター
    @IBOutlet weak var inidicator: AnimatableActivityIndicatorView!
    /// 入力文字列の保存する変数
    private var inputString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Viewmの初期化
        self.view.backgroundColor = UIColor.mainColor
        self.resultStackView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.notificationObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // インジケーターの初期化
        self.inidicator.animationType = .ballSpinFadeLoader
        self.inidicator.stopAnimating()
        // アニメーション
        cardView.animate(.slideFade(way: .in, direction: .up), duration: 1, damping: 1, velocity: 2, force: 1)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    
    @IBAction func action(_ sender: Any) {
        // 文字列の入力を確定
        self.view.endEditing(true)
        self.inputString = self.inputTextField.text!
        
        // 入力された文字列のValidation
        let status = KanjiValidator.validate(inputString) { $0
            .isNotEmpty()
            .hasKanji()
        }
        
        switch status {
        case .valid: //
            let request = HiraganaRequest(inputString: inputString)
            self.inidicator.startAnimating()
            Session.send(request) { result in
                switch result {
                case .success(let response):
                    self.displaySuccess(hiragana: response.hiragana)
                    self.inidicator.stopAnimating()
                case .failure:
                    self.inidicator.stopAnimating()
                }
            }
        case .invalid(.hasNotKanji): // 漢字を含んでいなかったら
            self.displayError(errorTitle: InvalidID.hasNotKanji.errorTitle)
        case .invalid(.empty): // 文字列が空だったら
            self.displayError(errorTitle: InvalidID.empty.errorTitle)
        }
    }
    
    // MARK: - DisplayResult
    
    /// 変換後のひらがなを表示する
    /// - Parameter response: 変換後のひらがな
    private func displaySuccess(hiragana: String){
        self.titleLabel.text = "入力された文字にルビを振ります"
        self.titleLabel.textColor = .label
        // 変換後の文字列を表示する
        self.resultStackView.isHidden = false
        self.inputStringLabel.text = inputTextField.text
        self.hiraganaLabel.text = hiragana
    }
    
    private func displayError(errorTitle: String){
        // エラーを表示する
        self.resultStackView.isHidden = true
        self.titleLabel.text = errorTitle
        self.titleLabel.textColor = .red
        inputTextField.animate(.shake(repeatCount: 1))
    }
    
    // MARK: - Notification
    
    /// Notification発行
    private func notificationObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                 name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                 name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// キーボード表示時に画面をずらす
    @objc func keyboardWillShow(_ notification: Notification?) {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: -(self.cardView.frame.height / 2))
            self.cardView.transform = transform
        }
    }
    
    /// キーボード終了時に画面を戻す
    @objc func keyboardWillHide(_ notification: Notification?) {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.cardView.transform = CGAffineTransform.identity
        }
    }
}
