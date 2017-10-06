//
//  ViewController.swift
//  FaceDetectVision
//
//  Created by Karen Tserunyan on 10/2/17.
//  Copyright © 2017 Karen Tserunyan. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let buttonsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var selectSourceButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 24, g: 105, b: 128)
        button.setTitle("Select Source", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(hanldeSelectSource), for: .touchUpInside)
        return button
    }()
    
    lazy var detectFacesButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 24, g: 105, b: 128)
        button.setTitle("Detect Faces", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(hanldeFaceDetection), for: .touchUpInside)
        return button
    }()
    
    let emptynessLabel: UILabel = {
        let label = UILabel()
        label.text = "Source is not selected :("
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var sourceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    @objc func hanldeSelectSource() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            sourceImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func hanldeFaceDetection() {
        if let image = sourceImageView.image {
            let request = VNDetectFaceRectanglesRequest { (req, err) in
                
                if let err = err {
                    print("Failed to detect faces:", err)
                    return
                }
                
                req.results?.forEach({ (res) in
                    
                    DispatchQueue.main.async {
                        guard let faceObservation = res as? VNFaceObservation else { return }
                        
                        let x = self.sourceImageView.frame.width * faceObservation.boundingBox.origin.x
                        
                        let height = (self.sourceImageView.image?.size.height)! * faceObservation.boundingBox.size.height
                        
                        let y = self.sourceImageView.frame.minY
                        
                        let width = self.sourceImageView.frame.width * faceObservation.boundingBox.size.width
                        
                        
                        let redView = UIView()
                        redView.backgroundColor = .red
                        redView.alpha = 0.4
                        redView.frame = CGRect(x: x, y: y, width: width, height: height)
                        self.sourceImageView.addSubview(redView)
                        
                        print(faceObservation.boundingBox)
                    }
                })
            }
            guard let cgImage = image.cgImage else { return }
            
            DispatchQueue.global(qos: .background).async {
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do {
                    try handler.perform([request])
                } catch let reqErr {
                    print("Failed to perform request:", reqErr)
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        view.addSubview(emptynessLabel)
        setupEmptynessLabel()
        
        view.addSubview(sourceImageView)
        setupSourceImageView()
        
        view.addSubview(buttonsContainerView)
        setupButtonsContainerView()
        
        
    }
    func setupEmptynessLabel() {
        emptynessLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptynessLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptynessLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        emptynessLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupSourceImageView() {
        sourceImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sourceImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sourceImageView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -10).isActive = true
        sourceImageView.heightAnchor.constraint(equalTo: view.widthAnchor, constant: -10).isActive = true
    }
    
    func setupButtonsContainerView () {
        buttonsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        buttonsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        buttonsContainerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        buttonsContainerView.addSubview(selectSourceButton)
        buttonsContainerView.addSubview(detectFacesButton)
        
        selectSourceButton.leftAnchor.constraint(equalTo: buttonsContainerView.leftAnchor).isActive = true
        selectSourceButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: -10).isActive = true
        selectSourceButton.widthAnchor.constraint(equalTo: buttonsContainerView.widthAnchor, multiplier: 0.5, constant: -5).isActive = true
        selectSourceButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        detectFacesButton.rightAnchor.constraint(equalTo: buttonsContainerView.rightAnchor).isActive = true
        detectFacesButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor, constant: -10).isActive = true
        detectFacesButton.widthAnchor.constraint(equalTo: buttonsContainerView.widthAnchor, multiplier: 0.5, constant: -5).isActive = true
        detectFacesButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
   
    
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat ) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
