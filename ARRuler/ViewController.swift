//
//  ViewController.swift
//  ARRuler
//
//  Created by Jawahar Tunuguntla on 05/07/2018.
//  Copyright © 2018 Jawahar Tunuguntla. All rights reserved.
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
    
    func addDot(at location: ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNodes.append(dotNode)
        dotNode.position = SCNVector3(x: location.worldTransform.columns.3.x, y: location.worldTransform.columns.3.y, z: location.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        if dotNodes.count == 2{
            calculate()
        }
    }
    
    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        var distance = sqrt(pow(a,2) + pow(b,2) + pow(c,2))
        var distanceUnit = ""
        
        if distance >= 1{
            distanceUnit = "m"
        }else{
            distance = distance*100
            distanceUnit = "cm"
        }
        
        updateText(with: String(distance), unit: distanceUnit, atPosition: SCNVector3((end.position.x+start.position.x)/2, (end.position.y+start.position.y)/2, (end.position.z+start.position.z)/2))
        
    }
    
    func updateText(with distance: String, unit: String, atPosition: SCNVector3) {
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: distance+unit, extrusionDepth: 0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(atPosition.x+0.01, atPosition.y+0.01, atPosition.z)
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2{
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes.removeAll()
        }
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first{
                addDot(at: hitResult)
            }
        }
    }
}
