<h2>SwiftUI Rule Enhancements for ZeeQL
  <img src="http://zeezide.com/img/d2s/D2SIcon.svg"
       align="right" width="128" height="128" />
</h2>

[ZeeQL](http://zeeql.io) provides its own (pure Swift) implementation and 
infrastructure to support KeyValueCoding (KVC).
It also comes with `Qualifier` types which are essentially the same like 
Foundation's `NSPredicate` objects (or SwiftUIRules `RulePredicate` objects).

This directory contains enhancements so that ZeeQL KeyValueCoding can be used
together with 
[SwiftUIRules](https://github.com/DirectToSwift/SwiftUIRules/blob/develop/README.md),
and that ZeeQL qualifiers can be used as rule predicates.

It also comes with a rule parser which can parse and build rule models 
dynamically.
