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
        static let frameHorizontalBorderRatio = 0.15
        static let frameVerticalBorderRatio = 0.115
        static let lightIntensity: CGFloat = 180
        static let wallNodeName = "wall-found"
        static let gridNodeName = "wall-grid"
        static let seeResultLabel = "See result"
        static let addMoreLabel = "Add more"
        static let gridImage = UIImage(named: Bundle.main.path(forResource: "grid", ofType: "png")!)!
        static let frameImage = UIImage(named: Bundle.main.path(forResource: "frame", ofType: "png")!)!
        
    }
    
    
    // MARK: - Private properties
    @IBOutlet private var sceneView: ARSCNView!
    @IBOutlet private weak var showButton: UIButton!
    @IBOutlet private weak var pickImageButton: UIButton!
    
    private var presentationMode = false
    private var imageToDisplay = UIImage(named: Bundle.main.path(forResource: "test-pic", ofType: "jpeg")!)!
    
    
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
            createFrame(anchor: anchor, node: first)
        }
        else {
            showMessage("Not a wall")
        }
    }
    
    
    private func createFrame(anchor: ARPlaneAnchor, node: ARHitTestResult) {
        let wallHeight = CGFloat(anchor.extent.z)
        let imageRatio = imageToDisplay.size.height / imageToDisplay.size.width
        let imageHeight = wallHeight * Configuration.imageToWallRatio
        let frameNode = createImageNode(image: Configuration.frameImage, size: (imageHeight / imageRatio, imageHeight))
        let pictureNode = createImageNode(image: imageToDisplay, size: (imageHeight / imageRatio / ( 1 + 2 * Configuration.frameHorizontalBorderRatio), imageHeight / ( 1 + 2 * Configuration.frameVerticalBorderRatio)))
        frameNode.transform = SCNMatrix4(anchor.transform)
        frameNode.eulerAngles = SCNVector3(frameNode.eulerAngles.x + (-Float.pi / 2), frameNode.eulerAngles.y, frameNode.eulerAngles.z)
        frameNode.position = SCNVector3(node.worldTransform.columns.3.x, node.worldTransform.columns.3.y, node.worldTransform.columns.3.z + 0.001)
        pictureNode.transform = SCNMatrix4(anchor.transform)
        pictureNode.eulerAngles = SCNVector3(pictureNode.eulerAngles.x + (-Float.pi / 2), pictureNode.eulerAngles.y, pictureNode.eulerAngles.z)
        pictureNode.position = SCNVector3(node.worldTransform.columns.3.x, node.worldTransform.columns.3.y, node.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(pictureNode)
        sceneView.scene.rootNode.addChildNode(frameNode)
    }
    
    
    private func createImageNode(image: UIImage, size: (CGFloat, CGFloat)) -> SCNNode{
        let imageGeometry = SCNPlane(width: size.0, height: size.1)
        let imageMaterial = SCNMaterial()
        imageMaterial.diffuse.contents = image
        imageGeometry.materials = [imageMaterial]
        let imageNode = SCNNode(geometry: imageGeometry)
        let imageLight = SCNLight()
        imageLight.intensity = Configuration.lightIntensity
        imageLight.type = .directional
        imageNode.light = imageLight
        return imageNode
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
            guard let planeNode = node.childNodes.first else { return }
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








