//
//  VideoGridViewController.swift
//  VideoLoader
//
//  Created by ROHIT DAS on 22/07/24.
//

import UIKit
import Photos
import AVFoundation

class VideoGridViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var videos: [PHAsset] = []
    private let fetchLimit = 20
    private var fetchingMore = false
    private var totalVideos = 0
    private var lastFetchedAsset: PHAsset?
    private var selectedAsset: PHAsset?
    
    private let proceedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Proceed", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(proceedButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupProceedButton()
        checkPhotoLibraryPermission()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width / 3 - 1, height: view.frame.width / 3 - 1)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.identifier)
        
        view.addSubview(collectionView)
    }
    
    private func setupProceedButton() {
        view.addSubview(proceedButton)
        
        NSLayoutConstraint.activate([
            proceedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            proceedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            proceedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            proceedButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            fetchVideos()
        case .denied, .restricted:
            print("Access to photo library is denied or restricted.")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.fetchVideos()
                    } else {
                        print("Access to photo library was not authorized.")
                    }
                }
            }
        @unknown default:
            fatalError("Unknown authorization status for photo library.")
        }
    }
    
    private func fetchVideos() {
        fetchingMore = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = fetchLimit
        
        if let lastAsset = lastFetchedAsset {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d AND creationDate < %@", PHAssetMediaType.video.rawValue, lastAsset.creationDate! as NSDate)
        }
        
        let allVideos = PHAsset.fetchAssets(with: fetchOptions)
        totalVideos = allVideos.count
        
        allVideos.enumerateObjects { (asset, index, stop) in
            self.videos.append(asset)
        }
        
        lastFetchedAsset = videos.last
        fetchingMore = false
        collectionView.reloadData()
    }
    
    private func fetchMoreVideos() {
        guard !fetchingMore else { return }
        fetchVideos()
    }
    
    @objc private func proceedButtonTapped() {
        guard let selectedAsset = selectedAsset else { return }
        let videoMetadataVC = VideoMetadataViewController(asset: selectedAsset)
        navigationController?.pushViewController(videoMetadataVC, animated: true)
    }
    
    private func playAllVisibleVideos() {
        for cell in collectionView.visibleCells {
            if let videoCell = cell as? VideoCell {
                videoCell.player?.play()
            }
        }
    }
    
    private func pauseAllVisibleVideos() {
        for cell in collectionView.visibleCells {
            if let videoCell = cell as? VideoCell {
                videoCell.player?.pause()
            }
        }
    }
}

extension VideoGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as! VideoCell
        let asset = videos[indexPath.item]
        cell.configure(with: asset)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = videos[indexPath.item]
        selectedAsset = asset
        proceedButton.isHidden = false
        pauseAllVisibleVideos()
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? VideoCell {
            selectedCell.player?.play()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 2 {
            fetchMoreVideos()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            playAllVisibleVideos()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playAllVisibleVideos()
    }
}
