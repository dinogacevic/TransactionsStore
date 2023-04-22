//
//  TSButton.swift
//  TransactionsStore
//
//  Created by Dino Gacevic on 21/03/2023.
//

import Combine
import UIKit

enum TSButtonAction {
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

struct TSButtonViewModel {
    var buttonType: TSButtonAction
}

protocol TSButtonConfiguration {
    var textColor: UIColor { get set }
    var backgroundColor: UIColor { get set }
}

struct ActionButtonConfiguration: TSButtonConfiguration {
    var textColor: UIColor = .black
    var backgroundColor: UIColor = .lightGray
}

struct GoButtonConfiguration: TSButtonConfiguration {
    var textColor: UIColor = .white
    var backgroundColor: UIColor = .systemGreen
}

class TSButton: UIButton {
    private let actionSubject = PassthroughSubject<TSButtonAction, Never>()
    var actionPublisher: AnyPublisher<TSButtonAction, Never> {
        actionSubject.eraseToAnyPublisher()
    }
    
    var tsButtonType: TSButtonAction = .get
    
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
    
    func setup(with model: TSButtonViewModel) {
        tsButtonType = model.buttonType
        setTitle(model.buttonType.title, for: .normal)
    }
    
    func configure(with config: TSButtonConfiguration) {
        setTitleColor(config.textColor, for: .normal)
        backgroundColor = config.backgroundColor
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        actionSubject.send(tsButtonType)
    }
}
