<h2>Direct to SwiftUI Default Assignments
  <img src="http://zeezide.com/img/d2s/D2SIcon.svg"
       align="right" width="128" height="128" />
</h2>

Some environment keys need values which are derived from a base object,
for example the displayed properties.

In D2W this is handled by a special action class: `DefaultAssignment`.

In addition we provide `d2s` trampolines on relevant objects which namespace
common D2S properties one might need.

> Also added DefaultAssignment things because that can derive values from
> multiple keys!

For example:

- `\.object.d2s.isDefault`
- `\.object.d2s.defaultTitle`
- `\.entity.d2s.isDefault`
- `\.entity.d2s.defaultTitle`
- `\.database.d2s.isDefault`
- `\.database.d2s.defaultTitle`
- `\.database.d2s.hasDefaultTitle`
- `\.attribute.d2s.isDefault`
- `\.relationship.d2s.isDefault`
- `\.relationship.d2s.type`: `.none`, `.toOne`, `.toMany`
- `\.model.d2s.isDefault`
- `\.model.d2s.defaultVisibleEntityNames`

## `isDefault` keys

Most D2S keys are structured so that they are not optionals, that includes
`object`, `entity` or `model`.
The rational is that Views should be able to declare their expected environment
without optionality, e.g.:
```swift
struct MyView: View {
  @Environment(\.object) var object // <== this NEEDs an object
}
```

That has the sideeffect, that we need to provide empty dummy objects if those
values are not explicitly set.

To check for those "non" objects, the `.d2s.isDefault` property is provided.
It can be used like so:
```swift
\.object.d2s.isDefault == false => \.title <= \.object.d2s.defaultTitle,
```

> TBD: Is this a good idea? Maybe we should just use optionals ...
