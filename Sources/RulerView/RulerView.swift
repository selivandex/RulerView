//
//  RulerView.swift
//  metaltest
//
//  Created by Alexander Selivanov on 25.01.2020.
//  Copyright © 2020 Atlantapps. All rights reserved.
//

import UIKit

public protocol RulerDelegate: class {
    func rulerValueChanged(_ ruler: RulerView, value: Float)
}

public class RulerView: UIView {
    public weak var delegate: RulerDelegate?
    public var markerTypes: [RulerRangeMarkerType] = [
        RulerRangeMarkerType(color: UIColor.white.withAlphaComponent(0.7), size: .init(width: 1, height: 10), scale: 0.2),
        RulerRangeMarkerType(color: .white, size: .init(width: 1, height: 10), scale: 1.0)
    ]
    
    public var range: RulerRange<Float> = .init(location: 3, length: 7)
    
    private let pointerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    private lazy var scrollView: RulerScrollView = {
        let sv = RulerScrollView()
        sv.range = range
        sv.markerTypes = markerTypes
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.backgroundColor = .clear
        sv.currentValue = 3.0
        sv.addTarget(self, action: #selector(scrollViewCurrentValueChanged), for: .valueChanged)
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(pointerView)
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            pointerView.heightAnchor.constraint(equalToConstant: 25),
            pointerView.widthAnchor.constraint(equalToConstant: 1),
            pointerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            pointerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            scrollView.heightAnchor.constraint(equalTo: heightAnchor),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func scrollViewCurrentValueChanged(_ sender: RulerScrollView) {
        let generator: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        generator.prepare()
        
        delegate?.rulerValueChanged(self, value: sender.currentValue)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.scrollToCurrentValueOffset()
    }
}
