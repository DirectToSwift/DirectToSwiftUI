<h2>Direct to SwiftUI Views
  <img src="http://zeezide.com/img/d2s/D2SIcon.svg"
       align="right" width="128" height="128" />
</h2>

The UI of a D2S application is driven by its SwiftUI Views. Those views are 
assembled using the rule engine, and they builtin D2S Views use the rule engine 
to render things.

All of the views can be customized and replaced with own SwiftUI Views. 
Also all of the views can be embedded in a custom SwiftUI View. Just make sure 
the environment is properly setup.

There are different types of builtin D2S Views:

- **Page Wrapper**: Those wrap around Page views, for example they embed them in 
  a NavigationView on watchOS and iOS, and in a SplitView on macOS
- **Pages**: Top level pages which map to and are selected based on the D2S 
  "tasks":
  - EntityList (associated w/ `query` task)
  - QueryList (associated w/ `list` task)
  - Inspect (associated w/ `inspect` task)
  - Edit (associated w/ `edit` task) 
- **Row Views**: Most of the pages use a List View to display their content. Row 
  Views can be used to customized the appearance of a list view row.
- **Property Views**: Also called "components". Those are used to view or edit a 
  single property (attribute or relationship) of an object, say the `lastname` 
  attribute.
  There are components for different types of properties, e.g. a 
  `D2SDisplayString` and a `D2SDisplayBool` view.
  [Properties](Properties/README.md).
- Debug Views: There is a set of views to support debugging. Debug views can be
  enabled using the `debug` environment key.
- Reusable Views: Just helper views to make common tasks easy.

```
  ┌──────────────┐               
┌─┤ Page Wrapper ├──────────────┐
│ └──────────────┘   ┌────┐     │
│  ┌─────────────────┤Page├──┐  │
│  │  ┌────┐         └────┘  │  │
│  │ ┌┤Row ├───────────────┐ │  │
│  │ │└────┘ ┌───────────┐ │ │  │
│  │ │       │ Property  │ │ │  │
│  │ │       └───────────┘ │ │  │
│  │ └─────────────────────┘ │  │
│  │  ┌────┐                 │  │
│  │ ┌┤Row ├───────────────┐ │  │
│  │ │└────┘ ┌───────────┐ │ │  │
│  │ │       │ Property  │ │ │  │
│  │ │       └───────────┘ │ │  │
│  │ └─────────────────────┘ │  │
│  └─────────────────────────┘  │
└───────────────────────────────┘
```

## Looks

There can be different "looks". Looks are just namespaced Views which can be 
selected using the `.look` environment key.

By default the "BasicLook" is provided (and used as the fallback for 
everything).

## Pages

A page is a view which is bound to and selected using the `page` environment 
key:
```swift
\.task == "edit" => \.page <= BasicLook.Page.Edit()
```
To summon a page using the rule system, just use the `D2SPageView` View.
Attach the necessary environment if necessary. Example:
```swift
var body: some View {
  VStack {
    Text("Hello!").font(.title)
    D2SPageView()
  }
}
```
It is almost the same like:
```swift
@Environment(\.page) var page

var body: some View {
  VStack {
    Text("Hello!").font(.title)
    page
  }
}
```
but also configures the navigation bar title (and other things a page might 
need).

### EntityList

Shows a customizable list of entities (think "tables") in the model/database. 
When clicked, it shows the page associated with the `nextTask`, for example 
"list" which pulls up the `QueryList` page.

### QueryList

This page lists the objects in an entity (think "records" of a "table"). By 
default a summary is shown (using the `D2SSummaryView`), but this can be fully 
customized using the rule system.
When clicked, again the page associated with the `nextTask` is invoked. For 
example "inspect" which pulls up the D2SInspectPage by default.

### Inspect

This shows a customizable read only view of the "properties" (attributes and 
relationships) of a single object (think `columns` of a `record`). 
Those properties are usually embedded in "Row Views" and displayed using
"Property Views".

If the object is editable the inspect by default has a button to invoke the 
"edit" action (which by default invokes the D2SEditPage).

### Edit

Same like `Inspect` page, but for editing objects.


## Properties

A property is a view which is bound to and selected using the `component`  
environment key:
```swift
\.task == "edit" && \.attribute.valueType == Date.self
  => \.component <= D2SEditDate()
```
To summon a property using the rule system, just use the `D2SComponentView` 
View.
Attach the necessary environment if necessary. Example:
```swift
var body: some View {
  VStack {
    Text("Value:").font(.title)
    D2SComponentView()
  }
}
```
It is the same (but less typing) as:
```swift
@Environment(\.component) var value

var body: some View {
  VStack {
    Text("Value:").font(.title)
    value
  }
}
```

[Properties](BasicLook/Properties/README.md)



## Writing your own Page View

Let assume that instead of using the generic `D2SInspectPage` to view a 
"customer" object in the database, we want to provide an own view which displays 
the title of the customer at the top.
But we still want to use the `D2SInspectPage` to display all the properties in a 
List:

```swift
struct CustomerView: View {
  
  @Environment(\.object) var object
  
  var body: some View {
    VStack {
      HStack {
        Text(verbatim: "\(object.firstName ?? "-")")
        Text(verbatim: "\(object.lastName ?? "-")")
        Spacer()
      }
      .font(.title)
      .padding()

      Divider()
      
      BasicLook.Page.Inspect()
    }
  }
}
```

To activate that in a rule model:

```swift
let MyRules : RuleModel = [
  \.task == "inspect" && \.entity.name == "Customer"
         => \.page <= CustomerView()
]
```

If the task is `inspect` and the entity is the "Customer" entity, use our 
`CustomerView` as the `page`.

## Writing your own Property View

If the edit or inspect page shows a property, it asks the rule engine what view 
should be used for that property.
Or in other words: You can replace the builtin display/edit views on a per 
property basis.

For example the dvdrental database "Film" entity has a property "rating" which
contains the movie ratings of a given film. In the database this is defined as a 
String, but only "G", "PG", "PG-13", "R", "NC-17" are actually allowed as 
values.

For display we can use the regular D2SDisplayString View. But for `edit` we 
might rather want to show a list of buttons (a Picker would also work) for this 
property:
```swift
struct EditRating: View {
  
  @EnvironmentObject private var object : OActiveRecord
  @Environment(\.displayNameForProperty) private var label
  @Environment(\.propertyKey)            private var propertyKey

  let ratings = [ "G", "PG", "PG-13", "R", "NC-17" ]
  
  var body: some View {
    HStack(spacing: 16) {
      Text(label)
      Spacer()
      ForEach(ratings, id: \.self) { rating in
        Group { // Button didn't work in here
          if self.object.rating as? String == rating {
            Text(rating)
              .foregroundColor(.black)
          }
          else {
            Text(rating)
              .foregroundColor(.gray)
          }
        }
        .onTapGesture { self.object.rating = rating }
      }
    }
  }
}
```

To activate that in a rule model:

```swift
let MyRules : RuleModel = [
  \.propertyKey == "rating" && \.task == "edit"
    => \.component <= EditRating(),
    
  \.propertyKey == "description" && \.task == "edit"
    => \.component <= D2SEditLargeString(),
    
  \.propertyKey == "rentalRate" || \.propertyKey == "replacementCost"
    => \.formatter <= currencyFormatter
]
```

If the property is named "rating" and the task is "edit", use the `EditRating` 
as the property component.

This rule model also shows how the builtin `D2SEditLargeString` is used to edit 
the longer film "description", and how the `formatter` key is used to customize 
the `D2SDisplayString`/`D2SEditString` Views with a currency formatter.
