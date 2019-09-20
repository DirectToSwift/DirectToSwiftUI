<h2>Direct to SwiftUI Property Components
  <img src="http://zeezide.com/img/d2s/D2SIcon.svg"
       align="right" width="128" height="128" />
</h2>

Those components are usually selected using the `component` environment key.

They display or edit one property of an entity, i.e. they inspect the 
`propertyKey`.

By default there is essentially one `View` and one `Edit` property component for 
each type. E.g. `D2SDisplayString` to display strings, `D2SEditString` to edit 
strings and `D2SDisplayDate` to display dates.

Which one is displayed for a property is selected by the rule system, and there 
are quite a few builtin rules to select the basic types, e.g.
```swift
(\.task == "edit" && \.attribute.valueType == Date.self
                     => \.component <= D2SEditDate())
                     .priority(3),
(\.task == "edit" && \.attribute.valueType == Bool.self
                     => \.component <= D2SEditBool())
                     .priority(3),
```

As usual you are not restricted to the builtin property View's. You can build a 
completely custom one. For example you could build a `DisplayLocationOnMap` view 
which instead of showing a lat/lon property as values, shows an actual MapKit 
map.

Also note that you can use "fake" propertyKey's which do not map to real entity 
properties, for example you could use a fake "name" propertyKey which then 
actually inspects the "firstname" and "lastname" properties and shows a combined 
View.
You just have to manually set the `displayPropertyKeys` to pull them up.
