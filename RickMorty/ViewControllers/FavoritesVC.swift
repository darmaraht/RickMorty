//
//  FavoritesVC.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import SDWebImage
import RealmSwift

class FavoritesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Subviews
    
    private let tableView = UITableView()
    private var emptyLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: FavoriteSegment.allCases.map { $0.title })
    
    // MARK: Properties
    
    private let realm = try! Realm()
    private var favoriteCharacters: Results<CharacterDBModel>?
    private var favoriteLocations: Results<LocationDBModel>?
    private var favoriteEpisodes: Results<EpisodeDBModel>?
    private var selectedSegment: FavoriteSegment = .characters {
        didSet {
            loadFavorites()
        }
    }
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSegmentedControl()
        setupTableView()
        setupEmptyLabel()
        loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
        tableView.reloadData()
    }
    
    // MARK: Setup UI
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: CharacterTableViewCell.reuseId)
        tableView.register(EpisodeTableViewCell.self, forCellReuseIdentifier: EpisodeTableViewCell.reuseId)
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.reuseId)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupEmptyLabel() {
        emptyLabel.textColor = .lightGray
        emptyLabel.font = .boldSystemFont(ofSize: 32)
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(10)
        }
    }
    
    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.right.equalToSuperview().inset(10)
        }
        segmentedControl.selectedSegmentIndex = selectedSegment.rawValue
        segmentedControl.selectedSegmentTintColor = .systemGray4
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        if let newSegment = FavoriteSegment(rawValue: sender.selectedSegmentIndex) {
            selectedSegment = newSegment
        }
    }
    
    // MARK: Private methods
    
    private func loadFavorites() {
        switch selectedSegment {
        case .characters:
            favoriteCharacters = realm.objects(CharacterDBModel.self).filter("isFavorite == true")
        case .locations:
            favoriteLocations = realm.objects(LocationDBModel.self).filter("isFavorite == true")
        case .episodes:
            favoriteEpisodes = realm.objects(EpisodeDBModel.self).filter("isFavorite == true")
        }
        updateEmptyLabelVisibility() // Обновляю emptyLabel после загрузки данных.
        tableView.reloadData()
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        try! realm.write {
            switch selectedSegment {
            case .characters:
                if let characterToDelete = favoriteCharacters?[indexPath.row - 1] {
                    characterToDelete.isFavorite = false
                }
            case .locations:
                if let locationToDelete = favoriteLocations?[indexPath.row - 1] {
                    locationToDelete.isFavorite = false
                }
            case .episodes:
                if let episodeToDelete = favoriteEpisodes?[indexPath.row - 1] {
                    episodeToDelete.isFavorite = false
                }
            }
        }
        loadFavorites()
    }
    
    private func getCountText() -> String {
        let count: Int
        let itemType: String
        switch selectedSegment {
        case .characters:
            count = favoriteCharacters?.count ?? 0
            itemType = String(format: NSLocalizedString("countCharacters", comment: ""), count)
        case .locations:
            count = favoriteLocations?.count ?? 0
            itemType = String(format: NSLocalizedString("countLocations", comment: ""), count)
        case .episodes:
            count = favoriteEpisodes?.count ?? 0
            itemType = String(format: NSLocalizedString("countEpisodes", comment: ""), count)
        }
        
        return "\(itemType)"
    }
    
    private func updateEmptyLabelVisibility() {
        var isFavoritesEmpty = false
        switch selectedSegment {
        case .characters:
            isFavoritesEmpty = favoriteCharacters?.isEmpty ?? true
        case .locations:
            isFavoritesEmpty = favoriteLocations?.isEmpty ?? true
        case .episodes:
            isFavoritesEmpty = favoriteEpisodes?.isEmpty ?? true
        }
        emptyLabel.text = selectedSegment.emptyMessage
        emptyLabel.isHidden = !isFavoritesEmpty
    }
    
    // MARK: UITableViewDataSourse
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count: Int
        switch selectedSegment {
        case .characters:
            count = favoriteCharacters?.count ?? 0
        case .locations:
            count = favoriteLocations?.count ?? 0
        case .episodes:
            count = favoriteEpisodes?.count ?? 0
        }
        return count > 0 ? count + 1 : count // Добавляем 1 для ячейки с количеством элементов, если count > 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "countCell")
            cell.textLabel?.text = getCountText()
            cell.selectionStyle = .none
            return cell
        } else {
            switch selectedSegment {
            case .characters:
                let cell = tableView.dequeueReusableCell(withIdentifier: CharacterTableViewCell.reuseId, for: indexPath) as!
                CharacterTableViewCell
                if let character = favoriteCharacters?[indexPath.row - 1] {
                    cell.setup(imageURL: character.image, nameText: character.name, speciesText: character.species)
                }
                cell.selectionStyle = .none
                return cell
            case .locations:
                let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseId, for: indexPath) as!
                LocationTableViewCell
                if let location = favoriteLocations?[indexPath.row - 1] {
                    cell.setup(locationText: location.name, isFavorite: true)
                }
                cell.selectionStyle = .none
                return cell
            case .episodes:
                let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeTableViewCell.reuseId, for: indexPath) as!
                EpisodeTableViewCell
                if let episod = favoriteEpisodes?[indexPath.row - 1] {
                    cell.setup(episodeText: episod.name, isFavorite: true)
                }
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row != 0 else { return nil } // Запрет на свайп действия для ячейки с количеством
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in guard let self = self else { return }
            
            let allertController = UIAlertController(title: String(localized: "deleteFromFavorites"), message: nil, preferredStyle: .alert)
            let confirmDeleteAction = UIAlertAction(title: String(localized: "yes"), style: .destructive) { _ in
                self.deleteItem(at: indexPath)
                completionHandler(true)
                NotificationCenter.default.post(name: NSNotification.Name("FavoritesUpdated"), object: nil)
            }
            let cancelAction = UIAlertAction(title: String(localized: "cancel"), style: .cancel) { _ in
                completionHandler(false)
            }
            
            allertController.addAction(confirmDeleteAction)
            allertController.addAction(cancelAction)
            
            self.present(allertController, animated: true, completion: nil)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}
