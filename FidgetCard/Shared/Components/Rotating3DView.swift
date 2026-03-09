import SwiftUI
import SceneKit

enum SceneCache {
    private static var cached: (scene: SCNScene, cameraNode: SCNNode, cardNode: SCNNode)?

    static func warmUp() {
        _ = shared
    }

    static var shared: (scene: SCNScene, cameraNode: SCNNode, cardNode: SCNNode) {
        if let cached { return cached }
        let result = Rotating3DView.buildScene()
        cached = result
        return result
    }

    static func restartAnimation() {
        guard let cached else { return }
        let cardNode = cached.cardNode
        cardNode.removeAction(forKey: "spin")
        cardNode.eulerAngles = SCNVector3Zero

        let openSpin = SCNAction.rotateBy(x: 0, y: -.pi * 2, z: 0, duration: 0.6)
        openSpin.timingFunction = { t in
            let inverse = 1 - t
            return 1 - inverse * inverse * inverse
        }

        let autoRotateStep = SCNAction.rotateBy(x: 0, y: -.pi * 2, z: 0, duration: 6)
        autoRotateStep.timingMode = .linear
        let autoRotate = SCNAction.repeatForever(autoRotateStep)

        cardNode.runAction(.sequence([openSpin, autoRotate]), forKey: "spin")
    }
}

struct Rotating3DView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let sceneSetup = SceneCache.shared
        scnView.scene = sceneSetup.scene
        scnView.pointOfView = sceneSetup.cameraNode
        SceneCache.restartAnimation()
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = true
        scnView.defaultCameraController.interactionMode = .orbitTurntable

        // Disable vertical swipe: lock camera pitch to initial angle.
        let lockedVerticalAngle = verticalAngle(for: sceneSetup.cameraNode.position)
        scnView.defaultCameraController.minimumVerticalAngle = lockedVerticalAngle
        scnView.defaultCameraController.maximumVerticalAngle = lockedVerticalAngle

        // Block pinch (zoom) and two-finger pan.
        // Keep horizontal one-finger orbit, but let vertical swipe pass to sheet drag.
        if let gestureRecognizers = scnView.gestureRecognizers {
            for gesture in gestureRecognizers {
                if gesture is UIPinchGestureRecognizer {
                    gesture.isEnabled = false
                } else if let pan = gesture as? UIPanGestureRecognizer {
                    if pan.minimumNumberOfTouches >= 2 {
                        pan.isEnabled = false
                    } else if pan.minimumNumberOfTouches == 1 {
                        pan.maximumNumberOfTouches = 1
                        pan.delegate = context.coordinator
                    }
                }
            }
        }

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func verticalAngle(for position: SCNVector3) -> Float {
        let xzRadius = sqrt(position.x * position.x + position.z * position.z)
        guard xzRadius > 0.0001 else { return 0 }
        return atan2(position.y, xzRadius) * 180 / .pi
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
                return true
            }

            let velocity = pan.velocity(in: pan.view)
            // Reject vertical drags so the sheet handles swipe-to-dismiss and bounce.
            return abs(velocity.x) >= abs(velocity.y)
        }
    }

    static func buildScene() -> (scene: SCNScene, cameraNode: SCNNode, cardNode: SCNNode) {
        let scene = SCNScene()

        let frontTextureImage = UIImage(named: "TexFront")
        let backTextureImage = UIImage(named: "TexBack")
        let defaultAspectRatio: CGFloat = 862.0 / 1165.0
        let documentAspectRatio = {
            guard let image = frontTextureImage,
                  image.size.width > 0,
                  image.size.height > 0 else {
                return defaultAspectRatio
            }
            return image.size.width / image.size.height
        }()

        // Match card proportion to front texture.
        let cardScale: CGFloat = 2.0
        let sizeScale: CGFloat = 0.7
        let baseCardWidth: CGFloat = 1.5
        let baseCardLength: CGFloat = 0.05
        let baseCornerRadius: CGFloat = 0.05
        let cardWidth: CGFloat = baseCardWidth * cardScale * sizeScale
        let cardHeight: CGFloat = (baseCardWidth / documentAspectRatio) * cardScale * sizeScale
        let cardThickness: CGFloat = baseCardLength * 1
        let cardCornerRadius = min(
            baseCornerRadius * cardScale * sizeScale,
            min(cardWidth, cardHeight) * 0.5
        )
        let cardPath = UIBezierPath(
            roundedRect: CGRect(
                x: -cardWidth * 0.5,
                y: -cardHeight * 0.5,
                width: cardWidth,
                height: cardHeight
            ),
            cornerRadius: cardCornerRadius
        )
        let card = SCNShape(path: cardPath, extrusionDepth: cardThickness)
        card.chamferRadius = 0
        let cardNode = SCNNode(geometry: card)
        cardNode.pivot = SCNMatrix4MakeTranslation(0, 0, Float(cardThickness * 0.5))
        cardNode.position = SCNVector3(0, 0, 0)

        let frontMaterial = SCNMaterial()
        frontMaterial.lightingModel = .physicallyBased
        frontMaterial.diffuse.contents = frontTextureImage ?? UIColor.systemGray5
        frontMaterial.metalness.contents = 0.0
        frontMaterial.roughness.contents = 1.0

        let backMaterial = SCNMaterial()
        backMaterial.lightingModel = .physicallyBased
        backMaterial.diffuse.contents = backTextureImage ?? UIColor(red: 0.97, green: 0.96, blue: 0.92, alpha: 1.0)
        backMaterial.metalness.contents = 0.0
        backMaterial.roughness.contents = 1.0

        let edgeMaterial = SCNMaterial()
        edgeMaterial.lightingModel = .physicallyBased
        edgeMaterial.diffuse.contents = backTextureImage ?? UIColor(red: 0.88, green: 0.86, blue: 0.81, alpha: 1.0)
        edgeMaterial.multiply.contents = UIColor(white: 0.9, alpha: 1.0)
        edgeMaterial.metalness.contents = 0.0
        edgeMaterial.roughness.contents = 1.0

        // SCNShape extruded materials order: front, back, side
        card.materials = [frontMaterial, backMaterial, edgeMaterial]

        scene.rootNode.addChildNode(cardNode)

        // Camera
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.bloomIntensity = 0.5
        camera.bloomThreshold = 0.8
        camera.contrast = 1.2
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 1.5, 5.5)
        cameraNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(cameraNode)

        // Ambient-only lighting
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.intensity = 800
        scene.rootNode.addChildNode(ambientNode)

        return (scene, cameraNode, cardNode)
    }
}
