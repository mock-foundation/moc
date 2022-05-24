# ``Logging``

An internal module for generating, managing, and displaying logs.

## Overview

The API is really simple. Like, dead simple. You just have
a struct called ``Logger``, which you initialize with a 
`label` attached to it. You can use a ``Logger/log(_:level:)``
function to log something at a ``LogLevel``.

## Usage example

Calling ``Logger/log(_:level:)`` function
```swift
let logger = Logger(label: "com.app.SomeService")
logger.log("A message", level: .info)
```

And an different example, that does the same thing
```swift
let logger = Logger(label: "com.app.SomeService")
logger.info("A message")
```

I think this is enough for understanding how it works. More
documentation can be found at ``Logger`` and ``LogLevel``
declarations.

## Under the hood

Under the hood the `Logger` structure is used, which is from a
new Unified Logging System introduced back in macOS 10.12(but the
struct itself appeared only in macOS 11). The saving-to-disk and
all the management is done by the Unified Logging System, this
package is basically a wrapper around it, in case I want to
change how logging will work under the hood.
