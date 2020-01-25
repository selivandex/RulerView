//
//  RulerLayer.swift
//  metaltest
//
//  Created by Alexander Selivanov on 25.01.2020.
//  Copyright © 2020 Atlantapps. All rights reserved.
//

import UIKit
import QuartzCore

public enum RulerMarkerVerticalAlignment: Int {
    case bottom = 0, center, top
}

public class RulerRange<T>: NSObject {
    open var location: T
    open var length: T

    public init(location: T, length: T) {
        self.location = location
        self.length = length
        super.init()
    }

    public override var description: String {
        return String("location : \(self.location) length: \(self.length)")
    }

    public override var debugDescription: String {
        return String("location : \(self.location) length: \(self.length)")
    }
}

public class RulerRangeMarkerType: NSObject, NSCopying {
    open var scale: Float = 1
    open var size: CGSize = CGSize(width: 1.0, height: 20.0)
    open var color: UIColor = UIColor.white

    public convenience init(color: UIColor, size: CGSize, scale: Float) {
        self.init()
        
        self.color = color
        self.size = size
        self.scale = scale
    }

    class func minScale(types: Array<RulerRangeMarkerType>?) -> Float {
        var minScale = Float.greatestFiniteMagnitude
        if let types = types {
            for markerType in types {
                minScale = fmin(markerType.scale, minScale)
            }
        }
        return minScale
    }

    class func largestScale(types: Array<RulerRangeMarkerType>?) -> Float {

        var largestScale = Float.leastNormalMagnitude
        if let types = types {
            for markerType in types {
                largestScale = fmax(markerType.scale, largestScale)
            }
        }
        return largestScale
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = RulerRangeMarkerType()
        copy.scale = self.scale
        copy.color = self.color
        copy.size = self.size
        return copy
    }
}

class RulerRangeMarker: NSObject {
    var type: RulerRangeMarkerType = RulerRangeMarkerType()
    var alignment: RulerMarkerVerticalAlignment = .bottom
    
    var value: Float = 0.0
}

class RulerRangeLayer: CALayer {
    var markerTypes: [RulerRangeMarkerType] = []
    var colorOverrides: [RulerRange<Float>: UIColor]?

    var range: RulerRange<Float> = RulerRange<Float>(location: 0, length: 0) {
        didSet {
            if range.length != 0 {
                self.setNeedsDisplay()
            }
        }
    }

    lazy var markers: [RulerRangeMarker] = self.initializeMarkers()

    override var frame: CGRect {
        didSet {
            if (oldValue != self.frame) {
                self.markers = self.initializeMarkers()
                self.setNeedsDisplay()
            }
        }
    }

    override func display() {
        super.display()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.drawLayer()
        CATransaction.commit()
    }

    func initializeMarkers() -> [RulerRangeMarker] {
        var valueToMarkerMap: [Float: RulerRangeMarker] = [:]
        
        if (self.frame.size.width > 0 && self.markerTypes.count > 0) {
            let rangeStart = fmin(self.range.location, self.range.location + self.range.length)
            let rangeEnd = fmax(self.range.location, self.range.location + self.range.length)
            let sortedMarkerTypes = self.markerTypes.sorted {
                $0.scale < $1.scale
            }
            
            for markerType in sortedMarkerTypes {
                var location = rangeStart
                
                while location <= rangeEnd {
                    let marker = RulerRangeMarker()
                    marker.value = location
                    marker.type = markerType
                    valueToMarkerMap[location] = marker
                    location = location + markerType.scale
                }
            }
        }
        
        return valueToMarkerMap.values.sorted {
            $0.value < $1.value
        }
    }

    /*
        Draw the markers
    */
    func drawLayer() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale);
        var position: Float = Float(kDefaultScrollViewSideOffset)
        
        let distanceBetweenLeastScaleMarkers = Float(self.frame.width) / range.length
        
        var previousMarker: RulerRangeMarker?
        if let context = UIGraphicsGetCurrentContext() {
            for marker in self.markers {
                if let previousMarker = previousMarker {
                    position = position + (marker.value - previousMarker.value) * distanceBetweenLeastScaleMarkers
                }
                
                self.drawMarker(marker, at: CGFloat(position), in: context)
                
                previousMarker = marker
            }
            
            if let imageToDraw = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext();
                imageToDraw.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                contents = imageToDraw.cgImage
            }
        }
    }

    /*
        Draw one marker. If marker.labelVisible is true then draw its numerical
        representation.
        marker.type.size is used for drawing the "thin" line that represents each
        marker
    */
    func drawMarker(_ marker: RulerRangeMarker, at pos: CGFloat, in context: CGContext) {
        let color = marker.type.color
        let xPos = pos - marker.type.size.width / 2
        var yPos: CGFloat = 0.0
        
        switch (marker.alignment) {
        case .center:
            yPos = (self.frame.size.height - marker.type.size.height) / 2.0
        case .bottom:
            yPos = self.frame.size.height - marker.type.size.height
        case .top:
            yPos = 0
        }
        
        let markerRect = CGRect(x: xPos, y: yPos, width: marker.type.size.width, height: marker.type.size.height)
        context.setFillColor(color.cgColor)
        context.fill(markerRect)
    }
}
