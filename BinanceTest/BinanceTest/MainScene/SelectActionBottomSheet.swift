//
//  SelectActionBottomSheet.swift
//  BinanceTest
//
//  Created by Dino Gacevic on 23/03/2023.
//

import Combine
import UIKit

class SelectActionBottomSheet: UIAlertController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private let actionSubject = PassthroughSubject<DGButtonAction, Never>()
    var actionPublisher: AnyPublisher<DGButtonAction, Never> {
        actionSubject.eraseToAnyPublisher()
    }
    
    let buttonActions: [DGButtonAction] = [.get, .set, .delete, .count, .begin, .commit, .rollback]
    
    private func setup() {
        buttonActions.forEach { action in
            addAction(UIAlertAction(title: action.title, style: .default) { [weak self] _ in
                self?.actionSubject.send(action)
            })
        }
        
        addAction(UIAlertAction(title: "Cancel", style: .cancel))
    }
}
