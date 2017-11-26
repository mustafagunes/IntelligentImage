//
//  ViewController.swift
//  IntelligentImage(MachineLearning)
//
//  Created by Mustafa GUNES on 26.11.2017.
//  Copyright © 2017 Mustafa GUNES. All rights reserved.
//

import UIKit
import CoreML // MachineLearning kütüphanesi eklendi.
import Vision // eklendi.

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate { // eklendi.

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!

    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func changeClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // Bundan sonra info.plist ten izin verdiriyorsun !!
        
        if let ciImage = CIImage(image: imageView.image!) { // imageView daki resmi al CIImage ye çevir.
            
            self.chosenImage = ciImage
        }
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image: CIImage){ // CIImage = CoreImage demek.
        
        resultLabel.text = "Finding ..."
        
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) {
        
            let request = VNCoreMLRequest(model: model, completionHandler: { (vnRequest, error) in
                
                if let result = vnRequest.results as? [VNClassificationObservation] {
                    
                    let topResult = result.first
                    
                    DispatchQueue.main.async { // işlem yaparken uygulama çökmesin diye bunu arkaplanda yaptırıyoruz.
                        
                        let conf = (topResult?.confidence)! * 100 // yüzde kaç ihtimalle doğru birşey yapıyoruz bunu gösterecek.
                        let rounded = Int(conf * 100) / 100
                        
                        self.resultLabel.text = "\(rounded)% it's \(String(topResult!.identifier))"
                    }
                }
            })
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    
                    try handler.perform([request])
                }
                catch
                {
                    print("Error !")
                }
            }
        }
    }
}

