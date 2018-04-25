//
//  GameElements.swift
//  EKSMATI
//
//  Created by Marianne Orusalu on 21/04/2018.
//  Copyright © 2018 Marianne Orusalu. All rights reserved.
//

import SpriteKit

struct CollisionBitMask{
    static let eksmatiCategory:UInt32 = 0x1 << 0
    static let postCategory:UInt32 = 0x1 << 1
    static let EAPCategory:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
}

extension GameScene{
    
    
    func createEksmati() -> SKSpriteNode {
        
        eksmati = SKSpriteNode(imageNamed: "eksmati")
        eksmati.size = CGSize(width: 50, height: 50)
        eksmati.position = CGPoint(x:self.frame.midX, y:self.frame.midY)
        
        eksmati.physicsBody = SKPhysicsBody(circleOfRadius: eksmati.size.width / 2)
        eksmati.physicsBody?.linearDamping = 1.1
        eksmati.physicsBody?.restitution = 0
        
        eksmati.physicsBody?.categoryBitMask = CollisionBitMask.eksmatiCategory
        eksmati.physicsBody?.collisionBitMask = CollisionBitMask.postCategory | CollisionBitMask.groundCategory
        eksmati.physicsBody?.contactTestBitMask = CollisionBitMask.postCategory | CollisionBitMask.EAPCategory | CollisionBitMask.groundCategory
        
        eksmati.physicsBody?.affectedByGravity = false
        eksmati.physicsBody?.isDynamic = true
        
        
        return eksmati
    }
    
    /* Loome restart nupu */
    func createRestartBtn() {
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width:100, height:100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createPauseBtn() {
        pauseBtn = SKSpriteNode(imageNamed: "pause")
        pauseBtn.size = CGSize(width:40, height:40)
        pauseBtn.position = CGPoint(x: self.frame.width - 30, y: 30)
        pauseBtn.zPosition = 6
        self.addChild(pauseBtn)
    }
    
    
    
    /* Loome skoori kuvamise ekraanil */
    func createScoreLabel() -> SKLabelNode {
        let scoreLbl = SKLabelNode()
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 3.0)
        scoreLbl.text = "\(score)"
        scoreLbl.fontColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        scoreLbl.zPosition = 5
        scoreLbl.fontSize = 50
        scoreLbl.fontName = "HelveticaNeue-Bold"
        return scoreLbl
    }
    
    
    
    
    /* Loome parima skoori kuvamise ekraanil */
    func createHighscoreLabel() -> SKLabelNode {
        let highscoreLbl = SKLabelNode()
        highscoreLbl.position = CGPoint(x: self.frame.width - 100, y: self.frame.height - 45)
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            highscoreLbl.text = "Highest EAP Score: \(highestScore)"
        } else {
            highscoreLbl.text = "Highest EAP Score: 0"
        }
        highscoreLbl.fontColor = UIColor(red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0))
        highscoreLbl.zPosition = 5
        highscoreLbl.fontSize = 15
        highscoreLbl.fontName = "Helvetica-Bold"
        return highscoreLbl
    }
    
    /* Loome logo kuvamise ekraanil */
    func createLogo() {
        logoImg = SKSpriteNode()
        logoImg = SKSpriteNode(imageNamed: "logo")
        logoImg.size = CGSize(width: 272, height: 65)
        logoImg.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 100)
        logoImg.setScale(0.5)
        self.addChild(logoImg)
        logoImg.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    
    func createTaptoplayLabel() -> SKLabelNode {
        let taptoplayLbl = SKLabelNode()
        taptoplayLbl.position = CGPoint(x:self.frame.midX, y:self.frame.midY - 100)
        taptoplayLbl.text = "Tap anywhere to play"
        taptoplayLbl.fontColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        taptoplayLbl.zPosition = 5
        taptoplayLbl.fontSize = 20
        taptoplayLbl.fontName = "HelveticaNeue"
        return taptoplayLbl
    }
    
    /* Iga seinapaari ekraanile kutsumiseks jooksutatakse läbi seda funktsiooni */
    func createWalls() -> SKNode  {
        
        /* Loome EAP ning paneme ta reageerima kokkupuutel Eksmtiga */
        let eapNode = SKSpriteNode(imageNamed: "EAP")
        eapNode.size = CGSize(width: 40, height: 40)
        eapNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        eapNode.physicsBody = SKPhysicsBody(rectangleOf: eapNode.size)
        eapNode.physicsBody?.affectedByGravity = false
        eapNode.physicsBody?.isDynamic = false
        eapNode.physicsBody?.categoryBitMask = CollisionBitMask.EAPCategory
        eapNode.physicsBody?.collisionBitMask = 0
        eapNode.physicsBody?.contactTestBitMask = CollisionBitMask.eksmatiCategory
        eapNode.color = SKColor.blue
        
        /* Loome SKNode objekti alumise ja ülemise posti kuvamiseks. */
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "post")
        let btmWall = SKSpriteNode(imageNamed: "post")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 420)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 420)
        
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = CollisionBitMask.postCategory
        topWall.physicsBody?.collisionBitMask = CollisionBitMask.eksmatiCategory
        topWall.physicsBody?.contactTestBitMask = CollisionBitMask.eksmatiCategory
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = CollisionBitMask.postCategory
        btmWall.physicsBody?.collisionBitMask = CollisionBitMask.eksmatiCategory
        btmWall.physicsBody?.contactTestBitMask = CollisionBitMask.eksmatiCategory
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        /* Selleks, et näidata ülemist posti üleval on vaja topWall'i keerata 180 kraadi ning seda sab teha CGFloat.pi abil */
        topWall.zRotation = CGFloat.pi
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        /* Paneme potipaari kõrgused suvaliselt jooksma vahemikus -200 ja 200 */
        let randomPosition = random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y +  randomPosition
        wallPair.addChild(eapNode)
        
        
        /* Liigutame postipaari horisontaalselt ning eemaldame need ekraanilt kui nad jõuuavad ekraani teise otsa */
        wallPair.run(moveAndRemove)
        
        return wallPair
    }
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
}
