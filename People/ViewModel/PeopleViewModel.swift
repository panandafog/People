//
//  PeopleViewModel.swift
//  People
//
//  Created by Andrey on 09.03.2023.
//

import Combine
import DeepDiff
import Swinject

// MARK: - PeopleViewModelDelegate
protocol PeopleViewModelDelegate: LocationServiceDelegate {
    var searchQuery: String? { get }
    
    func reload(changes: [Change<HumanViewModel>], updateData: @escaping () -> Void)
    func reloadVisible()
}

class PeopleViewModel {
    
    // MARK: Published properties
    
    @Published private (set) var loadingNextPage = false
    
    @Published private (set) var highlightedHumanViewModel: HumanViewModel?
    @Published private (set) var tableHumanViewModels: [HumanViewModel] = []
    @Published private (set) var humanViewModelsChanges: [Change<HumanViewModel>] = []
    @Published var refreshingCells = false
    @Published var backgroundState: BackgroundState = .common
    
    // MARK: Other properties
    
    private let peopleService: PeopleService
    private let locationService: LocationService
    
    private weak var delegate: PeopleViewModelDelegate?
    
    private var allHumanViewModels: [HumanViewModel] = []
    private var loadedPeoplePage: PeoplePage?
    private var nextPageExists = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(delegate: PeopleViewModelDelegate, container: Container = .defaultContainer) {
        self.delegate = delegate
        peopleService = container.resolve(PeopleService.self)!
        locationService = container.resolve(LocationService.self)!
    }
    
    // MARK: - Update data methods
    
    func refreshPeople() {
        if let searchQuery = delegate?.searchQuery {
            // show search
            if searchQuery.isEmpty {
                cancellables = []
                loadedPeoplePage = nil
                handleSearchResults([], searchIsStarting: true)
                backgroundState = .typeToSearch
            } else {
                peopleService.searchPeople(query: searchQuery) { [weak self] people in
                    self?.handleSearchResults(people)
                }
            }
        } else {
            // show people
            setNewPageToLoad(offset: 0, count: peopleService.maxPageCount)
        }
    }
    
    func loadPeople(center: Int? = nil) {
        let count = peopleService.maxPageCount
        let offset: Int
        if let center = center {
            offset = center - (count / 3)
        } else {
            guard nextPageExists else { return }
            offset = tableHumanViewModels.count
        }
        
        setNewPageToLoad(offset: offset, count: count)
    }
    
    private func setNewPageToLoad(offset: Int, count: Int) {
        let offset = max(offset, 0)
        guard offset != loadedPeoplePage?.offset else {
            return
        }
        cancellables = []
        
        loadedPeoplePage = peopleService.getPeople(
            offset: offset,
            count: count
        )
        loadedPeoplePage!.people.sink { [weak self] newPeople in
            self?.addNewPeopleToExisting(newPeople)
        }
        .store(in: &cancellables)
    }
    
    // MARK: Handling data updates
    
    private func addNewPeopleToExisting(_ newPeople: [HumanModel]) {
        nextPageExists = !newPeople.isEmpty
        for index in 0..<newPeople.count {
            if let existingIndex = allHumanViewModels.firstIndex(where: { $0.human == newPeople[index] }) {
                allHumanViewModels[existingIndex].human = newPeople[index]
            } else {
                allHumanViewModels.append(
                    HumanViewModel(human: newPeople[index], delegate: self)
                )
            }
        }
        updateTableHumanViewModels()
    }
    
    private func handleSearchResults(_ people: [HumanModel], searchIsStarting: Bool = false) {
        let newHumanViewModels = people.map { HumanViewModel(human: $0, delegate: self) }
        refreshingCells = false
        updateTableHumanViewModels(newHumanViewModels: newHumanViewModels)
        if searchIsStarting {
            backgroundState = .noResults
        } else {
            backgroundState = people.isEmpty ? .noResults : .common
        }
    }
    
    // MARK: Location methods
    
    func startUpdatingLocation() {
        guard let delegate = delegate else { return }
        locationService.startUpdatingLocation(delegate: delegate)
    }
    
    func stopUpdatingLocation() {
        locationService.stopUpdatingLocation()
    }
    
    // MARK: Human selection methods
    
    func handleHumanSelection(index: Int) {
        guard index >= 0 && index < tableHumanViewModels.count else {
            handleHumanDeselection()
            return
        }
        highlightedHumanViewModel?.isHighlighted = false
        highlightedHumanViewModel = tableHumanViewModels[index]
        highlightedHumanViewModel?.isHighlighted = true
        updateTableHumanViewModels()
    }
    
    func handleHumanDeselection() {
        highlightedHumanViewModel?.isHighlighted = false
        highlightedHumanViewModel = nil
        updateTableHumanViewModels()
    }
    
    private func updateTableHumanViewModels(newHumanViewModels: [HumanViewModel]? = nil) {
        let newHumanViewModels: [HumanViewModel] = newHumanViewModels ?? allHumanViewModels.filter {
            !$0.isHighlighted
        }
        humanViewModelsChanges = diff(old: tableHumanViewModels, new: newHumanViewModels)
        delegate?.reload(changes: humanViewModelsChanges) { self.tableHumanViewModels = newHumanViewModels }
    }
}

// MARK: - HumanViewModelDelegate
extension PeopleViewModel: HumanViewModelDelegate {
    var highlightedHumanPuplisher: Published<HumanViewModel?>.Publisher {
        $highlightedHumanViewModel
    }
    
    func removeHighlightedHuman() {
        handleHumanDeselection()
    }
}

extension PeopleViewModel {
    // MARK: - BackgroundState
    enum BackgroundState {
        case common
        case noResults
        case typeToSearch
    }
}
