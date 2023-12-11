//
//  CheckmarkView.swift
//  UnsplashPhotoPicker
//
//  Created by Olivier Collet on 2018-11-07.
//  Copyright © 2018 Unsplash. All rights reserved.
//

import UIKit

class CheckmarkView: UIView {

    override class var layerClass: AnyClass { return CAShapeLayer.self }
    override var intrinsicContentSize: CGSize { return CGSize(width: 24, height: 24) }

    private lazy var checkmark: UIImageView = {
        let image = UIImage(systemName: "checkmark")
        let imageView = UIImageView(image: image)
         imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        postInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }

    private func postInit() {
        guard let shapeLayer = layer as? CAShapeLayer else { return }
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
        shapeLayer.shadowRadius = 1
        shapeLayer.shadowOpacity = 0.25

        addSubview(checkmark)
        NSLayoutConstraint.activate([
            checkmark.centerXAnchor.constraint(equalTo: centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 14),
            checkmark.heightAnchor.constraint(equalToConstant: 14)
            ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let shapeLayer = layer as? CAShapeLayer else { return }
        shapeLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        shapeLayer.shadowPath = shapeLayer.path
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        guard let shapeLayer = layer as? CAShapeLayer else { return }
        shapeLayer.fillColor = UIColor.white.cgColor
    }

}
