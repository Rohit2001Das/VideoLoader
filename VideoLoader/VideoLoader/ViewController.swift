//
//  ViewController.swift
//  VideoLoader
//
//  Created by ROHIT DAS on 22/07/24.
//

import UIKit

class ViewController: UIViewController {
    
    private let loadVideosButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Load Videos", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loadVideosButtonTapped), for: .touchUpInside)
        
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(loadVideosButton)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            loadVideosButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadVideosButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadVideosButton.widthAnchor.constraint(equalToConstant: 200),
            loadVideosButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func loadVideosButtonTapped() {
        let videoGridVC = VideoGridViewController()
        navigationController?.pushViewController(videoGridVC, animated: true)
    }
}
