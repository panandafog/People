//
//  PeopleViewController.swift
//  People
//
//  Created by Andrey on 09.03.2023.
//

import Combine
import DeepDiff
import SnapKit
import UIKit

class PeopleViewController: UIViewController {
    
    // MARK: Layout & styling properties
    
    private static let highlightedHumanAnimationDuration = 0.3
    private static let headerTitle = "people.header.title".localized
    private static let searchBarPlaceholder = "people.search.placeholder".localized
    
    private let highlightedViewLeadingOffset: CGFloat = 10
    private let highlightedViewTrailingOffset: CGFloat = -10
    
    // MARK: UI elements
    
    private let tableView = UITableView()
    private lazy var headerView = HeaderView(title: Self.headerTitle)
    private let highlightedHumanView = HumanView(viewModel: nil)
    private let searchBar = UISearchBar()
    private let tableBackgroundLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Instance properties
    
    private var showsHighlightedHuman = false
    private var searchIsActive = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var viewModel = PeopleViewModel(delegate: self)
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setConstraints()
        setupStyling()
        setupSearch()
        setupTable()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.startUpdatingLocation()
        viewModel.refreshPeople()
    }
    
    // MARK: UI setup methods
    
    private func addSubviews() {
        view.addSubview(headerView)
        view.addSubview(searchBar)
        view.addSubview(tableView)
    }
    
    private func setConstraints() {
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupStyling() {
        navigationController?.isNavigationBarHidden = true
        
        tableView.separatorStyle = .none
    }
    
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(HumanTableCell.self, forCellReuseIdentifier: String(describing: HumanTableCell.self))
        tableView.backgroundView = tableBackgroundLabel
    }
    
    private func setupSearch() {
        searchBar.delegate = self
        searchBar.placeholder = Self.searchBarPlaceholder
    }
    
    // MARK: Binding view model
    
    private func bindViewModel() {
        viewModel.$highlightedHumanViewModel.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateHighlightedHumanView()
            }
        }
        .store(in: &cancellables)
        
        viewModel.$refreshingCells.sink { [weak self] refreshing in
            if !refreshing {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        .store(in: &cancellables)
        
        viewModel.$backgroundState.sink { [weak self] state in
            DispatchQueue.main.async {
                self?.handleNewBackgroundState(state)
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: HighlightedHumanView methods
    
    private func updateHighlightedHumanView() {
        if let highlightedHumanViewModel = viewModel.highlightedHumanViewModel {
            addHighlightedHumanView(viewModel: highlightedHumanViewModel)
        } else {
            removeHighlightedHumanView()
        }
    }
    
    private func addHighlightedHumanView(viewModel: HumanViewModel) {
        guard !showsHighlightedHuman else {
            highlightedHumanView.setup(viewModel: viewModel)
            return
        }
        
        view.addSubview(highlightedHumanView)
        setHighlightedHumanViewConstraints(viewIsHidden: true)
        view.bringSubviewToFront(headerView)
        view.bringSubviewToFront(searchBar)
        highlightedHumanView.setup(viewModel: viewModel)
        view.layoutIfNeeded()
        
        setHighlightedHumanViewConstraints(viewIsHidden: false)
        UIView.animate(withDuration: Self.highlightedHumanAnimationDuration) {
            self.highlightedHumanView.alpha = 1.0
            self.view.layoutIfNeeded()
        }
        
        addTopInsetToTableView()
        
        showsHighlightedHuman = true
    }
    
    private func removeHighlightedHumanView() {
        guard showsHighlightedHuman else {
            return
        }
        setHighlightedHumanViewConstraints(viewIsHidden: true)
        
        UIView.animate(withDuration: Self.highlightedHumanAnimationDuration) {
            self.highlightedHumanView.alpha = 0.0
            self.view.layoutIfNeeded()
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        showsHighlightedHuman = false
    }
    
    private func setHighlightedHumanViewConstraints(viewIsHidden: Bool) {
        highlightedHumanView.snp.removeConstraints()
        highlightedHumanView.snp.makeConstraints { make in
            if viewIsHidden {
                make.bottom.equalTo(searchBar.snp.bottom)
            } else {
                make.top.equalTo(searchBar.snp.bottom)
            }
            make.leading.equalToSuperview().offset(highlightedViewLeadingOffset)
            make.trailing.equalToSuperview().offset(highlightedViewTrailingOffset)
        }
    }
    
    // MARK: Other methods
    
    private func addTopInsetToTableView() {
        let topInset = highlightedHumanView.frame.height
        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        
        if tableView.contentOffset.y <= 0 {
            UIView.animate(withDuration: Self.highlightedHumanAnimationDuration) {
                self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentOffset.y - topInset), animated: false)
            }
        }
    }
    
    private func handleNewBackgroundState(_ newState: PeopleViewModel.BackgroundState) {
        tableBackgroundLabel.text = newState.text
    }
    
    @objc private func refresh(_ sender: AnyObject) {
        viewModel.refreshPeople()
    }
}

// MARK: - UITableViewDelegate
extension PeopleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        stopSearching()
        viewModel.handleHumanSelection(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !searchIsActive, let indexPath = tableView.indexPathForRow(at: tableView.bounds.center) else {
            return
        }
        viewModel.loadPeople(center: indexPath.row)
    }
}

// MARK: - UITableViewDataSource
extension PeopleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableHumanViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HumanTableCell.self), for: indexPath) as? HumanTableCell else {
            return UITableViewCell()
        }
        
        let index = indexPath.row
        if index >= 0 && index < viewModel.tableHumanViewModels.count {
            let cellViewModel = viewModel.tableHumanViewModels[index]
            cell.setup(viewModel: cellViewModel)
        }
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension PeopleViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchIsActive = true
        searchBar.showsCancelButton = true
        viewModel.refreshPeople()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.refreshPeople()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.refreshPeople()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        stopSearching()
        viewModel.refreshPeople()
    }
    
    private func stopSearching() {
        searchIsActive = false
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

// MARK: - PeopleViewModelDelegate
extension PeopleViewController: PeopleViewModelDelegate {
        
    var searchQuery: String? {
        if searchIsActive {
            return searchBar.text
        } else {
            return nil
        }
    }
    
    func reload(changes: [Change<HumanViewModel>], updateData: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.tableView.reload(changes: changes, updateData: updateData)
        }
    }
    
    func reloadVisible() {
        let paths = tableView.indexPathsForVisibleRows
        let visibleCells: NSMutableSet = []

        for path in paths! {
            visibleCells.add(tableView.cellForRow(at: path)!)
        }
        
        for index in tableView.indexPathsForVisibleRows ?? [] {
            let cell = tableView.cellForRow(at: index) as? HumanTableCell
            cell?.humanView.setup(viewModel: viewModel.tableHumanViewModels[index.row])
        }
    }
}

private extension PeopleViewModel.BackgroundState {
    
    // MARK: BackgroundState text
    var text: String? {
        switch self {
        case .common:
            return nil
        case .noResults:
            return "No results found"
        case .typeToSearch:
            return "Type to search"
        }
    }
}
