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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/car11.scn")!
        
        let rootNode = scene.rootNode
        
        carNode = rootNode.childNode(withName: "evo10", recursively: false)
        let MovingParts_Doors_Wheels = carNode.childNode(withName: "MovingParts_Doors_Wheels", recursively: false)
        let Front_RightWheel = MovingParts_Doors_Wheels!.childNode(withName: "Front_RightWheel", recursively: false)
        wheelFR = Front_RightWheel!.childNode(withName: "wheelFR", recursively: false)
        
        let Front_Left_Wheel = MovingParts_Doors_Wheels!.childNode(withName: "Front_Left_Wheel", recursively: false)
        wheelFL = Front_Left_Wheel!.childNode(withName: "wheelFL", recursively: false)
        
        let Rear_RightWheel = MovingParts_Doors_Wheels!.childNode(withName: "Rear_RightWheel", recursively: false)
        wheelRR = Rear_RightWheel!.childNode(withName: "wheelRR", recursively: false)
        
        let Rear_Left_wheel = MovingParts_Doors_Wheels!.childNode(withName: "Rear_Left_wheel", recursively: false)
        wheelRL = Rear_Left_wheel!.childNode(withName: "wheelRL", recursively: false)
        
        print("pivot wheelFR", wheelFR.pivot)
        print("pivot wheelFL", wheelFL.pivot)
        print("pivot wheelRR", wheelRR.pivot)
        print("pivot wheelRL", wheelRL.pivot)
        
        
        // Set the scene to the view
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
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(rotationGesture(gesture:)))
        sceneView.addGestureRecognizer(panGesture)
        
        pinchGestureRecognizer.addTarget(self, action: #selector(zoomGesture(gestureRecognizer:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func rotationGesture(gesture: UIPanGestureRecognizer) {
        let translition = gesture.translation(in: self.sceneView)
        
//        print(oldAndleY)
        oldAndleY += translition.y / 1000
        
//        wheelFR.pivot = SCNMatrix4Rotate(wheelFR.pivot, Float(oldAndleY), 1, 0, 0)
//        wheelFL.pivot = SCNMatrix4Rotate(wheelFR.pivot, Float(oldAndleY), 0, 1, 0)
//        wheelRR.pivot = SCNMatrix4Rotate(wheelFR.pivot, Float(oldAndleY), 0, 0, 1)
//        wheelRL.pivot = SCNMatrix4Rotate(wheelFR.pivot, Float(oldAndleY), 0, 0.5, 0)
        
        
        carNode.eulerAngles.y = Float(oldAndleY)
        
        
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
