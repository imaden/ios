//
//  SearchFilterView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SearchFilterView: UIView, UITextFieldDelegate {

    fileprivate var searchFieldView : UIView
    fileprivate var searchField : UITextField
    
    fileprivate var searchImageView: UIImageView
    
    fileprivate var topLine: UIView
    fileprivate var bottomLine: UIView
    
    var indicatorText: String = "" {
        didSet {
            
        }
    }
    var delegate : SearchViewControllerDelegate?

    var showingSmall: Bool = true {
        didSet {
            if showingSmall {
                self.searchFieldView.backgroundColor = UIColor.clear
            } else {
                self.searchFieldView.backgroundColor = Styles.Colors.cream1
            }
        }
    }

    fileprivate var shouldCloseFilters: Bool
    
    fileprivate var didsetupSubviews : Bool
    fileprivate var didSetupConstraints : Bool

    static var TOTAL_HEIGHT : CGFloat = 80
    static var FIELD_HEIGHT : CGFloat = 40

    override init(frame: CGRect) {
        
        searchFieldView = UIView()
        searchField = UITextField()
        
        searchImageView = UIImageView()
        searchImageView.image = UIImage(named: "icon_searchfield")
        topLine = UIView()
        bottomLine = UIView()
        
        shouldCloseFilters = true
        
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
        self.backgroundColor = UIColor.clear //stone if no blur?
        
        self.searchFieldView.layer.borderWidth = 0.5
        self.searchFieldView.layer.borderColor = Styles.Colors.cream1.cgColor
        searchFieldView.backgroundColor = UIColor.clear //stone if no blur?
        self.addSubview(searchFieldView)

        let attributes = [NSFontAttributeName: Styles.FontFaces.light(14), NSForegroundColorAttributeName: Styles.Colors.petrol2]
        
        searchField.clearButtonMode = UITextFieldViewMode.never
        searchField.font = Styles.FontFaces.regular(14)
        searchField.textColor = Styles.Colors.petrol2
        searchField.textAlignment = NSTextAlignment.natural
        searchField.attributedPlaceholder = NSAttributedString(string: "search_bar_text".localizedString, attributes: attributes)
        searchField.delegate = self
        searchField.keyboardAppearance = UIKeyboardAppearance.default
        searchField.keyboardType = UIKeyboardType.default
        searchField.autocorrectionType = UITextAutocorrectionType.no
        searchField.returnKeyType = UIReturnKeyType.search
        self.addSubview(searchField)
        
        searchImageView.contentMode = UIViewContentMode.center
        self.addSubview(searchImageView)
        
        topLine.backgroundColor = Styles.Colors.transparentWhite
        self.addSubview(topLine)
        
        bottomLine.backgroundColor = Styles.Colors.transparentBlack
        self.addSubview(bottomLine)

        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        searchFieldView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self).offset(12)
            make.right.equalTo(self).offset(-12)
            make.bottom.equalTo(self).offset(-10)
            make.height.equalTo(SearchFilterView.FIELD_HEIGHT)
        }
        
        searchField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.searchImageView.snp_right).offset(14)
            make.right.equalTo(self).offset(-12)
            make.bottom.equalTo(self).offset(-10)
            make.height.equalTo(SearchFilterView.FIELD_HEIGHT)
        }
        
        searchImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.centerY.equalTo(self.searchField)
            make.left.equalTo(self).offset(17 + 12)
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

    
    // UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.searchFieldView.frame.size.width > 0 {
            //calling this in a dispatch block prevents the
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(10 * NSEC_PER_MSEC)) / Double(NSEC_PER_SEC), execute: {
                self.searchField.modifyClearButtonWithImageNamed("icon_close", color: Styles.Colors.petrol2)
            })
            self.delegate?.startSearching()
            return true
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resultString = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        if resultString.characters.count >= 2 {
            SearchOperations.searchWithInput(resultString, forAutocomplete: true, completion: { (results) -> Void in
                self.delegate?.didGetAutocompleteResults(results)
            })
        } else {
            self.delegate?.didGetAutocompleteResults([])
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        SearchOperations.searchWithInput((textField.text ?? ""), forAutocomplete: false, completion: { (results) -> Void in
            
            let date : Date = Date()
            
            self.delegate!.displaySearchResults(results, checkinTime : date)
            
        })
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (self.searchField.text ?? "").isEmpty {
            endSearch()
        } else {
            delegate?.didGetAutocompleteResults([])
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            if shouldCloseFilters {
                //this happens the last time you press the x, to close the filters
                makeInactive(closeFilters: true)
            } else {
                //this happens the second time you press the x, to dismiss the keyboard
                endSearch()
            }
        } else {
            //this happens the first time you press the x, to clear the text
            clearSearch()
        }
        return true
    }
    
    func clearSearch() {
        delegate?.clearSearchResults()
        delegate?.didGetAutocompleteResults([])
        self.searchField.text = ""
        shouldCloseFilters = false
    }

    func endSearch() {
        clearSearch()
        self.searchField.endEditing(true)
        self.searchField.rightViewMode = UITextFieldViewMode.always
        shouldCloseFilters = true
    }

    //MARK- helper functions
    
    func makeActive() {
        searchField.becomeFirstResponder()
    }
    
    func makeInactive(closeFilters: Bool) {
        searchField.resignFirstResponder()
        delegate?.didGetAutocompleteResults([])
        self.searchField.rightViewMode = UITextFieldViewMode.whileEditing
        if closeFilters {
            self.delegate?.endSearchingAndFiltering()
        }
        shouldCloseFilters = false
        
        //this is where we change the right view!
        var rightViewWidth: CGFloat = 130
        let locationButtonWidth: CGFloat = 46
        
        //create the indicator button
        let indicatorButton = ViewFactory.redRoundedButtonWithHeight(20, font: Styles.FontFaces.regular(12), text: "")
        let attrs = [NSFontAttributeName: indicatorButton.titleLabel!.font]
        let maximumLabelSize = CGSize(width: rightViewWidth - locationButtonWidth - 10, height: 20)
        let labelRect = (indicatorText as NSString).boundingRect(with: maximumLabelSize, options: NSStringDrawingOptions(), attributes: attrs, context: nil)

        //add the close icon --> if we ever wish to re-add this, just add (5+closeImageView.frame.width) to the width of indicatorButton.frame
//        let closeImageView = UIImageView(image: UIImage(named:"icon_close"))
//        closeImageView.contentMode = .ScaleAspectFit
//        closeImageView.frame = CGRect(x: 10+labelRect.width+5, y: 5, width: 10, height: 10)
//        indicatorButton.addSubview(closeImageView)
        
        //add the label
        let label = UILabel(frame: CGRect(x: 10, y: 2.5, width: labelRect.width, height: labelRect.height))
        label.text = indicatorText
        label.font = Styles.FontFaces.regular(12)
        label.textColor = Styles.Colors.beige1
        indicatorButton.addSubview(label)
        
        indicatorButton.frame = indicatorText == "" ? CGRect.zero : CGRect(x: 10, y: 10, width: 10+labelRect.width+10, height: 20)
        indicatorButton.addTarget(self, action: "textFieldShouldBeginEditing:", for: UIControlEvents.touchUpInside)

        rightViewWidth = 10 + locationButtonWidth + 10 + indicatorButton.frame.width
        
        //this is a placeholder, the actual button should be on the mapview.
        let locationButton = UIButton(frame: CGRect(x: rightViewWidth - locationButtonWidth, y: 0, width: locationButtonWidth, height: SearchFilterView.FIELD_HEIGHT))
        
        let rightView = UIView()
        rightView.clipsToBounds = false
        rightView.frame = CGRect(x: 0, y: 0, width: rightViewWidth, height: SearchFilterView.FIELD_HEIGHT)
        rightView.backgroundColor = UIColor.clear
        rightView.addSubview(locationButton)
        rightView.addSubview(indicatorButton)
        searchField.rightView = rightView
        searchField.rightViewMode = UITextFieldViewMode.always
        
    }
    
    func setSearchResult(_ result: SearchResult) {
        makeInactive(closeFilters: false)
        self.searchField.text = result.title
        self.delegate!.displaySearchResults([result], checkinTime : Date())
    }

}
