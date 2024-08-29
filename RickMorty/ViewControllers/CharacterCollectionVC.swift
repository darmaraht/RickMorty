//
//  CharacterCollectionVC.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import RealmSwift

final class CharacterCollectionVC: UIViewController {
    
    // MARK: Subviews
    
    private let searchController = UISearchController()
    private let collectionView: UICollectionView
    private let gridButton = UIBarButtonItem()
    
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
    
    private var isGridView = true
    private let numberOfColumnsInGrid = 2
    private let gridLayout: UICollectionViewFlowLayout
    private let listLayout: UICollectionViewFlowLayout
    
    // MARK: Init
    
    init() {
        gridLayout = UICollectionViewFlowLayout()
        gridLayout.sectionInset = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
        gridLayout.minimumLineSpacing = 16
        gridLayout.minimumInteritemSpacing = 16
        
        listLayout = UICollectionViewFlowLayout()
        listLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        listLayout.minimumLineSpacing = 16
        listLayout.minimumInteritemSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout) // По умолчанию используем список
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = String(localized: "characterTitle")
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        gridButton.image = isGridView ? UIImage(systemName: "list.bullet") : UIImage(systemName: "square.grid.2x2")
        gridButton.target = self
        gridButton.action = #selector(toggleGridView)
        navigationItem.rightBarButtonItem = gridButton
        
        setupCollectionView()
        setupSearchController()
        loadCharactersFromRealm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: Setup UI
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: .zero, left: 16, bottom: .zero, right: 16)
        collectionView.register(CharacterCollectionGridCellView.self, forCellWithReuseIdentifier: CharacterCollectionGridCellView.reuseId)
        collectionView.register(CharacterCollectionListCellView.self, forCellWithReuseIdentifier: CharacterCollectionListCellView.reuseId)
        collectionView.register(CollectionLoadCell.self, forCellWithReuseIdentifier: CollectionLoadCell.reuseId)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        updateCollectionViewLayout()
    }
    
    private func calculateDynamicItemSize() -> CGSize {
        let totalWidth = UIScreen.main.bounds.width
        let padding: CGFloat = gridLayout.sectionInset.left + gridLayout.sectionInset.right
        let interItemSpacing = gridLayout.minimumInteritemSpacing * CGFloat(numberOfColumnsInGrid - 1)
        let availableWidth = totalWidth - padding - interItemSpacing
        let itemWidth = availableWidth / CGFloat(numberOfColumnsInGrid)
        
        let itemHeight = itemWidth + 80
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    private func updateCollectionViewLayout() {
        let layout: UICollectionViewFlowLayout
        if isGridView {
            layout = gridLayout
            gridLayout.itemSize = calculateDynamicItemSize()
        } else {
            layout = listLayout
        }
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = String(localized: "searchPlaceholder")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: Private methods
    
    @objc
    private func toggleGridView() {
        isGridView.toggle()
        gridButton.image = isGridView ? UIImage(systemName: "list.bullet") : UIImage(systemName: "square.grid.2x2")
        updateCollectionViewLayout()
        collectionView.reloadData() // Ensure the data is reloaded when switching views
    }
    
    private func loadData(query: String? = nil) {
        ApiService.shared.makeRequest(
            type: CharacterModel.self,
            path: .character,
            page: currentPage,
            searchQuery: query,
            callBack: { [weak self] result in
                switch result {
                case .success(let response):
                    if let query = query, self?.isFiltering == true {
                        // Добавляем новые результаты в отфильтрованные персонажи
                        self?.filteredCharacters.append(contentsOf: response.results)
                    } else {
                        // Добавляем данные в основной список
                        self?.characters.append(contentsOf: response.results)
                    }
                    
                    self?.hasMoreDataToLoad = response.info.next != nil
                    self?.currentPage += 1
                    
                    // Сохранение загруженных данных в Realm
                    self?.saveCharactersToRealm(response.results)
                    
                    self?.collectionView.reloadData()
                    
                    // Продолжаем загрузку, если есть еще страницы
                    if self?.hasMoreDataToLoad == true {
                        self?.loadData(query: query)
                    }
                    
                case .failure(let error):
                    print(error)
                    guard let self else { return }
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 2,
                        execute: {
                            if self.retries < 3 {
                                self.loadData(query: query)
                                self.retries += 1
                            } else {
                                // Загрузка персонажей из Realm при неудаче
                                self.loadCharactersFromRealm()
                            }
                        }
                    )
                }
            }
        )
    }
    
    // Функция для сохранения персонажей в Realm
    private func saveCharactersToRealm(_ characters: [CharacterModel]) {
        try! realm.write {
            realm.add(characters.map { $0.toRealmModel() }, update: .modified)
        }
    }
    
    // Функция для загрузки персонажей из Realm
    private func loadCharactersFromRealm() {
        let realmCharacters = realm.objects(CharacterDBModel.self)
        characters = realmCharacters.map { $0.toModel() }
        collectionView.reloadData()
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension CharacterCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isFiltering {
            return 1
        } else {
            return hasMoreDataToLoad ? 2 : 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return isFiltering ? filteredCharacters.count : characters.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if isGridView {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCollectionGridCellView.reuseId, for: indexPath) as? CharacterCollectionGridCellView else {
                    return UICollectionViewCell()
                }
                
                let character = isFiltering ? filteredCharacters[indexPath.row] : characters[indexPath.row]
                cell.setup(
                    text: character.name,
                    imageURLString: character.image,
                    speciesText: character.species
                )
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCollectionListCellView.reuseId, for: indexPath) as? CharacterCollectionListCellView else {
                    return UICollectionViewCell()
                }
                
                let character = isFiltering ? filteredCharacters[indexPath.row] : characters[indexPath.row]
                cell.setup(
                    text: character.name,
                    imageURLString: character.image,
                    speciesText: character.species
                )
                return cell
            }
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionLoadCell.reuseId, for: indexPath) as? CollectionLoadCell else {
                return UICollectionViewCell()
            }
            cell.startAnimating()
            
            // Подгрузка данных, если не фильтруется или если фильтрация активна и есть ещё данные для подгрузки
            if hasMoreDataToLoad && !isFiltering {
                loadData()
            }
            
            return cell
        }
    }
    
    // Вызывается при скроллинге коллекции
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Проверка, если выполняется фильтрация и коллекция дошла до конца, подгружаем данные
        if isFiltering && scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height - 100 {
            if hasMoreDataToLoad {
                loadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let detailVC = CharacterDetailVC()
        let character = isFiltering ? filteredCharacters[indexPath.row] : characters[indexPath.row]
        detailVC.character = character
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
}

// MARK: - UISearchResultsUpdating

extension CharacterCollectionVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredCharacters = characters
            collectionView.reloadData()
            return
        }
        
        // Фильтрация по локальным данным
        filteredCharacters = characters.filter { $0.name.contains(searchText) }
        
        if filteredCharacters.isEmpty {
            // Если ничего не найдено локально, делаем запрос на сервер
            currentPage = 1 // Сброс страницы для нового поиска
            filteredCharacters.removeAll() // Очищаем текущий список фильтрованных персонажей
            loadData(query: searchText) // Выполняем запрос на сервер
        } else {
            collectionView.reloadData()
        }
    }
}

extension CharacterCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if indexPath.section == 0 {
            return isGridView ? calculateDynamicItemSize() : CGSize(width: UIScreen.main.bounds.width - 32, height: 140)
        } else {
            return CGSize(width: UIScreen.main.bounds.width - 32, height: 60)
        }
    }
}
