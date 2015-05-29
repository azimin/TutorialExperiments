//
//  ViewController.swift
//  ExapleProject
//
//  Created by Alex Zimin on 29/05/15.
//  Copyright (c) 2015 WWDC-Scholars. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var contentView: UIView!
    
    let numberOfScreens: CGFloat = 4
    
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint! {
        didSet {
            contentViewWidthConstraint.constant = screenSize.width * numberOfScreens
        }
    }
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            contentViewHeightConstraint.constant = screenSize.height
        }
    }
    
    var screenSize: CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
    var objects: [TutorialObject] = []
    
    var quoteView: AZTagsView!
    var textWords: [String] = []
    var textChangedIndexes: [Int] = []
    var textWorksIndexes: [Int] = []
    
    var first = "Here's to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently. They're not fond of rules. And they have no respect for the status quo.\nYou can quote them, disagree with them, glorify or vilify them. About the only thing you can't do is ignore them. Because they change things. They push the human race forward.\nAnd while some may see them as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do."
    var second = "We are the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently. We're not fond of rules. And we have no respect for the status quo.\nYou can quote us, disagree with us, glorify or vilify us. About the only thing you can't do is ignore us. Because we change things. We push the human race forward.\nAnd while some may see us as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do."
    
    lazy var firstArray: [String] = self.first.componentsSeparatedByString(" ")
    lazy var secondArray: [String] = self.second.componentsSeparatedByString(" ")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObjects()
        
        pageControl.numberOfPages = Int(numberOfScreens)
    }
    
    func addObjects() {
        
        objects.append(self.addQuote())
        objects.append(self.logoObject())
        addOthersElemts()
        objects.map() { $0.changeObjectToPosition(self.scrollView.contentOffset) }
    }
    
    func logoObject() -> TutorialObject {
        let imageView = UIImageView(image: UIImage(named: "wwdc_logo"))
        imageView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        contentView.addSubview(imageView)
        
        let logoObject = TutorialObject(object: imageView)
        logoObject.setPoints([CGPoint(x: 0.5, y: 0.35), CGPoint(x: 1.5, y: 0.15), CGPoint(x: 2.5, y: 0.15), CGPoint(x: 3.5, y: 0.35)])
        
        let bigLogoSize = screenSize.width - 16
        let smallLogoSize = screenSize.width / 3
        logoObject.addActionAtPosition(TutorialObjectAction.Resize(size: CGSize(width: bigLogoSize, height: bigLogoSize)), position: 0)
        logoObject.addActionAtPosition(TutorialObjectAction.Resize(size: CGSize(width: smallLogoSize, height: smallLogoSize)), position: 1)
        logoObject.addActionAtPosition(TutorialObjectAction.Resize(size: CGSize(width: bigLogoSize, height: bigLogoSize)), position: 3)
        
        return logoObject
    }
    
    func addOthersElemts() {
        let imageView = UIImageView(image: UIImage(named: "wwdc_text_image"))
        imageView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 1.4)
        contentView.addSubview(imageView)
        
        let titleLable = UILabel(frame: CGRectMake(0, 0, (imageView.image?.size.width ?? 0) + 16, 70))
        titleLable.center =  CGPoint(x: screenSize.width / 2, y: imageView.center.y + imageView.frame.height + 16)
        titleLable.text = "An app to showcase the winners of the WWDC Scholarship."
        titleLable.numberOfLines = 0
        titleLable.textAlignment = .Center
        contentView.addSubview(titleLable)
        
        let startButton = UIButton(frame: CGRectMake(0, 0, imageView.frame.width, imageView.frame.height))
        startButton.center = CGPoint(x: screenSize.width * 3.5, y: screenSize.height / 1.4)
        startButton.backgroundColor = UIColor.redColor()
        startButton.setTitle("Start", forState: .Normal)
        contentView.addSubview(startButton)
    }
    
    func addQuote() -> TutorialObject {
        textWords = first.componentsSeparatedByString(" ")
        
        let smallLogoSize = screenSize.width / 3
        quoteView = AZTagsView(frame: CGRectMake(0, 0, screenSize.width - 16, screenSize.height - smallLogoSize - 16))
        quoteView.center = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2 + smallLogoSize)
        quoteView.dataSource = self
        contentView.addSubview(quoteView)
        
        let quoteObject = TutorialObject(object: quoteView)
        quoteObject.setPoints([CGPoint(x: 1.5, y: 0.65), CGPoint(x: 2.5, y: 0.65)])
        //quoteObject.addActionAtPosition(TutorialObjectAction.ChangeAlpha(value: 0.0), position: 1)
        
        return quoteObject
    }
    
    var lastContentOffset: CGPoint = CGPointZero
    var textState = 0
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updatePageControl()
        objects.map() { $0.changeObjectToPosition(scrollView.contentOffset) }
        
        if scrollView.contentOffset.x > screenSize.width * 0.9 {
            let delta = (scrollView.contentOffset.x - screenSize.width * 1.0) / screenSize.width
            changeStateAtPercent(delta)
        }
        
//        if scrollView.contentOffset.x > lastContentOffset.x && scrollView.contentOffset.x > screenSize.width * 1.1 {
//            changeTextStateToState(1)
//        } else if scrollView.contentOffset.x < lastContentOffset.x && scrollView.contentOffset.x < screenSize.width * 1.9 {
//            changeTextStateToState(0)
//        }
        
        lastContentOffset = scrollView.contentOffset
    }
    
    func updatePageControl() {
        var pageNumber = Int(round((scrollView.contentOffset.x / screenSize.width)))
        pageNumber = min(max(0, pageNumber), Int(numberOfScreens - 1))
        pageControl.currentPage = pageNumber
    }
    
    func changeTextStateToState(state: Int) {
        if state == textState {
            return
        }
        
        textState = state
        if state == 0 {
            let newNames: [String] = first.componentsSeparatedByString(" ")
            var indexes: [Int] = []
            
            for i in 0..<min(textWords.count, newNames.count) {
                if newNames[i] != textWords[i] {
                    indexes.append(i)
                }
            }
            
            textWords = newNames
            self.textChangedIndexes = []
            
            quoteView.updateAtIndexes(indexes)
        } else {
            let newNames: [String] = second.componentsSeparatedByString(" ")
            var indexes: [Int] = []
            
            for i in 0..<min(textWords.count, newNames.count) {
                if newNames[i] != textWords[i] {
                    indexes.append(i)
                }
            }
            
            textWords = newNames
            self.textChangedIndexes = indexes
            
            quoteView.updateAtIndexes(indexes)

        }
    }
    
    func changeStateAtPercent(percent: CGFloat) {
        let size = Int(CGFloat(textWords.count) * percent - 0.1)
        
        if size < 0 {
            return
        }
        
        var updatedIntexes: [Int] = []
        
        var changeFlag = false
        for i in 0..<min(firstArray.count, size) {
            if firstArray[i] != secondArray[i] {
                if find(textChangedIndexes, i) == nil {
                    textChangedIndexes.append(i)
                }
                
                if find(textWorksIndexes, i) == nil {
                    textWorksIndexes.append(i)
                    updatedIntexes.append(i)
                }
            }
            
            println(i)
        }
        
        for i in min(firstArray.count, size)..<textWords.count {
            if firstArray[i] != secondArray[i] {
                if find(textChangedIndexes, i) == nil {
                    textChangedIndexes.append(i)
                }
                
                if let index = find(textWorksIndexes, i) {
                    textWorksIndexes.removeAtIndex(index)
                    updatedIntexes.append(i)
                }
            }
        }
        
        quoteView.updateAtIndexes(updatedIntexes)
    }
}

extension ViewController: AZTagsViewDataSource {
    func numberOfTagsInTagsView(tagsView: AZTagsView) -> Int {
        return firstArray.count
    }
    
    func tagsView(tagsView: AZTagsView, tagAtIndex index: Int) -> String {
        return firstArray[index]
    }
    
    func tagsViewWithAttributesString(tagsView: AZTagsView, tagAtIndex index: Int) -> NSAttributedString? {
        if find(textWorksIndexes, index) != nil {
            var attrs = [NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue]
            return NSMutableAttributedString(string:secondArray[index], attributes:attrs)
        }
        
        return nil
    }
}

//extension ViewController: AZTagsViewDelegate {
//    func tagsView(tagsView: AZTagsView, didChangeSizeToSize size: CGSize) {
//        self.tagsViewHeightConstraint.constant = size.height
//        UIView.animateWithDuration(0.25, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//        })
//    }
//    
//    func tagsView(tagsView: AZTagsView, didSelectItemAtIndex index: Int) {
//        
//        
//        if state {
//            let newNames: [String] = first.componentsSeparatedByString(" ")
//            var indexes: [Int] = []
//            
//            for i in 0..<min(names.count, newNames.count) {
//                if newNames[i] != names[i] {
//                    indexes.append(i)
//                }
//            }
//            
//            names = newNames
//            self.indexs = []
//            
//            tagsView.updateAtIndexes(indexes)
//            state = !state
//            
//            return
//        }
//        
//        let newNames: [String] = second.componentsSeparatedByString(" ")
//        var indexes: [Int] = []
//        
//        for i in 0..<min(names.count, newNames.count) {
//            if newNames[i] != names[i] {
//                indexes.append(i)
//            }
//        }
//        
//        names = newNames
//        self.indexs = indexes
//        
//        tagsView.updateAtIndexes(indexes)
//        state = !state
//        
//        
//    }
//}

