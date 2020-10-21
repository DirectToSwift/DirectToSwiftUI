<h2>Direct to SwiftUI Environment Keys
  <img src="http://zeezide.com/img/d2s/D2SIcon.svg"
       align="right" width="128" height="128" />
</h2>

A lot of the functionality of D2S is built around "Environment Keys".

"Environment Keys" are keys which you can use like so in SwiftUI:

```swift
public struct D2SInspectPage: View {

  @Environment(\.database) private var database : Database // retrieve a key

  var body: some View {
    BlaBlub()
      .environment(\.task, "edit") // set a key
  }
}
```

They are scoped along the view hierarchy. D2S uses them to pass down its rule
execution context.

## Builtin environment keys

D2S has quiet a set of builtin environment keys, including:
- ZeeQL Objects:
  - `database`
  - `object`
- ZeeQL Model:
  - `model`
  - `entity`
  - `attribute`
  - `relationship`
  - `propertyKey`
- Rendering
  - `title`
  - `displayNameForEntity`
  - `displayNameForProperty`
  - `displayStringForNil`
  - `hideEmptyProperty`
  - `formatter`
  - `displayPropertyKeys`
  - `visibleEntityNames`
  - `navigationBarTitle`
- Components and Pages
  - `task`
  - `nextTask`
  - `page`
  - `rowComponent`
  - `component`
  - `pageWrapper`
  - `debugComponent`
- Permissions
  - `user`
  - `isObjectEditable`
  - `isObjectDeletable`
  - `isEntityReadOnly`
  - `readOnlyEntityNames`
- Misc
  - `look`
  - `platform`
  - `debug`
  - `initialPropertyValues`
  - `creationTimestampPropertyKey`
  - `updateTimestampPropertyKey`

Checkout the `D2SKeys` for the full set.


## Rule based environment keys

A key concept of D2S is that environment keys are not just static keys,
but that the value of a key can be derived from a "Rule Model".

For example:

```
entity.name = 'Movie' AND attribute.name = 'name' 
  => displayNameForProperty = 'Movie'
*true* 
  => displayNameForProperty = attribute.name
```

The value of `displayNameForProperty` will be different depending on the context
which arounds it.

All environment keys which are of that kind conform to the new 
`RuleEnvironmentKey` protocol, which also requires `EnvironmentKey`
conformance.

### RuleContext

> Unfortunately the builtin SwiftUI `EnvironmentValues` struct lacks a few 
> operations to allow us to directly make any environment key dynamic.

Dynamic environment keys are stored in a `RuleContext`. `RuleContext` is a
struct similar to SwiftUI's `EnvironmentValues`, but in addition to providing 
key storage, it can also evaluate keys against a rule model.

> The `RuleContext` itself is stored as a regular environment key!

The `RuleContext` is also the root object passed into the rule engine. So its
keys are exposed to the rule engine.


## Adding a new dynamic environment key

Since we want to support D2S keys as `EnvironmentKey` keys,
but also as `KeyValueCoding` keys,
and everything should still be as typesafe as possible,
it is quite some work to set one up ...

### Step A: Create a `DynamicEnvironmentKey`

This is the same as creating a regular `EnvironmentKey`.
Define a struct representing the key (D2S ones are in the `D2S` namespacing 
enum):
```swift
struct object: DynamicEnvironmentKey {
  public static var defaultValue : OActiveRecord = OActiveRecord()
}
```
A requirement of `EnvironmentKey` is that all keys have a default value which is 
active when no explicit key was set.

> If you want to make an optional key, just define it as an optional type!
> Note that the `defaultValue` is _always_ queried (at least as of beta6).

### Step B: Property on `D2SDynamicEnvironmentValues`

SwiftUI accesses environment keys using keypathes, e.g. the `\.database` in 
here:

```swift
@Environment(\.database) var database : Database
```

Those need to be declared as an extension to `D2SDynamicEnvironmentValues`:

```swift
public extension D2SDynamicEnvironmentValues {
  var database : Database {
    set { self[dynamic: D2SKeys.database.self] = newValue }
    get { self[dynamic: D2SKeys.database.self] }
  }
```

The `rule` subscript dispatches the set/get calls to the `RuleContext`, which 
either
- returns a value previously set,
- retrieves a value from the rule system
- or falls back to the default value (two variants are provided).

NOTE: Please keep all D2S system keypathes together in
      `D2SEnvironmentKeys.swift`.


### Step C: Expose the key to `KeyValueCoding`

This needs the stringly mapping ... The internal ones are declared in a map in
`D2SEnvironmentKeys.swift`.
```swift
private static var kvcToEnvKey : [ String: KVCMapEntry ] = [
  "database" : .init(D2SKeys.database.self),
  ...
]
```

A custom key can be added using `D2SContextKVC.expose(Key.self, "kvcname")`
by a framework consumer.
