//
//  EpisodeTableVC.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import RealmSwift

final class EpisodeTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    
    private var episodes: [EpisodeModel] = []
    private var filteredEpisodes: [EpisodeModel] = []
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
        title = String(localized: "episodeTitle")
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
        
        tableView.register(EpisodeTableViewCell.self, forCellReuseIdentifier: EpisodeTableViewCell.reuseId)
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
        searchController.searchBar.placeholder = String(localized: "searchEpisodPlaceholder")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: Load data from API
    
    func loadData() {
        ApiService.shared.makeRequest(
            type: EpisodeModel.self,
            path: .episode,
            page: currentPage,
            callBack: { [weak self] result in
                switch result {
                case .success(let response):
                    self?.episodes.append(contentsOf: response.results)
                    self?.pageLoad = response.info.next != nil
                    self?.currentPage += 1
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        )
    }
    
    // MARK: TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        pageLoad ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return section == 0 ? filteredEpisodes.count : 1
        } else {
            return section == 0 ? episodes.count : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeTableViewCell.reuseId, for: indexPath) as? EpisodeTableViewCell
            else {
                return UITableViewCell()
            }
            
            let episode = isFiltering ? filteredEpisodes[indexPath.row] : episodes[indexPath.row]
            let isFavorite = isEpisodeFavorite(episode.id)
            
            cell.setup(episodeText: episode.name, isFavorite: isFavorite)
            cell.favoriteAction = { [weak self] in
                self?.toggleFavorite(episode: episode)
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
        if indexPath.section == 1, pageLoad {
            loadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = EpisodeDetailVC(episode: episodes[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: Private Methods

    private func toggleFavorite(episode: EpisodeModel) {
        let feedBackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedBackGenerator.impactOccurred()
        
        if isEpisodeFavorite(episode.id) {
            updateFavoriteStatus(EpisodeID: episode.id, isFavorite: false)
        } else {
            updateFavoriteStatus(EpisodeID: episode.id, isFavorite: true)
        }
        
        tableView.reloadData()
    }
    
    private func updateFavoriteStatus(EpisodeID: Int, isFavorite: Bool) {
        if let realmEpisode = realm.object(ofType: EpisodeDBModel.self, forPrimaryKey: EpisodeID) {
            do {
                try realm.write {
                    realmEpisode.isFavorite = isFavorite
                }
            } catch {
                print("Ошибка при обновлении статуса избранного в Realm: \(error)")
            }
        } else if isFavorite {
            // Если локация еще не существует в Realm и её нужно добавить в избранные
            if let episode = episodes.first(where: { $0.id == EpisodeID }) {
                let realmEpisode = EpisodeDBModel()
                realmEpisode.id = episode.id
                realmEpisode.name = episode.name
                realmEpisode.airDate = episode.airDate
                realmEpisode.episode = episode.episode
                realmEpisode.characters.append(objectsIn: episode.characters)
                realmEpisode.url = episode.url
                realmEpisode.created = episode.created
                realmEpisode.isFavorite = isFavorite
                
                do {
                    try realm.write {
                        realm.add(realmEpisode)
                    }
                } catch {
                    print("Ошибка при добавлении эпизода в Realm: \(error)")
                }
            }
        }
    }
    
    private func isEpisodeFavorite(_ EpisodeID: Int) -> Bool {
        return realm.object(ofType: EpisodeDBModel.self, forPrimaryKey: EpisodeID)?.isFavorite ?? false
    }
}
  


// MARK: - UISearchResultsUpdating

extension EpisodeTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredEpisodes = episodes
            tableView.reloadData()
            return
        }
        
        filteredEpisodes = episodes.filter { episod in
            episod.name.lowercased().contains(searchText.lowercased()) ||
            episod.episode.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
}
