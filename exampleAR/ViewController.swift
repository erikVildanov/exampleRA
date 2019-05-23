//
//  ViewController.swift
//  exampleAR
//
//  Created by Erik Vildanov on 20/05/2019.
//  Copyright © 2019 Erik Vildanov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private var oldAndleY: CGFloat = 0
    private var pinchGestureAnchorScale: CGFloat?
    private let pinchGestureRecognizer = UIPinchGestureRecognizer()
    private var scale: CGFloat = 0
    private var carNode: SCNNode!
    
    private var wheelFR: SCNNode!
    private var wheelFL: SCNNode!
    private var wheelRR: SCNNode!
    private var wheelRL: SCNNode!
    
    var physicsVehicle: SCNPhysicsVehicle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/car11.scn")!
        sceneView.scene = scene
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        addPanGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    func addPanGesture() {
        let rootNode = sceneView.scene.rootNode
        
        carNode = rootNode.childNode(withName: "evo10", recursively: false)
        let car = carNode.childNode(withName: "Car", recursively: false)
        let physicsShape = SCNPhysicsShape(node: car!, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        physicsBody.friction = 4
        physicsBody.damping = 1
        
        wheelFR = carNode!.childNode(withName: "wheelFrontRight", recursively: false)
        wheelFL = carNode!.childNode(withName: "wheelFrontLeft", recursively: false)
        wheelRR = carNode!.childNode(withName: "wheelRearRight", recursively: false)
        wheelRL = carNode!.childNode(withName: "wheelRearLeft", recursively: false)
        
        let physicsVehicleWheel1 = SCNPhysicsVehicleWheel(node: wheelFR)
        let physicsVehicleWheel2 = SCNPhysicsVehicleWheel(node: wheelFL)
        let physicsVehicleWheel3 = SCNPhysicsVehicleWheel(node: wheelRR)
        let physicsVehicleWheel4 = SCNPhysicsVehicleWheel(node: wheelRL)
        
        
        physicsVehicle = SCNPhysicsVehicle(chassisBody: physicsBody, wheels: [physicsVehicleWheel1, physicsVehicleWheel2, physicsVehicleWheel3, physicsVehicleWheel4])
        
        //        wheelFR = carNode!.childNode(withName: "wheelFrontRight", recursively: false)
        //        wheelFL = carNode!.childNode(withName: "wheelFrontLeft", recursively: false)
        //        wheelRR = carNode!.childNode(withName: "wheelRearRight", recursively: false)
        //        wheelRL = carNode!.childNode(withName: "wheelRearLeft", recursively: false)
        
        //        print("pivot wheelFR", wheelFR.pivot)
        //        print("pivot wheelFL", wheelFL.pivot)
        //        print("pivot wheelRR", wheelRR.pivot)
        //        print("pivot wheelRL", wheelRL.pivot)
        
        // Set the scene to the view
        
        
        sceneView.scene.physicsWorld.addBehavior(physicsVehicle)
        
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(rotationGesture(gesture:)))
        sceneView.addGestureRecognizer(panGesture)
        
        pinchGestureRecognizer.addTarget(self, action: #selector(zoomGesture(gestureRecognizer:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func rotationGesture(gesture: UIPanGestureRecognizer) {
        let translition = gesture.translation(in: self.sceneView)
        
//        print(oldAndleY)
        oldAndleY += translition.y / 1000
        
        physicsVehicle.applyEngineForce(translition.y, forWheelAt: 0)
        physicsVehicle.applyEngineForce(translition.y, forWheelAt: 1)
        physicsVehicle.applyEngineForce(translition.y, forWheelAt: 2)
        physicsVehicle.applyEngineForce(translition.y, forWheelAt: 3)
        
//        wheelFR.pivot = SCNMatrix4Rotate(wheelFR.pivot, Float(oldAndleY), 0, 1, 0)
//        wheelFL.pivot = SCNMatrix4Rotate(wheelFR.pivot, Float(oldAndleY), 0, 1, 0)
//        wheelRR.pivot = SCNMatrix4Rotate(wheelFR.pivot, Float(oldAndleY), 0, 1, 0)
//        wheelRL.pivot = SCNMatrix4Rotate(wheelFR.pivot, Float(oldAndleY), 0, 1, 0)
        
        
//        carNode.eulerAngles.y = Float(oldAndleY)
        
        
    }
    
    @objc func zoomGesture(gestureRecognizer: UIPinchGestureRecognizer) {
        guard pinchGestureRecognizer === gestureRecognizer else { assert(false); return }
        
        switch gestureRecognizer.state {
        case .began:
            assert(pinchGestureAnchorScale == nil)
            pinchGestureAnchorScale = gestureRecognizer.scale
            
        case .changed:
            guard let pinchGestureAnchorScale = pinchGestureAnchorScale else { assert(false); return }
            
            let gestureScale = gestureRecognizer.scale
            scale += gestureScale - pinchGestureAnchorScale
            self.pinchGestureAnchorScale = gestureScale
            
            if scale > 0 && scale < 1.5 {
                carNode.scale = SCNVector3(scale, scale, scale)
            }
            
            print(scale)
            
        case .cancelled, .ended:
            pinchGestureAnchorScale = nil
            
        case .failed, .possible:
            assert(pinchGestureAnchorScale == nil)
            break
        @unknown default:
            fatalError()
        }
    }
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
