//
//  ViewController.swift
//  gallery-test
//
//  Created by Yelyzaveta Boiarchuk on 03.07.2022.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

// TODO: Track overlaying with wall planes (tv) and add images "between them"


class ViewController: UIViewController, ARSCNViewDelegate {
    
    private enum Configuration {
        static let imageToWallRatio = 0.3
        static let wallNodeName = "wall-found"
        static let gridNodeName = "wall-grid"
        static let gridImage = UIImage(named: "grid.png")!
        static let seeResultLabel = "See result"
        static let addMoreLabel = "Add more"
    }
    
    
    // MARK: - Private properties
    @IBOutlet private var sceneView: ARSCNView!
    @IBOutlet private weak var showButton: UIButton!
    @IBOutlet private weak var pickImageButton: UIButton!
    private var presentationMode = false
    private var imageToDisplay = UIImage(named: "pict.jpeg")!
    

    
    // MARK: - Main methods
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        initGectureRecognizers()
    }
    
    
    private func initGectureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        showButton.addTarget(self, action: #selector(changeMode), for: .touchUpInside)
    }
    
    
    @objc func changeMode(_ sender: UIButton) {
        let newLabel = presentationMode ? Configuration.seeResultLabel : Configuration.addMoreLabel
        showButton.setTitle(newLabel, for: .normal)
        sceneView.scene.rootNode.childNodes.filter({ $0.name == "wall-found" }).forEach({ $0.childNodes.filter({ $0.name == "wall-grid" }).forEach({ $0.isHidden = !presentationMode })})
        presentationMode = !presentationMode
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        if presentationMode { return }
        
        let location = sender.location(in: self.sceneView)
        let hitTestScene = self.sceneView.hitTest(location, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane])
        
        if let first = hitTestScene.first, let anchor = first.anchor as? ARPlaneAnchor, case .wall = anchor.classification {
            
            let imageRatio = imageToDisplay.size.height / imageToDisplay.size.width
            let wallHeight = CGFloat(anchor.extent.z)
            let imageHeight = wallHeight * Configuration.imageToWallRatio
            
            let planeGeometry = SCNPlane(width: imageHeight / imageRatio, height: imageHeight)
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.diffuse.contents = imageToDisplay
            planeGeometry.materials = [material]
            
            let pictureNode = SCNNode(geometry: planeGeometry)
            pictureNode.transform = SCNMatrix4(first.anchor!.transform)
            pictureNode.eulerAngles = SCNVector3(pictureNode.eulerAngles.x + (-Float.pi / 2), pictureNode.eulerAngles.y, pictureNode.eulerAngles.z)
            pictureNode.position = SCNVector3(first.worldTransform.columns.3.x, first.worldTransform.columns.3.y, first.worldTransform.columns.3.z)
            
            sceneView.scene.rootNode.addChildNode(pictureNode)
        }
        else { showMessage("Not a wall") }
    }
    
    
    // TODO: Add "message" to screen when user tries to tap not a wall
    private func showMessage(_ message: String) {
        print(message)
    }
    
    
    // MARK: - Renderer methods
    
    // add grids when finding new walls
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if presentationMode { return }
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        
        if case .wall = planeAnchor.classification {
            node.name = Configuration.wallNodeName
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let grid = SCNNode(geometry: SCNPlane(width: width, height: height))
            
            grid.name = Configuration.gridNodeName
            grid.eulerAngles.x = -.pi/2
            grid.geometry?.firstMaterial?.diffuse.contents = Configuration.gridImage
            node.addChildNode(grid)
        }
    }
    
    
    // update grids
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if case .wall = planeAnchor.classification {
            guard let planeNode = node.childNodes.first, let plane = planeNode.geometry as? SCNPlane else { return }
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            plane.width = width
            plane.height = height
        }
        else {
            guard let planeNode = node.childNodes.first, let plane = planeNode.geometry as? SCNPlane else { return }
            planeNode.isHidden = true
            
        }
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








