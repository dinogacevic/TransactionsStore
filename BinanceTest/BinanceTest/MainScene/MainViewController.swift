//
//  MainViewController.swift
//  BinanceTest
//
//  Created by Dino Gacevic on 21/03/2023.
//

import Combine
import SnapKit
import UIKit

class MainViewController: UIViewController, UIActionSheetDelegate, Transactionable {
    
    private var observers: [AnyCancellable] = []
    var dataSource: MainDataSource?
    
    var transaction: [String : String] = [:]
    var tempTransactions: [[String : String]] = []
    
    var action = DGButtonAction.get {
        didSet {
            updateSubviews()
        }
    }
    
    private lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        let zeroView = UIView(frame: .init(origin: .zero, size: .init(width: 0, height: CGFloat.leastNonzeroMagnitude)))
        tableView.tableHeaderView = zeroView
        tableView.tableFooterView = zeroView
        
        tableView.estimatedSectionHeaderHeight = CGFloat.leastNormalMagnitude
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.estimatedSectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.sectionFooterHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = .clear
        tableView.layer.borderWidth = BorderSize.standard.rawValue
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.cornerRadius = CornerRadius.large.rawValue
        
        tableView.register(ActionTextCell.self, forCellReuseIdentifier: ActionTextCell.cellId)
        tableView.register(TextCell.self, forCellReuseIdentifier: TextCell.cellId)
        
        return tableView
    }()
    
    private lazy var verticalContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Margins.small.rawValue
        return stack
    }()
    
    private lazy var actionButton: DGButton = {
        let button = DGButton()
        button.setup(with: .init(buttonType: action))
        button.actionPublisher.sink { [weak self] buttonType in
            self?.didTapActionButton()
        }.store(in: &observers)
        return button
    }()
    
    private lazy var goButton: DGButton = {
        let button = DGButton()
        button.setup(with: .init(buttonType: .go))
        button.configure(with: GoButtonConfiguration())
        button.actionPublisher.sink { [weak self] buttonType in
            self?.didTapGoButton()
        }.store(in: &observers)
        return button
    }()
    
    private lazy var textFieldStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = Margins.standard.rawValue
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var keyTextField: DGTextField = {
        let textField = DGTextField()
        textField.textFieldType = .key
        textField.textFieldPublisher.sink { [weak self] response in
            self?.handleTextFieldResponse(response: response)
        }.store(in: &observers)
        return textField
    }()

    private lazy var valueTextField: DGTextField = {
        let textField = DGTextField()
        textField.textFieldType = .value
        textField.textFieldPublisher.sink { [weak self] response in
            self?.handleTextFieldResponse(response: response)
        }.store(in: &observers)
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = MainDataSource()
        setupSubviews()
    }

    private func setupSubviews() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(verticalContainer)
        verticalContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Margins.standard.rawValue)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        verticalContainer.addArrangedSubview(textFieldStack)
        verticalContainer.addArrangedSubview(actionButton)
        verticalContainer.addArrangedSubview(goButton)
        
        textFieldStack.addArrangedSubview(keyTextField)
        textFieldStack.addArrangedSubview(valueTextField)
        valueTextField.isHidden = true
        
        textFieldStack.snp.makeConstraints { make in
            make.height.equalTo(ViewSize.standard.rawValue)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(Margins.standard.rawValue)
            make.bottom.equalTo(verticalContainer.snp.top).offset(-Margins.standard.rawValue)
        }
    }
    
    private func updateSubviews() {
        actionButton.setTitle(action.title, for: .normal)
        switch action {
        case .begin, .commit, .rollback:
            self.textFieldStack.isHidden = true
            
        case .get, .delete:
            self.keyTextField.isHidden = false
            self.valueTextField.isHidden = true
            self.textFieldStack.isHidden = false
            
        case .set:
            self.keyTextField.isHidden = false
            self.valueTextField.isHidden = false
            self.textFieldStack.isHidden = false
            
        case .count:
            self.keyTextField.isHidden = true
            self.valueTextField.isHidden = false
            self.textFieldStack.isHidden = false
            
        case .go:
            break
        }
        
        view.layoutIfNeeded()
        verticalContainer.layoutIfNeeded()
        tableView.layoutIfNeeded()
    }
    
    private func handleTextFieldResponse(response: DGTextFieldPassthroughSubject) {
        switch response.textFieldType {
        case .key:
            dataSource?.currentKey = response.text
            
        case .value:
            dataSource?.currentValue = response.text
        }
    }
    
    private func didTapActionButton() {
        let selectActionController = SelectActionBottomSheet()
        selectActionController.actionPublisher.sink { [weak self] action in
            self?.action = action
            self?.keyTextField.text = nil
            self?.valueTextField.text = nil
        }.store(in: &observers)
        present(selectActionController, animated: true)
    }
    
    private func didTapGoButton() {
        switch action {
        case .get:
            onGetTapped()
            
        case .set:
            onSetTapped()
            
        case .delete:
            onDeleteTapped()
            
        case .count:
            onCountTapped()
            
        case .begin:
            onBeginTapped()
            
        case .commit:
            onCommitTapped()
            
        case .rollback:
            onRollbackTapped()
            
        case .go:
            break
        }
        
        resetValues()
    }
    
    private func onGetTapped() {
        guard let key = dataSource?.currentKey else { return }
        
        let actionResponse = get(key: key)
        switch actionResponse {
        case .success(let value):
            dataSource?.tableViewData.append(ActionTextCellViewModel(action: .get, key: key, value: nil))
            dataSource?.tableViewData.append(TextCellViewModel(value: value))
            
        case .failure(let error):
            dataSource?.tableViewData.append(TextCellViewModel(value: error.description))
        }
        
        tableView.reloadData()
    }
    
    private func onSetTapped() {
        guard let key = dataSource?.currentKey, let value = dataSource?.currentValue else { return }
        
        set(key: key, value: value)
        
        dataSource?.tableViewData.append(ActionTextCellViewModel(action: .set, key: key, value: value))
        tableView.reloadData()
    }
    
    private func onDeleteTapped() {
        guard let key = dataSource?.currentKey else { return }
        
        delete(key: key)
        
        dataSource?.tableViewData.append(ActionTextCellViewModel(action: .delete, key: key, value: nil))
        tableView.reloadData()
    }
    
    private func onCountTapped() {
        guard let value = dataSource?.currentValue else { return }
        
        let keysCount = count(value: value)
        
        valueTextField.text = nil
        
        dataSource?.tableViewData.append(ActionTextCellViewModel(action: .count, key: nil, value: value))
        dataSource?.tableViewData.append(TextCellViewModel(value: "\(keysCount)"))
        return
    }
    
    private func onBeginTapped() {
        begin()
        
        dataSource?.tableViewData.append(ActionTextCellViewModel(action: .begin, key: nil, value: nil))
        tableView.reloadData()
    }
    
    private func onCommitTapped() {
        let commitResult = commit()
        switch commitResult {
        case .success:
            dataSource?.tableViewData.append(ActionTextCellViewModel(action: .commit, key: nil, value: nil))
            
        case .failure(let error):
            dataSource?.tableViewData.append(ActionTextCellViewModel(action: .commit, key: nil, value: nil))
            dataSource?.tableViewData.append(TextCellViewModel(value: error.description))
        }
        
        tableView.reloadData()
    }
    
    private func onRollbackTapped() {
        let rollbackResult = rollback()
        switch rollbackResult {
        case .success:
            dataSource?.tableViewData.append(ActionTextCellViewModel(action: .rollback, key: nil, value: nil))
            
        case .failure(let error):
            dataSource?.tableViewData.append(ActionTextCellViewModel(action: .rollback, key: nil, value: nil))
            dataSource?.tableViewData.append(TextCellViewModel(value: error.description))
        }
        
        tableView.reloadData()
    }
    
    private func resetValues() {
        dataSource?.currentKey = nil
        dataSource?.currentValue = nil
        keyTextField.text = nil
        valueTextField.text = nil
    }
}
