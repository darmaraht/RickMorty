//
//  ViewController.swift
//  RickMorty
//
//  Created by Денис Королевский on 8/8/24.
//

import UIKit
import SnapKit
import RealmSwift

final class CharacterTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    private var characters: [CharacterModel] = []
    private var filteredCharacters: [CharacterModel] = []
    
    private var currentPage = 1
    private var hasMoreDataToLoad = true
    private var retries = 0
    
    private var isFiltering: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    private let realm = try! Realm()
    
    // MARK: Subviews
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = String(localized: "characterTitle")
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupSearchController()
        setupTableView()
        loadCharactersFromRealm()
        
        // Load initial data
        loadData()
    }
    
    
    // MARK: Setup UI
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: CharacterTableViewCell.reuseId)
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
        searchController.searchBar.placeholder = String(localized: "searchPlaceholder")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = CharacterDetailVC()
        let character = isFiltering ? filteredCharacters[indexPath.row] : characters[indexPath.row]
        detailVC.character = character
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return filteredCharacters.isEmpty ? 1 : 2
        } else {
            return hasMoreDataToLoad ? 2 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isFiltering ? filteredCharacters.count : characters.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CharacterTableViewCell.reuseId, for: indexPath) as? CharacterTableViewCell else {
                return UITableViewCell()
            }
            
            let character = isFiltering ? filteredCharacters[indexPath.row] : characters[indexPath.row]
            cell.setup(
                imageURL: character.image,
                nameText: character.name,
                speciesText: character.species
            )
            cell.selectionStyle = .none
            cell.contentView.layer.masksToBounds = false
            cell.contentView.layer.shadowColor = UIColor.black.cgColor
            cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.contentView.layer.shadowOpacity = 0.3
            cell.contentView.layer.shadowRadius = 4
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TableLoadCell.reuseId, for: indexPath) as? TableLoadCell else {
                return UITableViewCell()
            }
            cell.animate()
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && hasMoreDataToLoad {
            loadData()
        }
    }
    
    // MARK: Load data from API
    
    private func loadData() {
        ApiService.shared.makeRequest(
            type: CharacterModel.self,
            path: .character,
            page: currentPage,
            callBack: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.characters.append(contentsOf: response.results)
                    self.hasMoreDataToLoad = response.info.next != nil
                    self.currentPage += 1
                    self.saveCharactersToRealm(response.results)
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if self.retries < 3 {
                            self.loadData()
                            self.retries += 1
                        } else {
                            self.loadCharactersFromRealm()
                        }
                    }
                }
            }
        )
    }
    
    private func saveCharactersToRealm(_ characters: [CharacterModel]) {
        try! realm.write {
            realm.add(characters.map { $0.toRealmModel() }, update: .modified)
        }
    }
    
    private func loadCharactersFromRealm() {
        let realmCharacters = realm.objects(CharacterDBModel.self)
        characters = realmCharacters.map { $0.toModel() }
        tableView.reloadData()
    }
}

// MARK: - UISearchResultsUpdating
extension CharacterTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredCharacters = characters
            tableView.reloadData()
            return
        }
        
        filteredCharacters = characters.filter { character in
            character.name.lowercased().contains(searchText.lowercased()) ||
            character.species.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
}

