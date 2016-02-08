//
//  PPSignInViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-04.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit
import MessageUI

class PPSignInViewController: AbstractViewController, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, PPHeaderViewDelegate {
    
    private var statusView = UIView()
    private var headerView = PPHeaderView()
    private let tableView = UITableView()
    
    private var username: String?
    private var password: String?
    
    private(set) var BACKGROUND_COLOR = Styles.Colors.stone
    private(set) var BACKGROUND_TEXT_COLOR = Styles.Colors.anthracite1
    private(set) var BACKGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.petrol2
    private(set) var FOREGROUND_COLOR = Styles.Colors.cream1
    private(set) var FOREGROUND_TEXT_COLOR = Styles.Colors.anthracite1
    private(set) var FOREGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.red2
    
    private(set) var HEADER_HEIGHT = 80
    private(set) var HEADER_FONT = Styles.FontFaces.regular(12)
    private(set) var MIN_FOOTER_HEIGHT = 65
    private(set) var FOOTER_FONT = Styles.FontFaces.regular(12)
    
    private(set) var SMALL_CELL_HEIGHT: CGFloat = 48
    private(set) var BIG_CELL_HEIGHT: CGFloat = 61
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = UIView()
        setupViews()
        setupConstraints()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Parking Panda Sign In View"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections)), withRowAnimation: .None)
    }
    
    func setupViews () {
        
        view.backgroundColor = BACKGROUND_COLOR
        
        statusView.backgroundColor = Styles.Colors.transparentBlack
        self.view.addSubview(statusView)
        
        headerView.delegate = self
        view.addSubview(headerView)
        
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
    }
    
    func setupConstraints () {
        
        statusView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.snp_topLayoutGuideBottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        headerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.height.equalTo(HEADER_HEIGHT)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.headerView.snp_bottom)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
    }
    
    
    //MARK: UITableViewDataSource
    
    //TODO: All these strings need to be localized
    var tableSource: [(String, [SettingsCell])] {
        
        let emailCell = SettingsCell(placeholderText: "email".localizedString, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:")
        let passwordCell = SettingsCell(placeholderText: "password".localizedString, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:")
        let formSection = [emailCell, passwordCell]
        
        return [("enter_your_credentials", formSection)]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSource[section].1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        return settingsCell.tableViewCell(tableView)
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        return settingsCell.canSelect
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        if settingsCell.selectorsTarget != nil && settingsCell.cellSelector != nil {
            settingsCell.selectorsTarget!.performSelector(Selector(settingsCell.cellSelector!))
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SMALL_CELL_HEIGHT
    }
    
    
    //MARK: selector functions
    
    func formCallback(sender: AnyObject?) {
        if let timer = sender as? NSTimer {
            if let dict = timer.userInfo as? [String: String] {
                username = dict["email".localizedString] ?? username
                password = dict["password".localizedString] ?? password
            }
            timer.invalidate()
        }
    }
    
    func present() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let rootVC = appDelegate.window?.rootViewController {
            if let navVC = rootVC.navigationController {
                navVC.pushViewController(self, animated: true)
            } else {
                rootVC.presentViewController(self, animated: true, completion: nil)
            }
        }
        
    }
    
    func dismiss() {
        
        if let navVC = self.navigationController {
            navVC.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    //MARK: PPHeaderViewDelegate
    func tappedBackButton() {
        dismiss()
    }
    
    func tappedNextButton() {
        ParkingPandaOperations.login(username: username, password: password, completion: { (user, error) -> Void in
            if user != nil {
                //we have logged in!
                self.dismiss()
            } else {
                //TODO: show error message
            }
        })

    }
    
}
