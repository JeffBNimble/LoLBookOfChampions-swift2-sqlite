//: Playground - noun: a place where people can play

import UIKit
import ReactiveCocoa

var str = "Hello, Champion playground"

let (signal, sink) = Signal<String, NoError>.pipe()
signal.map() { string in
    string.uppercaseString
    }.observe(next: print)

sendNext(sink, "a")
sendNext(sink, "b")
sendNext(sink, "c")

let signalProducer = SignalProducer<String, NoError>() { observer, disposable in
    sendNext(observer, "Yo")
    }
    .map() { string in
        return string.lowercaseString
}

signalProducer.start(next: { string in
    print(string)
})

protocol ColorListener {
    func colorChanged(color: UIColor)
}

class ColorGenerator {
    var listener : ColorListener?
    let colors = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.purpleColor(), UIColor.orangeColor()]
    init() {}
    
    func generateNewColor() {
        // If a tree falls in the woods
        guard let listener = listener else {
            return
        }
        
        let newIndex = Int(rand()) % colors.count
        listener.colorChanged(colors[newIndex])
    }
}

class Artist : ColorListener {
    let sink : Event<UIColor, NoError>.Sink
    init(sink : Event<UIColor, NoError>.Sink) {
        self.sink = sink
    }
    
    func colorChanged(color: UIColor) {
        sendNext(self.sink, color)
    }
}

let colorGenerator = ColorGenerator()
let colorSignalProducer = SignalProducer<UIColor, NoError>() { observer, disposable in
    colorGenerator.listener = Artist(sink: observer)
}

colorSignalProducer.start(next: { color in
    print(color)
})

colorGenerator.generateNewColor()
colorGenerator.generateNewColor()
colorGenerator.generateNewColor()
