//
//  Graph.swift
//  Graph
//
//  Created by admin on 12/7/19.
//  Copyright © 2019 chapin. All rights reserved.
//

import UIKit

class Graph: UIView {
    
    var data: [CGFloat]! = []
    
    var offset = 0, count = -1
    
    let minSpacing: CGFloat = 3.0
    
    let gridSpacing = 10
    
    var gridColor = UIColor.lightGray.cgColor
    var lineColor = UIColor.green.cgColor
    
    var detailView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(sender:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:))))
        addSubview(detailView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Could not get current UIGraphics context.")
            return
        }
        // Fill the background
        context.setFillColor(backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context.fill(rect)
        // Draw the grid
        context.setStrokeColor(gridColor)
        context.setLineWidth(1.0)
        for i in 0...gridSpacing {
            let x = interpolate(to: frame.width, index: CGFloat(i) / CGFloat(gridSpacing))
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: frame.height))
            context.strokePath()
            let y = interpolate(to: frame.height, index: CGFloat(i) / CGFloat(gridSpacing))
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: frame.width, y: y))
            context.strokePath()
        }
        // Draw the data
        if data.count == 0 {
            return
        }
        context.setStrokeColor(lineColor)
        context.setLineWidth(1.0)
        let numPoints = self.numPoints()
        let startIndex = max(0, data.count - 1 - numPoints - offset)
        let endIndex = min(startIndex + numPoints - 1, data.count - 1)
        let end = endIndex - startIndex
        for i in startIndex..<endIndex {
            let j = i - startIndex
            let firstPoint = CGPoint(x: interpolate(to: frame.width, index: CGFloat(j) / CGFloat(end)), y: frame.height - data[i])
            let secondPoint = CGPoint(x: interpolate(to: frame.width, index: CGFloat(j + 1) / CGFloat(end)), y: frame.height - data[i + 1])
            context.move(to: firstPoint)
            context.addLine(to: secondPoint)
            context.strokePath()
        }
    }
    
    @objc func didTap(sender: UITapGestureRecognizer) {
        selectPoint(atX: sender.location(in: self).x)
    }
    
    @objc func didPan(sender: UIPanGestureRecognizer) {
        selectPoint(atX: sender.location(in: self).x)
    }
    
    func selectPoint(atX x: CGFloat) {
        // Get the spacing between each point to get the two that need to be interpolated
        let spacing = frame.width / CGFloat(numPoints() - 1)
        let index = Int(x / spacing) - offset
        // Get the value between those two points
        let y = interpolate(from: data(index: index), to: data(index: index + 1), index: x.truncatingRemainder(dividingBy: spacing) / spacing)
        // Setup the detail view
        for subview in detailView.subviews {
            subview.removeFromSuperview()
        }
        detailView.frame = CGRect(x: x - 3, y: frame.height - y - 3, width: 6, height: 6)
        detailView.layer.cornerRadius = 3
        detailView.backgroundColor = UIColor.black
        detailView.clipsToBounds = false
        let detail: UILabel = UILabel(frame: CGRect(x: detailView.frame.width / 2, y: detailView.frame.height / 2, width: 0, height: 0))
        detail.text = String(format: "$%.02f", y)
        detail.sizeToFit()
        // @TODO Check if the label will clip if to the left/right
        if detailView.frame.origin.x > frame.width / 2 {
            detail.frame.origin.x -= detail.frame.width
        }
        // @TODO Check if the label will clip if to the top/bottom
        if detailView.frame.origin.y > frame.height / 2 {
            detail.frame.origin.y -= detail.frame.height
        }
        detailView.addSubview(detail)
    }
    
    func numPoints() -> Int {
        let maxPoints = Int(frame.width / minSpacing)
        return min(count < 0 ? data.count : count, maxPoints)
    }
    
    func interpolate(from a: CGFloat = 0, to b: CGFloat, index i: CGFloat) -> CGFloat {
        return a + (b - a) * i
    }
    
    func data(index i: Int) -> CGFloat {
        return data[max(0, min(i, data.count - 1))]
    }
    
    func append(_ point: CGFloat) {
        data.append(point)
    }
    
    func append(_ points: [CGFloat], reversed: Bool = false) {
        let orderedPoints = reversed ? points.reversed() : points
        for point in orderedPoints {
            data.append(point)
        }
    }
    
}
