//
//  AudioRecorder.swift
//  Darty
//
//  Created by Руслан Садыков on 22.08.2021.
//

import Foundation
import AVFoundation

final class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    
    static let shared = AudioRecorder()
    
    private override init() {
        super.init()
        checkForRecordPermission()
    }
    
    func checkForRecordPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { isAllowed in
                self.isAudioRecordingGranted = isAllowed
            }
        case .denied:
            #warning("Нужно выводить алерт с сообщением о необходиости предоставить разрешение в настройках")
            print("NO ACCESS TO THE MICROPHONE. NEED CHANGE IN SETTINGS")
            isAudioRecordingGranted = false
        case .granted:
            isAudioRecordingGranted = true
        @unknown default:
            break
        }
    }
    
    func setupRecorder() {
        if isAudioRecordingGranted {
            recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            } catch {
                print("ERROR_LOG Error setting up audio recorder: ", error.localizedDescription)
            }
        }
    }
    
    func startRecording(fileName: String) {
        let audioFileName = getDocumentsUrl().appendingPathComponent(fileName + ".m4a", isDirectory: false)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("ERROR_LOG Error recording: ", error.localizedDescription)
            finishRecording()
        }
    }
    
    func finishRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
}
