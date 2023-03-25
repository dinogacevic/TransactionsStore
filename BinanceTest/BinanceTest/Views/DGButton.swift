//
//  DGButton.swift
//  BinanceTest
//
//  Created by Dino Gacevic on 21/03/2023.
//

import Combine
import UIKit

enum DGButtonAction {
    case set
    case get
    case delete
    case count
    case begin
    case commit
    case rollback
    case go
    
    var title: String {
        switch self {
        case .set:
            return "SET"
        case .get:
            return "GET"
        case .delete:
            return "DELETE"
        case .count:
            return "COUNT"
        case .begin:
            return "BEGIN"
        case .commit:
            return "COMMIT"
        case .rollback:
            return "ROLLBACK"
        case .go:
            return "GO"
        }
    }
}

struct ButtonViewModel {
    var buttonType: DGButtonAction
}

protocol DGButtonConfiguration {
    var textColor: UIColor { get set }
    var backgroundColor: UIColor { get set }
}

struct ActionButtonConfiguration: DGButtonConfiguration {
    var textColor: UIColor = .black
    var backgroundColor: UIColor = .lightGray
}

struct GoButtonConfiguration: DGButtonConfiguration {
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .systemGreen
}

class DGButton: UIButton {
    private let actionSubject = PassthroughSubject<DGButtonAction, Never>()
    var actionPublisher: AnyPublisher<DGButtonAction, Never> {
        actionSubject.eraseToAnyPublisher()
    }
    
    var dgButtonType: DGButtonAction = .get
    
    required override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        layer.cornerRadius = CornerRadius.standard.rawValue
        addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        configure(with: ActionButtonConfiguration())
    }
    
    func setup(with model: ButtonViewModel) {
        dgButtonType = model.buttonType
        setTitle(model.buttonType.title, for: .normal)
    }
    
    func configure(with config: DGButtonConfiguration) {
        setTitleColor(config.textColor, for: .normal)
        backgroundColor = config.backgroundColor
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        actionSubject.send(dgButtonType)
    }
}
