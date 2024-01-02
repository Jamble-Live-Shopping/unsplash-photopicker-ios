//
//  PhotoView.swift
//  Unsplash
//
//  Created by Olivier Collet on 2017-11-06.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import UIKit

class PhotoView: UIView {

    static var nib: UINib { return UINib(nibName: "PhotoView", bundle: Bundle.local) }

    private var currentPhotoID: String?
    private var imageDownloader = ImageDownloader()
    private var screenScale: CGFloat { return UIScreen.main.scale }
    private var profileLink: URL?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet var overlayViews: [UIView]!
    
    
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .white.withAlphaComponent(0.8)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 18),
            button.widthAnchor.constraint(equalToConstant: 18)
        ])
        button.addTarget(self, action: #selector(toggleUsername), for: .touchUpInside)
        return button
    }()

    var showsUsername = true {
        didSet {
            userNameLabel.alpha = showsUsername ? 1 : 0
            gradientView.alpha = showsUsername ? 1 : 0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        accessibilityIgnoresInvertColors = true
        
        
        
        infoButton.isUserInteractionEnabled = true
        gradientView.setColors([
            GradientView.Color(color: .clear, location: 0),
            GradientView.Color(color: UIColor(white: 0, alpha: 0.5), location: 1)
        ])
        
        self.addSubview(infoButton)
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            infoButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4)
        ])
    }

    func prepareForReuse() {
        currentPhotoID = nil
        userNameLabel.text = nil
        imageView.backgroundColor = .clear
        imageView.image = nil
        imageDownloader.cancel()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let fontSize: CGFloat = traitCollection.horizontalSizeClass == .compact ? 10 : 13
        userNameLabel.font = UIFont.systemFont(ofSize: fontSize)
    }

    // MARK: - Setup

    func configure(with photo: UnsplashPhoto, showsUsername: Bool = true) {
        self.showsUsername = false
        self.profileLink = photo.user.profileURL
        userNameLabel.text = "Photo by: \(photo.user.displayName) on Unsplash"
        userNameLabel.numberOfLines = 2
        userNameLabel.font = .systemFont(ofSize: 12)
        imageView.backgroundColor = photo.color
        imageView.layer.cornerCurve = .continuous
        imageView.layer.cornerRadius = 4
        currentPhotoID = photo.identifier
        downloadImage(with: photo)


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openUserLink))
        userNameLabel.addGestureRecognizer(tapGesture)
        userNameLabel.isUserInteractionEnabled = true
    }
    
    @objc private func toggleUsername() {
     
        if self.showsUsername == false {
            self.showsUsername = true
        } else {
            showsUsername = false
        }
    }
    
    @objc private func openUserLink() {
        guard let profileLink else { return }
        var urlString = profileLink.absoluteString
        urlString.append("?utm_source=jamble&utm_medium=referral")
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
}
    

    private func downloadImage(with photo: UnsplashPhoto) {
        guard let regularUrl = photo.urls[.regular] else { return }

        let url = sizedImageURL(from: regularUrl)

        let downloadPhotoID = photo.identifier

        imageDownloader.downloadPhoto(with: url, completion: { [weak self] (image, isCached) in
            guard let strongSelf = self, strongSelf.currentPhotoID == downloadPhotoID else { return }

            if isCached {
                strongSelf.imageView.image = image
            } else {
                UIView.transition(with: strongSelf, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    strongSelf.imageView.image = image
                }, completion: nil)
            }
        })
    }

    private func sizedImageURL(from url: URL) -> URL {
        layoutIfNeeded()
        return url.appending(queryItems: [
            URLQueryItem(name: "w", value: "\(frame.width)"),
            URLQueryItem(name: "dpr", value: "\(Int(screenScale))")
        ])
    }
    

    // MARK: - Utility

    class func view(with photo: UnsplashPhoto) -> PhotoView? {
        guard let photoView = nib.instantiate(withOwner: nil, options: nil).first as? PhotoView else {
            return nil
        }

        photoView.configure(with: photo)

        return photoView
    }

}
