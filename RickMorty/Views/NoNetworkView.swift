//
//  NoNetworkView.swift
//  RickMorty
//
//  Created by Денис Королевский on 29/8/24.
//

import UIKit
import SnapKit
import Reachability

class NoNetworkView: UIView {
    
    // MARK: Subviews
    
    private let notificationImageView = UIImageView()
    private let messageLabel = UILabel()
    
    // MARK: Properties
    
    private var isExpanded = false
    private var widthConstraint: NSLayoutConstraint?
    private let reachability = try! Reachability()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupNetworkMonitoring()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupNetworkMonitoring()
        setupNetworkMonitoring()
    }
    
    deinit {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    // MARK: Setup UI
    
    private func setupView() {
        backgroundColor = .systemGray4
        self.translatesAutoresizingMaskIntoConstraints = false
        
        clipsToBounds = true
        layer.cornerRadius = 25
        
        widthConstraint = widthAnchor.constraint(equalToConstant: 50)
        widthConstraint?.isActive = true
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(notificationImageView)
        notificationImageView.image = UIImage(systemName: "network.slash")
        notificationImageView.tintColor = .red
        notificationImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(5)
            $0.width.height.equalTo(40)
        }
        
        addSubview(messageLabel)
        messageLabel.text = "Отсутствует связь с сетью"
        messageLabel.textColor = .black
        messageLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        messageLabel.textAlignment = .center
        messageLabel.backgroundColor = .clear
        messageLabel.isHidden = true
        messageLabel.snp.makeConstraints {
            $0.right.equalTo(notificationImageView.snp.left).offset(-15)
            $0.centerY.equalTo(notificationImageView)
        }
        
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(expandWidth))
        addGestureRecognizer(gestureRecognizer)
        
    }
    
    // MARK: Private methods
    
    @objc
    private func expandWidth() {
        if isExpanded { return }
        
        isExpanded = true
        messageLabel.isHidden = false
        widthConstraint?.constant = 330
        
        UIView.animate(withDuration: 0.3, animations: {
            self.superview?.layoutIfNeeded()
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.isExpanded = false
                self.widthConstraint?.constant = 50
                UIView.animate(withDuration: 0.3) {
                    self.superview?.layoutIfNeeded()
                }
            }
        }
    }
    
    private func setupNetworkMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Could not start reachability notifier")
        }
    }
    
    @objc private func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi, .cellular:
            self.isHidden = true
        case .unavailable:
            self.isHidden = false
            self.expandWidth()
        }
    }
}
