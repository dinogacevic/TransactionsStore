//
//  TextCell.swift
//  BinanceTest
//
//  Created by Dino Gacevic on 25/03/2023.
//

import UIKit

struct TextCellViewModel: ViewModel {
    let value: String
}

class TextCell: UITableViewCell {
    static let cellId = "TextCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubiews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupSubiews()
    }
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private func setupSubiews() {
        backgroundColor = .clear
        
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(Margins.minimal.rawValue)
            make.horizontalEdges.equalToSuperview().inset(Margins.small.rawValue)
        }
    }
    
    func setup(with model: TextCellViewModel) {
        valueLabel.text = model.value
    }
}
