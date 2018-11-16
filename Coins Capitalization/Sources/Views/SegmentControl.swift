//
//  SegmentControl.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 04.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class SegmentedControl: UIControl {
    
    // MARK: - Public Nested
    
    enum Thumb {
        case line
        case rectangle
    }
    
    // MARK: - Public Properties
    
    var items: [String] = [NSLocalizedString("1D", comment: ""),
                           NSLocalizedString("1W", comment: ""),
                           NSLocalizedString("1M", comment: ""),
                           NSLocalizedString("3M", comment: ""),
                           NSLocalizedString("6M", comment: ""),
                           NSLocalizedString("1Y", comment: ""),
                           NSLocalizedString("ALL", comment: "")]
        {
        didSet {
            setupLabels()
        }
    }
    
    var itemsFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            labels.forEach { $0.font = itemsFont }
        }
    }
    
    var thumbProgress: CGFloat = 0.0 {
        didSet {
            guard !isHandlingTap else { return }
            
            if (lastThumbProgress - 0.5) * (thumbProgress - 0.5) < 0 {
                feedBackGenerator?.selectionChanged()
            }
            
            lastThumbProgress = thumbProgress
            
            let maxX = bounds.width - thumbView.bounds.width
            thumbView.frame.origin.x = min(max(0, thumbProgress * maxX), maxX)
            
            for index in 0..<labels.count {
                if labels[index].frame.origin.x == thumbView.frame.origin.x {
                    lastSelectedIndex = selectedIndex
                    selectedIndex = index
                    displayNewSelectedItem(animated: false)
                }
            }
        }
    }
    
    var thumb: Thumb = .rectangle
    var lastSelectedIndex: Int = 0
    var selectedIndex: Int = 0
    var selectedTextColor = UIColor.white
    var unselectedTextColor = UIColor.lightGray
    var thumbColor = Colors.controlEnabled
    
    var feedbackGeneratorIsOn = true {
        didSet {
            feedBackGenerator = feedbackGeneratorIsOn ? UISelectionFeedbackGenerator() : nil
        }
    }
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Public Methods
    
    func setupView() {
        backgroundColor = .clear
        setupLabels()
        addSubview(thumbView)
        sendSubview(toBack: thumbView)
        feedBackGenerator = feedbackGeneratorIsOn ? UISelectionFeedbackGenerator() : nil
    }
    
    func setupLabels() {
        
        labels.forEach { $0.removeFromSuperview() }
        labels.removeAll(keepingCapacity: true)
        
        for (index, item) in items.enumerated() {
            let label = UILabel(frame: CGRect.zero)
            label.text = item
            label.font = itemsFont
            label.textAlignment = .center
            label.textColor = index == selectedIndex ? selectedTextColor : unselectedTextColor
            self.addSubview(label)
            labels.append(label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = self.bounds
        let newWidth = selectFrame.width / CGFloat(items.count)
        selectFrame.size.width = newWidth
        
        switch thumb {
        case .line:
            var frame = selectFrame
            frame.size.height = 2.0
            frame.origin.y = selectFrame.maxY - frame.size.height
            thumbView.frame = frame
            thumbView.backgroundColor = thumbColor
            thumbView.layer.cornerRadius = thumbView.frame.height / 2
        case .rectangle:
            thumbView.frame = selectFrame
            thumbView.backgroundColor = thumbColor
            thumbView.layer.cornerRadius = thumbView.frame.height / 2
        }
        
        let labelHeight = bounds.height
        let labelWidth = bounds.width / CGFloat(labels.count)
        
        for index in 0...labels.count - 1 {
            let label = labels[index]
            
            let xPosition = CGFloat(index) * labelWidth
            label.frame = CGRect(x: xPosition, y: 0, width: labelWidth, height: labelHeight)
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isHandlingTap = true
        
        let location = touch.location(in: self)
        
        var calculatedIndex: Int?
        
        for (index, item) in labels.enumerated() {
            
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        if let index = calculatedIndex {
            lastSelectedIndex = selectedIndex
            selectedIndex = index
            displayNewSelectedItem(animated: true)
            feedBackGenerator?.selectionChanged()
            sendActions(for: .valueChanged)
        }
        
        return false
    }
    
    func displayNewSelectedItem(animated: Bool) {
        let label = labels[selectedIndex]
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       animations: {
                        self.thumbView.frame.origin.x = label.frame.origin.x
                        self.labels[self.lastSelectedIndex].textColor = self.unselectedTextColor },
                       completion: { _ in
                        self.labels[self.selectedIndex].textColor = self.selectedTextColor
                        self.isHandlingTap = false
        }
        )
    }
    
    // MARK: - Private properties
    
    private var labels = [UILabel]()
    private var thumbView = UIView()
    private var feedBackGenerator: UISelectionFeedbackGenerator?
    private var isHandlingTap = false
    private var lastThumbProgress: CGFloat = 0.0
}
