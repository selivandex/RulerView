//
//  RulerView.swift
//  metaltest
//
//  Created by Alexander Selivanov on 25.01.2020.
//  Copyright © 2020 Atlantapps. All rights reserved.
//

import UIKit
import QuartzCore

class RulerScrollView: UIControl, UIScrollViewDelegate {
    public var currentValue: Float = 0
    public var sideOffset: CGFloat = kDefaultScrollViewSideOffset
    
    var automaticallyUpdatingScroll: Bool = false
    var scrollView: UIScrollView = UIScrollView()
    var rangeLayer: RulerRangeLayer = RulerRangeLayer()
    var range: RulerRange<Float> = RulerRange<Float>(location: 0, length: 0) {
        didSet {
            setupScrollView()
            currentValue = ceilf((range.location + range.length) / 2.0)
        }
    }

    var markerTypes: [RulerRangeMarkerType]? {
        didSet {
            setupScrollView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupScrollView() {
        if let _ = self.markerTypes {
            self.subviews.forEach({ $0.removeFromSuperview() })
            self.scrollView = UIScrollView(frame: self.bounds)
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            scrollView.delegate = self
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            self.setupRangeLayer()
            self.addSubview(scrollView)
        }
    }
    
    fileprivate func setupRangeLayer() {
        if let markerTypes = self.markerTypes {
            self.rangeLayer = RulerRangeLayer()
            self.rangeLayer.range = self.range
            self.rangeLayer.markerTypes = markerTypes
            self.scrollView.layer.addSublayer(rangeLayer)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let sideInset = self.scrollView.frame.width / 2.0
        self.scrollView.contentInset = UIEdgeInsets(
            top: 0, left: sideInset - self.sideOffset, bottom: 0, right: sideInset - self.sideOffset)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.rangeLayer.frame = self.frameForRangeLayer()
        CATransaction.commit()
        self.scrollView.contentSize = CGSize(width: self.rangeLayer.frame.width, height: self.frame.size.height)
//        self.scrollView.contentOffset = self.contentOffsetForValue(value: self.currentValue)
        
    }

    func frameForRangeLayer() -> CGRect {
        let maxScale = RulerRangeMarkerType.largestScale(types: self.markerTypes)
        let scaleFitsInScreen = range.length < 5 * maxScale ? 1 : 5 * maxScale
        
        let widthPerScale = Float(self.bounds.size.width) / scaleFitsInScreen
        let width = min(widthPerScale * self.range.length, kRangeLayerMaximumWidth)
        return CGRect(x: 0.0, y: 0.0, width: Double(width), height: Double(self.frame.height))
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!automaticallyUpdatingScroll) {
            let oldValue = currentValue
            let minScale = RulerRangeMarkerType.minScale(types: self.markerTypes)
            let rawValue = self.valueForContentOffset(contentOffset: self.scrollView.contentOffset)
            self.currentValue = Float(lroundf(rawValue / minScale)) * minScale
            if (oldValue != currentValue) {
                self.sendActions(for: UIControl.Event.valueChanged)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var value = self.valueForContentOffset(contentOffset: targetContentOffset.pointee)
        let minScale = RulerRangeMarkerType.minScale(types: self.markerTypes)
        value = Float(lroundf(value / minScale)) * minScale
        
        targetContentOffset.pointee.x = self.contentOffsetForValue(value: value).x
    }
    
    func valueForContentOffset(contentOffset: CGPoint) -> Float {
        let rangeStart = fmin(self.range.location, self.range.location + self.range.length)
        let value = Float(rangeStart) + Float(contentOffset.x + self.scrollView.contentInset.left) / Float(self.offsetCoefficient())
        return value
    }
    
    func contentOffsetForValue(value: Float) -> CGPoint {
        let rangeStart = fmin(self.range.location, self.range.location + self.range.length)
        
        let contentOffset: CGFloat = CGFloat(value - rangeStart) * self.offsetCoefficient() - scrollView.contentInset.left
        return CGPoint(x: contentOffset, y: scrollView.contentOffset.y)
    }
    
    func scrollToCurrentValueOffset() {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.automaticallyUpdatingScroll = true
                self.scrollView.setContentOffset(self.contentOffsetForValue(value: self.currentValue), animated: false)
        },
            completion: { completed in
                self.automaticallyUpdatingScroll = false
        })
    }
    
    func offsetCoefficient() -> CGFloat {
        return self.self.rangeLayer.frame.width / CGFloat(abs(range.length))
    }
}
