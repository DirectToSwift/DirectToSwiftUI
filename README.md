<h2>Direct to SwiftUI
  <img src="http://zeezide.com/img/d2s/D2SIcon.svg"
       align="right" width="128" height="128" />
</h2>

![Swift5.1](https://img.shields.io/badge/swift-5.1-blue.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![iOS](https://img.shields.io/badge/os-iOS-green.svg?style=flat)
![watchOS](https://img.shields.io/badge/os-watchOS-green.svg?style=flat)
![Travis](https://api.travis-ci.org/DirectToSwift/DirectToSwiftUI.svg?branch=develop&style=flat)

_Going fully declarative_: Direct to SwiftUI.

Note(2024-12-09): This doesn't currently build against the current ZeeQL3
                  anymore.

**Direct to SwiftUI**
is an adaption of an old 
[WebObjects](https://en.wikipedia.org/wiki/WebObjects) 
technology called 
[Direct to Web](https://developer.apple.com/library/archive/documentation/WebObjects/Developing_With_D2W/WalkThrough/WalkThrough.html#//apple_ref/doc/uid/TP30001015-DontLinkChapterID_5-TPXREF101).
This time for Apple's new framework:
[SwiftUI](https://developer.apple.com/xcode/swiftui/).
Instant 
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete)
apps, configurable using 
[a declarative rule system](http://www.alwaysrightinstitute.com/swiftuirules/),
yet fully integrated with SwiftUI.

There is a blog entry explaining how to use this:
[Introducing Direct to SwiftUI](http://www.alwaysrightinstitute.com/directtoswiftui/).

A Direct to SwiftUI variant using 
[CoreData](https://developer.apple.com/documentation/coredata)
instead of
[ZeeQL](http://zeeql.io)
can be found over here:
[CoreDataToSwiftUI](https://github.com/DirectToSwift/CoreDataToSwiftUI).

## Requirements

Direct to SwiftUI requires an environment capable to run SwiftUI.
That is: macOS Catalina, iOS 13 or watchOS 6.
In combination w/ Xcode 11.

Note that you can run iOS 13/watchOS 6 apps on Mojave in the emulator,
so that is fine as well.

## Using the Package

You can either just drag the Direct to SwiftUI Xcode project into your own
project,
or you can use Swift Package Manager.

The package URL is:
[https://github.com/DirectToSwift/DirectToSwiftUI.git
](https://github.com/DirectToSwift/DirectToSwiftUI.git).


## Misc

- [The Environment](Sources/DirectToSwiftUI/Environment/README.md)
- [Views](Sources/DirectToSwiftUI/Views/README.md)
- [Database Setup](Sources/DirectToSwiftUI/DatabaseSetup.md)

## What it looks like

A demo application using the Sakila database is provided:
[DVDRental](https://github.com/DirectToSwift/DVDRental).

### Watch

<p float="left" valign="top">
<img width="200" src="http://www.alwaysrightinstitute.com/images/d2s/watchos-screenshots/01-homepage.png?v=2">
<img width="200" src="http://www.alwaysrightinstitute.com/images/d2s/watchos-screenshots/02-customers.png?v=2">
<img width="200" src="http://www.alwaysrightinstitute.com/images/d2s/watchos-screenshots/03-customer.png?v=2">
<img width="200" src="http://www.alwaysrightinstitute.com/images/d2s/watchos-screenshots/04-movies.png?v=2">
</p>

### Phone

<p float="left" valign="top">
<img width="320" src="http://www.alwaysrightinstitute.com/images/d2s/limited-entities.png">
<img width="320" src="http://www.alwaysrightinstitute.com/images/d2s/list-customer-default.png">
</p>

### macOS

Still too ugly to show, but works in a very restricted way ;-) 

## Who

Brought to you by
[The Always Right Institute](http://www.alwaysrightinstitute.com)
and
[ZeeZide](http://zeezide.de).
We like
[feedback](https://twitter.com/ar_institute),
GitHub stars,
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.
