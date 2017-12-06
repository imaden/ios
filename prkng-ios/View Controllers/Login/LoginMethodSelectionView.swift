//
//  LoginMethodSelectionView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginMethodSelectionView: UIView {
    
    static let HEIGHT = 187
    
    var containerView = UIView()
    var loginTitleLabel = UILabel()
    var facebookButton = ViewFactory.bigRedRoundedButton()
    var googleButton = ViewFactory.bigRedRoundedButton()
    var emailButton = UIButton()
    
    var selectedMethod : LoginMethod?
    
    var delegate : LoginMethodSelectionViewDelegate?
    
    var didSetupSubviews = false
    var didSetupConstraints = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        
        if(!didSetupSubviews) {
            setupSubviews()
            didSetupConstraints = false
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        self.clipsToBounds = true
        addSubview(containerView)
        
        loginTitleLabel.font = Styles.FontFaces.bold(12)
        loginTitleLabel.textColor = Styles.Colors.cream1
        loginTitleLabel.text = "login_with".localizedString
        containerView.addSubview(loginTitleLabel)
        
        facebookButton.backgroundColor = Styles.Colors.facebookBlue
        facebookButton.setTitle("login_with_facebook".localizedString, for: UIControlState())
        facebookButton.addTarget(self, action: #selector(LoginMethodSelectionView.facebookButtonTapped), for: UIControlEvents.touchUpInside)
        containerView.addSubview(facebookButton)
        
        googleButton.setTitle("login_with_google".localizedString, for: UIControlState())
        googleButton.addTarget(self, action: #selector(LoginMethodSelectionView.googleButtonTapped), for: UIControlEvents.touchUpInside)
        containerView.addSubview(googleButton)
        
        emailButton.titleLabel?.font = Styles.FontFaces.regular(12)
        emailButton.titleLabel?.textColor = Styles.Colors.anthracite1
        emailButton.setTitle("login_with_email".localizedString, for: UIControlState())
        emailButton.addTarget(self, action: #selector(LoginMethodSelectionView.emailButtonTapped), for: UIControlEvents.touchUpInside)
        containerView.addSubview(emailButton)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(LoginMethodSelectionView.HEIGHT)
        }
        
        loginTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.containerView)
            make.centerX.equalTo(self.containerView)
        }
        
        facebookButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView).offset(Styles.Sizes.bigRoundedButtonSideMargin)
            make.right.equalTo(self.containerView).offset(-Styles.Sizes.bigRoundedButtonSideMargin)
            make.top.equalTo(self.loginTitleLabel.snp_bottom).offset(14)
            make.height.equalTo(Styles.Sizes.bigRoundedButtonHeight)
        }
        
        googleButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView).offset(Styles.Sizes.bigRoundedButtonSideMargin)
            make.right.equalTo(self.containerView).offset(-Styles.Sizes.bigRoundedButtonSideMargin)
            make.bottom.equalTo(self.containerView).offset(-70)
            make.height.equalTo(Styles.Sizes.bigRoundedButtonHeight)
        }
        
        emailButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
            make.height.equalTo(70)
        }
        
        didSetupConstraints = true
    }
    
    
    
    func facebookButtonTapped () {
        
        if(selectedMethod == LoginMethod.facebook) {
            return
        }
        
        deselectAll()
        selectedMethod = LoginMethod.facebook
        
        if (delegate != nil) {
            delegate!.loginFacebookSelected()
        }
        
    }
    
    
    func googleButtonTapped () {
        
        if(selectedMethod == LoginMethod.google) {
            return
        }
        
        deselectAll()
        selectedMethod = LoginMethod.google
        
        if (delegate != nil) {
            delegate!.loginGoogleSelected()
        }
        
    }
    
    func emailButtonTapped () {
        
        if(selectedMethod == LoginMethod.email) {
            return
        }
        
        deselectAll()
        selectedMethod = LoginMethod.email
        
        if (delegate != nil) {
            delegate!.loginEmailSelected()
        }
        
    }
        
    func deselectAll () {
        
        selectedMethod = nil
        
    }
    
}

protocol LoginMethodSelectionViewDelegate {
    
    func loginFacebookSelected()
    func loginGoogleSelected()
    func loginEmailSelected()
    
}


enum LoginMethod {
    case facebook
    case google
    case email
}
