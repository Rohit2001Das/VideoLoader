//
//  VideoMetadataViewController.swift .swift
//  VideoLoader
//
//  Created by ROHIT DAS on 22/07/24.
//
import UIKit
import Photos

class VideoMetadataViewController: UIViewController {
    
    private let asset: PHAsset
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let videoNameLabel = UILabel()
    private let videoSizeLabel = UILabel()
    private let videoResolutionLabel = UILabel()
    private let videoDurationLabel = UILabel()
    
    init(asset: PHAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        displayMetadata()
        loadThumbnail()
    }
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [thumbnailImageView, videoNameLabel, videoSizeLabel, videoResolutionLabel, videoDurationLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 9.0/16.0)
        ])
    }
    
    private func displayMetadata() {
        videoNameLabel.text = "Name: \(asset.value(forKey: "filename") as? String ?? "Unknown")"
        videoSizeLabel.text = "Size: \(asset.pixelWidth)x\(asset.pixelHeight)"
        videoResolutionLabel.text = "Resolution: \(asset.pixelWidth)x\(asset.pixelHeight)"
        videoDurationLabel.text = "Duration: \(Int(asset.duration)) seconds"
    }
    
    private func loadThumbnail() {
        let imageManager = PHImageManager.default()
        let imageOptions = PHImageRequestOptions()
        imageOptions.isSynchronous = true
        imageOptions.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: view.frame.width - 32, height: (view.frame.width - 32) * 9.0 / 16.0), contentMode: .aspectFit, options: imageOptions) { [weak self] (image, _) in
            self?.thumbnailImageView.image = image
        }
    }
}
