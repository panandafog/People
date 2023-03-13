//
//  HeaderView.swift
//  People
//
//  Created by Andrey on 12.03.2023.
//

import SnapKit
import UIKit

class HeaderView: UIView {
    
    // MARK: Layout & styling properties
    
    private let titleTopOffset: CGFloat = 10
    private let titleBottomOffset: CGFloat = -10
    private let titleLeadingOffset: CGFloat = 30
    private let titleTrailingOffset: CGFloat = -30
    
    private let titleFont = UIFont.preferredFont(forTextStyle: .title3)
    
    // MARK: UI elements
    
    private let label = UILabel()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    convenience init(title: String?) {
        self.init(frame: CGRect.zero)
        addSubviews()
        setupConstraints()
        setupLabel(text: title)
        setupStyling()
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    
    private func addSubviews() {
        addSubview(label)
    }
    
    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(titleTopOffset)
        }
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(titleLeadingOffset)
            make.trailing.equalToSuperview().offset(titleTrailingOffset)
            make.bottom.equalToSuperview().offset(titleBottomOffset)
        }
    }
    
    // MARK: UI setup methods
    
    private func setupLabel(text: String?) {
        label.textAlignment = .center
        label.text = text
        label.font = titleFont
    }
    
    private func setupStyling() {
        backgroundColor = .systemBackground
    }
}
