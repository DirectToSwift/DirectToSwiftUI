//
//  D2SDefaultRules.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Date
import struct Foundation.Decimal
import struct SwiftUI.EmptyView
import struct SwiftUI.Text

/**
 * The default rules to drive a D2S application.
 *
 * To use them, make sure to add them as fallback rules to your own rule
 * model, e.g. using:
 *
 *     RuleModel().fallback(D2SDefaultRules)
 *
 */
public let D2SDefaultRules : RuleModel = [
  
  // set to true in your model if you want the red debug views
  \.debug <= false,
  
  
  /* pages */

  \.task == "query"   => \.page <= BasicLook.Page.EntityList(),
  \.task == "list" && \.platform == .watch
                      => \.page <= BasicLook.Page.SmallQueryList(),
  \.task == "list" && \.platform == .desktop
                      => \.page <= BasicLook.Page.AppKit.WindowQueryList(),
  \.task == "list"    => \.page <= BasicLook.Page.QueryList(),
  \.task == "inspect" => \.page <= BasicLook.Page.Inspect(),
  \.task == "edit"    => \.page <= BasicLook.Page.Edit(),
  \.task == "select"  => \.page <= BasicLook.Page.Select(),
  // editrelationship
  // queryall
  // confirm
  // error
  \.task == "login"   => \.page <= BasicLook.Page.Login(),
                         \.page <= Text("Unexpected task!"),


  /* row components */

  (\.task == "list"    => \.rowComponent <= D2STitledSummaryView())
                       .priority(1),
  (\.task == "select"  => \.rowComponent <= D2STitledSummaryView())
                       .priority(1),

  (\.task == "edit"    => \.rowComponent <= BasicLook.Row.PropertyValue())
                       .priority(1),

  (\.platform == .watch && \.relationship.d2s.type == .none
                       => \.rowComponent <= BasicLook.Row.PropertyNameAsTitle())
                       .priority(.fallback),
  (\.relationship.d2s.type == .toMany
                       => \.rowComponent <= BasicLook.Row.NamedToManyLink())
                       .priority(.fallback),
  (\.relationship.d2s.type == .toOne
                       => \.rowComponent <= BasicLook.Row.PropertyNameAsTitle())
                       .priority(.fallback),
  (\.relationship.d2s.type == .none
                       => \.rowComponent <= BasicLook.Row.PropertyNameValue())
                       .priority(.fallback),


  /* property components */
  
  (\.task == "edit" && \.relationship.d2s.type == .toMany
                       => \.component <= Text("TODO: Edit ToMany"))
                       .priority(3),
  (\.task == "edit" && \.relationship.d2s.type == .toOne
                       => \.component <= BasicLook.Property.Edit.ToOne())
                       .priority(3),
  (\.task == "edit" && \.attribute.valueType == Date.self
                       => \.component <= BasicLook.Property.Edit.Date())
                       .priority(3),
  (\.task == "edit" && \.attribute.valueType == Bool.self
                       => \.component <= BasicLook.Property.Edit.Bool())
                       .priority(3),
  (\.task == "edit" && \.attribute.valueType == Int.self
                       => \.component <= BasicLook.Property.Edit.Number())
                       .priority(3),
  (\.task == "edit" && \.attribute.valueType == Double.self
                       => \.component <= BasicLook.Property.Edit.Number())
                       .priority(3),
  (\.task == "edit" && \.attribute.valueType == Decimal.self
                       => \.component <= BasicLook.Property.Edit.Number())
                       .priority(3),
  (\.task == "edit" && \.attribute.isPassword == true
                       => \.component <= BasicLook.Property.Display.Password())
                       .priority(3),
  (\.task == "edit"    => \.component <= BasicLook.Property.Edit.String())
                       .priority(3),
  
  (\.relationship.d2s.type == .toMany
                   => \.component <= Text("TODO: DisplayToMany"))
                       .priority(2),
  (\.relationship.d2s.type == .toOne
                   => \.component <= BasicLook.Property.Display.ToOneSummary())
                       .priority(2),
  
  (\.attribute.valueType == Date.self
                   => \.component <= BasicLook.Property.Display.Date())
                       .priority(.fallback),
  (\.attribute.valueType == Bool.self
                   => \.component <= BasicLook.Property.Display.Bool())
                       .priority(.fallback),

  (\.attribute.isPassword == true
                       => \.component <= BasicLook.Property.Display.Password())
                       .priority(.fallback),

  (\.component <= BasicLook.Property.Display.String())
                .priority(.fallback),
  
  (\.attribute.valueType == Int.self     => \.formatter <= intFormatter)
                       .priority(.fallback),
  (\.attribute.valueType == Double.self  => \.formatter <= floatFormatter)
                       .priority(.fallback),
  (\.attribute.valueType == Float.self   => \.formatter <= floatFormatter)
                       .priority(.fallback),
  (\.attribute.valueType == Decimal.self => \.formatter <= decimalFormatter)
                       .priority(.fallback),
  (\.attribute.valueType == Date.self    => \.formatter <= dateTimeFormatter)
                       .priority(.fallback),

  /* pageWrapper */
  
  \.platform == .desktop
                      => \.pageWrapper <= BasicLook.PageWrapper.MasterDetail(),
  \.platform == .phone || \.platform == .pad || \.platform == .watch
                      => \.pageWrapper <= BasicLook.PageWrapper.Navigation(),
                         \.pageWrapper <= D2SPageView(),
  
  /* title */

  \.task == "login" => \.navigationBarTitle <= "Login",
  \.navigationBarTitle <= \.title,

  (\.object.d2s.isDefault == false => \.title <= \.object.d2s.defaultTitle)
                                               .priority(3),
  (\.entity.d2s.isDefault == false => \.title <= \.displayNameForEntity)
                                               .priority(2),
  (\.database.d2s.hasDefaultTitle == true // TBD: nil?
                                   => \.title <= \.database.d2s.defaultTitle)
                                               .priority(1),
                                     (\.title <= "Direct to SwiftUI")
                                               .priority(.fallback),
  
  /* property keys */

  \.visibleEntityNames <= \.model.d2s.defaultVisibleEntityNames,

  \.task == "inspect" => \.displayPropertyKeys
                    <= \.entity.d2s.defaultAttributeAndRelationshipPropertyKeys,
  \.task == "edit"    => \.displayPropertyKeys
                    <= \.entity.d2s.defaultAttributeAndToOnePropertyKeys,
                         \.displayPropertyKeys
                    <= \.entity.d2s.defaultDisplayPropertyKeys,
  
  \.displayNameForProperty <= \.propertyKey.capitalizedWithPreUpperSpace,
  \.displayNameForEntity   <= \.entity.name,
  
  \.task == "edit" => \.hideEmptyProperty <= false,
                      \.hideEmptyProperty <= true,

  \.task == "edit" => \.displayStringForNil <= "",
                      \.displayStringForNil <= "-",
                      
  /* default task */
  
  \.task == "login"                          => \.nextTask <= "query",
  \.task == "query"                          => \.nextTask <= "list",
  \.task == "list" && \.platform == .desktop => \.nextTask <= "edit",
  \.task == "list"                           => \.nextTask <= "inspect",
  \.task == "inspect"                        => \.nextTask <= "edit",

                      \.task <= "query",
  
  /* permissions */
  
  /* TBD: We have no "not keypath"
  \.isObjectEditable  <= !\.isEntityReadOnly,
  \.isObjectDeletable <= !\.isEntityReadOnly,
   */
  D2SDefaultAssignments.isObjectEditable,
  D2SDefaultAssignments.isObjectDeletable,
  
  \.task == "login" => D2SDefaultAssignments.loginEntity,
  
  /* debugging */
  
  \.debug == true && (\.task == "list" || \.task == "select")
                   => \.debugComponent <= D2SDebugEntityInfo(),
  \.debug == true && \.task == "inspect"
                   => \.debugComponent <= D2SDebugEntityDetails(),
  \.debug == true && \.task == "edit"
                   => \.debugComponent <= D2SDebugObjectEditInfo(),
  \.debug == true  => \.debugComponent <= D2SDebugDatabaseInfo(),
  \.debug == false => \.debugComponent <= EmptyView(),
                      
  /* derived defaults */
  D2SDefaultAssignments.model,
  D2SDefaultAssignments.attribute,
  D2SDefaultAssignments.relationship,
  D2SDefaultAssignments.isEntityReadOnly,
  D2SDefaultAssignments.propertyValue
]


// MARK: - Common Formatters

import class Foundation.NumberFormatter

internal let intFormatter : NumberFormatter = {
  let nf = NumberFormatter()
  nf.allowsFloats = false
  return nf
}()
internal let floatFormatter : NumberFormatter = {
  let nf = NumberFormatter()
  nf.allowsFloats = true
  return nf
}()
internal let decimalFormatter : NumberFormatter = {
  let nf = NumberFormatter()
  nf.allowsFloats = true
  nf.generatesDecimalNumbers = true
  return nf
}()
