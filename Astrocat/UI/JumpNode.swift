//
//  JumpNode.swift
//  Wildsnare
//
//  Created by Valentino Manuel Gunawan on 02/05/26.
//

import SpriteKit

class JumpNode: SKNode {
    private let background: SKShapeNode
    var onTap: (() -> Void)?
    
    init(iconName: String) {
        background = SKShapeNode(circleOfRadius: 60)
        background.strokeColor = .white
        background.fillColor = .white.withAlphaComponent(0.1)
        
        super.init()
        addChild(background)
        self.isUserInteractionEnabled = true
        
        // Setup Icon
        if let tex = textureFromSymbol(name: iconName, color: .white) {
            let icon = SKSpriteNode(texture: tex)
            addChild(icon)
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.sequence([
            SKAction.scale(to: 0.9, duration: 0.1),
            SKAction.wait(forDuration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        onTap?()
    }
    
    private func textureFromSymbol(name: String, color: UIColor) -> SKTexture? {
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .bold)
        guard let sym = UIImage(systemName: name, withConfiguration: config) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: sym.size)
        let img = renderer.image { _ in
            color.set()
            sym.withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
        return SKTexture(image: img)
    }
}
