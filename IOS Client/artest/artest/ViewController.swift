//
//  ViewController.swift
//  artest
//
//  Created by Zachary Kauble on 2/7/21.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target:self,action: #selector(handleTap(recognizer:))))
    }
    
    // MARK: Setup Methods
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        
        
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        //configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
        
        
    }
    
    func cgImage(from ciImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(ciImage, from:ciImage.extent)
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer)
    {
       // let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from:CGPoint(x:0,y:0), allowing: .estimatedPlane, alignment: .horizontal)
        
        var viewSize = self.view.frame.size
        
        let results2 = arView.raycast(from:CGPoint(x:viewSize.width,y:viewSize.height), allowing: .estimatedPlane, alignment: .horizontal)
            
        
        // save the captured image to the camera role to examine
        if let firstResult = results.first {
            if let firstResult2 = results2.first {
            
                guard let capturedImage = arView.session.currentFrame?.capturedImage else {return }
                let ciimage = CIImage(cvPixelBuffer:capturedImage)
                guard let cgimage = cgImage(from: ciimage) else { return }
                let newImage = UIImage(cgImage: cgimage)
                let imageMeta = newImage.jpegData(compressionQuality: 1.0)!
                
                let url = URL(string:"https://5tw4crdmrh.execute-api.us-east-1.amazonaws.com/myCloverFinder")
                
                var request = URLRequest(url: url!)
                
                request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = imageMeta
                
                let task = URLSession.shared.dataTask(with:request) {
                    [unowned self] data, response, error in
                    guard error == nil else {
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    do {
                       
                        let webResults: Results = try! JSONDecoder().decode(Results.self, from: data)
                        
                        self.DrawSomething(s1:firstResult.worldTransform, s2:firstResult2.worldTransform, result:webResults)
                    
                    }
                    catch let parsingError{
                        print("Error", parsingError)
                    }
                    
                }
            
                task.resume()
                
               
                    
            } else { // couldn't  find a surface
                print("Object placement failed = couldn't find surface.")
            }
        }  else {
            print("Object placement failed = couldn't find surface.")
        }
    }
    
    func DrawSomething(s1:simd_float4x4, s2:simd_float4x4, result:Results){
    
        // loop through array of predictions
        for p in result.prediction {
            if (p[1] > 0.4) {
                
                var t = simd_float4x4(
                    float4(1,0,0,0),
                    float4(0,1,0,0),
                    float4(0,0,1,0),
                    float4(0,0,0,1)
                )
                
                var xloc = p[3]+(p[5]-p[3])/2.0 //(p[2]+p[4])/2.0
                var yloc = p[2]+(p[4]-p[2])/2.0//(p[3]+p[5])/2.0
               
                t.columns.3.x = s1.columns.3.x + (s2.columns.3.x-s1.columns.3.x) * xloc
                t.columns.3.y = s1.columns.3.y //+ (s2.columns.3.y-s1.columns.3.y) * 0.5
                t.columns.3.z = s1.columns.3.z + (s2.columns.3.z-s1.columns.3.z) * yloc
                
            
                let anchor = ARAnchor(name: "plane", transform:t)
            
                arView.session.add(anchor:anchor)
            }
        }
        

   

        
    }
    
    
    @objc
    func saveError(_ image:UIImage, didFinishSavingWithError error: Error?, contextInfo:UnsafeRawPointer) {
        if let error = error {
            print("error \(error.localizedDescription)")
        } else {
            print("Save Completed!")
        }
    }
    
    func placeObject(named entityName:String, for anchor: ARAnchor) {
       // let entity = try! ModelEntity.loadModel(named: entityName)
        let entity = CustomBox()
        
        //entity.generateCollisionShapes(recursive: true)
        //arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
    
        anchorEntity.addChild(entity)
        
        arView.scene.addAnchor(anchorEntity)
        
    }
}

class CustomBox: Entity, HasModel {
    required init() {
        super.init()
        self.components[ModelComponent] = ModelComponent(
            mesh: .generateBox(size:0.01),
            materials: [SimpleMaterial(color:UIColor(red:1, green:0, blue:0, alpha:1),isMetallic: false)])
    }
}


extension ViewController : ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "plane" {
                placeObject(named: anchorName, for: anchor)
                //addPlane(
            }
        }
    }
}

struct Results: Decodable {
    let prediction: [[Float]]
    
}
