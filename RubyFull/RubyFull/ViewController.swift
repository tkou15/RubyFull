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
    
    @IBOutlet weak var cardView: AnimatableView!
    @IBOutlet weak var inputTextField: AnimatableTextField!
    @IBOutlet weak var inputStringLabel: UILabel!
    @IBOutlet weak var hiraganaLabel: UILabel!
    @IBOutlet weak var resultStackView: UIStackView!
    
    var alertController: UIAlertController!
    
    private var inputString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.mainColor
        self.resultStackView.isHidden = true
        
        cardView.animate(.slideFade(way: .in, direction: .up), duration: 1, damping: 1, velocity: 2, force: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.notificationObserver()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
            Session.send(request) { result in
                switch result {
                case .success(let response):
                    self.displaySuccess(hiragana: response.hiragana)
                case .failure(let error):
                    print(error)
                }
            }
        case .invalid(.hasNotKanji): // 漢字を含んでいなかったら
            self.displayAlert(errorTitle: InvalidID.hasNotKanji.alertTitle)
        case .invalid(.empty): // 文字列が空だったら
            self.displayAlert(errorTitle: InvalidID.empty.alertTitle)
        }
    }
    
    // MARK: - DisplayResult
    
    /// 変換後のひらがなを表示する
    /// - Parameter response: 変換後のひらがな
    private func displaySuccess(hiragana: String){
        // 変換後の文字列を表示する
        self.resultStackView.isHidden = false
        self.inputStringLabel.text = inputTextField.text
        self.hiraganaLabel.text = hiragana
    }
    
    private func displayAlert(errorTitle: String){
        self.resultStackView.isHidden = true
        
        alertController = UIAlertController(title: errorTitle, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
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
            self.view.transform = transform
        }
    }
    
    /// キーボード終了時に画面を戻す
    @objc func keyboardWillHide(_ notification: Notification?) {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform.identity
        }
    }
}
