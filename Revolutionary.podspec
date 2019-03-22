Pod::Spec.new do |s|
s.name                      = "Revolutionary"
s.version                   = "0.3.1"
s.summary                   = "Animate your Revolutions :)"
s.description               = <<-DESC
Revolutionary helps you to manage circular animations by using SpriteKit (so you can use in watchOS and tvOS as well) working seamlessly when imported in UIKit.
There are good examples of its usage in the root of the repository, the main use cases being:
- A circle that animates a progress -> like visually representing a download;
- A "timer control" that behaves like a stopwatch or a countdown -> like any possible timer.

This project was created to provide an easy way to implement a circular progress in the watchOS platform, where UIKit is not an option. The easiest option was
to create this behavior using SpriteKit. As its use-cases were turning a little more "complex", a decent API was built on top of it. The usage was good enough
to be used in all platforms, because the core functionality is built in a SKNode, so it's completly flexible if importing in UIKit.

There are both SKScene and SKView - which suits better your scenario - to be called directly, there is no need to create any extra SKScene/SKView to put the
Revolutionary SKNode in.
DESC

s.author                    = { "Guilherme C. Matuella" => "guilherme1matuella@gmail.com" }
s.homepage                  = "https://github.com/matuella/Revolutionary"
s.license                   = { :type => "MIT", :file => "LICENSE" }

s.swift_version             = "4.2"
s.ios.deployment_target     = "10.0"

s.source                    = { :git => "https://github.com/matuella/Revolutionary.git", :tag => "v#{s.version}" }
s.source_files              = "Revolutionary/**/*.swift"

s.frameworks                = "Foundation", "SpriteKit"
end
