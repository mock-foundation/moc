# ``Caching``

An internal module for managing cache of chats, messages and stuff.

## Overview

There are classes for each thing that requires caching, such as
data about a chat, messages in a chat, and more. For ease of use,
there are static properties `cache` for structs that are cached,
so basically access to a cache will be something like this:

```swift
func getChat(forId id: Int64) -> Chat {
    let cached = Chat.cache[id]
    if let chat = cached { // If there is no such chat in cache
        let networkChat = getChatFromServer(id) // Get a chat from the server
        Chat.cache.save(networkChat) // Save chat in cache
    }
}
```

Pretty simple tbh.

Under the hood a [Cache](https://github.com/hyperoslo/Cache) library was used,
that allows me to do hybrid caching(both in-memory and on disk). This thing
simplified a lot of stuff related to caching.
