//
//  ViewController.swift
//  MachineLearning
//
//  Created by Mustafa Ali KILCI on 4.12.2022.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var textLabel2: UILabel!
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
    
    
    
    let gesturRecocognizzer = UITapGestureRecognizer(target: self, action: #selector(hideeKeybord))
    view.addGestureRecognizer(gesturRecocognizzer)
    // Do any additional setup after loading the view.
    
    imageView.isUserInteractionEnabled = true
    let iamageGestrecocognizer = UITapGestureRecognizer(target: self, action: #selector(selecktimage))
    imageView.addGestureRecognizer(iamageGestrecocognizer)
}

@objc func selecktimage() {
    
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.sourceType = .photoLibrary
    present(picker, animated: true,completion: nil)

    
    
}
    @objc func hideeKeybord(){
        view.endEditing(true)
    }
    

    @IBAction func imageBtn(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true,completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true , completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
        } // Core ML in kullandığı image türü olarak Cİimage kullanıyoruz burdada normal image Ciimage dönüştüüryoruz
        
        recognizerImage(image: chosenImage)
        
    }
    
    func recognizerImage(image : CIImage){
        
        //Recoest istek
        //Handler isteği ele almak
        
        
        //Recoest istek
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            
            //bu proje icersindeki MobilNetv2 dosyasını model değişkenine atatdık
            
            let request = VNCoreMLRequest(model: model) { [self] vnRequest, error in
                if error != nil {
                    makealert(titleInput: "Error", MesageInput: error?.localizedDescription ?? "Error")
                    
                }else {
                    
                    if let results = vnRequest.results as? [VNClassificationObservation]{
                        if results.count > 0 {
                            let topResult = results.first
                            DispatchQueue.main.async {
                                //
                                let counfidenceLevel = (topResult?.confidence ?? 0) * 100 // resmin doğruluk yüzdesi
                              
                                let roundet = Int(counfidenceLevel * 100 ) / 100
                                
                                
                                self.textLabel.text = "\(roundet)% it's "
                               
                                self.textLabel2.text = topResult?.identifier
                                
                                
                            }
                            
                        }
                    }
                    
                    
                }
            }
            let handler = VNImageRequestHandler(ciImage:image )
            DispatchQueue.global(qos: .userInitiated) .async {
                do{
                    try handler.perform([request])
                }catch{
                    print("Error")
                }
            }
            
            
        }
        
    }
    
    func makealert (titleInput:String , MesageInput:String){
        
        let alert = UIAlertController(title: titleInput, message: MesageInput, preferredStyle: UIAlertController.Style.alert)
        let okbuton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default ,handler: nil)
        alert.addAction(okbuton)
        self.present(alert, animated: true, completion: nil)
    }
    
}

