//
//  ContentView.swift
//  dBMeter
//
//  Created by Sigit Academy on 24/04/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    let audioRecorder: AVAudioRecorder
    @State var timer: Timer?
    @State var decibels: Float = 0
    
    init() {
        let audioFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("audio.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
        } catch let error {
            fatalError("Error creating audio recorder: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack {
            Text("Noise Level: \(String(format: "%.2f", decibels)) dB")
                .font(.title)
                .padding()
            Button(action: {
                if timer == nil {
                    startMetering()
                } else {
                    stopMetering()
                }
            }) {
                Text(timer == nil ? "Start" : "Stop")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    func startMetering() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.record)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("Error setting up audio session: \(error.localizedDescription)")
            return
        }
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            audioRecorder.updateMeters()
            var decibels = audioRecorder.peakPower(forChannel: 0)
//            decibels = min(max(decibels, -100), 0)
//            self.decibels = decibels + 100  // <<---
            self.decibels = decibels
        }
    }
    
    func stopMetering() {
        timer?.invalidate()
        timer = nil
        audioRecorder.stop()
    }
}

#Preview {
    ContentView()
}
