//
//  VideoCell.swift
//  VideoLoader
//
//  Created by ROHIT DAS on 22/07/24.
//

import UIKit
import AVFoundation
import Photos

class VideoCell: UICollectionViewCell {
    
    static let identifier = "VideoCell"
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPlayerLayer() {
        playerLayer = AVPlayerLayer()
        playerLayer?.videoGravity = .resizeAspectFill
        if let playerLayer = playerLayer {
            contentView.layer.addSublayer(playerLayer)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
    }
    
    func configure(with asset: PHAsset) {
        // Reset the player if it's already set
        player?.pause()
        player = nil
        
        // Fetching the video URL for the PHAsset
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] (avAsset, _, _) in
            guard let strongSelf = self, let avAsset = avAsset as? AVURLAsset else { return }
            DispatchQueue.main.async {
                let playerItem = AVPlayerItem(asset: avAsset)
                strongSelf.player = AVPlayer(playerItem: playerItem)
                strongSelf.playerLayer?.player = strongSelf.player
                strongSelf.player?.play()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.player = nil
        player = nil
    }
}
