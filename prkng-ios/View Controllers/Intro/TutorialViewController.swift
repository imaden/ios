//
//  TutorialViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 26/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class TutorialViewController: GAITrackedViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    var delegate: TutorialViewControllerDelegate?
    var backgroundImageFromView : UIImageView
    var backgroundImageToView : UIImageView
    var imageFromView : UIImageView
    var imageToView : UIImageView
    var pageViewController : UIPageViewController
    var pageControl : UIPageControl
    var nextButton : UIButton
    var getStartedButton : UIButton
    var contentViewControllers : [TutorialContentViewController]
    var transitioningToVC: TutorialContentViewController?
    
    fileprivate var SMALL_SCREEN_IMAGE_HEIGHT_DIFFERENCE = UIScreen.main.bounds.height == 480 ? 30 : 0

    static let PAGE_CONTROL_BOTTOM_OFFSET = 90
    
    let pageCount = 4
    
    let images = [ UIImage(named: "tutorial_1"),
        UIImage(named: "tutorial_2"),
        UIImage(named: "tutorial_3"),
        UIImage(named: "tutorial_4")]
    
    let texts = [ "tutorial_step_1".localizedString,
        "tutorial_step_2".localizedString,
        "tutorial_step_3".localizedString,
        "tutorial_step_4".localizedString]
    
    init() {
        backgroundImageFromView = UIImageView()
        backgroundImageToView = UIImageView()
        imageFromView = UIImageView()
        imageToView = UIImageView()
        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
        pageViewController.gestureRecognizers
        pageControl = UIPageControl()
        nextButton = UIButton()
        getStartedButton = ViewFactory.redRoundedButton()
        contentViewControllers = []
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
        self.screenName = "Intro - Tutorial View"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setupViews() {
        
        backgroundImageFromView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageFromView)

        backgroundImageToView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageToView)

        imageFromView.clipsToBounds = true
        imageFromView.contentMode = UIViewContentMode.scaleAspectFit
        view.addSubview(imageFromView)

        imageToView.clipsToBounds = true
        imageToView.contentMode = UIViewContentMode.scaleAspectFit
        view.addSubview(imageToView)

        for i in 0...(pageCount - 1) {
            let backgroundImageName = ((i % 2) == 0) ? "bg_red_gradient" : "bg_blue_gradient"
            let backgroundImage = UIImage(named: backgroundImageName)
            let page = TutorialContentViewController(backgroundImage: backgroundImage!, image: images[i]!, text: texts[i], index : i)
            contentViewControllers.append(page)
        }
        
        pageViewController.willMove(toParentViewController: self)
        addChildViewController(pageViewController)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        self.imageFromView.image = contentViewControllers[0].imageView.image
        self.backgroundImageFromView.image = contentViewControllers[0].backgroundImageView.image
        pageViewController.setViewControllers([contentViewControllers[0]], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        view.addSubview(pageViewController.view)
        
        pageControl.numberOfPages = pageCount
        view.addSubview(pageControl)
        
        nextButton.setImage(UIImage(named:"btn_forward"), for: UIControlState())
        nextButton.addTarget(self, action: #selector(TutorialViewController.nextButtonTapped), for: UIControlEvents.touchUpInside)
        view.addSubview(nextButton)
        
        getStartedButton.setTitle("tutorial_confirm".localizedString, for: UIControlState())
        getStartedButton.isHidden = true
        getStartedButton.addTarget(self, action: #selector(TutorialViewController.getStartedButtonTapped), for: UIControlEvents.touchUpInside)
        view.addSubview(getStartedButton)
        
        //now setup the scroll view delegate so that we can track swipes and content changes to the pageviewcontroller
        for subview in self.pageViewController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    
    func setupConstraints () {
        
        backgroundImageFromView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }

        backgroundImageToView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }

        imageFromView.snp_makeConstraints { (make) -> () in
            make.top.lessThanOrEqualTo(self.view).offset(60)
            make.left.equalTo(self.view).offset(35)
            make.right.equalTo(self.view).offset(-35)
            make.height.lessThanOrEqualTo(self.imageFromView.snp_width).offset(0 - self.SMALL_SCREEN_IMAGE_HEIGHT_DIFFERENCE)
        }

        imageToView.snp_makeConstraints { (make) -> () in
            make.top.lessThanOrEqualTo(self.view).offset(60)
            make.left.equalTo(self.view).offset(35)
            make.right.equalTo(self.view).offset(-35)
            make.height.lessThanOrEqualTo(self.imageToView.snp_width).offset(0 - self.SMALL_SCREEN_IMAGE_HEIGHT_DIFFERENCE)
        }

        pageViewController.view.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        pageControl.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(0 - TutorialViewController.PAGE_CONTROL_BOTTOM_OFFSET)
        }
        
        nextButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-31)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        getStartedButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-31)
            make.size.equalTo(CGSize(width: 113, height: 26))
        }
        
    }
    
    func nextButtonTapped() {
        
        if pageViewController.viewControllers != nil && pageViewController.viewControllers!.count < 1 {
            return
        }
        
        if let vc = pageViewController.viewControllers?.first as? TutorialContentViewController {
            
            let index = vc.pageIndex >= contentViewControllers.count ? contentViewControllers.count - 1 : vc.pageIndex + 1
            
            if (index >= contentViewControllers.count) {
                return
            }
            
            let nextVC = contentViewControllers[index]
            transitioningToVC = nextVC

            self.pageViewController.setViewControllers([nextVC], direction: UIPageViewControllerNavigationDirection.forward, animated: true) { (completed) -> Void in
                self.updateViewsWithAnimation(true)
            }
        }
    }
    
    func getStartedButtonTapped() {
        dismiss(animated: true, completion: { () -> Void in
            self.delegate?.didFinishAndDismissTutorial()
        })
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! TutorialContentViewController
        
        if (vc.pageIndex > 0) {
            return contentViewControllers[vc.pageIndex - 1]
        }
        return nil
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! TutorialContentViewController
        
        if (vc.pageIndex < pageCount - 1) {
            return contentViewControllers[vc.pageIndex + 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        transitioningToVC = pendingViewControllers[0] as? TutorialContentViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.updateViewsWithAnimation(false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var percentage = scrollView.contentOffset.x / UIScreen.main.bounds.width
        var fromPercentage = percentage
        var toPercentage = percentage
        if percentage > 1 {
            percentage = percentage - 1
            fromPercentage = 1 - percentage
            toPercentage = percentage
        } else {
            fromPercentage = percentage
            toPercentage = 1 - percentage
        }

        if transitioningToVC != nil
            && percentage != 1
            && transitioningToVC?.imageView.image != self.imageFromView.image {
                self.imageToView.image = transitioningToVC!.imageView.image
                self.backgroundImageToView.image = transitioningToVC!.backgroundImageView.image
                self.imageFromView.alpha = fromPercentage
                self.backgroundImageFromView.alpha = fromPercentage
                self.imageToView.alpha = toPercentage
                self.backgroundImageToView.alpha = toPercentage
        }
    }
    
    func updateViewsWithAnimation(_ animate: Bool) {
        
        let activeContentVC = (pageViewController.viewControllers?.first as! TutorialContentViewController)
        
        self.imageFromView.image = activeContentVC.imageView.image
        self.backgroundImageFromView.image = activeContentVC.backgroundImageView.image
        self.imageFromView.alpha = 1
        self.backgroundImageFromView.alpha = 1
        self.imageToView.alpha = 0
        self.backgroundImageToView.alpha = 0

        pageControl.currentPage = activeContentVC.pageIndex
        
        if (pageControl.currentPage == pageCount - 1 && self.getStartedButton.isHidden) {
            
            self.getStartedButton.alpha = 0.0
            self.getStartedButton.isHidden = false
            
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                self.getStartedButton.alpha = 1.0
                self.nextButton.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.nextButton.isHidden = true
            })
        }
    }
    
    
}

protocol TutorialViewControllerDelegate {
    func didFinishAndDismissTutorial()
}
