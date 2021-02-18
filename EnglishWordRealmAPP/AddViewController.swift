//
//  AddViewController.swift
//  EnglishWordRealmAPP
//
//  Created by 井関竜太郎 on 2021/02/18.
//

import UIKit
import Speech
import AVFoundation
import RealmSwift


class AddViewController: UIViewController {
    
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    @IBOutlet weak var text3: UITextView!
    @IBOutlet weak var addword: UIButton!
    @IBOutlet weak var addword2: UIButton!
    
    
    
    var isRecording = false
    var isRecording2 = false
    
    let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en_JP"))!
    private let speechRecognnizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en_JP"))
    
    var audioEngine: AVAudioEngine!
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var recognitionTask2: SFSpeechRecognitionTask?
    
    
    // 検索機能で使うURL
    let searchUrl = "https://www.google.co.jp/search?q="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine = AVAudioEngine()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        //マイクの設定(変更の必要なし。)
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                if authStatus != SFSpeechRecognizerAuthorizationStatus.authorized {
                    self.addword.isEnabled = false
                    self.addword.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                }
            }
        }
    }
    
    
    func stopLiveTranscription() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }
    
    
    func startLiveTranscription() throws {
        // もし前回の音声認識タスクが実行中ならキャンセル 2つのタスクを同時にキャンセル。
        if let recognitionTask = self.recognitionTask
        {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        if self.isRecording == true {
            text1.text = ""
        }else if self.isRecording2 == true {
            
            text3.text = ""
        }
        
        // 音声認識リクエストの作成
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else {
            return
        }
        recognitionReq.shouldReportPartialResults = true
        // オーディオセッションの設定
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, time) in
            recognitionReq.append(buffer)
        }
        
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = recognizer.recognitionTask(with: recognitionReq, resultHandler: { (result, error) in
            if let error = error {
                print("\(error)")
            } else {
                DispatchQueue.main.async {
                    if self.isRecording == true {
                        self.text1.text = result?.bestTranscription.formattedString
                    }else if self.isRecording2  == true {
                        self.text3.text = result?.bestTranscription.formattedString
                    }
                    
                    
                }
            }
        })
        
    }
    
    @IBAction func record(_ sender: Any) {
        if isRecording {
            UIView.animate(withDuration: 0.2) {
            }
            stopLiveTranscription()
            self.addword.layer.cornerRadius = 3
        } else {
            UIView.animate(withDuration: 0.2) {
            }
            try! startLiveTranscription()
            self.addword.layer.cornerRadius = 25
        }
        isRecording = !isRecording
    }
    
    
    @IBAction func record2(_ sender: Any) {
        if isRecording2 {
            UIView.animate(withDuration: 0.2) {
            }
            stopLiveTranscription()
            self.addword2.layer.cornerRadius = 3
        } else {
            UIView.animate(withDuration: 0.2) {
            }
            try! startLiveTranscription()
            self.addword2.layer.cornerRadius = 25
        }
        isRecording2 = !isRecording2
    }
    
    
    @IBAction func shearch(_ sender: Any) {
        if text1.text == "" {
            print("単語を登録しよう")
        }else{
            searchBarSearchButtonClicked()
        }
        
        
    }
    
    // 検索ボタンを押下した時に実行されるメソッド
    func searchBarSearchButtonClicked() {
        if let searchText = text1.text {
            let mean = "意味"
            let url = NSURL(string: searchUrl + searchText.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)! + mean.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)! )
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            
        }
    }
    
}







