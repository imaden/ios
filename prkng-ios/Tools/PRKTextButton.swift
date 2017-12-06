//
//  PRKTextButton.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PRKTextButton: UIView {

    fileprivate var imageSize: CGSize
    fileprivate var labelText: String
    fileprivate var labelFont: UIFont
    fileprivate var image: UIImage?
    
    fileprivate var button: UIButton
    fileprivate var imageView: UIImageView
    fileprivate var label: UILabel
    
    fileprivate var didsetupSubviews : Bool
    fileprivate var didSetupConstraints : Bool


    init(image: UIImage?, imageSize: CGSize, labelText: String, labelFont: UIFont) {
        
        self.image = image
        self.imageSize = imageSize
        self.labelText = labelText
        self.labelFont = labelFont

        button = UIButton()
        imageView = UIImageView()
        label = UILabel()
        
        didsetupSubviews = false
        didSetupConstraints = true
        
        super.init(frame: CGRect.zero)

    }
    
    init() {
        
        button = UIButton()
        imageView = UIImageView()
        label = UILabel()
        
        imageSize = CGSize.zero
        labelText = ""
        labelFont = Styles.FontFaces.regular(17)

        didsetupSubviews = false
        didSetupConstraints = true

        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (!didsetupSubviews) {
            setupSubviews()
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        if(!didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }
    
    func setupSubviews () {
        
        self.clipsToBounds = true
        self.backgroundColor = Styles.Colors.red2
        self.layer.cornerRadius = imageSize.height / 2
        
        self.addSubview(imageView)
        imageView.image = image
        imageView.contentMode = UIViewContentMode.center
        
        label.text = labelText
        label.font = labelFont
        label.textColor = Styles.Colors.cream1
        self.addSubview(label)
        
        self.addSubview(button)
        
        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        button.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        imageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(self.imageSize)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }

        self.setLabelText(labelText)
        
    }
    
    func setImage(_ image: UIImage?) {
        if self.image != image {
            self.image = image
            animateChangeImageTo()
        }
    }
    
    fileprivate func animateChangeImageTo() {
        
        let fadeAnimation = CATransition()
        fadeAnimation.duration = 0.2
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        fadeAnimation.type = kCATransitionFade
        self.imageView.layer.add(fadeAnimation, forKey: "fade")
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.imageView.transform = self.imageView.transform.rotated(by: CGFloat(M_PI))
            self.imageView.image = self.image
        })
    }
    
    func addTarget(_ target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        self.button.addTarget(target, action: action, for: controlEvents)
    }
    
    func setLabelText(_ text: String) {
        if text == "" {
            label.snp_remakeConstraints { (make) -> () in
                make.left.equalTo(self)
                make.right.equalTo(self.imageView.snp_left)
                make.centerY.equalTo(self)
            }
        } else {
            label.snp_remakeConstraints { (make) -> () in
                make.left.equalTo(self).offset(12)
                make.right.equalTo(self.imageView.snp_left).offset(2)
                make.centerY.equalTo(self)
            }
        }
        
        self.setNeedsLayout()

        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.layoutIfNeeded()
        })
        
        self.labelText = text
        self.label.text = text
    }
    
    func setLabelFont(_ labelFont: UIFont) {
        self.labelFont = labelFont
        self.label.font = labelFont
    }

}
