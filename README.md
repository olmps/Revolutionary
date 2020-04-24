<h1 align="center">
  <br>
  Revolutionary
  <br>
  <img src="https://raw.githubusercontent.com/matuella/Revolutionary/master/Resources/icon.png" alt="Revolutionary Icon" width="300">
  <br>
</h1>

<h4 align="center">Create your circular/progress/timer/stopwatch/countdown animations with ease!</h4>

<p align="center">
  <a href="https://travis-ci.org/matuella/Revolutionary">
    <img src="https://travis-ci.org/matuella/Revolutionary.svg?branch=master)">
  </a>
  <a href="http://cocoadocs.org/docsets/Revolutionary">
    <img src="https://img.shields.io/badge/docs-API-lightgrey.svg">
  </a>
  <a href="https://github.com/matuella/Revolutionary/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/matuella/Revolutionary.svg">
  </a>
  <a href="https://github.com/matuella/Revolutionary/releases">
    <img src="https://img.shields.io/github/release/matuella/Revolutionary.svg">
  </a>
  <a href="https://docs.swift.org/swift-book/">
    <img src="https://img.shields.io/badge/swift%20version-4.2-red.svg">
  </a>
  <a href="https://github.com/Carthage/Carthage">
    <img src="https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat">
  </a>
  <a href="http://cocoapods.org/pods/Revolutionary">
    <img src="https://img.shields.io/cocoapods/p/Revolutionary.svg">
  </a>
</p>
<p align="center">
  <a href="https://saythanks.io/to/matuella">
    <img src="https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg" alt="Say Thanks!">
  </a>
  <a href="http://makeapullrequest.com">
    <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=shields">
  </a>
</p>

<p align="center">  
  <a href="#features">Features</a> |
  <a href="#roadmap">Roadmap</a> |
  <a href="#installing">Installing</a> |
  <a href="#how-to-use">How To Use</a> |
  <a href="#contributing">Contributing</a> |
  <a href="#changelog">Changelog</a> |
  <a href="#license">License</a>
</p>

## Description

Revolutionary was built due to a personal need - in essence, the intuit was to create a circle that would behave like a countdown and a stopwatch, but on **`watchOS`**. One of the "problems" is that we don't have `Core Animation`, so we may eventually [try using a bunch of images][watchkitImagesTutorial] (and call it on [WKInterfaceImage][appleDocWKII] in our assets folder), which is completely fine - if the animation is not complex -, but if you want something more detailed (more fluid without a ton of assets) and "controllable", you will probably end ask for help to our beloved `SpriteKit` and its `SKAction`s.

With all of this in mind, an **API** was created to manage a `SKNode`, which basically control the UI behavior and do the necessary callbacks.<!-- TODO: You can see the below screenshots and gifs to visually understand if **Revolutionary** fits your use-case. -->

**Relevant info.**: Because the same behavior was needed in both **`iOS`** and **`tvOS`**, "class helpers" were created to be instantiated directly - a `SKView` and/or a `SKScene` - so we can manipulate the **Revolutionary** `SKNode` without other `SpriteKit` UI elements creating "noise" over the instantiation of our main `SKNode` - the `Revolutionary.swift`. These helpers make this framework works seamlessly on any platform.

<!--
### Screenshots and GIFs
TODO
-->

## Features

- [x] iOS support
- [x] Fully customizable UI properties of the drawn arcs
- [x] Manage a Progress behavior
- [x] Manage a Stopwatch/Countdown behavior

## Roadmap

All features, improvements and fixes can be watched here in this [github's project (roadmap)][project]

## Installing

- **Carthage**: add `github "matuella/Revolutionary" ~> 0.3.0` to your `Cartfile`;
- **CocoaPods**: add `pod 'Revolutionary'` to your `Podfile`;
- **Manual**: copy all the files in the [Revolutionary][revolutionary_folder] folder to your project and you're good to go.

## How to Use

### Instantiating `RevolutionaryView`

Because this framework is *UI-heavy*, it uses a [Builder pattern][designPatternBuilder] - required in the classes `init` -, so you can explicitly set the desired parameters with a much more clear and concise syntax.

Example of creating a `RevolutionaryBuilder`:

```swift
let revolutionaryBuilder = RevolutionaryBuilder { builder in
    //Customize properties here
    //I.E.:
    builder.mainArcColor = .coolPurple
    builder.mainArcWidth = 10
    builder.backgroundArcWidth = 10

    builder.displayStyle = .percentage(decimalPlaces: 2)
}
```

---

**Using [Interface Builder][appleDocsIB]**:

```swift

`@IBOutlet private weak var myWrapperView: UIView!`
`private var revolutionary: Revolutionary!`

private func viewDidLoad() {
  super.viewDidLoad()
  let myBuilder = RevolutionaryBuilder { builder in
    builder.mainArcColor = .black
  }
        
  let revolutionaryView = RevolutionaryView(revolutionaryBuilder, frame: myWrapperView.bounds)

  //or by calling a default init with its default properties
  //let revolutionaryView = RevolutionaryView(frame: myWrapperView.bounds)

  //glueing the revolutionary view to my wrapper view
  revolutionaryView.translatesAutoresizingMaskIntoConstraints = false
  revolutionaryViewWrapper.addSubview(revolutionaryView)
  revolutionaryView.leadingAnchor.constraint(equalTo: revolutionaryViewWrapper.leadingAnchor).isActive = true
  revolutionaryView.trailingAnchor.constraint(equalTo: revolutionaryViewWrapper.trailingAnchor).isActive = true
  revolutionaryView.topAnchor.constraint(equalTo: revolutionaryViewWrapper.topAnchor).isActive = true
  revolutionaryView.bottomAnchor.constraint(equalTo: revolutionaryViewWrapper.bottomAnchor).isActive = true

  //Because Revolutionary is a SKNode, we must stay with its reference to manipulate its state
  revolutionary = revolutionaryView.rev

  //If you don't want to create a custom `SKLabel` on the builder, just customize the default one after instantiation. I.e:
  revolutionary.displayLabel.fontColor = .purple

  //If you don't want to use the builder, just instante the RevolutionaryView with default values (just passing the frame)
  //and set the same properties that you would've passed in the RevolutionaryBuilder
  revolutionary.mainArcColor = .cyan
}
```

---

**Using Programmatically-created UI**:

To exemplify, we will center the `Revolutionary` in the middle of the screen:

```swift
private var revolutionary: Revolutionary!

private func viewDidLoad() {
  super.viewDidLoad()
  let myBuilder = RevolutionaryBuilder { builder in
    builder.mainArcColor = .black
  }
  
  let revolutionaryViewFrame = CGRect(x: 0, y: 0, width: 200, height: 200)
  
  let revolutionaryView = RevolutionaryView(revolutionaryBuilder, frame: revolutionaryViewFrame)

  //or by calling a default init with its default properties
  //let revolutionaryView = RevolutionaryView(frame: revolutionaryViewFrame)

  let centeredView = UIView()
  centeredView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
  centeredView.translatesAutoresizingMaskIntoConstraints = false
  centeredView.addSubview(revView)

  revolutionaryView.topAnchor.constraint(equalTo: centeredView.topAnchor).isActive = true
  revolutionaryView.bottomAnchor.constraint(equalTo: centeredView.bottomAnchor).isActive = true
  revolutionaryView.leadingAnchor.constraint(equalTo: centeredView.leadingAnchor).isActive = true
  revolutionaryView.trailingAnchor.constraint(equalTo: centeredView.trailingAnchor).isActive = true

  view.addSubview(centeredView)
  centeredView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  centeredView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

  //Because Revolutionary is a SKNode, we must stay with its reference to manipulate its state
  revolutionary = revolutionaryView.rev

  //If you don't want to create a custom `SKLabel` on the builder, just customize the default one after instantiation. I.e:
  revolutionary.displayLabel.fontColor = .purple

  //If you don't want to use the builder, just instante the RevolutionaryView with default values (just passing the frame)
  //and set the same properties that you would've passed in the RevolutionaryBuilder
  revolutionary.mainArcColor = .cyan
}
```

---

**Alternatively - instantiating the `SpriteKit` classes directly:**

If you intend to use the `SpriteKit` classes directly (like the `Revolutionary` which is a `SKNode`, or the `RevolutionaryScene` which is a `SKScene`):

`RevolutionaryScene` - `SKScene`:
```swift
let revolutionarySize = CGSize(width: 100, height: 100)
let myRevolutionaryScene = RevolutionaryScene(size: revolutionarySize)

//or with builder
//let myBuilder = RevolutionaryBuilder { builder in
//  builder.mainArcColor = .black
//}
//let myRevolutionaryScene = RevolutionaryScene(myBuilder, size: revolutionarySize)

let revolutionary = myRevolutionaryScene.rev
```

`Revolutionary` - `SKNode`:
```swift
let myRevolutionary = Revolutionary(withRadius: 50)

//or with builder
//let myBuilder = RevolutionaryBuilder { builder in
//  builder.mainArcColor = .black
//}
//let myRevolutionary = Revolutionary(withRadius: 50, builder: myBuilder)

let revolutionary = myRevolutionaryScene.rev
```

**IMPORTANT**: As you can see, the `init` of both `RevolutionaryView` and `RevolutionaryScene` requires a `padding: CGFloat`, which defaults to `16`, but this is basically the padding in which the `Revolutionary` will draw its circle. This is needed because the `UIBezierPath` which will draw the arcs may get out of the `SKScene`.
To clarify, lets say you need a circle of `radius = 100`. If you set the `padding = 8`, you'll need a frame of `116` of height/width, because the padding will be 8 points in each "side".


---

### `Revolutionary` usage

Now that we have a reference to our `Revolutionary` node, we can call the necessary functions, given our use-case.

**Progress usage**:

Used when you need to manage the arc state, like a download progress, a completion ratio of some arbitrary in-game progress, a progress of a onboarding, etc.

```swift
let progressAnimationDuration = 3.5

//Animating the new progress - in terms of 0-100% - to 50%.
//Important to notice that 0%/0 degress means `CGFloat = 0` and 100%/360 degrees means `CGFloat = 1`
let newProgress: CGFloat = 0.5

revolutionary.run(toProgress: newProgress, withDuration: progressAnimationDuration) {
  print("Completed Progress in")
}
```

---

**Countdown usage**:

There's basically two modes when *running* **Countdown**: indefinite and definite. This means to pick if you want the animation to keep going until stopped (indefinite) or using predetermined duration/amounts of revolutions.

*Definite countdown*:
```swift
//This is in seconds. Meaning half of a second for each revolution in this case
let countdownDuration = 0.5
//Total revolution times
let totalRevolutions = 5
revolutionary.runCountdown(withRevolutionDuration: countdownDuration, amountOfRevolutions: revolutionsAmount) {
  print("The countdown finished in \(countdownDuration * Double(totalRevolutions))")
}
```

*Indefinite countdown*:
```swift
//This is in seconds. Meaning half of a second for each revolution in this case
let countdownDuration = 0.5
revolutionary.runCountdownIndefinitely(withRevolutionDuration: countdownDuration)
```

---

**Stopwatch usage**:

Just like the **Countdown**, the **Stopwatch** use the same indefinite/definite separation.

*Definite stopwatch*:
```swift
//This is in seconds. Meaning half of a second for each revolution in this case
let stopwatchDuration = 0.5
//Total revolution times
let totalRevolutions = 5
revolutionary.runStopwatch(withRevolutionDuration: stopwatchDuration, amountOfRevolutions: revolutionsAmount) {
  print("The stopwatch finished in \(stopwatchDuration * Double(totalRevolutions))")
}
```

*Indefinite stopwatch*:
```swift
//This is in seconds. Meaning half of a second for each revolution in this case
let countdownDuration = 0.5
revolutionary.runStopwatchIndefinitely(withRevolutionDuration: countdownDuration)
```

---

**Managing the state**:

*Resetting*: 
```swift
//Completed in this case, means if it should reset to the full arc (360 degrees) / `true` or no arc (0 degress) / `false`
revolutionary.reset(completed: true)
```

*Pausing*:
```swift
revolutionary.pause()
```
*Resuming*:
```swift
revolutionary.resume()
```

## Contributing

If you have any suggestion, issue or idea, please contribute with what you've in your mind. Also, read [CONTRIBUTING][contributing].

## Changelog

The version history and meaningful changes will all be available in the [CHANGELOG][changelog].

## License 

Revolutionary is licensed under MIT - [LICENSE][license].


<!--- Links --->

[project]:https://github.com/orgs/olmps/projects/1

[watchkitImagesTutorial]:https://www.natashatherobot.com/watchkit-animate/
[appleDocWKII]:https://developer.apple.com/documentation/watchkit/wkinterfaceimage

[designPatternBuilder]:https://github.com/ochococo/Design-Patterns-In-Swift#-builder
[appleDocsIB]:https://developer.apple.com/xcode/interface-builder/

[revolutionary_folder]:https://github.com/matuella/Revolutionary/tree/master/Revolutionary
[changelog]:https://github.com/matuella/Revolutionary/blob/master/CHANGELOG.md
[contributing]:https://github.com/matuella/Revolutionary/blob/master/CONTRIBUTING.md
[license]:https://github.com/matuella/Revolutionary/blob/master/LICENSE
