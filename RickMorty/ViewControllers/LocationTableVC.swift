//
//  LocationTableVC.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import RealmSwift

final class LocationTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    private var locations: [LocationModel] = []
    private var filteredLocations: [LocationModel] = []
    private let realm = try! Realm()
    private var currentPage = 1
    private var pageLoad = true
    
    private var isFiltering: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    // MARK: Subviews
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "locationTitle")
        view.backgroundColor = .systemBackground
        
        setupSearchController()
        setupTableView()
        
        loadData()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: Setup UI
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.reuseId)
        tableView.register(TableLoadCell.self, forCellReuseIdentifier: TableLoadCell.reuseId)
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 15)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = String(localized: "searchLocationPlaceholder")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        pageLoad ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return section == 0 ? filteredLocations.count : 1
        } else {
            return section == 0 ? locations.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseId, for: indexPath) as? LocationTableViewCell
            else {
                return UITableViewCell()
            }
            
            let location = isFiltering ? filteredLocations[indexPath.row] : locations[indexPath.row]
            let isFavorite = isLocationFavorite(location.id)
            
            cell.setup(locationText: location.name, isFavorite: isFavorite)
            cell.favoriteAction = { [weak self] in
                self?.toggleFavorite(location: location)
            }
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableLoadCell.reuseId, for: indexPath) as! TableLoadCell
            cell.animate()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if pageLoad {
                loadData()
            }
        }
    }
    
    // MARK: Load data from API
    
    func loadData() {
        ApiService.shared.makeRequest(
            type: LocationModel.self,
            path: .location,
            page: currentPage,
            callBack: { [weak self] result in
                switch result {
                case .success(let response):
                    self?.locations.append(contentsOf: response.results)
                    self?.pageLoad = response.info.next != nil
                    self?.currentPage += 1
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        )
    }
    
    // MARK: Private Methods

    private func toggleFavorite(location: LocationModel) {
        let feedBackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedBackGenerator.impactOccurred()
        
        if isLocationFavorite(location.id) {
            updateFavoriteStatus(locationID: location.id, isFavorite: false)
        } else {
            updateFavoriteStatus(locationID: location.id, isFavorite: true)
        }
        
        tableView.reloadData()
    }
    
    private func updateFavoriteStatus(locationID: Int, isFavorite: Bool) {
        if let realmLocation = realm.object(ofType: LocationDBModel.self, forPrimaryKey: locationID) {
            do {
                try realm.write {
                    realmLocation.isFavorite = isFavorite
                }
            } catch {
                print("Ошибка при обновлении статуса избранного в Realm: \(error)")
            }
        } else if isFavorite {
            // Если локация еще не существует в Realm и её нужно добавить в избранные
            if let location = locations.first(where: { $0.id == locationID }) {
                let realmLocation = LocationDBModel()
                realmLocation.id = location.id
                realmLocation.name = location.name
                realmLocation.type = location.type
                realmLocation.dimension = location.dimension
                realmLocation.residents.append(objectsIn: location.residents)
                realmLocation.url = location.url
                realmLocation.created = location.created
                realmLocation.isFavorite = isFavorite
                
                do {
                    try realm.write {
                        realm.add(realmLocation)
                    }
                } catch {
                    print("Ошибка при добавлении локации в Realm: \(error)")
                }
            }
        }
    }
    
    private func isLocationFavorite(_ locationID: Int) -> Bool {
        return realm.object(ofType: LocationDBModel.self, forPrimaryKey: locationID)?.isFavorite ?? false
    }
}

// MARK: - UISearchResultsUpdating

extension LocationTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredLocations = locations
            tableView.reloadData()
            return
        }
        
        filteredLocations = locations.filter { location in
            location.name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
}
