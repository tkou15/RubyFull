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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: AnimatableView!
    @IBOutlet weak var inputTextField: AnimatableTextField!
    @IBOutlet weak var inputStringLabel: UILabel!
    @IBOutlet weak var hiraganaLabel: UILabel!
    @IBOutlet weak var resultStackView: UIStackView!
    @IBOutlet weak var inidicator: AnimatableActivityIndicatorView!
    
    var alertController: UIAlertController!
    
    private var inputString = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.view.backgroundColor = UIColor.mainColor
        self.resultStackView.isHidden = true
        
        // インジケーターのs初期化
        self.inidicator.animationType = .ballSpinFadeLoader
        self.inidicator.stopAnimating()
        
        cardView.animate(.slideFade(way: .in, direction: .up), duration: 1, damping: 1, velocity: 2, force: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.notificationObserver()
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
                case .failure(let error):
                    print(error)
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
