//
//  ViewController.swift
//  run_bash
//
//

import Cocoa


extension NSTextView {
    func append(string: String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.textStorage?.appendAttributedString(NSAttributedString(string: string))
            self.scrollToEndOfDocument(nil)
        })
    }
}


class ViewController: NSViewController {

    @IBOutlet weak var commandTextField: NSTextField!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var runButton: NSButton!
    @IBOutlet var outputTextView: NSTextView!
    
    var task: NSTask? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.enabled = false
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "commandOutputNotification:",
            name: NSFileHandleDataAvailableNotification,
            object: nil)
    }
        
    func commandTerminationHandler(task: NSTask) -> Void {       
        stopButton.enabled = false
        runButton.enabled = true
    }

    func commandOutputNotification(notification: NSNotification) {
        let fileHandle = notification.object as! NSFileHandle
        let data = fileHandle.availableData
        
        if data.length > 0 {
            self.outputTextView.append(String.init(data: data, encoding: NSUTF8StringEncoding)!)
            fileHandle.waitForDataInBackgroundAndNotify()
        }
    }
    
    @IBAction func stopCommand(sender: AnyObject) {
        stopButton.enabled = false
        
        self.task?.terminate()
        self.task?.waitUntilExit()
    }
    
    @IBAction func runCommand(sender: AnyObject) {
        runButton.enabled = false
        stopButton.enabled = true
        
        let command = commandTextField.stringValue
        
        self.outputTextView.append("\n$ \(command)\n")
        
        self.task = NSTask()
        self.task!.terminationHandler = self.commandTerminationHandler
        self.task!.launchPath = "/bin/bash"
        self.task!.arguments = ["-c", command]
        
        let pipe = NSPipe()
        
        task!.standardOutput = pipe
        task!.standardError = pipe
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        task!.launch()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
}

