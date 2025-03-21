//
//  CaptureCameraViewControllerRepresentable.swift
//  WriteSmith-SwiftUI
//
//  Created by Alex Coundouriotis on 10/28/23.
//

import SwiftUI

struct CaptureCameraViewControllerRepresentable: UIViewControllerRepresentable {
    

    @Binding var reset: Bool
    var withCropFrame: CGRect?
    var withImage: UIImage?
    var onAttach: (_ image: UIImage, _ cropFrame: CGRect?, _ unmodifiedImage: UIImage?)->Void
//    var onScan: (String)->Void
    
    class CaptureCameraViewControllerCoordinator: CaptureCameraViewControllerDelegate {
        
//        @Binding var isShowing: Bool
        var onAttach: (_ image: UIImage, _ cropFrame: CGRect?, _ unmodifiedImage: UIImage?)->Void
//        var onScan: (String)->Void
        
        init(onAttach: @escaping (_ image: UIImage, _ cropFrame: CGRect?, _ unmodifiedImage: UIImage?)->Void) {
//            self._isShowing = isShowing
            self.onAttach = onAttach
//            self.onScan = onScan
        }
        
        func didAttachImage(image: UIImage, cropFrame: CGRect?, unmodifiedImage: UIImage?) {
            onAttach(image, cropFrame, unmodifiedImage)
        }
        
        func dismiss() {
//            isShowing = false
        }
        
    }
    
    
    func makeUIViewController(context: Context) -> CaptureCameraViewController {
        let captureCameraViewController = CaptureCameraViewController()
        
        captureCameraViewController.delegate = context.coordinator
        
        if let withImage = withImage {
            captureCameraViewController.initializeCropView(with: withImage, cropFrame: withCropFrame, fixOrientation: false, contentMode: .scaleAspectFit)
            
            // I'm doing this here to avoid the logic in the cameraViewController itself lol
            captureCameraViewController.rootView.showCropViewSwitch.isOn = withCropFrame != nil
            captureCameraViewController.rootView.showCropViewSwitchChanged(captureCameraViewController.rootView.showCropViewSwitch)
        }
        
        return captureCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CaptureCameraViewController, context: Context) {
//        uiViewController.setCameraButtonActivityIndicatorViewStatus(isActive: isLoading)
        
        if reset {
            DispatchQueue.main.async {
                uiViewController.reset()
                
                self.reset = false
            }
        }
    }
    
    func makeCoordinator() -> CaptureCameraViewControllerCoordinator {
        CaptureCameraViewControllerCoordinator(onAttach: onAttach)
    }
    
}

#Preview {
    CaptureCameraViewControllerRepresentable(
//        isShowing: .constant(true),
//        isLoading: .constant(false),
        reset: .constant(false),
        onAttach: { image, cropRect, unmodifiedImage in
            
        })
    .ignoresSafeArea()
}

