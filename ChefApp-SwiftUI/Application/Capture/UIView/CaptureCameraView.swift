//
//  CaptureCameraView.swift
//  ChitChat
//
//  Created by Alex Coundouriotis on 4/11/23.
//

import AVKit
import UIKit

protocol CaptureCameraViewDelegate {
    func cameraButtonPressed()
    func flashButtonPressed()
    func imageButtonPressed()
    func retakeButtonPressed()
    func showCropViewSwitchChanged(to newValue: Bool)
}

class CaptureCameraView: UIView {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var retakeButton: RoundedButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var initialImageCropZone: SillyCropView!
    
    @IBOutlet weak var tapToCaptureImageView: UIImageView!
    @IBOutlet weak var instructionsContainer: RoundedView!
    
    @IBOutlet weak var cameraButtonActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var cropViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cropViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cropViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cropViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topResizeView: RoundedView!
    @IBOutlet weak var leftResizeView: RoundedView!
    @IBOutlet weak var rightResizeView: RoundedView!
    @IBOutlet weak var bottomResizeView: RoundedView!
    
    @IBOutlet weak var topOverlay: UIView!
    @IBOutlet weak var leftOverlay: UIView!
    @IBOutlet weak var rightOverlay: UIView!
    @IBOutlet weak var bottomOverlay: UIView!
    
    @IBOutlet weak var showCropViewSwitchContainer: RoundedView!
    @IBOutlet weak var showCropViewSwitch: UISwitch!
    
    @IBOutlet weak var scanIntroText: RoundedView!
    
    let defaultOverlayOpacity = 0.4
    
    var delegate: CaptureCameraViewDelegate?
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        delegate?.cameraButtonPressed()
    }
    
    @IBAction func flashButtonPressed(_ sender: Any) {
        delegate?.flashButtonPressed()
    }
    
    @IBAction func imageButtonPressed(_ sender: Any) {
        delegate?.imageButtonPressed()
    }
    
    @IBAction func retakeButtonPressed(_ sender: Any) {
        delegate?.retakeButtonPressed()
    }
    
    
    @IBAction func showCropViewSwitchChanged(_ sender: UISwitch) {
        delegate?.showCropViewSwitchChanged(to: sender.isOn)
    }
    
}

