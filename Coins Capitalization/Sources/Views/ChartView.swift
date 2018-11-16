//
//  ChartView.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 04.03.18.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class ChartView: UIView {
    
    // MARK: - Public Properites
    
    var data: [[Double]] = [] {
        didSet {
            let numberOfPoints = Int(bounds.width)
            points = [Double](repeating: 0.0, count: numberOfPoints)
            yCoordinates = [CGFloat](repeating: 0.0, count: numberOfPoints)
            dates = [String](repeating: "", count: numberOfPoints)
            let k = Double(data.count) / Double(numberOfPoints)
            
            for i in 0..<points.count {
                let index = Int(Double(i) * k)
                points[i] = data[index][1]
                dates[i] = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(data[index][0] / 1000)))
            }
            if k < 1 { points[points.count - 1] = data[data.count - 2][1] }
            
            // for layout bubble view
            let value = points.first ?? 0
            Formatter.formatCost(label: priceLabel, value: value, maximumFractionDigits: value > 1.0 ? 2 : 5)
            
            setNeedsDisplay()
        }
    }
    
    // MARK: - Public Methods
    
    override func draw(_ rect: CGRect) {
        
        let topPadding: CGFloat = 45.0
        let height = rect.height - topPadding
        
        guard let minValue = points.min(), let maxValue = points.max() else { return }
        let columnYPoint = { (point: Double) -> CGFloat in
            let y = (CGFloat(point - minValue) / CGFloat(maxValue - minValue)) * height
            return height - y + topPadding
        }
        
        Colors.controlHighlighted.setFill()
        Colors.controlHighlighted.setStroke()
        
        // Line
        
        let chartPath = UIBezierPath()
        chartPath.move(to: CGPoint(x: 0, y: columnYPoint(points[0])))
        yCoordinates[0] = columnYPoint(points[0])
        
        for i in 1..<points.count {
            let yCoordinate = columnYPoint(points[i])
            yCoordinates[i] = yCoordinate
            
            let nextPoint = CGPoint(x: CGFloat(i), y: yCoordinate)
            chartPath.addLine(to: nextPoint)
        }
        
        chartPath.stroke()
        
        // Gradient
        
        let clippingPath = chartPath.copy() as! UIBezierPath
        
        clippingPath.addLine(to: CGPoint(x: CGFloat(points.count - 1), y: height))
        clippingPath.addLine(to: CGPoint(x: 0, y: height))
        clippingPath.close()
        clippingPath.addClip()
        
        let graphStartPoint = CGPoint(x: 0, y: 0)
        let graphEndPoint = CGPoint(x: 0, y: height)
        let context = UIGraphicsGetCurrentContext()!
        let colors = [Colors.controlEnabled.cgColor, Colors.controlDisabled.cgColor, UIColor.clear.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 0.2, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        context.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
        
//        testHandle()
//        showBubble(true)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        guard needsSetViews else { return }
        
        [lineView, bubbleView, pointView].forEach { addSubview($0) }
        [dateLabel, priceLabel].forEach {
            bubbleView.addSubview($0)
            $0.textAlignment = .center
        }
        
        priceLabel.font = UIFont.systemFont(ofSize: 12.0)
        priceLabel.textColor = .white
        
        dateLabel.font = UIFont.systemFont(ofSize: 10.0)
        dateLabel.textColor = .lightGray
        
        pointView.backgroundColor = .white
        lineView.backgroundColor = Colors.bubbleBackground
        bubbleView.backgroundColor = Colors.bubbleBackground
        bubbleView.layer.cornerRadius = 5.0
        pointView.layer.cornerRadius = 2.5
        
        [bubbleView, dateLabel, priceLabel, lineView, pointView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        priceLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 5.0).isActive = true
        dateLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 0.0).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5.0).isActive = true
        
        priceLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10.0).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 10.0).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10.0).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10.0).isActive = true
        
        bubbleView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubbleViewconstraint = bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0)
        bubbleViewconstraint?.isActive = true
        
        bubbleView.bottomAnchor.constraint(equalTo: lineView.topAnchor, constant: 5.0).isActive = true
        bottomAnchor.constraint(equalTo: lineView.bottomAnchor).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: 2.0).isActive = true
        lineViewconstraint = lineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0)
        lineViewconstraint?.isActive = true
        
        pointView.heightAnchor.constraint(equalToConstant: 5.0).isActive = true
        pointView.widthAnchor.constraint(equalToConstant: 5.0).isActive = true
        pointView.centerXAnchor.constraint(equalTo: lineView.centerXAnchor).isActive = true
        pointViewconstraint = pointView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0)
        pointViewconstraint?.isActive = true
        
        showBubble(false)
        
        needsSetViews = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handle(touches: touches)
        showBubble(true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handle(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        showBubble(false)
    }
    
    // MARK: - Private Properties
    
    private var needsSetViews = true
    private var points: [Double] = []
    private var dates: [String] = []
    private var yCoordinates: [CGFloat] = []
    
    private let dateLabel  = UILabel()
    private let priceLabel = UILabel()
    private let bubbleView = UIView()
    private let lineView   = UIView()
    private let pointView  = UIView()
    
    private var bubbleViewconstraint: NSLayoutConstraint?
    private var lineViewconstraint: NSLayoutConstraint?
    private var pointViewconstraint: NSLayoutConstraint?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
}

private extension ChartView {
    
    // MARK: - Private Methods
    
    func showBubble(_ show: Bool) {
        bubbleView.isHidden = !show
        lineView.isHidden = !show
        pointView.isHidden = !show
    }
    
    func handle(touches: Set<UITouch>) {
        guard let touch = touches.first, self.bounds.contains(touch.location(in: self)) else {
            showBubble(false)
            return
        }
        let xPoint = touch.location(in: self).x
        let index = Int(round(xPoint))
        
        guard index < dates.count else { return }
        
        dateLabel.text = dates[index]
        let value = points[index]
        Formatter.formatCost(label: priceLabel, value: value, maximumFractionDigits: value > 1.0 ? 2 : 5)
        
        pointViewconstraint?.constant = yCoordinates[index] - pointView.bounds.width / 2
        lineViewconstraint?.constant = xPoint - lineView.bounds.width / 2
        
        let bubbleHalfWidth = bubbleView.bounds.width / 2
        if xPoint <= bubbleHalfWidth {
            bubbleViewconstraint?.constant = 0
        } else if xPoint >= bounds.width - bubbleHalfWidth {
            bubbleViewconstraint?.constant = bounds.width - bubbleView.bounds.width
        } else {
            bubbleViewconstraint?.constant = xPoint - bubbleHalfWidth
        }
    }
    
    func testHandle() {
        guard !data.isEmpty else { return }
        let xPoint: CGFloat = bounds.width / 3 * 2
        let index = Int(round(xPoint))
        
        dateLabel.text = dates[index]
        let value = points[index]
        Formatter.formatCost(label: priceLabel, value: value, maximumFractionDigits: value > 1.0 ? 2 : 5)
        layoutIfNeeded()
        pointViewconstraint?.constant = yCoordinates[index] - pointView.bounds.width / 2
        lineViewconstraint?.constant = xPoint - lineView.bounds.width / 2
        bubbleViewconstraint?.constant = xPoint - bubbleView.bounds.width / 2
    }
    
}
