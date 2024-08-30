//
//  UserTabBarController.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import FirebaseRemoteConfig

class UserTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let noNetworkView = NoNetworkView()
    
    var remoteConfig = RemoteConfig.remoteConfig()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRemoteConfig()
        self.delegate = self
        
        configureTabs()
        
        // Загрузка конфигурации и добавление первого таба
        fetchConfig {
            self.addFirstTab()
        }
        
        setupNoNetworkView()
    }
    
    private func setupNoNetworkView() {
        view.addSubview(noNetworkView)
        noNetworkView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(100)
            make.right.equalToSuperview().inset(18)
        }
    }
    
    private func configureRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 5 // Использовать большее значение в продакшн-среде
        remoteConfig.configSettings = settings
        
        // Установка значений по умолчанию
        remoteConfig.setDefaults(["CharacterCollectionVCToggle": true as NSObject])
    }
    
    private func fetchConfig(completion: @escaping () -> Void) {
        remoteConfig.fetchAndActivate { status, error in
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                print("Remote Config fetched and activated.")
            } else {
                print("Remote Config fetch failed: \(error?.localizedDescription ?? "No error available.")")
            }
            completion()
        }
    }
    
    private func addFirstTab() {
        let featureEnabled = remoteConfig["CharacterCollectionVCToggle"].boolValue
        
        let characterVC: UIViewController
        if featureEnabled {
            characterVC = CharacterCollectionVC()
        } else {
            characterVC = CharacterTableVC()
        }
        
        characterVC.tabBarItem.image = UIImage(systemName: "figure.arms.open")
        characterVC.title = String(localized: "characterTitle")
        let nav1 = UINavigationController(rootViewController: characterVC)
        
        var currentViewControllers = viewControllers ?? []
        currentViewControllers.insert(nav1, at: 0)
        
        setViewControllers(currentViewControllers, animated: true)
    }

    private func configureTabs() {
        let locationVC = LocationTableVC()
        let episodeVC = EpisodeTableVC()
        let favoritesVC = FavoritesVC()
        
        locationVC.tabBarItem.image = UIImage(systemName: "globe")
        episodeVC.tabBarItem.image = UIImage(systemName: "film.stack")
        favoritesVC.tabBarItem.image = UIImage(systemName: "heart.fill")
        
        locationVC.tabBarItem.title = String(localized: "locationTitle")
        episodeVC.tabBarItem.title = String(localized: "episodesTitle")
        favoritesVC.tabBarItem.title = String(localized: "favoritesTitle")
        
        let nav2 = UINavigationController(rootViewController: locationVC)
        let nav3 = UINavigationController(rootViewController: episodeVC)
        let nav4 = UINavigationController(rootViewController: favoritesVC)
        
        tabBar.tintColor = .label
        tabBar.backgroundColor = .systemBackground
        
        setViewControllers([nav2, nav3, nav4], animated: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}
