//
//  EpisodeDetailVC.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit

final class EpisodeDetailVC: UIViewController {
    
    // MARK: Properties
    
    private let episodeModel: EpisodeModel
    private var characters = [CharacterModel]()
    
    // MARK: Subviews
    
    private lazy var tableView = UITableView()
    
    // MARK: Init
    
    init(episode: EpisodeModel) {
        self.episodeModel = episode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCharacters()
    }
    
    
    // MARK: Private methods
    
    private func loadCharacters() {
        let group = DispatchGroup()
        
        episodeModel.characters.forEach { url in
            group.enter()
            print("@ ENTER \(url)")
            loadCharacter(
                from: url,
                onFinish: {
                    print("@ LEAVE \(url)")
                    group.leave()
                }
            )
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // load Characters from API
    private func loadCharacter(from urlString: String, onFinish: @escaping () -> Void) {
        ApiService.shared.makeSingleObjectRequest(
            type: CharacterModel.self,
            fullUrlString: urlString,
            callBack: { [weak self] result in
                switch result {
                case .success(let characterResponce):
                    self?.characters.append(characterResponce)
             //       self?.updateCharacters()
                case .failure(let error):
                    print(error)
                }
                onFinish()
            }
        )
    }
    
    
    // MARK: setup UI
    
    private func setupUI() {
        title = String(localized: "episod") + episodeModel.episode
        view.backgroundColor = .systemBackground
        setupTableView()
    }
    
    // setup tableView
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview()
            
            tableView.register(EpisodeDetailInfoCell.self, forCellReuseIdentifier: EpisodeDetailInfoCell.reuseId)
            tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: CharacterTableViewCell.reuseId)
            
            tableView.contentInset = .init(top: 0, left: 0, bottom: 16, right: 0)
            tableView.separatorStyle = .none
            tableView.dataSource = self
        }
    }
    
}

// MARK: - UITableViewDelegate

extension EpisodeDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        characters.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: EpisodeDetailInfoCell.reuseId,
                    for: indexPath
                ) as? EpisodeDetailInfoCell else { return UITableViewCell() }
            
            cell.setup(episodeName: episodeModel.name, episodeDate: episodeModel.airDate)
            
            return cell
        } else {
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: CharacterTableViewCell.reuseId,
                    for: indexPath
                ) as? CharacterTableViewCell else { return UITableViewCell() }
            let character = characters[indexPath.row - 1]
            cell.setup(imageURL: character.image, nameText: character.name, speciesText: character.species)
            cell.selectionStyle = .none
            
            return cell
        }
    }
}
