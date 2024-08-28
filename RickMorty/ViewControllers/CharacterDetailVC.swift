//
//  CharacterDetailVC.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import SDWebImage
import RealmSwift

final class CharacterDetailVC: UIViewController {
    
    // MARK: Properties
    var character: CharacterModel?
    private var realm: Realm?
    private let descriptionLabelText: String = String(localized: "descriptionLabelText")
    private var currentCharacterIndex: Int = 0
    private var typingTimer: Timer?
    
    // MARK: Subviews
    private lazy var characterDetailScrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    private let characterImageView = UIImageView()
    private let characterNameLabel = UILabel()
    private let characterSpeciesLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    
    private let characterDescriptionStackView = UIStackView()
    private let characterIdLabel = UILabel()
    private let characterStatusLabel = UILabel()
    private let characterTypeLabel = UILabel()
    private let characterGenderLabel = UILabel()
    private let characterEpisodeLabel = UILabel()
    private let descriptionContainerView = UIView()
    private let rickAndmortyDescriptionLabel = UILabel()
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        
        setupUI()
        setupShareBarButton()
        setupFavoriteButton()
        startTypingAnimation()
        
        makeNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Скрываем tabBar при появлении экрана
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Показываем tabBar, когда экран будет исчезать
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Private methods
    
    private func setupShareBarButton() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonDidTap))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    private func configurePopoverPresentation(for activityViewController: UIActivityViewController) {
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
    }
    
    @objc private func shareButtonDidTap() {
        guard let characterImage = characterImageView.image, let characterName = character?.name else {
            print("Нет данных для отправки")
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [characterImage, characterName], applicationActivities: nil)
        configurePopoverPresentation(for: activityViewController)
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func setupFavoriteButton() {
        contentView.addSubview(favoriteButton)
        favoriteButton.tintColor = .red
        favoriteButton.snp.makeConstraints { make in
            make.right.equalTo(characterImageView.snp.right).inset(30)
            make.bottom.equalTo(characterImageView.snp.bottom).inset(30)
        }
        
        if let character = character, let realm = realm {
            let isFavorite = realm.objects(CharacterDBModel.self).filter("id == %@", character.id).first?.isFavorite ?? false
            let imgName = isFavorite ? "heart.fill" : "heart"
            let img = UIImage(systemName: imgName)
            favoriteButton.setImage(img, for: .normal)
        }
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonDidTap), for: .touchUpInside)
    }
    
    @objc private func favoriteButtonDidTap() {
        guard let character = character, let realm = realm else { return }
        
        let feedBackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedBackGenerator.impactOccurred()
        
        try! realm.write {
            if let existingCharacter = realm.objects(CharacterDBModel.self).filter("id == %@", character.id).first {
                existingCharacter.isFavorite.toggle()
                let imgName = existingCharacter.isFavorite ? "heart.fill" : "heart"
                favoriteButton.setImage(UIImage(systemName: imgName), for: .normal)
            } else {
                let realmCharacter = character.toRealmModel()
                realmCharacter.isFavorite = true
                realm.add(realmCharacter)
                favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        }
    }
    
    private func startTypingAnimation() {
        rickAndmortyDescriptionLabel.text = ""
        currentCharacterIndex = 0
        
        // Таймер с небольшим интервалом
        typingTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(typeCharacter), userInfo: nil, repeats: true)
    }

    @objc private func typeCharacter() {
        if currentCharacterIndex < descriptionLabelText.count {
            let index = descriptionLabelText.index(descriptionLabelText.startIndex, offsetBy: currentCharacterIndex)
            rickAndmortyDescriptionLabel.text?.append(descriptionLabelText[index])
            currentCharacterIndex += 1

        } else {
            typingTimer?.invalidate()
        }
        
        let bottomOffset = CGPoint(x: 0, y: characterDetailScrollView.contentSize.height - characterDetailScrollView.bounds.size.height)
        guard bottomOffset.y > 0 else { return }
        UIView.animate(withDuration: 0.1, animations: {
            self.characterDetailScrollView.setContentOffset(bottomOffset, animated: false)
        })
    }
    
    // MARK: Setup UI
    
    private func makeNavigationController() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.view.backgroundColor = .clear
        
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        view.addSubview(characterDetailScrollView)
        characterDetailScrollView.addSubview(contentView)
        contentView.addSubview(characterImageView)
        contentView.addSubview(characterNameLabel)
        contentView.addSubview(characterSpeciesLabel)
        contentView.addSubview(characterDescriptionStackView)
        contentView.addSubview(descriptionContainerView)
        contentView.addSubview(rickAndmortyDescriptionLabel)
        
        setupCharacterDetailScrollView()
        setupContentView()
        setupCharacterImageView()
        setupCharacterNameLabel()
        setupCharacterSpeciesLabel()
        setupDescriptionLabelStackView()
        setupDescriptionContainerView()
        setupRickAndmortyDescriptionLabel()
    }
    
    private func setupCharacterDetailScrollView() {
        characterDetailScrollView.backgroundColor = .systemGray6
        characterDetailScrollView.automaticallyAdjustsScrollIndicatorInsets = false
        characterDetailScrollView.contentInsetAdjustmentBehavior = .never
        characterDetailScrollView.snp.makeConstraints {
            //$0.top.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.left.right.equalToSuperview()
           // $0.bottom.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setupContentView() {
        contentView.backgroundColor = .systemGray6
        contentView.snp.makeConstraints {
            $0.edges.equalTo(characterDetailScrollView)
            $0.width.equalTo(characterDetailScrollView.snp.width)
        }
    }
    
    private func setupCharacterImageView() {
        characterImageView.contentMode = .scaleAspectFill
        characterImageView.layer.masksToBounds = true
        characterImageView.layer.cornerRadius = 15
        characterImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.left.right.equalTo(contentView).inset(16)
            make.height.equalTo(characterImageView.snp.width)
        }
        
        if let characterImageURL = character?.image {
            DispatchQueue.main.async {
                self.characterImageView.sd_setImage(with: URL(string: characterImageURL), placeholderImage: UIImage(named: "placeholder"))
            }
        }
    }
    
    private func setupCharacterNameLabel() {
        characterNameLabel.text = character?.name
        characterNameLabel.font = UIFont.boldSystemFont(ofSize: 32)
        characterNameLabel.textColor = .white
        characterNameLabel.shadowColor = .black
        characterNameLabel.shadowOffset = CGSize(width: 3, height: 3)
        characterNameLabel.snp.makeConstraints {
            $0.left.equalTo(characterImageView.snp.left).offset(20)
            $0.bottom.equalTo(characterSpeciesLabel.snp.top).inset(10)
        }
    }
    
    private func setupCharacterSpeciesLabel() {
        characterSpeciesLabel.text = character?.species
        characterSpeciesLabel.font = UIFont.boldSystemFont(ofSize: 32)
        characterSpeciesLabel.textColor = .white
        characterSpeciesLabel.shadowColor = .black
        characterSpeciesLabel.shadowOffset = CGSize(width: 3, height: 3)
        characterSpeciesLabel.snp.makeConstraints {
            $0.left.equalTo(characterImageView.snp.left).offset(20)
            $0.bottom.equalTo(characterImageView.snp.bottom).inset(20)
        }
    }
    
    private func setupDescriptionLabelStackView() {
        [
            characterIdLabel,
            characterStatusLabel,
            characterTypeLabel,
            characterGenderLabel,
            characterEpisodeLabel
        ].forEach({
            characterDescriptionStackView.addArrangedSubview($0)
        })
        characterDescriptionStackView.axis = .vertical
        characterDescriptionStackView.distribution = .fillEqually
        characterDescriptionStackView.alignment = .fill
        characterDescriptionStackView.backgroundColor = .systemTeal
        characterDescriptionStackView.spacing = 10
        
        characterDescriptionStackView.layer.cornerRadius = 15
        characterDescriptionStackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        characterDescriptionStackView.isLayoutMarginsRelativeArrangement = true
                
        characterDescriptionStackView.snp.makeConstraints { make in
            make.top.equalTo(characterImageView.snp.bottom).offset(16)
            make.left.right.equalTo(contentView).inset(16)
            make.height.equalTo(200)
        }
        
        // setupCharacterIdLabel
        characterIdLabel.text = String(localized: "id:") + String(character?.id ?? 0)
        characterIdLabel.font = UIFont.boldSystemFont(ofSize: 22)
        characterIdLabel.textColor = .darkText
        characterIdLabel.numberOfLines = 0
        
        // setupCharacterStatusLabel
        characterStatusLabel.text = String(localized: "status:") + String(character?.status ?? "")
        characterStatusLabel.font = UIFont.boldSystemFont(ofSize: 22)
        characterStatusLabel.textColor = .darkText
        characterStatusLabel.numberOfLines = 0
        
        // setupCharacterTypeLabel
        characterTypeLabel.text = String(localized: "type:") + String(character?.type ?? "")
        characterTypeLabel.font = UIFont.boldSystemFont(ofSize: 22)
        characterTypeLabel.textColor = .darkText
        characterTypeLabel.numberOfLines = 0
        
        // setupCharacterGenderLabel
        characterGenderLabel.text = String(localized: "gender:") + String(character?.gender ?? "")
        characterGenderLabel.font = UIFont.boldSystemFont(ofSize: 22)
        characterGenderLabel.textColor = .darkText
        characterGenderLabel.numberOfLines = 0
        
        // setupCharacterEpisodeLabel
        characterEpisodeLabel.text = String(localized: "episodes:") + String(character?.episode.count ?? 0)
        characterEpisodeLabel.font = UIFont.boldSystemFont(ofSize: 22)
        characterEpisodeLabel.textColor = .darkText
        characterEpisodeLabel.numberOfLines = 0
    }
    
    private func setupDescriptionContainerView() {      
        descriptionContainerView.layer.masksToBounds = true
        descriptionContainerView.backgroundColor = .systemGray5
        descriptionContainerView.layer.cornerRadius = 15
        descriptionContainerView.snp.makeConstraints {
            $0.top.equalTo(characterDescriptionStackView.snp.bottom).offset(16)
            $0.left.right.equalTo(contentView).inset(16)
            $0.bottom.equalTo(contentView).inset(16)
        }
    }
    
    private func setupRickAndmortyDescriptionLabel() {
        rickAndmortyDescriptionLabel.font = UIFont.systemFont(ofSize: 16)
        rickAndmortyDescriptionLabel.layer.masksToBounds = true
        rickAndmortyDescriptionLabel.textColor = .black
        rickAndmortyDescriptionLabel.numberOfLines = 0
        rickAndmortyDescriptionLabel.lineBreakMode = .byWordWrapping
        rickAndmortyDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionContainerView.snp.top).offset(16)
            $0.left.right.equalTo(descriptionContainerView).inset(16)
            $0.bottom.equalTo(descriptionContainerView).inset(16)
        }
    }
}


