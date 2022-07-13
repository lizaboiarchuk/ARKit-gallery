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
import Photos
import CoreLocation

// TODO: Track overlaying with wall planes (tv) and add images "between them"

class ViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    private enum Configuration {
        static let lightIntensity: CGFloat = 180
        static let wallNodeName = "wall-found"
        static let gridNodeName = "wall-grid"
        static let seeResultLabel = "See result"
        static let addMoreLabel = "Add more"
        static let gridImage = UIImage(named: Bundle.main.path(forResource: "grid", ofType: "png")!)!
    }
    
    
    // MARK: - Private properties
    @IBOutlet private var sceneView: ARSCNView!
    @IBOutlet private weak var showButton: UIButton!
    @IBOutlet private weak var pickImageButton: UIButton!
    @IBOutlet private weak var styleButton: UIButton!
    @IBOutlet private weak var captureButton: UIButton!
    @IBOutlet private weak var scaleButton: UIButton!
    
    private var presentationMode = false
    private var imageToDisplay = UIImage(named: Bundle.main.path(forResource: "test-pic", ofType: "jpeg")!)!
    private var styledImage = UIImage(named: Bundle.main.path(forResource: "test-pic", ofType: "jpeg")!)!
    private var imageCreatedDateText: String?
    private var imageLocationText: String?
    private var imageToWallRatio = 0.2
    
    private var currentStyle: ImageStyle = .default
    
    private var currentFrame: FrameStyle = .gold
    private var frameConfig = getFrameBorders(style: .gold)
    private var frameImage = getFrameImage(style: .gold)
    
    private let styler: ImageStyler = ImageStyler()
    
    
    
    
    // MARK: - Main methods
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        initGectureRecognizers()
        styleButton.addTarget(self, action: #selector(chooseStyle), for: .touchUpInside)
        PHPhotoLibrary.requestAuthorization({ status in print(status) })
    }
    
    
    
    @objc func chooseStyle(_ sender: UIButton) {
    }
    
    
    
    private func initGectureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        showButton.addTarget(self, action: #selector(changeMode), for: .touchUpInside)
    }
    
    
    @objc func changeMode(_ sender: UIButton) {
        let newLabel = presentationMode ? Configuration.seeResultLabel : Configuration.addMoreLabel
        showButton.setTitle(newLabel, for: .normal)
        sceneView.scene.rootNode.childNodes.filter({ $0.name == Configuration.wallNodeName }).forEach({ $0.childNodes.filter({ $0.name == Configuration.gridNodeName }).forEach({ $0.isHidden = !presentationMode })})
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
        guard let query = sceneView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .vertical) else {
           return
        }
                
        for result in sceneView.session.raycast(query) {
            guard let anchor = result.anchor as? ARPlaneAnchor, let node = sceneView.node(for: anchor) else {
                continue
            }
            
            if node.name != Configuration.gridNodeName && node.name != Configuration.wallNodeName {
                node.removeFromParentNode()
            } else if case .wall = anchor.classification {
                createFrame(anchor: anchor, node: result)
            }
        }
    }
    
//    @objc func handleTap(_ sender: UITapGestureRecognizer) {
//
//        if presentationMode { return }
//
//        let location = sender.location(in: self.sceneView)
//        let hitTestScene = self.sceneView.hitTest(location, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane])
//        if let first = hitTestScene.first, let anchor = first.anchor as? ARPlaneAnchor, case .wall = anchor.classification {
//            createFrame(anchor: anchor, node: first)
//        }
//        else {
//            showMessage("Not a wall")
//        }
//    }
    
    
    private func createFrame(anchor: ARPlaneAnchor, node: ARRaycastResult) {
        styledImage = styler.styleImage(imageToDisplay, as: currentStyle)
        
        let wallHeight = CGFloat(anchor.extent.z)
        let imageRatio = styledImage.size.height / styledImage.size.width
        let imageHeight = wallHeight * self.imageToWallRatio
        let frameNode = createImageNode(image: frameImage, size: (imageHeight / imageRatio, imageHeight))
        let pictureNode = createImageNode(image: styledImage, size: (imageHeight / imageRatio / ( 1 + 2 * frameConfig.horizontal), imageHeight / ( 1 + 2 * frameConfig.vertical)))
        
        frameNode.transform = SCNMatrix4(anchor.transform)
        frameNode.eulerAngles = SCNVector3(frameNode.eulerAngles.x + (-Float.pi / 2), frameNode.eulerAngles.y, frameNode.eulerAngles.z)
        frameNode.position = SCNVector3(node.worldTransform.columns.3.x, node.worldTransform.columns.3.y, node.worldTransform.columns.3.z + 0.001)
        
        pictureNode.transform = SCNMatrix4(anchor.transform)
        pictureNode.eulerAngles = SCNVector3(pictureNode.eulerAngles.x + (-Float.pi / 2), pictureNode.eulerAngles.y, pictureNode.eulerAngles.z)
        pictureNode.position = SCNVector3(node.worldTransform.columns.3.x, node.worldTransform.columns.3.y, node.worldTransform.columns.3.z)
        
        if let location = self.imageLocationText, let date = self.imageCreatedDateText {
            let text = SCNText(string: "\(date) \n \(location)", extrusionDepth: 1)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.black
            text.materials = [material]
            
            let textNode = SCNNode()
            textNode.position = SCNVector3(frameNode.position.x, frameNode.position.y - Float(imageHeight) / 2 + Float(text.containerFrame.height) - 0.02, frameNode.position.z)
            textNode.eulerAngles = SCNVector3(textNode.eulerAngles.x, textNode.eulerAngles.y + (-Float.pi / 10), textNode.eulerAngles.z)
            textNode.scale = SCNVector3(x:0.001, y:0.001, z:0.001)
            textNode.geometry = text
            
            sceneView.scene.rootNode.addChildNode(textNode)
        }
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            self.imageToDisplay = image.fixOrientation()
        }

        if let asset: PHAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            self.imageCreatedDateText = asset.creationDate?.formatted()
            if let loc = asset.location {
                CLGeocoder().reverseGeocodeLocation(loc) { placemarks, error in

                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                        return
                    }

                    let geo = ReversedGeoLocation(with: placemark)
                    self.imageLocationText = "\(geo.city), \(geo.country)"
                    print("\(geo.city), \(geo.country)")
                }
            }
        } else {
            print("Asset: nil")
        }
    }
    
    @IBAction func chooseImageTap(_ sender: Any) {
        let pickerViewController = UIImagePickerController()
        pickerViewController.delegate = self
        pickerViewController.sourceType = .photoLibrary
        present(pickerViewController, animated: true)
    }
    
    @IBAction func unwindSegueFromFrameController(_ sender: UIStoryboardSegue) {
        let sourceViewController = sender.source as! FrameTableViewController
        self.currentFrame = FrameStyle(rawValue: sourceViewController.selectedOption) ?? .gold
        self.frameConfig = getFrameBorders(style: self.currentFrame)
        self.frameImage = getFrameImage(style: self.currentFrame)
        print(self.currentFrame.rawValue)
    }
    
    @IBAction func unwindSegueFromStyleController(_ sender: UIStoryboardSegue) {
        let sourceViewController = sender.source as! StylesTableViewController
        self.currentStyle = ImageStyle(rawValue: sourceViewController.selectedOption) ?? .default
        print(self.currentStyle.rawValue)
        
    }
    
    @IBAction func onCaptureTap(_ sender: Any) {
        if !presentationMode {
            let alert = UIAlertController(title: "Oops", message: "Only available in presentation mode", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let takeScreenshotBlock = {
            UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
            DispatchQueue.main.async {
                // Briefly flash the screen.
                let flashOverlay = UIView(frame: self.sceneView.frame)
                flashOverlay.backgroundColor = UIColor.white
                self.sceneView.addSubview(flashOverlay)
                UIView.animate(withDuration: 0.25, animations: {
                    flashOverlay.alpha = 0.0
                }, completion: { _ in
                    flashOverlay.removeFromSuperview()
                })
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            takeScreenshotBlock()
        case .restricted, .denied:
            let title = "Photos access denied"
            let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    takeScreenshotBlock()
                }
            })
        default:
            return
        }
    }
    
    @IBAction func onScaleTap(_ sender: Any) {
        if self.imageToWallRatio == 0.8 {
            self.imageToWallRatio = 0.2
        } else {
            self.imageToWallRatio += 0.2
        }
        
        let alert = UIAlertController(title: "Scale", message: "Current image to wall ratio is \(String(format: "%.1f", self.imageToWallRatio))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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














