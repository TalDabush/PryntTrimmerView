//
//  PryntTrimmerView.swift
//  PryntTrimmerView
//
//  Created by HHK on 27/03/2017.
//  Copyright © 2017 Prynt. All rights reserved.
//

import AVFoundation
import UIKit

public protocol TrimmerViewDelegate: class {
    func didChangePositionBar(_ playerTime: CMTime)
    func positionBarStoppedMoving(_ playerTime: CMTime)
}

/// A view to select a specific time range of a video. It consists of an asset preview with thumbnails inside a scroll view, two
/// handles on the side to select the beginning and the end of the range, and a position bar to synchronize the control with a
/// video preview, typically with an `AVPlayer`.
/// Load the video by setting the `asset` property. Access the `startTime` and `endTime` of the view to get the selected time
// range
@IBDesignable public class TrimmerView: AVAssetTimeSelector {
    
    // MARK: - Properties
    
    // MARK: Color Customization
    
    /// The color of the main border of the view
    @IBInspectable public var mainColor: UIColor = UIColor.white {
        didSet {
            updateMainColor()
        }
    }
    
    /// The color of the handles on the side of the view
    @IBInspectable public var handleColor: UIColor = UIColor.white {
        didSet {
            updateHandleColor()
        }
    }
    
    /// The color of the position indicator
    @IBInspectable public var positionBarColor: UIColor = UIColor.white {
        didSet {
            //positionBar.backgroundColor = positionBarColor
        }
    }
    
    // MARK: Interface
    
    public weak var delegate: TrimmerViewDelegate?
    
    // MARK: Subviews
    
    private let trimView = UIView()
    private let leftHandleView = HandlerView()
    private let rightHandleView = HandlerView()
    //private let positionBar = UIView()
    private let leftHandleKnob = UIImageView()
    private let rightHandleKnob = UIImageView()
    private let leftMaskView = UIView()
    private let rightMaskView = UIView()
    private let durationView = UIView()
    private let durationLabel = UILabel()
    
    // MARK: Constraints
    
    private var currentLeftConstraint: CGFloat = 0
    private var currentRightConstraint: CGFloat = 0
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var positionConstraint: NSLayoutConstraint?
    
    private let handleWidth: CGFloat = 15
    
    
    
    /// The maximum duration allowed for the trimming. Change it before setting the asset, as the asset preview
    public var maxDuration: Double = 15 {
        didSet {
            assetPreview.maxDuration = maxDuration
        }
    }
    
    /// The minimum duration allowed for the trimming. The handles won't pan further if the minimum duration is attained.
    public var minDuration: Double = 1
    
    // MARK: - View & constraints configurations
    
    override func setupSubviews() {
        
        super.setupSubviews()
        backgroundColor = UIColor.clear
        layer.zPosition = 1
        setupTrimmerView()
        setupDurationLabel()
        setupHandleView()
        //setupMaskView()
        //setupPositionBar()
        setupGestures()
        updateMainColor()
        
        //updateHandleColor()
    }
    
    override func constrainAssetPreview() {
        assetPreview.leftAnchor.constraint(equalTo: leftAnchor, constant: handleWidth).isActive = true
        assetPreview.rightAnchor.constraint(equalTo: rightAnchor, constant: -handleWidth).isActive = true
        assetPreview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        assetPreview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func setupTrimmerView() {
        
        //        trimView.layer.borderColor = UIColor.black.cgColor
        //        trimView.layer.borderWidth = 0.5
        trimView.backgroundColor = UIColor.white
        trimView.layer.cornerRadius = 6.0
        trimView.translatesAutoresizingMaskIntoConstraints = false
        trimView.isUserInteractionEnabled = false
        addSubview(trimView)
        
        trimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        trimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftConstraint = trimView.leftAnchor.constraint(equalTo: leftAnchor)
        rightConstraint = trimView.rightAnchor.constraint(equalTo: rightAnchor)
        leftConstraint?.isActive = true
        rightConstraint?.isActive = true
    }
    
    private func setupHandleView() {
        
        leftHandleView.isUserInteractionEnabled = true
        leftHandleView.layer.cornerRadius = 6.0
        leftHandleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftHandleView)
        
        leftHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        leftHandleView.widthAnchor.constraint(equalToConstant: handleWidth).isActive = true
        leftHandleView.leftAnchor.constraint(equalTo: trimView.leftAnchor, constant: 2).isActive = true
        leftHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        leftHandleKnob.image = UIImage(named: "handleKnobIcon")
        leftHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        leftHandleView.addSubview(leftHandleKnob)
        
        leftHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        leftHandleKnob.widthAnchor.constraint(equalToConstant: 7).isActive = true
        leftHandleKnob.centerYAnchor.constraint(equalTo: leftHandleView.centerYAnchor).isActive = true
        leftHandleKnob.leadingAnchor.constraint(equalTo: leftHandleView.leadingAnchor, constant: 8).isActive = true
        
        rightHandleView.isUserInteractionEnabled = true
        rightHandleView.layer.cornerRadius = 6.0
        rightHandleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightHandleView)
        
        rightHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        rightHandleView.widthAnchor.constraint(equalToConstant: handleWidth).isActive = true
        rightHandleView.rightAnchor.constraint(equalTo: trimView.rightAnchor, constant: -2).isActive = true
        rightHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        rightHandleKnob.image = UIImage(named: "handleKnobIcon")
        rightHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        rightHandleView.addSubview(rightHandleKnob)
        
        rightHandleKnob.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        rightHandleKnob.widthAnchor.constraint(equalToConstant: 7).isActive = true
        rightHandleKnob.centerYAnchor.constraint(equalTo: rightHandleView.centerYAnchor).isActive = true
        rightHandleKnob.trailingAnchor.constraint(equalTo: rightHandleView.trailingAnchor, constant: -8).isActive = true
    }
    
    private func setupMaskView() {
        
        leftMaskView.isUserInteractionEnabled = false
        leftMaskView.backgroundColor = .white
        leftMaskView.alpha = 0.7
        leftMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(leftMaskView, belowSubview: leftHandleView)
        
        leftMaskView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        leftMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftMaskView.rightAnchor.constraint(equalTo: leftHandleView.centerXAnchor).isActive = true
        
        rightMaskView.isUserInteractionEnabled = false
        rightMaskView.backgroundColor = .white
        rightMaskView.alpha = 0.7
        rightMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(rightMaskView, belowSubview: rightHandleView)
        
        rightMaskView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        rightMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rightMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rightMaskView.leftAnchor.constraint(equalTo: rightHandleView.centerXAnchor).isActive = true
    }
    
    private func setupPositionBar() {
        //
        //        positionBar.frame = CGRect(x: 0, y: 0, width: 3, height: frame.height)
        //        positionBar.backgroundColor = positionBarColor
        //        positionBar.center = CGPoint(x: leftHandleView.frame.maxX, y: center.y)
        //        positionBar.layer.cornerRadius = 1
        //        positionBar.translatesAutoresizingMaskIntoConstraints = false
        //        positionBar.isUserInteractionEnabled = false
        //        addSubview(positionBar)
        //
        //        positionBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        //        positionBar.widthAnchor.constraint(equalToConstant: 3).isActive = true
        //        positionBar.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        //        positionConstraint = positionBar.leftAnchor.constraint(equalTo: leftHandleView.rightAnchor, constant: 0)
        //        positionConstraint?.isActive = true
    }
    
    private func setupGestures() {
        
        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TrimmerView.handlePanGesture))
        leftHandleView.addGestureRecognizer(leftPanGestureRecognizer)
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TrimmerView.handlePanGesture))
        rightHandleView.addGestureRecognizer(rightPanGestureRecognizer)
    }
    
    private func setupDurationLabel(){
        durationView.isUserInteractionEnabled = false
        durationView.backgroundColor = .white
        durationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(durationView)
        
        durationView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        durationView.widthAnchor.constraint(equalToConstant: 37).isActive = true
        durationView.centerXAnchor.constraint(equalTo: trimView.centerXAnchor, constant: 4).isActive = true
        durationView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        durationView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        durationView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        durationLabel.isUserInteractionEnabled = false
        durationLabel.backgroundColor = .white
        durationLabel.textColor = .black
        durationLabel.font = UIFont.systemFont(ofSize: 12)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationView.addSubview(durationLabel)
        
        durationLabel.heightAnchor.constraint(equalTo: durationView.heightAnchor).isActive = true
        durationLabel.widthAnchor.constraint(equalTo: durationView.widthAnchor).isActive = true
        durationLabel.centerXAnchor.constraint(equalTo: durationView.centerXAnchor).isActive = true
        durationLabel.centerYAnchor.constraint(equalTo: durationView.centerYAnchor).isActive = true
        durationLabel.text = ""
        
    }
    
    private func updateMainColor() {
        leftHandleView.backgroundColor = mainColor
        rightHandleView.backgroundColor = mainColor
    }
    
    private func updateHandleColor() {
        leftHandleKnob.backgroundColor = handleColor
        rightHandleKnob.backgroundColor = handleColor
    }
    
    // MARK: - Trim Gestures
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view, let superView = gestureRecognizer.view?.superview else { return }
        let isLeftGesture = view == leftHandleView
        switch gestureRecognizer.state {
            
        case .began:
            if isLeftGesture {
                currentLeftConstraint = leftConstraint!.constant
            } else {
                currentRightConstraint = rightConstraint!.constant
            }
            updateSelectedTime(stoppedMoving: false)
        case .changed:
            let translation = gestureRecognizer.translation(in: superView)
            if isLeftGesture {
                updateLeftConstraint(with: translation)
            } else {
                updateRightConstraint(with: translation)
            }
            layoutIfNeeded()
            if let startTime = startTime, isLeftGesture {
                seek(to: startTime)
            } else if let endTime = endTime {
                seek(to: endTime)
            }
            updateSelectedTime(stoppedMoving: false)
            
        case .cancelled, .ended, .failed:
            updateSelectedTime(stoppedMoving: true)
        default: break
        }
    }
    
    public func setStartAndEndTime(_ start: CMTime, _ end: CMTime){
        let leftHandleTransition = calculateLeftTransition(start)
        let rightHandleTransition = calculateRightTransition(end)
        moveLeftHandleView(leftHandleTransition)
        moveRightHandleView(rightHandleTransition)
    }
    
    public func setDurationLabel(text: String){
        durationLabel.text = text
    }
    
    private func calculateLeftTransition(_ start: CMTime) -> CGFloat{
        let width = assetPreview.contentSize.width
        let startSeconds = start.seconds
        let currentStartTimeSeconds = self.startTime!.seconds
        let durationSeconds = self.asset!.duration.seconds
        return CGFloat(((startSeconds - currentStartTimeSeconds) / durationSeconds)) * width
    }
    
    private func calculateRightTransition(_ end: CMTime) -> CGFloat{
        let width = assetPreview.contentSize.width
        let endSeconds = end.seconds
        let currentEndTimeSeconds = self.endTime!.seconds
        let durationSeconds = self.asset!.duration.seconds
        return CGFloat(((endSeconds - currentEndTimeSeconds) / durationSeconds)) * width
    }
    
    public func moveLeftHandleView(_ xTranslation: CGFloat){
        currentLeftConstraint = leftConstraint!.constant
        updateLeftConstraint(with: CGPoint(x: xTranslation, y: 0))
        layoutIfNeeded()
        
    }
    
    public func moveRightHandleView(_ xTranslation: CGFloat){
        currentRightConstraint = rightConstraint!.constant
        updateRightConstraint(with: CGPoint(x: xTranslation, y: 0))
        layoutIfNeeded()
    }
    
    private func updateLeftConstraint(with translation: CGPoint) {
        let maxConstraint = max(rightHandleView.frame.origin.x - handleWidth -  minimumDistanceBetweenHandle, 0)
        let newConstraint = min(max(0, currentLeftConstraint + translation.x), maxConstraint)
        leftConstraint?.constant = newConstraint
    }
    
    private func updateRightConstraint(with translation: CGPoint) {
        let maxConstraint = min(2 * handleWidth - frame.width + leftHandleView.frame.origin.x + minimumDistanceBetweenHandle, 0)
        let newConstraint = max(min(0, currentRightConstraint + translation.x), maxConstraint)
        rightConstraint?.constant = newConstraint
    }
    
    // MARK: - Asset loading
    
    override func assetDidChange(newAsset: AVAsset?) {
        super.assetDidChange(newAsset: newAsset)
        resetHandleViewPosition()
    }
    
    private func resetHandleViewPosition() {
        leftConstraint?.constant = 0
        rightConstraint?.constant = 0
        layoutIfNeeded()
    }
    
    // MARK: - Time Equivalence
    
    /// Move the position bar to the given time.
    public func seek(to time: CMTime) {
        if let newPosition = getPosition(from: time) {
            
            //            let offsetPosition = newPosition - assetPreview.contentOffset.x - leftHandleView.frame.origin.x
            //            let maxPosition = rightHandleView.frame.origin.x - (leftHandleView.frame.origin.x + handleWidth)
            //                - positionBar.frame.width
            //            let normalizedPosition = min(max(0, offsetPosition), maxPosition)
            //            positionConstraint?.constant = normalizedPosition
            layoutIfNeeded()
        }
    }
    
    /// The selected start time for the current asset.
    public var startTime: CMTime? {
        let startPosition = leftHandleView.frame.origin.x + assetPreview.contentOffset.x - 2
        return getTime(from: startPosition)
    }
    
    /// The selected end time for the current asset.
    public var endTime: CMTime? {
        let endPosition = rightHandleView.frame.origin.x + assetPreview.contentOffset.x - handleWidth + 2
        return getTime(from: endPosition)
    }
    
    private func updateSelectedTime(stoppedMoving: Bool) {
        guard let playerTime = positionBarTime else {
            return
        }
        if stoppedMoving {
            delegate?.positionBarStoppedMoving(playerTime)
        } else {
            delegate?.didChangePositionBar(playerTime)
        }
    }
    
    private var positionBarTime: CMTime? {
        let barPosition = assetPreview.contentOffset.x
        return getTime(from: barPosition)
    }
    
    private var minimumDistanceBetweenHandle: CGFloat {
        guard let asset = asset else { return 0 }
        return CGFloat(minDuration) * assetPreview.contentView.frame.width / CGFloat(asset.duration.seconds)
    }
    
    // MARK: - Scroll View Delegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedTime(stoppedMoving: true)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateSelectedTime(stoppedMoving: true)
        }
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectedTime(stoppedMoving: false)
    }
}
