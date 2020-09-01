//
//  GameScene.swift
//  FreeWorld
//
//  Created by Tyler Burgee on 8/30/20.
//  Copyright © 2020 Tyler Burgee. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BodyType:UInt32 {
    case player = 1
    case building = 2
    case doorway = 4
}

// PLAYER NODES
var player = SKSpriteNode()

// BOUNDARY NODES
var left_house = SKSpriteNode()
var right_house = SKSpriteNode()

var top_wall = SKSpriteNode()
var bottom_wall = SKSpriteNode()
var left_wall = SKSpriteNode()
var right_wall = SKSpriteNode()

// DOORWAY NODES
var skate_shop_entry = SKSpriteNode()
var skate_shop_exit = SKSpriteNode()

// PLAYER CONTROL NODES
var up_button = SKSpriteNode()
var down_button = SKSpriteNode()
var left_button = SKSpriteNode()
var right_button = SKSpriteNode()

// BUTTON PRESSED VARIABLES
var up_button_pressed = false
var down_button_pressed = false
var left_button_pressed = false
var right_button_pressed = false

// GAME LOOK VARIABLES
var background = SKSpriteNode()
var player_skin = "shooter_player1"

class GameScene: SKScene, SKPhysicsContactDelegate {

    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var player_x = 200
    var player_y = 200
  
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        town_square()
        DisplayControls()
        SpawnSprite()
    }
    
    func town_square() {
        removeAllChildren()
        SetBackground(background_image: "NEW_MAP")
        DisplayControls()
        SetBoundary(object: left_house, name: "left_house", width: 400, height: 375, x: -500, y: 340)
        SetBoundary(object: right_house, name: "right_house", width: 400, height: 375, x: 500, y: 340)
        SetDoorway(object: skate_shop_entry, name: "skate_shop_entry", width: 85, height: 80, x: -490, y: 150)
    }
    
    func skate_shop() {
        removeAllChildren()
        SetBackground(background_image: "skate_shop")
        DisplayControls()
        SetBoundary(object: top_wall, name: "wall_house", width: 775, height: 50, x: 15, y: 250)
        SetBoundary(object: bottom_wall, name: "wall_house", width: 450, height: 50, x: -150, y: -225)
        SetBoundary(object: left_wall, name: "wall_house", width: 35, height: 450, x: -350, y: 0)
        SetBoundary(object: right_wall, name: "wall_house", width: 35, height: 450, x: 370, y: 0)
        SetDoorway(object: skate_shop_exit, name: "skate_shop_exit", width: 100, height: 50, x: 200, y: -225)
        player_x = 225
        player_y = -165
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // THIS GETS CALLED AUTOMATICALLY WHEN TWO OBJECTS BEGIN CONTACT
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
            case BodyType.player.rawValue | BodyType.building.rawValue:
                up_button_pressed = false
                down_button_pressed = false
                left_button_pressed = false
                right_button_pressed = false
            case BodyType.player.rawValue | BodyType.doorway.rawValue:
                if contact.bodyA.node?.name == "skate_shop_exit" {
                    player_x = -480
                    player_y = 50
                    town_square()
                    print("player hit skate exit")
                } else if contact.bodyA.node?.name == "skate_shop_entry"{
                    skate_shop()
                    print("player hit skate entry")
                }

            default:
                return
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        // THIS GETS CALLED AUTOMATICALLY WHEN TWO OBJECTS END CONTACT
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        case BodyType.player.rawValue | BodyType.building.rawValue:
            print("HI")
        case BodyType.player.rawValue | BodyType.doorway.rawValue:
            print("HELLO")
        default:
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        if up_button.contains(touch.location(in: self)) {
            up_button_pressed = true
        } else if down_button.contains(touch.location(in: self)) {
            down_button_pressed = true
        } else if left_button.contains(touch.location(in: self)) {
            left_button_pressed = true
        } else if right_button.contains(touch.location(in: self)) {
            right_button_pressed = true
        }
    }
    
    func SpawnSprite() {
        player = SKSpriteNode(imageNamed: player_skin)
        player.name = "player"
        player.size = CGSize(width: 60, height: 60)
        player.position = CGPoint(x: player_x, y: player_y)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.isDynamic = true
        player.physicsBody!.categoryBitMask = BodyType.player.rawValue
        player.physicsBody!.collisionBitMask = BodyType.building.rawValue | BodyType.doorway.rawValue
        player.physicsBody!.contactTestBitMask = BodyType.building.rawValue | BodyType.doorway.rawValue
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.restitution = 0
        
        self.addChild(player)
    }
    
    func SetBackground(background_image: String) {
        background = SKSpriteNode(imageNamed: background_image)
        background.size = self.frame.size
        background.zPosition = -1
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
    }
    
    func SetBoundary(object: SKSpriteNode, name: String, width: Int, height: Int, x: Int, y:Int) {
        object.color = UIColor.clear
        object.name = name
        object.position = CGPoint(x: x, y: y)
        object.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        object.physicsBody!.affectedByGravity = false
        object.physicsBody!.isDynamic = false
        object.physicsBody!.categoryBitMask = BodyType.building.rawValue
        
        self.addChild(object)
    }
    
    func SetDoorway(object: SKSpriteNode, name: String, width: Int, height: Int, x: Int, y:Int) {
        object.color = UIColor.orange
        object.name = name
        object.position = CGPoint(x: x, y: y)
        object.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        object.physicsBody!.affectedByGravity = false
        object.physicsBody!.isDynamic = false
        object.physicsBody!.categoryBitMask = BodyType.doorway.rawValue
        
        self.addChild(object)
    }
    
    func DisplayControls() {
        // PLAYER MOVEMENT CONTROLS
        up_button = SKSpriteNode(color: UIColor.orange, size: CGSize(width: 40, height: 40))
        up_button.position = CGPoint(x: self.frame.midX - 425, y: self.frame.midY - 125)
        up_button.name = "up_button"
        
        down_button = SKSpriteNode(color: UIColor.orange, size: CGSize(width: 40, height: 40))
        down_button.position = CGPoint(x: self.frame.midX - 425, y: self.frame.midY - 250)
        down_button.name = "down_button"
        
        left_button = SKSpriteNode(color: UIColor.orange, size: CGSize(width: 40, height: 40))
        left_button.position = CGPoint(x: self.frame.midX - 485, y: self.frame.midY - 185)
        left_button.name = "left_button"
        
        right_button = SKSpriteNode(color: UIColor.orange, size: CGSize(width: 40, height: 40))
        right_button.position = CGPoint(x: self.frame.midX - 365, y: self.frame.midY - 185)
        right_button.name = "right_button"
        
        // ADD PLAYER MOVEMENT CONTROLS TO SCREEN
        self.addChild(up_button)
        self.addChild(down_button)
        self.addChild(left_button)
        self.addChild(right_button)
    }
    
    func touchDown(atPoint pos : CGPoint) {
           
    }
       
    func touchMoved(toPoint pos : CGPoint) {

    }
       
    func touchUp(atPoint pos : CGPoint) {
    
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        let touch = touches.first!
        
        if up_button.contains(touch.location(in: self)) {
            up_button_pressed = false
        } else if down_button.contains(touch.location(in: self)) {
            down_button_pressed = false
        } else if left_button.contains(touch.location(in: self)) {
            left_button_pressed = false
        } else if right_button.contains(touch.location(in: self)) {
            right_button_pressed = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        let touch = touches.first!
        
        if up_button.contains(touch.location(in: self)) {
            up_button_pressed = false
        } else if down_button.contains(touch.location(in: self)) {
            down_button_pressed = false
        } else if left_button.contains(touch.location(in: self)) {
            left_button_pressed = false
        } else if right_button.contains(touch.location(in: self)) {
            right_button_pressed = false
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if up_button_pressed == true {
            player_y += 5
        } else if down_button_pressed == true {
            player_y -= 5
        } else if left_button_pressed == true {
            player_x -= 5
        } else if right_button_pressed == true {
            player_x += 5
        }
        //background = SKSpriteNode(imageNamed: background_image)
        player.removeFromParent()
        SpawnSprite()
    }
}
