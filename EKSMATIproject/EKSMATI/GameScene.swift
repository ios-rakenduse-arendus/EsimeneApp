//
//  GameScene.swift
//  EKSMATI
//
//  Created by Marianne Orusalu on 21/04/2018.
//  Copyright © 2018 Marianne Orusalu. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /*Mängu alguse ja kaotamise näitamine*/
    var isGameStarted = Bool(false)
    var isDied = Bool(false)
    
    /*Skoori salvestamine*/
    var score = Int(0)
    
    /*Hetke skoori & parima skoori kuvamine*/
    var scoreLbl = SKLabelNode()
    var highscoreLbl = SKLabelNode()
    
    /*taptoplay teksti kuvamine*/
    var taptoplayLbl = SKLabelNode()
    
    /*Restart & pausi nupu kuvamine*/
    var restartBtn = SKSpriteNode()
    var pauseBtn = SKSpriteNode()
    
    /*Logo ja eksmati näitamine*/
    var logoImg = SKSpriteNode()
    var eksmati = SKSpriteNode()
    
    /*Seinapaari näitamine*/
    var wallPair = SKNode()
    
    let EAPSound = SKAction.playSoundFileNamed("EAPSound.mp3", waitForCompletion: false)
    let wolfSound = SKAction.playSoundFileNamed("wolfSound.mp3", waitForCompletion: false)
    
    var moveAndRemove = SKAction()
    
    
    override func didMove(to view: SKView) {
        createScene()

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isGameStarted == false{
            /* Mäng algas: paneme Eksmati gravitatsioonile reageerima ning lisame ekraanile pausi nupu */
            isGameStarted =  true
            eksmati.physicsBody?.affectedByGravity = true
            createPauseBtn()
            
            /* Mäng algas: eemaldame logo */
            logoImg.run(SKAction.scale(to: 0.5, duration: 0.3), completion: {
                self.logoImg.removeFromParent()
            })
            taptoplayLbl.removeFromParent()
            
            //TODO: siia lisame hiljem postid
            /* Loome ja lisame postipaari ekraanile */
            let spawn = SKAction.run({
                () in
                self.wallPair = self.createWalls()
                self.addChild(self.wallPair)
            })
            
            /* Lisame ajalise vahemaa postipaari loomiste vahel ning paneme selle lõpmatuseni end välja kutsuma */
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            /* Liigutame ja eemaldame poste */
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePostid = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removePostid = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePostid, removePostid])
            
            /* Määrame kiiruse olematuks, et tagada Eksmati püsivus ning paneme ta ülespoole hüplema */
            eksmati.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            eksmati.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
        } else {
            
            /* Mäng algas, mis tähendab, et isGameStarted väärtuseks on senikauua true ning me kutsume siin välja else väärtuse, mis ütleb, et mängija rakendab ekraani puudutamist, seni kuni Eksmati pole surnud */
            if isDied == false {
                eksmati.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                eksmati.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            }
        }
        
        
        /* Kontrollime, kus ja milla mängija ekraani vajutas, et me teaks, mida mäng parajasti kuvama peab */
        for touch in touches{
            let location = touch.location(in: self)
            
            /* Sündmused, kui mängija kaotas: kuvame ainut restart nupu ning kontrollime selle vajutamisel parimat skoori */
            if isDied == true{
                if restartBtn.contains(location){
                    if UserDefaults.standard.object(forKey: "highestScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                        if hscore < Int(scoreLbl.text!)!{
                            UserDefaults.standard.set(scoreLbl.text, forKey: "highestScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "highestScore")
                    }
                    restartScene()
                }
            } else {
                
                /* Sündmused, kui mäng veel kestab: pausi ja play nupu ja sündmuse kuvamine */
                if pauseBtn.contains(location){
                    if self.isPaused == false{
                        self.isPaused = true
                        pauseBtn.texture = SKTexture(imageNamed: "play")
                    } else {
                        self.isPaused = false
                        pauseBtn.texture = SKTexture(imageNamed: "pause")
                    }
                }
            }
        }
        
    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        isDied = false
        isGameStarted = false
        score = 0
        createScene()
    }
    
    func createScene(){
        /*Loome füüsilise keha twrve ekraani ümber kasutades selleks edgeLoopFrom'i ning anname sellele väärtuse self.frame*/
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.eksmatiCategory
        self.physicsBody?.contactTestBitMask = CollisionBitMask.eksmatiCategory
        self.physicsBody?.isDynamic = false
        
        /*Tagame selle et mängija(Eksmati) ei kukuks ekraanist välja*/
        self.physicsBody?.affectedByGravity = false
        
        /*Selleks et mäng tuvastaks kokkupõrke eksmati ja seina vahel*/
        self.physicsWorld.contactDelegate = self
        
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        
        
        
        for i in 0..<2
        {
            let background = SKSpriteNode(imageNamed: "taust")
            background.anchorPoint = CGPoint.init(x: 0, y:0)
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
            
        }
        
        /* Kutsume GameElement.swift failis loodud Eksmati välja */
        self.eksmati = createEksmati()
        self.addChild(eksmati)
        
        /* Kutsume GameElements.swift failis loodud skoori välja */
        scoreLbl = createScoreLabel()
        self.addChild(scoreLbl)
        
        
        /* Kutsume GameElements.swift failis loodud parima skoori välja */
        highscoreLbl = createHighscoreLabel()
        self.addChild(highscoreLbl)
        
        
        /* Kutsume GameElements.swift failis loodud logo välja */
        createLogo()
        
        taptoplayLbl = createTaptoplayLabel()
        self.addChild(taptoplayLbl)
    }
    
    /* Kontrollime Eksmati kokkupõrget posti või põrandaga ning nendel juhtudel lõpetame mängu */
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.eksmatiCategory && secondBody.categoryBitMask == CollisionBitMask.postCategory || firstBody.categoryBitMask == CollisionBitMask.postCategory && secondBody.categoryBitMask == CollisionBitMask.eksmatiCategory || firstBody.categoryBitMask == CollisionBitMask.eksmatiCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.eksmatiCategory{
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if isDied == false{
                isDied = true
                createRestartBtn()
                pauseBtn.removeFromParent()
                self.eksmati.removeAllActions()
                run(wolfSound)
            }
            
            /* Kontrollime, kas Eksmati sai EAP kätte, lisame sellele tegevusele heli ning suurendame skoori ja eemaldame kätte saadud EAP ekraanilt*/
        } else if firstBody.categoryBitMask == CollisionBitMask.eksmatiCategory && secondBody.categoryBitMask == CollisionBitMask.EAPCategory {
            run(EAPSound)
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.EAPCategory && secondBody.categoryBitMask == CollisionBitMask.eksmatiCategory {
            run(EAPSound)
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if isGameStarted == true{
            if isDied == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let taust = node as! SKSpriteNode
                    taust.position = CGPoint(x: taust.position.x - 2, y: taust.position.y)
                    if taust.position.x <= -taust.size.width {
                        taust.position = CGPoint(x:taust.position.x + taust.size.width * 2, y:taust.position.y)
                    }
                }))
            }
        }
    }
}
