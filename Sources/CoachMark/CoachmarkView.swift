//
//  CoachmarkView.swift
//  KptnCook
//
//  Created by Grigor on 10.06.22.
//  Copyright © 2022 KptnCook. All rights reserved.
//

import UIKit

public enum ArrowPosition {
    case top, bottom, centerTop, centerBottom
}

extension UIView {
    public func showCoachmark(text: String,
                       for viewRect: CGRect = .zero,
                       position: ArrowPosition = .top,
                       font: UIFont = UIFont.systemFont(ofSize: 11),
                       verticalMargin: CGFloat = 20,
                       horizontalMargin: CGFloat = 0,
                       contentViewPadding: CGFloat = 2) {
        
        let coachmark = CoachmarkView(text: text,
                                      viewRect: viewRect,
                                      position: position,
                                      font: font,
                                      verticalMargin: verticalMargin,
                                      horizontalMargin: horizontalMargin,
                                      contentViewPadding: contentViewPadding)

        addSubview(coachmark)
        coachmark.show()
    }
}

public class CoachmarkView: UIView {
    
    private let text: String
    private let pointRect: CGRect
    private var position: ArrowPosition
    private let contentViewPadding: CGFloat
    private let labelFont: UIFont
    private let verticalMargin: CGFloat
    private let horizontalMargin: CGFloat
    
    private let arrowMargin = 5.0
    private let arrowWidth = 16.0
    private let screenSize = UIScreen.main.bounds.size
    
    init(text: String,
         viewRect: CGRect,
         position: ArrowPosition = .top,
         font: UIFont = UIFont.systemFont(ofSize: 11),
         verticalMargin: CGFloat = 20,
         horizontalMargin: CGFloat = 0,
         contentViewPadding: CGFloat = 2) {
        self.text = text
        self.pointRect = viewRect
        self.position = position
        self.contentViewPadding = contentViewPadding
        self.labelFont = font
        self.verticalMargin = verticalMargin
        self.horizontalMargin = horizontalMargin
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        translatesAutoresizingMaskIntoConstraints = false
        
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
        ])
        setupView()
    }
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var arrowView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 3.0
        view.transform = CGAffineTransform(rotationAngle: .pi/4)
        return view
    }()
    
    private lazy var msgLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = labelFont
        label.text = text
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 4.0
        label.textAlignment = .center
        label.leftInset = 15
        label.rightInset = 15
        label.topInset = 7
        label.bottomInset = 7
        label.alpha = 0.5
        return label
    }()
    
    private var isArrowTop: Bool {
        position == .top || position == .centerTop
    }
    
    private var arrowDiagonal: CGFloat {
        sqrt(2.0) * arrowWidth
    }
    
    private var canLabelWidthGreaterThanScreen: Bool {
        msgLabel.intrinsicContentSize.width > screenSize.width - 2 * contentViewPadding
    }
    
    private var labelSize: CGSize {
        let width = screenSize.width - 2 * contentViewPadding
        let sizeOfWidth = labelSizeForWidth(width: width)
        return CGSize(width: sizeOfWidth.width , height: sizeOfWidth.height )
    }
    
    private var arrowXpoint: CGFloat {
        pointRect.origin.x + pointRect.width / 2 + horizontalMargin
    }
    
    //common func to init our view
    private func setupView() {
        layoutContentView()
        
        layoutArrowView()
        
        layoutLabel()
    }
    
    private func labelSizeForWidth(width: CGFloat) -> CGSize {
        let label: PaddingLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: width - msgLabel.leftInset - msgLabel.rightInset, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = msgLabel.lineBreakMode
        label.font = msgLabel.font
        label.text = msgLabel.text
        label.leftInset = msgLabel.leftInset
        label.rightInset = msgLabel.rightInset
        label.topInset = msgLabel.topInset
        label.bottomInset = msgLabel.bottomInset
        label.sizeToFit()
        let newSize = CGSize(width: label.frame.width + msgLabel.leftInset + msgLabel.rightInset, height: label.frame.height + msgLabel.topInset + msgLabel.bottomInset)
        return newSize
    }
    
    private func layoutContentView() {
        addSubview(contentView)
        
        var heightConstant = max(pointRect.origin.y + verticalMargin, contentViewPadding)
        heightConstant = min(heightConstant, screenSize.height - labelSize.height - contentViewPadding)
        
        if canLabelWidthGreaterThanScreen {
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: topAnchor, constant: heightConstant),
                contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -contentViewPadding),
                contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: contentViewPadding),
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            ])
        } else {
            if isArrowTop {
                contentView.topAnchor.constraint(equalTo: topAnchor, constant: heightConstant).isActive = true
            } else {
                contentView.bottomAnchor.constraint(equalTo: topAnchor, constant: heightConstant).isActive = true
            }
            
            
            if arrowXpoint < screenSize.width / 2 {
                var widthConstant = max(arrowXpoint - labelSize.width / 2, contentViewPadding)
                widthConstant = min(widthConstant, screenSize.width - labelSize.width - contentViewPadding)
                
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: widthConstant).isActive = true
                contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -contentViewPadding).isActive = true
            } else {
                var widthConstant = max(screenSize.width - (arrowXpoint + labelSize.width / 2), contentViewPadding)
                widthConstant = min(widthConstant, screenSize.width - labelSize.width - contentViewPadding)
                
                contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: contentViewPadding).isActive = true
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -widthConstant).isActive = true
            }
        }
    }
    
    private func layoutArrowView() {
        contentView.addSubview(arrowView)
        
        let arrowConstant = (arrowDiagonal - arrowWidth) / 2
        
        var arrowLeadingConstant = max((arrowXpoint - arrowWidth / 2), contentViewPadding + arrowConstant + arrowMargin)
        arrowLeadingConstant = min(arrowLeadingConstant, screenSize.width - contentViewPadding - arrowWidth - arrowConstant - arrowMargin)
        
        NSLayoutConstraint.activate([
            arrowView.heightAnchor.constraint(equalToConstant: arrowWidth),
            arrowView.widthAnchor.constraint(equalToConstant: arrowWidth),
            arrowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: arrowLeadingConstant)
        ])
        
        if isArrowTop {
            arrowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: arrowConstant).isActive = true
        } else {
            arrowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -arrowConstant).isActive = true
        }
    }
    
    private func layoutLabel() {
           contentView.addSubview(msgLabel)
           NSLayoutConstraint.activate([
               msgLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
               msgLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
               msgLabel.topAnchor.constraint(equalTo: isArrowTop ? arrowView.centerYAnchor : contentView.topAnchor, constant: isArrowTop ? -3 : 0),
               msgLabel.bottomAnchor.constraint(equalTo: isArrowTop ? contentView.bottomAnchor : arrowView.centerYAnchor, constant: isArrowTop ? 0 : 3)
           ])
    }
}

private class PaddingLabel: UILabel {
    var topInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    var leftInset: CGFloat = 0
    var rightInset: CGFloat = 0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    
    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}
