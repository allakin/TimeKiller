//
//  ViewController.swift
//  TimeKiller
//
//  Created by VAndrJ on 11/10/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit
import AudioToolbox

class GameState {
    
    static let maxScore = 60
    
    enum State {
        case start
        case paused
        case countdown
        case started
        case loose
        case none
        case win
        case `continue`
    }
    
    enum Complexity: Int {
        case normal = 20
        case hard = 15
        case hell = 10
        case resume
    }
    
    enum Mode {
        case time
        case classic
    }
    
    private static var subscribers: [GameStateable] = [] {
        didSet {
            print(subscribers.count)
        }
    }
    private static var state: State = .none
    private static var gameTimer: Timer?
    private static var startTime: Double = 0
    private static var pauseTime: Double = 0
    private static var timeSpended: Double = 0
    static var spended: Double {
        return timeSpended
    }
    static var gameState: State {
        return state
    }
    private static var mode: Mode = .time
    static var gameMode: Mode {
        return mode
    }
    static func setMode(_ newMode: Mode) {
        mode = newMode
    }
    
    static func setState(to newState: State) {
        if newState == .loose || newState == .win {
            print(Date().timeIntervalSince1970)
            print(startTime)
            timeSpended += Date().timeIntervalSince1970 - startTime
        }
        state = newState
        notificate(newState)
        checkState()
    }
    
    private static func checkState() {
        switch state {
        case .start:
            timeSpended = 0
            startTime = Date().timeIntervalSince1970
            countdownTime = 3
            setState(to: .countdown)
        case .countdown:
            if countdownTime > 0 {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                    countdownTime -= 1
                    setState(to: .countdown)
                    timer.invalidate()
                })
            } else {
                counterTime = complexity.rawValue
                setState(to: .started)
            }
        case .started:
            if gameMode == .time {
                counterTime -= 1
            }
            if counterTime <= 0 {
                setState(to: .loose)
                return
            }
            if counterTime >= maxScore {
                setState(to: .win)
                return
            }
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                setState(to: .started)
            })
        case .paused:
            timeSpended += Date().timeIntervalSince1970 - startTime
            
            gameTimer?.invalidate()
        case .continue:
            startTime = Date().timeIntervalSince1970
            setState(to: .started)
        default:
            break
        }
    }
    
    static func iconFailed(isKiller: Bool) {
        if isKiller {
            counterTime -= 2
        } else {
            counterTime += 1
        }
    }
    
    private static func notificate(_ newState: State) {
        for subscriber in subscribers {
            DispatchQueue.main.async {
                subscriber.stateChanged(to: newState)
            }
        }
    }
    
    static func subscribe(_ subscriber: GameStateable) {
        subscribers.append(subscriber)
        subscriber.stateChanged(to: state)
    }
    
    static func unsubscribe(_ subscriber: GameStateable) {
        subscribers = subscribers.filter({ $0.subscriberId != subscriber.subscriberId })
    }
    static var countdownTime = 0
    static var counterTime = 0
    static var complexity: Complexity = .normal
    
    static func setComplexity(_ newComplexity: Complexity) {
        if newComplexity != .resume {
            complexity = newComplexity
            setState(to: .none)
        }
    }
    
    static func addTime(_ isAdd: Bool) {
        if isAdd {
            var timeToAdd: Int
            switch complexity {
            case .hard:
                timeToAdd = 2
            case .normal:
                timeToAdd = 3
            default:
                timeToAdd = 1
            }
            GameState.counterTime += timeToAdd
        } else {
            AudioServicesPlaySystemSound(1519)
            var timeToAdd: Int
            switch complexity {
            case .hard:
                timeToAdd = 2
            default:
                timeToAdd = 1
            }
            GameState.counterTime -= timeToAdd
        }
    }
}

protocol GameStateable {
    var subscriberId: String { get }
    func stateChanged(to newValue: GameState.State)
}

class ViewController: UIViewController, GameStateable {
    // MARK: - GameStateable protocol
    var subscriberId: String {
        return String(describing: self)
    }
    
    func stateChanged(to newValue: GameState.State) {
        switch newValue {
        case .start:
            startButton.isHidden = true
            countdownLabel.isHidden = false
            indicatorBackground.isHidden = true
            pauseButton.isHidden = true
            exitButton.isHidden = true
        case .countdown:
            startButton.isHidden = true
            countdownLabel.isHidden = false
            indicatorBackground.isHidden = true
            pauseButton.isHidden = true
            countdownLabel.text = "\(GameState.countdownTime)"
            exitButton.isHidden = true
        case .started:
            startButton.isHidden = true
            indicatorBackground.isHidden = false
            countdownLabel.isHidden = true
            pauseButton.isHidden = false
            exitButton.isHidden = true
            
            pauseButton.setTitle("Pause", for: .normal)
            updateIndicator()
            fireClock()
        case .loose:
            onLooseAction()
        case .none:
            //startButton.isHidden = false
            countdownLabel.isHidden = true
            indicatorBackground.isHidden = true
            pauseButton.isHidden = true
            exitButton.isHidden = true
        case .paused:
            startButton.isHidden = true
            countdownLabel.isHidden = true
            indicatorBackground.isHidden = false
            pauseButton.isHidden = false
            exitButton.isHidden = false
            for subView in gameView.subviews {
                subView.layer.pause()
            }
            pauseButton.setTitle("Continue", for: .normal)
            updateIndicator()
        case .continue:
            for subView in gameView.subviews {
                subView.layer.resume()
            }
        case .win:
            onWinAction()
        }
    }
    
    func updateIndicator() {
        let progress = (CGFloat(GameState.counterTime) / CGFloat(GameState.maxScore))
        indicatorConstraint.constant = max(64 * (1 - progress), 0)
        switch progress {
        case ..<0.3: indicatorView.backgroundColor = .red
        case 0.3..<0.6: indicatorView.backgroundColor = .orange
        case 0.6..<0.9: indicatorView.backgroundColor = .yellow
        default: indicatorView.backgroundColor = .green
        }
    }
    
    // MARK: - state helpers
    var state: GameState.State {
        return GameState.gameState
    }
    func setState(_ newState: GameState.State) {
        GameState.setState(to: newState)
    }

    enum Side {
        case left
        case right
        case bottom
        case top
    }
    
    var touchStartPoint: CGPoint? {
        willSet {
            if let startPoint = newValue {
                if pointerView.superview == nil {
                    pointerView.center = startPoint
                    view.addSubview(pointerView)
                } else {
                    UIView.animate(withDuration: 5/60, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut, .preferredFramesPerSecond60], animations: { [weak self] in
                        self?.pointerView.center = startPoint
                        }, completion: nil)
                }
            } else {
                pointerView.removeFromSuperview()
            }
        }
    }

    // MARK: - Life cycle
    
    override func loadView() {
        super.loadView()
        createUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPanGestureRecognizer()
        addDisplayLink()
        
        GameState.subscribe(self)
        NotificationCenter.default.addObserver(self, selector: #selector(forcePauseAction), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setState(.start)
    }
    
    func onWinAction() {
        let alertController = UIAlertController(title: "Win", message: "You win \(GameState.spended)", preferredStyle: .alert)
        let backAction = UIAlertAction(title: "Back", style: .cancel, handler: { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        })
        let againAction = UIAlertAction(title: "Again", style: .default, handler: { [weak self] (_) in
            self?.setState(.start)
        })
        alertController.addAction(backAction)
        alertController.addAction(againAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func onLooseAction() {
//        let alertController = UIAlertController(title: "Loose", message: "Game over \(GameState.spended)", preferredStyle: .alert)
//        let backAction = UIAlertAction(title: "Back", style: .cancel, handler: { [weak self] (_) in
//            self?.dismiss(animated: true, completion: nil)
//        })
//        let againAction = UIAlertAction(title: "Again", style: .default, handler: { [weak self] (_) in
//            self?.setState(.start)
//        })
//        alertController.addAction(backAction)
//        alertController.addAction(againAction)
      
//      let gameOverViewController = self.storyboard?.instantiateViewController(withIdentifier: String.init(describing: GameOverViewController.self)) as! GameOverViewController
//          gameOverViewController.timeSession = GameState.spended
//          present(gameOverViewController, animated: true, completion: nil)
    }
    
    func fireClock() {
        var actions: [(side: Side, isKiller: Bool)] = []
        if random(75) {
            for _ in 0...3 {
                if random(75) {
                    actions.append((side: .bottom, isKiller: random(85)))
                }
            }
        }
        if GameState.complexity == .hard || GameState.complexity == .hell {
            if random(50) {
                for _ in 0...2 {
                    if random(50) {
                        actions.append((random(50) ? .left : .right, random(55)))
                    }
                }
            }
        }
        if GameState.complexity == .hell {
            if random(25) {
                for _ in 0...3 {
                    if random(25) {
                        actions.append((.top, random(20)))
                    }
                }
            }
        }
        
        for action in actions {
            fireIcon(side: action.side, isKiller: action.isKiller)
        }
    }
    
    func random(_ chance: UInt32) -> Bool {
        assert(0...100 ~= chance)
        return 0...chance ~= arc4random_uniform(101)
    }
    
    func fireIcon(side: Side, isKiller: Bool) {
        let timeView = TimeView(frame: .init(origin: .zero, size: .init(width: 44, height: 44)))
        timeView.isKiller = isKiller
        gameView.addSubview(timeView)
        let time = (Double(arc4random_uniform(15)) + Double(GameState.complexity.rawValue)) / 10
        switch side {
        case .bottom:
            let xCoord = CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width * 0.8))) + UIScreen.main.bounds.width * 0.1
            let deltaX = CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width/8))) - UIScreen.main.bounds.width / 16
            let startPosition = CGPoint.init(x: xCoord, y: UIScreen.main.bounds.height)
            let cp1 = CGPoint.init(x: (xCoord + deltaX), y: UIScreen.main.bounds.height / 2 - CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.height / 2))))
            let cp2 = CGPoint.init(x: xCoord + 2 * deltaX, y: UIScreen.main.bounds.height)
            
            timeView.frame.origin = startPosition
            UIView.animate(withDuration: time, delay: 0, options: [.curveEaseOut, .preferredFramesPerSecond60], animations: {
                timeView.frame.origin = cp1
            }) { (_) in
                UIView.animate(withDuration: time, delay: 0, options: [.curveEaseIn, .preferredFramesPerSecond60], animations: {
                    timeView.frame.origin = cp2
                }, completion: { (complete) in
                    if complete {
                        timeView.removeFromSuperview()
                        GameState.iconFailed(isKiller: timeView.isKiller!)
                    }
                })
            }
        case .top:
            let xCoord = CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width * 0.8))) +  UIScreen.main.bounds.width * 0.1
            let deltaX = CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width/8))) - UIScreen.main.bounds.width / 16
            timeView.frame.origin = CGPoint(x: xCoord, y: -44)
            UIView.animate(withDuration: time * 0.8, delay: time * 0.2, options: [.beginFromCurrentState, .curveEaseIn], animations: {
                timeView.frame.origin = .init(x: xCoord + deltaX, y: UIScreen.main.bounds.height)
            })  { (complete) in
                if complete {
                    timeView.removeFromSuperview()
                    GameState.iconFailed(isKiller: timeView.isKiller!)
                }
            }
        case .left: fallthrough
        case .right:
            let yCoord = CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.height * 0.5)))
            let deltaX = CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width * 0.4))) +  UIScreen.main.bounds.width * 0.4
            timeView.frame.origin = CGPoint(x: (side == .left ? -44 : UIScreen.main.bounds.width), y: yCoord)
            UIView.animate(withDuration: time, delay: 0, options: [.curveEaseOut, .preferredFramesPerSecond60], animations: {
                timeView.frame.origin = .init(x: (side == .left ? deltaX : UIScreen.main.bounds.width - deltaX), y: 0)
            })
            UIView.animate(withDuration: time * 0.8, delay: time * 0.2, options: [.beginFromCurrentState, .curveEaseIn], animations: {
                timeView.frame.origin = .init(x: (side == .left ? deltaX : UIScreen.main.bounds.width - deltaX), y: UIScreen.main.bounds.height)
            }) { (complete) in
                if complete {
                    timeView.removeFromSuperview()
                    GameState.iconFailed(isKiller: timeView.isKiller!)
                }
            }
            break
        }
    }
    
    @objc func forcePauseAction() {
        setState(.paused)
    }
    
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return .all
    }
    
    func addPanGestureRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        view.addGestureRecognizer(panRecognizer)
    }
    
    func addDisplayLink() {
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkStep))
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    @objc func displayLinkStep() {
        if pointerView.superview != nil {
            addPathView(pointerView.frame)
            checkPointerIntersections()
        }
    }
    
    func checkPointerIntersections() {
        for element in gameView.subviews {
            guard let element = element as? TimeView else {
                continue
            }
            if element.layer.presentation()?.frame.contains(pointerView.frame.origin) ?? false && !element.isDestroyed {
                let frame = (element.layer.presentation()?.frame)!
                element.frame = frame
                element.layer.removeAllAnimations()
                element.isDestroyed = true
                GameState.addTime(element.isKiller!)
                UIView.animate(withDuration: 10/60, animations: {
                    element.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
                }, completion: { (_) in
                    UIView.animate(withDuration: 30/60, animations: {
                        element.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
                        element.alpha = 0
                    }, completion: { (_) in
                        element.removeFromSuperview()
                    })
                })
            }
        }
    }
    
    fileprivate func addPathView(_ frame: CGRect) {
        let pathView = UIView(frame: frame)
        pathView.backgroundColor = UIColor.black
        view.addSubview(pathView)
        UIView.animate(withDuration: 10/60, animations: {
            pathView.alpha = 0
        }, completion: { (_) in
            pathView.removeFromSuperview()
        })
    }

    // MARK: - UI actions
    
    @objc func panAction(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began: fallthrough
        case .changed:
            switch state {
            case .started:
                if sender.numberOfTouches > 0 {
                    touchStartPoint = sender.location(ofTouch: 0, in: sender.view)
                }
            default:
                break
            }
        default:
            touchStartPoint = nil
            pointerView.removeFromSuperview()
        }
    }
    @objc func startAction(_ sender: UIButton) {
        setState(.start)
    }
    @objc func pauseAction(_ sender: UIButton) {
        switch state {
        case .paused:
            setState(.continue)
        case .started:
            setState(.paused)
        default:
            break
        }
    }
    @objc func exitAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UI elements
    
    lazy var pointerView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 6, height: 6))
        view.backgroundColor = .black
        return view
    }()
    lazy var startButton: UIButton = { [weak self] in
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(startAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var countdownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.init(name: "Godzilla-", size: 100)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.init(name: "Godzilla-", size: 20)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("Pause", for: .normal)
        button.addTarget(self, action: #selector(pauseAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.init(name: "Godzilla-", size: 20)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitle("Exit", for: .normal)
        button.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var gameView = UIView()
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var indicatorBackground: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var indicatorConstraint: NSLayoutConstraint!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        GameState.unsubscribe(self)
    }
}

// MARK: - UI creation

extension ViewController {
    func createUI() {
        view.backgroundColor = .white
        addGameView()
        addStartButton()
        addCountdownLabel()
        addPauseButton()
        addindicator()
        addExitButton()
    }
    
    func addindicator() {
        view.addSubview(indicatorBackground)
        let bgConstraint = [indicatorBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8), indicatorBackground.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20), indicatorBackground.widthAnchor.constraint(equalToConstant: 64), indicatorBackground.heightAnchor.constraint(equalToConstant: 20)]
        NSLayoutConstraint.activate(bgConstraint)
        indicatorBackground.addSubview(indicatorView)
        indicatorConstraint = indicatorView.leftAnchor.constraint(equalTo: indicatorBackground.leftAnchor)
        let constraints = [indicatorView.topAnchor.constraint(equalTo: indicatorBackground.topAnchor),
                           indicatorConstraint!,
                           indicatorView.bottomAnchor.constraint(equalTo: indicatorBackground.bottomAnchor),
                           indicatorView.rightAnchor.constraint(equalTo: indicatorBackground.rightAnchor)]
        NSLayoutConstraint.activate(constraints)
    }
    
    func addGameView() {
        gameView.translatesAutoresizingMaskIntoConstraints = false
        gameView.backgroundColor = .clear
        view.addSubview(gameView)
        NSLayoutConstraint.activate([gameView.topAnchor.constraint(equalTo: view.topAnchor),
                                     gameView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     gameView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     gameView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
    
    func addStartButton() {
        view.addSubview(startButton)
        NSLayoutConstraint.activate([startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
    
    func addCountdownLabel() {
        view.addSubview(countdownLabel)
        NSLayoutConstraint.activate([countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                                     countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
    
    func addPauseButton() {
        view.addSubview(pauseButton)
        NSLayoutConstraint.activate([pauseButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
                                     pauseButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20)])
    }
    
    func addExitButton() {
        view.addSubview(exitButton)
        NSLayoutConstraint.activate([exitButton.topAnchor.constraint(equalTo: pauseButton.bottomAnchor, constant: 8),
                                     exitButton.leftAnchor.constraint(equalTo: pauseButton.leftAnchor, constant: 0)])
    }
}

extension ViewController {
    static var identifier: String {
        return String(describing: self)
    }
    
    static func getController(gameComplexity: GameState.Complexity, mode: GameState.Mode) -> UIViewController {
        if gameComplexity == .resume && GameState.gameState != .paused {
            assertionFailure("Use .resume only when paused")
        }
        let controller = ViewController()
        GameState.setComplexity(gameComplexity)
        GameState.setMode(mode)
        return controller
    }
}

extension CALayer {
    func pause() {
        let pausedTime: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil)
        self.speed = 0.0
        self.timeOffset = pausedTime
    }
    
    func resume() {
        let pausedTime: CFTimeInterval = self.timeOffset
        self.speed = 1.0
        self.timeOffset = 0.0
        self.beginTime = 0.0
        let timeSincePause: CFTimeInterval = self.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.beginTime = timeSincePause
    }
}
