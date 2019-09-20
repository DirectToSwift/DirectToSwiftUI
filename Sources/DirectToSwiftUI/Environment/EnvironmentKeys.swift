//
//  D2SKeys.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class    Foundation.Formatter
import class    ZeeQLCombine.OActiveRecord
import protocol SwiftUIRules.DynamicEnvironmentKey
import protocol SwiftUIRules.DynamicEnvironmentValues
import struct   SwiftUI.AnyView
import struct   SwiftUI.Text
import struct   SwiftUI.EmptyView

public enum D2SKeys {}

// Note: The defaultValue is always queried when the `.environment` is
//       invoked!
//       So we can't do
//         `fatalError("attempt to grab missing database from environment")`
//       etc in the getter.

public extension D2SKeys {
  
  // MARK: - Core

  struct debug: DynamicEnvironmentKey {
    #if DEBUG
      public static var defaultValue = true
    #else
      public static var defaultValue = false
    #endif
  }

  struct database: DynamicEnvironmentKey {
    public static var defaultValue : Database = D2SDummyDatabase()
  }
  
  struct firstTask: DynamicEnvironmentKey {
    public static let defaultValue = "query"
  }
  struct task: DynamicEnvironmentKey {
    // Task could be an enum, but then it'll be harder to compare it in KVC.
    public static let defaultValue = "query"
  }
  struct nextTask: DynamicEnvironmentKey {
    public static let defaultValue = "query"
  }

  struct object: DynamicEnvironmentKey {
    // TBD: This one should really be an EnvironmentObject, but how
    //      would we do this? More in the keypath \.object.
    public static var defaultValue : OActiveRecord = .init()
  }

  struct propertyKey: DynamicEnvironmentKey {
    public static let defaultValue = ""
  }

  struct propertyValue: DynamicEnvironmentKey {
    public static let defaultValue : Any? = nil
  }

  // MARK: - Model
  
  struct model: DynamicEnvironmentKey {
    public static var defaultValue : Model = D2SDefaultModel()
  }

  struct entity: DynamicEnvironmentKey {
    public static var defaultValue : Entity = D2SDefaultEntity.shared
  }
  
  /**
   * Returns the active ZeeQL Attribute.
   *
   * If none is set explicitly, it tries to lookup the attribute using the
   * `entity` and `propertyKey`.
   * If that also fails, the default dummy attribute is returned.
   */
  struct attribute: DynamicEnvironmentKey {
    public static var  defaultValue : Attribute = D2SDefaultAttribute()
  }
  
  /**
   * Returns the active ZeeQL Relationship.
   *
   * If none is set explicitly, it tries to lookup the relationship using the
   * `entity` and `propertyKey`.
   * If that also fails, the default dummy relationship is returned.
   */
  struct relationship: DynamicEnvironmentKey {
    public static var  defaultValue : Relationship = D2SDefaultRelationship()
  }

  // MARK: - Derived

  struct page: DynamicEnvironmentKey {
    public static let defaultValue : AnyView = AnyView(Text("No Page?"))
  }
  struct component: DynamicEnvironmentKey {
    public static let defaultValue : AnyView
                        = AnyView(BasicLook.Property.Display.String())
  }
  struct pageWrapper: DynamicEnvironmentKey {
    public static let defaultValue : AnyView = AnyView(D2SPageView())
  }
  struct debugComponent: DynamicEnvironmentKey {
    #if DEBUG
      public static let defaultValue : AnyView = AnyView(D2SDebugDatabaseInfo())
    #else
      public static let defaultValue : AnyView = AnyView(EmptyView())
    #endif
  }
  struct rowComponent: DynamicEnvironmentKey {
    public static let defaultValue : AnyView = AnyView(EmptyView())
  }

  struct isEntityReadOnly: DynamicEnvironmentKey {
    public static let defaultValue = false
  }
  struct readOnlyEntityNames: DynamicEnvironmentKey {
    public static let defaultValue = [ String ]()
  }
  struct displayNameForEntity: DynamicEnvironmentKey {
    public static let defaultValue = ""
  }
  struct displayNameForProperty: DynamicEnvironmentKey {
    public static let defaultValue = ""
  }
  
  struct hideEmptyProperty: DynamicEnvironmentKey {
    public static let defaultValue = true
  }
  struct formatter: DynamicEnvironmentKey {
    public static let defaultValue : Formatter? = nil
  }
  struct displayStringForNil: DynamicEnvironmentKey {
    public static let defaultValue : String = "-"
  }
  
  struct initialPropertyValues: DynamicEnvironmentKey {
    public static let defaultValue : [ String : Any? ] = [:]
  }

  /**
   * The entities which are being displayed on a page.
   */
  struct visibleEntityNames: DynamicEnvironmentKey {
    public static let defaultValue = [ String ]()
  }

  /**
   * The properties which are being displayed on a page. Can be attributes
   * or relationships (or any other KVC key).
   */
  struct displayPropertyKeys: DynamicEnvironmentKey {
    public static let defaultValue = [ String ]()
  }
  
  struct title: DynamicEnvironmentKey {
    public static let defaultValue = "Direct2SwiftUI"
  }

  struct navigationBarTitle: DynamicEnvironmentKey {
    public static let defaultValue = title.defaultValue
  }
  
  struct platform: DynamicEnvironmentKey {
    public static let defaultValue = Platform.default
  }
  struct look: DynamicEnvironmentKey {
    public static let defaultValue = "neutral"
  }


  // MARK: - Permissions
  
  struct user: DynamicEnvironmentKey {
    public static let defaultValue: OActiveRecord? = nil
  }
  
  struct isObjectEditable: DynamicEnvironmentKey {
    public static let defaultValue = false
  }
  struct isObjectDeletable: DynamicEnvironmentKey {
    public static let defaultValue = false
  }
  
  
  // MARK: - Display Group
  
  struct auxiliaryQualifier : DynamicEnvironmentKey {
    public static let defaultValue: Qualifier? = nil
  }
}
