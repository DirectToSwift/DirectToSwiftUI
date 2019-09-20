//
//  D2SEnvironmentKeys.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class    Foundation.Formatter
import class    ZeeQL.Database
import class    ZeeQL.Model
import protocol ZeeQL.Entity
import protocol ZeeQL.Attribute
import protocol ZeeQL.Relationship
import class    ZeeQLCombine.OActiveRecord
import struct   SwiftUI.AnyView
import protocol SwiftUIRules.DynamicEnvironmentPathes

public extension DynamicEnvironmentPathes {
  
  // MARK: - Core

  /**
   * Flip this to Views w/ debug information. Affects various D2S Views.
   *
   * Sample Rule:
   *
   *     \.platform == .phone => \.debug <= true
   *
   */
  var debug : Bool {
    set { self[dynamic: D2SKeys.debug.self] = newValue }
    get { self[dynamic: D2SKeys.debug.self] }
  }
  
  /**
   * A ZeeQL object representing the database we are connected to. This
   * wraps the lower level `Adaptor` object.
   */
  var database : Database {
    set { self[dynamic: D2SKeys.database.self] = newValue }
    get { self[dynamic: D2SKeys.database.self] }
  }

  /**
   * The currently active task. A `task` is a higher level abstraction over
   * `page` which allows you to switch between pages based on the current
   * environment.
   *
   * For example if the user selects an object for `view`, you may want
   * to present different pages depending on the type or state of the
   * object:
   *
   *     \.task == "view" && \.object.isDone == true
   *         => \.page <= CompletedWorkflowView()
   *
   * D2W Tasks:
   * - query
   * - list
   * - inspect
   * - edit
   * - select
   * - editrelationship
   * - queryall
   * - confirm
   * - error
   */
  var task : String {
    set { self[dynamic: D2SKeys.task.self] = newValue }
    get { self[dynamic: D2SKeys.task.self] }
  }
  
  /**
   * The task which is invoked on startup. For example:
   *
   *     \.firstTask <= "query"
   *
   */
  var firstTask : String {
    set { self[dynamic: D2SKeys.firstTask.self] = newValue }
    get { self[dynamic: D2SKeys.firstTask.self] }
  }

  /**
   * The task which is the logical next step of the current task.
   * For example:
   *
   *     \.task == "query" => \.nextTask <= "list"
   *     \.task == "list"  => \.nextTask <= "inspect"
   *
   * E.g. on macOS, we do not usually want to open a separate window for
   * inspecting an object, we can jump straight to the editor, hence:
   * task=list => nextTask=edit.
   */
  var nextTask : String {
    set { self[dynamic: D2SKeys.nextTask.self] = newValue }
    get { self[dynamic: D2SKeys.nextTask.self] }
  }

  /**
   * The currently active database object.
   *
   * Right now this is tied to `OActiveRecord`, which is a rather stupid
   * RoR like ORM object representing a single record in the database.
   *
   * A ZeeQL `ActiveRecord` tracks the database snapshot itself, i.e. it knows
   * whether and how it changed.
   * The `O` makes the `ActiveRecord` a Combine `ObservableObject`.
   */
  var object : OActiveRecord {
    // TBD: This one should really be an EnvironmentObject, but how
    //      would we do this?
    //      I suspect EnvObj's are just keyed on the class type (instead of
    //      an environment key), like so:
    //        self[OActiveRecord.self] = object
    //      but this is probably not enough to get it subscribed, I suspect
    //      the subscription is stored in the property wrapper itself.
    //      Also: to allow `self[OActiveRecord.self]`,
    //            `self[OActiveRecord.self]` has to be an EnvKey (which would
    //            be OK I guess?)
    //      Right now it can't be an EnvironmentKey, because ActiveRecord
    //      already has a nested `Value` type (which is a little hard to
    //      replace) :-/
    set { self[dynamic: D2SKeys.object.self] = newValue }
    get { self[dynamic: D2SKeys.object.self] }
  }
  
  /**
   * The current `property` being generated. A property is either a
   * ZeeQL `Relationship` or `Attribute`.
   *
   * Note: You can also use "fake" property names, but be careful
   *       with the builtin components then, since they won't be
   *       able to lookup the property in the active `Entity`.
   */
  var propertyKey : String {
    set { self[dynamic: D2SKeys.propertyKey.self] = newValue }
    get { self[dynamic: D2SKeys.propertyKey.self] }
  }

  /**
   * The value associated with the current `propertyKey`.
   *
   * By default this is simply derived using KVC:
   *
   *     \.object.valueForKeyPath(\.propertyKey)
   *
   * Note that this is an `Any?`.
   */
  var propertyValue : Any? {
    set { self[dynamic: D2SKeys.propertyValue.self] = newValue }
    get { self[dynamic: D2SKeys.propertyValue.self] }
  }

  /**
   * Just an abstract platform value, so that you can select pages
   * based on the environment.
   *
   * Values: watch, desktop, phone, pad
   */
  var platform : Platform {
    set { self[dynamic: D2SKeys.platform.self] = newValue }
    get { self[dynamic: D2SKeys.platform.self] }
  }
  
  /**
   * The look can be used to style the app in different ways and allow the user
   * to switch between those styles.
   *
   * E.g. there could be a `modern` and `web1.0` look, which bind look specific
   * pages like so:
   *
   *     \.look == "web1.0" && \.task == "list"
   *     => \.page <= NetscapeNavigatorView()
   *
   */
  var look : String {
    set { self[dynamic: D2SKeys.look.self] = newValue }
    get { self[dynamic: D2SKeys.look.self] }
  }

  
  // MARK: - Schema Reflection
  
  /**
   * The ZeeQL model. It contains the ORM mapping to the database schema and
   * is central to the working of Direct To Swift.
   *
   * If the adaptor provides the facility, one can fetch a model from the
   * database itself (`try adaptor.fetchModel()`).
   * This uses the SQL catalog to produce a default model.
   *
   * Alternatively ZeeQL provides a set of ways to specify models,
   * using Codable classes, it supports loading CoreData models,
   * and you can always create a model "by hand".
   *
   * A ZeeQL model is just a collection of ZeeQL entities.
   */
  var model : Model {
    set { self[dynamic: D2SKeys.model.self] = newValue }
    get { self[dynamic: D2SKeys.model.self] }
  }
  
  /**
   * The current ZeeQL entity. An entity usually maps to a database table
   * and contains a set of "attributes" and "relationships".
   *
   * Attributes again usually map to the database columns, while relationships
   * model object relationships between different tables based on foreign keys.
   *
   * It is possible to create own ZeeQL entities and restrict them to specific
   * attributes (e.g. to improve fetch performance by not always fetching all
   * columns). Or you can add additional relationships the schema fetch might
   * not have detected.
   */
  var entity : Entity {
    set { self[dynamic: D2SKeys.entity.self] = newValue }
    get { self[dynamic: D2SKeys.entity.self] }
  }
  
  /**
   * An ZeeQL attribute of the `entity`. The attribute holds the description
   * of the property mapping to the database. That is, the attribute name,
   * the name in the SQL database, the Swift type used to represent the
   * attribute, and the external SQL type. Whether it is nullable or not, etc.
   */
  var attribute : Attribute {
    set { self[dynamic: D2SKeys.attribute.self] = newValue }
    get { self[dynamic: D2SKeys.attribute.self] }
  }
  
  /**
   * A ZeeQL relationship object, part of an `entity`. Relationships form
   * connections between objects in different (or the same) entities.
   *
   * For example a `toManager` relationship might connect an employee record
   * with the record representing the manager.
   */
  var relationship : Relationship {
    set { self[dynamic: D2SKeys.relationship.self] = newValue }
    get { self[dynamic: D2SKeys.relationship.self] }
  }

  
  // MARK: - View Selection

  var page : AnyView {
    set { self[dynamic: D2SKeys.page.self] = newValue }
    get { self[dynamic: D2SKeys.page.self] }
  }
  var pageWrapper : AnyView {
    set { self[dynamic: D2SKeys.pageWrapper.self] = newValue }
    get { self[dynamic: D2SKeys.pageWrapper.self] }
  }
  var component : AnyView {
    set { self[dynamic: D2SKeys.component.self] = newValue }
    get { self[dynamic: D2SKeys.component.self] }
  }
  var rowComponent : AnyView {
    set { self[dynamic: D2SKeys.rowComponent.self] = newValue }
    get { self[dynamic: D2SKeys.rowComponent.self] }
  }
  var debugComponent : AnyView {
    set { self[dynamic: D2SKeys.debugComponent.self] = newValue }
    get { self[dynamic: D2SKeys.debugComponent.self] }
  }

  
  // MARK: - Display Strings

  /**
   * If the name of an entity is displayed, this key is queried. By default
   * it just returns the straight name of the entity, e.g. `Person`.
   *
   * You can use that to rename an entity for just display purposes.
   */
  var displayNameForEntity : String {
    set { self[dynamic: D2SKeys.displayNameForEntity.self] = newValue }
    get { self[dynamic: D2SKeys.displayNameForEntity.self] }
  }

  /**
   * The string used to display the _name_ of a property, e.g. `lastName`.
   * By default this queries the `propertyKey` and performs a small
   * transformation on them to make them look nicer.
   */
  var displayNameForProperty : String {
    set { self[dynamic: D2SKeys.displayNameForProperty.self] = newValue }
    get { self[dynamic: D2SKeys.displayNameForProperty.self] }
  }
  
  /**
   * The string used when a property is `nil`.
   *
   * By default this is the empty string for edit tasks, and `-` for other
   * tasks.
   */
  var displayStringForNil : String {
    set { self[dynamic: D2SKeys.displayStringForNil.self] = newValue }
    get { self[dynamic: D2SKeys.displayStringForNil.self] }
  }
  
  /**
   * On some pages, e.g. the `D2SInspectPage` this is used to control whether
   * empty properties should be hidden. Empty properties are those with a
   * `nil` value, or empty strings.
   */
  var hideEmptyProperty : Bool {
    set { self[dynamic: D2SKeys.hideEmptyProperty.self] = newValue }
    get { self[dynamic: D2SKeys.hideEmptyProperty.self] }
  }
  
  var formatter : Formatter? {
    set { self[dynamic: D2SKeys.formatter.self] = newValue }
    get { self[dynamic: D2SKeys.formatter.self] }
  }
  
  
  // MARK: - Display Sets

  /**
   * The properties of an object which are displayed, that is the attributes
   * and relationships which should show up.
   *
   * By default all properties of an entity are displayed, with some smart
   * logic to hide foreign keys and such.
   */
  var displayPropertyKeys : [ String ] {
    set { self[dynamic: D2SKeys.displayPropertyKeys.self] = newValue }
    get { self[dynamic: D2SKeys.displayPropertyKeys.self] }
  }

  /**
   * The entities which appear in D2S pages showing lists of entities, for
   * example the `D2SEntityListPage`.
   *
   * By default all entities of a model are shown, one can use the key to
   * restrict the displayed entities, e.g.:
   *
   *     \.visibleEntityNames <= [ "Customer", "Actor", "Film", "Staff" ]
   *
   */
  var visibleEntityNames : [ String ] {
    set { self[dynamic: D2SKeys.visibleEntityNames.self] = newValue }
    get { self[dynamic: D2SKeys.visibleEntityNames.self] }
  }

  
  // MARK: - Title

  /**
   * The title to use for the current component.
   *
   * This can be the navigationBarTitle for iOS, or the title of a window on
   * macOS.
   */
  var title : String {
    set { self[dynamic: D2SKeys.title.self] = newValue }
    get { self[dynamic: D2SKeys.title.self] }
  }
  
  /**
   * The title to use for the iOS navigation bar. By default this just maps
   * to the value of the `title` key.
   */
  var navigationBarTitle : String {
    set { self[dynamic: D2SKeys.navigationBarTitle.self] = newValue }
    get { self[dynamic: D2SKeys.navigationBarTitle.self] }
  }

  
  // MARK: - Permissions
  
  /**
   * Use this to control whether the user can write to the entity. Also check
   * the more granular `isObjectEditable` (which by default just queries
   * `isEntityReadOnly`).
   *
   * E.g. to disable writes to all entities, just add:
   *
   *     \.isEntityReadOnly <= true
   *
   * Or to select it based on the state of the logged in user:
   *
   *     \.user.isAdmin == true => \.isEntityReadOnly <= false,
   *                               \.isEntityReadOnly <= true
   *
   * By default this inspects the `readOnlyEntityNames`.
   */
  var isEntityReadOnly : Bool {
    set { self[dynamic: D2SKeys.isEntityReadOnly.self] = newValue }
    get { self[dynamic: D2SKeys.isEntityReadOnly.self] }
  }
  
  /**
   * The list of entities which are read-only. Look at the docs of
   * `isEntityReadOnly` for a detailed description.
   */
  var readOnlyEntityNames : [ String ] {
    set { self[dynamic: D2SKeys.readOnlyEntityNames.self] = newValue }
    get { self[dynamic: D2SKeys.readOnlyEntityNames.self] }
  }
  
  /**
   * This can be used to fill in initial values when a new object is created.
   *
   * Example:
   *
   *     \.initialProperties <= { [ "created": Date() ] }
   *
   * This is a closure, so that the values can be dynamic. It doesn't get any
   * context though.
   */
  var initialPropertyValues : [ String : Any? ] {
    set { self[dynamic: D2SKeys.initialPropertyValues.self] = newValue }
    get { self[dynamic: D2SKeys.initialPropertyValues.self] }
  }
  
  /**
   * If you implement a login page, you can assign a value to the `user`
   * environment. And then adjust other environments based on that,
   * e.g. `isEntityReadOnly` or even `auxiliaryQualifier`.
   */
  var user : OActiveRecord? {
    set { self[dynamic: D2SKeys.user.self] = newValue }
    get { self[dynamic: D2SKeys.user.self] }
  }
  
  /**
   * Whether the current object is editable. By default this just queries
   * `isEntityReadOnly` to determine whether the object should show up as
   * editable.
   *
   * This more granular key can be used to decide whether an object is editable
   * based on the object itself. Example:
   *
   *     \.user.isAdmin == true       => \.isObjectEditable <= true,
   *     \.user.id == \object.ownerId => \.isObjectEditable <= true,
   *                                     \.isObjectEditable <= false
   *
   */
  var isObjectEditable : Bool {
    set { self[dynamic: D2SKeys.isObjectEditable.self] = newValue }
    get { self[dynamic: D2SKeys.isObjectEditable.self] }
  }
  /**
   * Whether the user can delete the given object. Follows the same rules
   * like `isObjectEditable`.
   */
  var isObjectDeletable : Bool {
    set { self[dynamic: D2SKeys.isObjectDeletable.self] = newValue }
    get { self[dynamic: D2SKeys.isObjectDeletable.self] }
  }

  
  // MARK: - Display Group
  
  /**
   * The auxiliaryQualifier can be used to restrict the queries in a page.
   */
  var auxiliaryQualifier : Qualifier? {
    set { self[dynamic: D2SKeys.auxiliaryQualifier.self] = newValue }
    get { self[dynamic: D2SKeys.auxiliaryQualifier.self] }
  }
}

// MARK: - KeyValueCoding

extension D2SContextKVC {
  
  static var kvcToEnvKey : [ String: AnyKVCMapEntry ] = [
    "database"               : KVCMapEntry(D2SKeys.database              .self),
    "debug"                  : KVCMapEntry(D2SKeys.debug                 .self),
    "task"                   : KVCMapEntry(D2SKeys.task                  .self),
    "firstTask"              : KVCMapEntry(D2SKeys.firstTask             .self),
    "nextTask"               : KVCMapEntry(D2SKeys.nextTask              .self),
    "model"                  : KVCMapEntry(D2SKeys.model                 .self),
    "entity"                 : KVCMapEntry(D2SKeys.entity                .self),
    "attribute"              : KVCMapEntry(D2SKeys.attribute             .self),
    "relationship"           : KVCMapEntry(D2SKeys.relationship          .self),
    "object"                 : KVCMapEntry(D2SKeys.object                .self),
    "propertyKey"            : KVCMapEntry(D2SKeys.propertyKey           .self),
    "page"                   : KVCMapEntry(D2SKeys.page                  .self),
    "component"              : KVCMapEntry(D2SKeys.component             .self),
    "rowComponent"           : KVCMapEntry(D2SKeys.rowComponent          .self),
    "debugComponent"         : KVCMapEntry(D2SKeys.debugComponent        .self),
    "displayNameForEntity"   : KVCMapEntry(D2SKeys.displayNameForEntity  .self),
    "displayNameForProperty" : KVCMapEntry(D2SKeys.displayNameForProperty.self),
    "displayStringForNil"    : KVCMapEntry(D2SKeys.displayStringForNil   .self),
    "hideEmptyProperty"      : KVCMapEntry(D2SKeys.hideEmptyProperty     .self),
    "displayPropertyKeys"    : KVCMapEntry(D2SKeys.displayPropertyKeys   .self),
    "visibleEntityNames"     : KVCMapEntry(D2SKeys.visibleEntityNames    .self),
    "isEntityReadOnly"       : KVCMapEntry(D2SKeys.isEntityReadOnly      .self),
    "readOnlyEntityNames"    : KVCMapEntry(D2SKeys.readOnlyEntityNames   .self),
    "title"                  : KVCMapEntry(D2SKeys.title                 .self),
    "navigationBarTitle"     : KVCMapEntry(D2SKeys.navigationBarTitle    .self),
    "platform"               : KVCMapEntry(D2SKeys.platform              .self),
    "look"                   : KVCMapEntry(D2SKeys.look                  .self),
    "user"                   : KVCMapEntry(D2SKeys.user                  .self),
    "isObjectEditable"       : KVCMapEntry(D2SKeys.isObjectEditable      .self),
    "isObjectDeletable"      : KVCMapEntry(D2SKeys.isObjectDeletable     .self),
    "auxiliaryQualifier"     : KVCMapEntry(D2SKeys.auxiliaryQualifier    .self),
  ]
}
