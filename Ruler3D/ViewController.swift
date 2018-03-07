//
//  ViewController.swift
//  Ruler3D
//
//  Created by Admin on 26.02.18.
//  Copyright © 2018 Ionut-Catalin Bolea. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Detect user touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            dotNodes.forEach{ (dot) in
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    //MARK: - Dot rendering methods
    func addDot(at hitResult: ARHitTestResult) {
        
        let dotGeometry = SCNSphere(radius: 0.005)
        let dotMaterial = SCNMaterial()
        
        dotMaterial.diffuse.contents = UIColor.red
        
        dotGeometry.materials.append(dotMaterial)
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculateDistance()
        }
        
    }
    
    
    //MARK: - Calculate distances between 2 points
    func calculateDistance() {
        let startNodePosition = dotNodes[0].position
        let endNodePosition = dotNodes[1].position
        
        //d = sqrt( a^2 + b^2 + c^2 )
        
        let distance = sqrt(
            pow(startNodePosition.x - endNodePosition.x, 2) +
            pow(startNodePosition.y - endNodePosition.y, 2) +
            pow(startNodePosition.z - endNodePosition.z, 2)
        )
        
        generateText3D(withNumber: distance, atPosition: endNodePosition)
    }
    
    func generateText3D(withNumber number:Float, atPosition position: SCNVector3) {
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: "\(number) meters", extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = position
        
        textNode.scale = SCNVector3(x: 0.003, y: 0.003, z: 0.003)
        
        if let camera = sceneView.pointOfView {
            textNode.orientation = camera.orientation
        }
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
        
        
    }

}
