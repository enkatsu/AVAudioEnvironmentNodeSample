//
//  ViewController.swift
//  AVAudioEnvironmentNodeSample
//
//  Created by Katsuya Endoh on 2022/12/02.
//
//  https://github.com/lazerwalker/ios-3d-audio-test

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    let engine = AVAudioEngine()
    let environment = AVAudioEnvironmentNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.listenerAngularOrientation = AVAudioMake3DAngularOrientation(0.0, 0.0, 0.0)
        engine.attach(environment)
        let reverbParameters = environment.reverbParameters
        reverbParameters.enable = true
//        reverbParameters.loadFactoryReverbPreset(.largeHall)
//        let westNode = self.playSound(file: "beep-c", atPosition: AVAudio3DPoint(x: 0, y: 0, z: 10))
//        let eastNode = self.playSound(file: "beep-g", atPosition: AVAudio3DPoint(x: 0, y: 0, z: -10))
//        let northNode = self.playSound(file: "beep-e", atPosition: AVAudio3DPoint(x: 10, y: 0, z: 0))
//        let southNode = self.playSound(file: "beep-bb", atPosition: AVAudio3DPoint(x: -10, y: 0, z: 0))
//        let nodes = [westNode, eastNode, northNode, southNode]
        reverbParameters.loadFactoryReverbPreset(.largeHall2)
        let beepCNode = self.playSound(file: "beep-c", atPosition: AVAudio3DPoint(x: -20, y: 0, z: 0))
        let nodes = [beepCNode]
//        engine.connect(environment, to: engine.mainMixerNode, format: nil)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)
        engine.prepare()

        do {
            try engine.start()
            nodes.map({ $0.play() })
            print("Started")
        } catch let e as NSError {
            print("Couldn't start engine", e)
        }
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    func playSound(file: String, withExtension ext: String = "wav", atPosition position: AVAudio3DPoint) -> AVAudioPlayerNode {
        let node = AVAudioPlayerNode()
        node.position = position
//        node.reverbBlend = 0.1
        node.reverbBlend = 0.0
        node.renderingAlgorithm = .HRTF

        let url = Bundle.main.url(forResource: file, withExtension: ext)!
        let file = try! AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))!
        try! file.read(into: buffer)
        engine.attach(node)
        engine.connect(node, to: environment, format: buffer.format)
        node.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)

        return node
    }
}

