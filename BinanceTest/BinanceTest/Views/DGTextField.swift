//
//  DGTextField.swift
//  BinanceTest
//
//  Created by Dino Gacevic on 22/03/2023.
//

import Combine
import UIKit

enum DGTextFieldType: String {
    case key, value
}

struct DGTextFieldPassthroughSubject {
    var textFieldType: DGTextFieldType
    var text: String
}

class DGTextField: UITextField {
    private let actionSubject = PassthroughSubject<DGTextFieldPassthroughSubject, Never>()
    var textFieldPublisher: AnyPublisher<DGTextFieldPassthroughSubject, Never> {
        actionSubject.eraseToAnyPublisher()
    }
    
    var textFieldType = DGTextFieldType.key {
        didSet {
            placeholder = textFieldType.rawValue
        }
    }
    
    required override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = CornerRadius.standard.rawValue
        layer.borderWidth = BorderSize.standard.rawValue
        layer.borderColor = UIColor.black.cgColor
        autocapitalizationType = .none
        
        textAlignment = .center
        autocorrectionType = .no
        
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        actionSubject.send(.init(textFieldType: textFieldType, text: text))
    }
}
