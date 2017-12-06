//
//  TimeFilterView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-17.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class TimeFilterView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    var containerView: UIView
    
    var timeImageView: UIImageView
    
    var scrollView: UIScrollView
    var contentView: UIView

    var messageLabel: UILabel
    var infoButton = ViewFactory.infoButton()

    var times: [TimeFilter]
    var selectedPermitValue: Bool
    var selectedValue: TimeInterval?
    var lastSelectedValue: TimeInterval?
    
    var topLine: UIView
    var bottomLine: UIView

    var delegate: TimeFilterViewDelegate?
    
    var enableSnapping : Bool
    
    fileprivate var didsetupSubviews : Bool
    fileprivate var didSetupConstraints : Bool

    static var TOTAL_HEIGHT : CGFloat = 46
    static var SCROLL_HEIGHT: CGFloat = 46
    
    override init(frame: CGRect) {

        containerView = UIView()
        
        messageLabel = UILabel()
        timeImageView = UIImageView()

        scrollView = UIScrollView()
        contentView = UIView()

        selectedPermitValue = false
        times = [
            TimeFilter(interval: -1, labelText: "all".localizedString.uppercased()),
            TimeFilter(interval: 30 * TimeFilter.SECONDS_PER_MINUTE),
            TimeFilter(interval: 1 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 2 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 4 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 8 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 12 * TimeFilter.SECONDS_PER_HOUR),
            TimeFilter(interval: 24 * TimeFilter.SECONDS_PER_HOUR),
        ]
        
        topLine = UIView()
        bottomLine = UIView()

        enableSnapping = false
        
        didsetupSubviews = false
        didSetupConstraints = true
     
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (!didsetupSubviews) {
            setupSubviews()
            self.setNeedsUpdateConstraints()
        }
        
        resizeContentViewWidth()
        scrollToNearestLabel()
        
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
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(TimeFilterView.toggleSelectFromTap(_:)))
        tapRec.delegate = self
        self.addGestureRecognizer(tapRec)

        self.addSubview(containerView)
        containerView.backgroundColor = Styles.Colors.cream1
        containerView.clipsToBounds = true
        
        containerView.addSubview(scrollView)
        scrollView.backgroundColor = Styles.Colors.cream1
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.addSubview(contentView)
        
        for time in times {
            contentView.addSubview(time.label)
        }
        
        timeImageView.isUserInteractionEnabled = false
        timeImageView.contentMode = UIViewContentMode.left
        containerView.addSubview(timeImageView)

        messageLabel.textColor = Styles.Colors.petrol2
        messageLabel.font = Styles.FontFaces.light(14)
        containerView.addSubview(messageLabel)
        
        infoButton.addTarget(self, action: #selector(TimeFilterView.infoButtonTapped), for: UIControlEvents.touchUpInside)
        containerView.addSubview(infoButton)

        topLine.backgroundColor = Styles.Colors.transparentWhite
        self.addSubview(topLine)

        bottomLine.backgroundColor = Styles.Colors.transparentBlack
        self.addSubview(bottomLine)
        
        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        timeImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalTo(self.containerView)
            make.left.equalTo(self.containerView).offset(28.5)
        }
        
        messageLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.timeImageView.snp_right).offset(15)
            make.right.equalTo(self.containerView)
            make.centerY.equalTo(self.containerView)
        }
        
        infoButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.containerView.snp_right).offset(-28.5)
            make.centerY.equalTo(self.containerView)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView).offset(28.5 + 20 + 14)
            make.right.equalTo(self.containerView)
            make.top.equalTo(self.containerView)
            make.height.equalTo(TimeFilterView.SCROLL_HEIGHT)
        }
        
        contentView.snp_makeConstraints { (make) -> () in
            make.width.greaterThanOrEqualTo(self.scrollView).multipliedBy(2).offset(70)
            make.height.equalTo(self.scrollView)
            make.edges.equalTo(self.scrollView)
        }
        
        times[0].label.snp_makeConstraints(closure: { (make) -> () in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(-30)
        })
        
        var leftViewToLabel: UIView = times[0].label
        for i in 1..<times.count {
            let label = times[i].label
            label.snp_makeConstraints(closure: { (make) -> () in
                make.centerY.equalTo(self.contentView)
                make.left.equalTo(leftViewToLabel.snp_right).offset(30)
            })
            leftViewToLabel = label
        }
        
        topLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(0.5)
        }
        
        bottomLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(0.5)
        }
        
    }
    
    func resizeContentViewWidth() {
        
        var contentViewWidth = 30 * (times.count - 3)
        var lastAddedWidth = 0
        for time in times {
            let label = time.label
            lastAddedWidth = Int(label.bounds.width)
            contentViewWidth += lastAddedWidth
        }
        contentViewWidth += Int(scrollView.bounds.width)
        
        contentView.snp_remakeConstraints { (make) -> () in
            make.width.greaterThanOrEqualTo(contentViewWidth)
            make.height.equalTo(self.scrollView)
            make.edges.equalTo(self.scrollView)
        }

    }
    
    func update() {
        
        if Settings.shouldFilterForCarSharing() {
            timeImageView.image = UIImage(named: "icon_exclamation")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            messageLabel.text = "car_sharing_enabled_text".localizedString
            infoButton.isHidden = false
            contentView.isHidden = true
            self.delegate?.filterLabelUpdate("")
        } else {
            timeImageView.image = UIImage(named: "icon_time")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            messageLabel.text = ""
            infoButton.isHidden = true
            contentView.isHidden = false
        }
        
        timeImageView.tintColor = Styles.Colors.petrol2


    }
    
    
    //MARK- UIScrollViewDelegate
    var alreadySelected = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        recolorLabels()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToNearestLabel()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollToNearestLabel()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToNearestLabel()
        }
    }
    
    
    //MARK- helper functions
    
    func scrollToNearestLabel() {

        if enableSnapping {
            let centerPoint = getScrollViewCenter()
            scrollToNearestLabel(centerPoint)
        }
    }
    
    func scrollToNearestLabel(_ centerPoint: CGPoint) -> PRKLabel {
        
        //get the label nearest to the centerPoint
        var nearestLabelDistanceFromPoint = CGFloat.greatestFiniteMagnitude
        var nearestLabelDistanceFromCenter = CGFloat.greatestFiniteMagnitude

        let nearestLabel: PRKLabel = getNearestLabel(centerPoint, nearestLabelDistanceFromPoint: &nearestLabelDistanceFromPoint, nearestLabelDistanceFromCenter: &nearestLabelDistanceFromCenter)
        
        //now scroll this label to the center
        if enableSnapping {
            if nearestLabelDistanceFromPoint > 1 {
                let point = CGPoint(x: scrollView.contentOffset.x + nearestLabelDistanceFromCenter, y: 0)
                scrollView.setContentOffset(point, animated: true)
            }
        }
        
        recolorLabels()
        
        return nearestLabel
    }
    
    func getNearestLabel(_ fromPoint: CGPoint) -> PRKLabel  {
        
        var nearestLabelDistanceFromPoint = CGFloat.greatestFiniteMagnitude
        var nearestLabelDistanceFromCenter = CGFloat.greatestFiniteMagnitude
        
        return getNearestLabel(fromPoint, nearestLabelDistanceFromPoint: &nearestLabelDistanceFromPoint, nearestLabelDistanceFromCenter: &nearestLabelDistanceFromCenter)
    }
    
    func getNearestLabel(_ fromPoint: CGPoint, nearestLabelDistanceFromPoint: inout CGFloat, nearestLabelDistanceFromCenter: inout CGFloat) -> PRKLabel  {
        
        let contentViewCurrentCenterPoint = getScrollViewCenter()
        
        //get the label nearest to the centerPoint
        nearestLabelDistanceFromPoint = CGFloat.greatestFiniteMagnitude
        nearestLabelDistanceFromCenter = CGFloat.greatestFiniteMagnitude
        var nearestLabel = PRKLabel()
        
        for time in times {
            let label = time.label
            let distance = fromPoint.distanceToPoint(label.center)
            if distance < nearestLabelDistanceFromPoint {
                nearestLabelDistanceFromPoint = distance
                nearestLabelDistanceFromCenter = label.center.x - contentViewCurrentCenterPoint.x
                nearestLabel = label
            }
        }

        return nearestLabel
    }
    
    
    //select or deselect a label and change the UI accordingly
    //gesture recognizer tap
    func toggleSelectFromTap(_ recognizer: UITapGestureRecognizer) {
        
        if !Settings.shouldFilterForCarSharing() {
            let tap = recognizer.location(in: self.contentView)
            toggleSelectFromPoint(tap)
        }
    }

    func resetValue() {
        let point = CGPoint(x: 0, y: 0)
        scrollToNearestLabel(point)
//        toggleSelectFromPoint(point)
        //instead of doing the line above, reset actually shows NOTHING even though the default time is 30 minutes
        selectedValue = 1800.0
        selectedPermitValue = false
        delegate?.filterValueWasChanged(hours: selectedValueInHours(), selectedLabelText: "", permit: selectedPermitValue, fromReset: true)
        update()
    }
    
    func toggleSelectFromPoint(_ point: CGPoint) {
        
        let label = scrollToNearestLabel(point)
        
        let time = times.filter { (time) -> Bool in
            time.label == label
        }.first!
        
        selectedValue = label.valueTag
        selectedPermitValue = time.permit
        
        delegate?.filterValueWasChanged(hours: selectedValueInHours(), selectedLabelText: time.labelText(), permit: time.permit, fromReset: false)
        
    }
    
    func getScrollViewCenter() -> CGPoint {
        let visibleRect = CGRect(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        let contentViewCurrentCenterPoint = CGPoint(x: visibleRect.size.width/2 + scrollView.contentOffset.x, y: visibleRect.size.height/2 + scrollView.contentOffset.y);

        return contentViewCurrentCenterPoint
    }

    func getScrollViewLeft() -> CGPoint {
        let contentViewCurrentLeftPoint = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y);
        return contentViewCurrentLeftPoint
    }

    func recolorLabels() {

        let contentViewCurrentCenterPoint = getScrollViewLeft()
        
        var timeLabels = times.map { (time) -> PRKLabel in
            time.label
        }
        
        for label in timeLabels {
            let distance = contentViewCurrentCenterPoint.distanceToPoint(label.center)
            label.tag = Int(distance)
        }

        timeLabels.sort { (left: PRKLabel, right: PRKLabel) -> Bool in
            left.tag > right.tag
        }
        
        let maxDistance = timeLabels.first?.tag
        for i in 0..<timeLabels.count {
            let alpha = 1.1 - Float(timeLabels[i].tag) / Float(maxDistance!)
            timeLabels[i].textColor = Styles.Colors.petrol2.withAlphaComponent(CGFloat(alpha))
        }
    }
    
    func selectedValueInHours() -> Float? {
        var timeInterval = selectedValue
        timeInterval = timeInterval < 0 ? nil : timeInterval
        
        var hours: Float? = nil
        
        if timeInterval != nil {
            hours = Float(timeInterval! / 3600)
        }
        
        return hours
    }
    
    func infoButtonTapped() {
        self.delegate?.showCarSharingInfo()
    }
    
}

protocol TimeFilterViewDelegate {
    
    func filterValueWasChanged(hours:Float?, selectedLabelText: String, permit: Bool, fromReset: Bool)
    func filterLabelUpdate(_ labelText: String)
    func showCarSharingInfo()
}

class TimeFilter {
    
    var interval: TimeInterval
    var label: PRKLabel
    var permit: Bool
    fileprivate var overriddenLabelText: String?
    
    static var SECONDS_PER_MINUTE : TimeInterval = 60
    static var SECONDS_PER_HOUR : TimeInterval = 3600
    static var FONT : UIFont = Styles.FontFaces.light(14)

    convenience init(interval: TimeInterval) {
        self.init(interval: interval, labelText: nil)
    }

    convenience init(interval: TimeInterval, labelText: String?) {
        self.init(interval: interval, labelText: nil, permit: nil)
    }

    init(interval: TimeInterval, labelText: String?, permit: Bool?) {
        
        self.interval = interval
        self.label = PRKLabel()

        if labelText != nil {
            self.overriddenLabelText = labelText!
        }
        
        if permit != nil {
            self.permit = permit!
        } else {
            self.permit = false
        }
        
        label.font = TimeFilter.FONT
        label.textColor = Styles.Colors.petrol2
        label.valueTag = interval
        label.text = self.labelText()
        
    }
    
    func labelText() -> String {
        
        if overriddenLabelText != nil {
            return overriddenLabelText!
        }
        
        if interval < 0 {
            return ""
        } else if interval < TimeFilter.SECONDS_PER_HOUR {
            return String(format: "%dmin", Int(interval/TimeFilter.SECONDS_PER_MINUTE))
        } else {
            return String(format: "%dh", Int(interval/TimeFilter.SECONDS_PER_HOUR))
        }
    }
    
}
