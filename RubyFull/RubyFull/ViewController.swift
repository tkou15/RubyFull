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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.mainColor
        self.resultStackView.isHidden = true
        
        cardView.animate(.slideFade(way: .in, direction: .up), duration: 2, damping: 1, velocity: 2, force: 1)
    }
    
    @IBAction func action(_ sender: Any) {
        
        guard let inputString = self.inputTextField.text else { return }
        let status = KanjiValidator.validate(inputString) { $0
            .isNotEmpty()
            .hasKanji()
        }
        
        switch status {
        case .valid:
            let request = HiraganaRequest(inputString: inputString)
            Session.send(request) { result in
                switch result {
                case .success(let response):
                    self.displaySuccess(response)
                case .failure(let error):
                    print(error)
                }
            }
        case .invalid(.hasNotKanji):
            self.displayAlert(errorTitle: InvalidID.hasNotKanji.alertTitle)
        case .invalid(.empty):
            self.displayAlert(errorTitle: InvalidID.empty.alertTitle)
        }
    }
    
    private func displaySuccess(_ response: HiraganaResponse){
        self.resultStackView.isHidden = false
        self.inputStringLabel.text = inputTextField.text
        self.hiraganaLabel.text = response.hiragana
    }
    
    private func displayAlert(errorTitle: String){
        alertController = UIAlertController(title: errorTitle,
                                   message: nil,
                                   preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                       style: .default,
                                       handler: nil))
        present(alertController, animated: true)
    }
}
