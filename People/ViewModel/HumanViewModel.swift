//
//  HumanViewModel.swift
//  People
//
//  Created by Andrey on 10.03.2023.
//

import Combine
import CoreLocation
import DeepDiff
import Swinject

// MARK: - HumanViewModelDelegate
protocol HumanViewModelDelegate: AnyObject {
    var highlightedHumanPuplisher: Published<HumanViewModel?>.Publisher { get }
    var highlightedHumanViewModel: HumanViewModel? { get }
    
    func removeHighlightedHuman()
}

class HumanViewModel {
    
    // MARK: Published properties
    
    @Published var distance: Distance
    @Published var avatar: UIImage?
    
    // MARK: Other properties
    
    private let locationService: LocationService
    private let imageService: ImageService
    private weak var delegate: HumanViewModelDelegate?
    
    var human: HumanModel {
        didSet {
            calculateDistance()
        }
    }
    
    var isHighlighted = false {
        didSet {
            calculateDistance()
        }
    }
    var removesHighlight: Bool { isHighlighted }
    var hasTapAction: Bool { isHighlighted }
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(
        human: HumanModel,
        delegate: HumanViewModelDelegate,
        container: Container = .defaultContainer
    ) {
        self.human = human
        self.delegate = delegate
        self.distance = .unknown
        
        locationService = container.resolve(LocationService.self)!
        imageService = container.resolve(ImageService.self)!
        setupBindings()
    }
    
    // MARK: Setting up methods
    
    private func setupBindings() {
        locationService.$location.sink { [weak self] _ in
            self?.calculateDistance()
        }
        .store(in: &cancellables)
        
        delegate?.highlightedHumanPuplisher.sink { [weak self] newValue in
            self?.calculateDistance(highlightedHumanViewModel: newValue)
        }
        .store(in: &cancellables)
    }
    
    // MARK: Calculating distance methods
    
    private func calculateDistance() {
        calculateDistance(highlightedHumanViewModel: delegate?.highlightedHumanViewModel)
    }
    
    private func calculateDistance(highlightedHumanViewModel: HumanViewModel?) {
        if isHighlighted || highlightedHumanViewModel == nil {
            if let userLocation = locationService.location {
                distance = .toUser(clLocationDistance: userLocation.distance(from: human.location))
            } else {
                distance = .unknown
            }
        } else if let highlightedHumanViewModel = highlightedHumanViewModel {
            distance = .toAnotherUser(
                user: highlightedHumanViewModel.human,
                clLocationDistance: highlightedHumanViewModel.human.location.distance(from: human.location)
            )
        } else {
            distance = .unknown
        }
    }
    
    // MARK: Other methods
    
    func handleTap() {
        guard removesHighlight else { return }
        delegate?.removeHighlightedHuman()
    }
    
    func updateAvatar() {
        imageService.getAvatar(url: human.avatarURL) { [weak self] avatar in
            self?.avatar = avatar
        }
    }
}

// MARK: - Distance
extension HumanViewModel {
    enum Distance {
        case unknown
        case toUser(clLocationDistance: CLLocationDistance)
        case toAnotherUser(user: HumanModel, clLocationDistance: CLLocationDistance)
    }
}

// MARK: - DiffAware
extension HumanViewModel: DiffAware {
    typealias DiffId = Int

    var diffId: DiffId {
        human.id
    }

    static func compareContent(_ lhs: HumanViewModel, _ rhs: HumanViewModel) -> Bool {
        lhs.human == rhs.human
    }
}
