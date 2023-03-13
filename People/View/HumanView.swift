//
//  HumanView.swift
//  People
//
//  Created by Andrey on 10.03.2023.
//

import Combine
import MapKit
import SnapKit
import UIKit

class HumanView: UIView {
    
    // MARK: Layout & styling properties
    
    private let imageSize: CGFloat = 50
    private var imageTopOffset: CGFloat {
        (viewModel?.isHighlighted ?? false) ? 15 : 10
    }
    private var imageLeadingOffset: CGFloat {
        (viewModel?.isHighlighted ?? false) ? 15 : 0
    }
    private var imageBottomOffset: CGFloat {
        (viewModel?.isHighlighted ?? false) ? -15 : -10
    }
    private var nameLabelTopOffset: CGFloat {
        (viewModel?.isHighlighted ?? false) ? 15 : 10
    }
    private let nameLabelLeadingOffset: CGFloat = 10
    private let distanceLabelTopOffset: CGFloat = 5
    private let distanceLabelLeadingOffset: CGFloat = 13
    private var distanceLabelBottomOffset: CGFloat {
        (viewModel?.isHighlighted ?? false) ? -15 : -10
    }
    
    private let distanceText = "human.distance".localized
    
    private let nameLabelFont = UIFont.preferredFont(forTextStyle: .body)
    private let distanceLabelFont = UIFont.preferredFont(forTextStyle: .footnote)
    
    private let distanceFormatter: MKDistanceFormatter = {
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.unitStyle = .full
        return distanceFormatter
    }()
    
    // MARK: UI elements
    
    private let nameLabel = UILabel()
    private let distanceLabel = UILabel()
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let blurView: UIView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
    // MARK: Instance properties
    
    private var viewModel: HumanViewModel?
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    convenience init(viewModel: HumanViewModel?) {
        self.init(frame: CGRect.zero)
        self.viewModel = viewModel
        
        setup(viewModel: viewModel)
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
    }
    
    // MARK: UI setup methods
    
    private func addSubviews() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(distanceLabel)
    }
    
    private func setupConstraints() {
        layer.cornerRadius = (viewModel?.isHighlighted ?? false) ? 10 : 0
        layer.masksToBounds = true
        
        avatarImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(imageTopOffset)
            make.leading.equalToSuperview().offset(imageLeadingOffset)
            make.bottom.lessThanOrEqualToSuperview().offset(imageBottomOffset)
            make.height.equalTo(imageSize)
            make.width.equalTo(avatarImageView.snp.height)
        }
        
        nameLabel.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(nameLabelTopOffset)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(nameLabelLeadingOffset)
            make.trailing.equalToSuperview()
        }
        
        distanceLabel.snp.remakeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(distanceLabelTopOffset)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(distanceLabelLeadingOffset)
            make.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(distanceLabelBottomOffset)
        }
    }
    
    func setup(viewModel: HumanViewModel?) {
        self.viewModel = viewModel
        
        setupLabels()
        setupStyling()
        bindViewModel()
        setupConstraints()
        
        if viewModel?.hasTapAction ?? false {
            addGestureHandlers()
        }
        viewModel?.updateAvatar()
        
        if viewModel?.isHighlighted ?? false {
            addBlurView()
        }
    }
    
    private func bindViewModel() {
        cancellables = []
        viewModel?.$distance.sink { [weak self] newDistance in
            self?.updateDistance(new: newDistance)
        }
        .store(in: &cancellables)
        
        viewModel?.$avatar.sink { [weak self] newImage in
            self?.avatarImageView.image = newImage
        }
        .store(in: &cancellables)
    }
    
    private func setupStyling() {
        if viewModel?.isHighlighted ?? false {
            backgroundColor = .gray.withAlphaComponent(0.2)
        } else {
            backgroundColor = .clear
        }
        nameLabel.font = nameLabelFont
        distanceLabel.font = distanceLabelFont
    }
    
    private func setupLabels() {
        nameLabel.text = viewModel?.human.name
    }
    
    private func addBlurView() {
        addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sendSubviewToBack(blurView)
    }
    
    // MARK: Updating UI state
    
    private func updateDistance(new distance: HumanViewModel.Distance) {
        let distanceString: String
        var targetString: String?
        
        switch distance {
        case .unknown:
            distanceString = "unknown"
        case let .toUser(clLocationDistance):
            distanceString = distanceFormatter.string(
                fromDistance: clLocationDistance
            )
        case let .toAnotherUser(user, clLocationDistance):
            targetString = user.name
            distanceString = distanceFormatter.string(
                fromDistance: clLocationDistance
            )
        }
        
        distanceLabel.text = distanceText.localized
        + (targetString == nil ? "" : (" to " + targetString!))
        + ": " + distanceString
    }
    
    // MARK: Handling gestures
    
    private func addGestureHandlers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        viewModel?.handleTap()
    }
}
