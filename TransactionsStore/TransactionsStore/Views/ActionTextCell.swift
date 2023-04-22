//
//  TextCell.swift
//  TransactionsStore
//
//  Created by Dino Gacevic on 21/03/2023.
//

import UIKit

protocol ViewModel {}

struct ActionTextCellViewModel: ViewModel {
    let action: TSButtonAction
    let key: String?
    let value: String?
}

class ActionTextCell: UITableViewCell {
    static let cellId = "ActionTextCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubiews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupSubiews()
    }
    
    private lazy var labelStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = Margins.small.rawValue
        return stack
    }()
    
    private lazy var insertLabel: UILabel = {
        let label = UILabel()
        label.text = ">"
        return label
    }()
    
    private lazy var actionLabel: UILabel = {
        return UILabel()
    }()
    
    private lazy var keyLabel: UILabel = {
        return UILabel()
    }()
    
    
    private lazy var valueLabel: UILabel = {
        return UILabel()
    }()
    
    private lazy var spacer: UIView = {
        return UIView()
    }()
    
    private func setupSubiews() {
        backgroundColor = .clear
        
        contentView.addSubview(labelStack)
        labelStack.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(Margins.minimal.rawValue)
            make.horizontalEdges.equalToSuperview().inset(Margins.small.rawValue)
        }
        
        labelStack.addArrangedSubview(insertLabel)
        labelStack.addArrangedSubview(actionLabel)
        labelStack.addArrangedSubview(keyLabel)
        labelStack.addArrangedSubview(valueLabel)
        labelStack.addArrangedSubview(spacer)
    }
    
    func setup(with model: ActionTextCellViewModel) {
        actionLabel.text = model.action.title
        
        keyLabel.text = model.key
        keyLabel.isHidden = model.key == nil
        
        valueLabel.text = model.value
        valueLabel.isHidden = model.value == nil
    }
}
