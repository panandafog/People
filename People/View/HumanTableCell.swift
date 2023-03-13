//
//  HumanTableCell.swift
//  People
//
//  Created by Andrey on 09.03.2023.
//

import Combine
import SnapKit
import UIKit

class HumanTableCell: UITableViewCell {
    
    let humanView = HumanView(viewModel: nil)
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.layoutMargins = .zero
        contentView.addSubview(humanView)
        
        humanView.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    func setup(viewModel: HumanViewModel) {
        humanView.setup(viewModel: viewModel)
    }
}
