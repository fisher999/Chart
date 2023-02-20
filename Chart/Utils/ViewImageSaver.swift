//
//  ViewImageSaver.swift
//  Chart
//
//  Created by vi.s.semenov on 20.02.2023.
//

import Foundation
import UIKit

protocol ViewImageSaverDelegate: AnyObject {
    func viewImageSaver(
        _ saver: ViewImageSaver,
        didFinishSavingView view: UIView
    )
    func viewImageSaver(
        _ saver: ViewImageSaver,
        didFailSavingView view: UIView,
        error: Error
    )
}

class ViewImageSaver: NSObject {
    weak var delegate: ViewImageSaverDelegate?
    
    func writeViewToPhotoAlbum(view: UIView) {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        let contextInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(view).toOpaque())
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(saveCompleted),
            contextInfo
        )
    }
    
    private @objc func saveCompleted(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        let view = Unmanaged<UIView>.fromOpaque(contextInfo).takeUnretainedValue()
        if let error = error {
            delegate?.viewImageSaver(
                self,
                didFailSavingView: view,
                error: error
            )
            return
        }
        
        delegate?.viewImageSaver(self, didFinishSavingView: view)
    }
}
