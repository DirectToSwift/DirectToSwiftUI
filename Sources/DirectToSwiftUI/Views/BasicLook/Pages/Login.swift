//
//  Login.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import ZeeQL

public extension BasicLook.Page {
  
  /**
   * Shows a simple login page.
   *
   * D2S tries to find the table which contains the user information by matching
   * the attributes of the entities in the model.
   * If you don't want that, just add a rule as usual:
   *
   *     \.task == "login" => \.entity <= "UserDatabase"
   *
   * Note: By default the `firstTask` is not login, rather the system jumps
   *       directly into the DB.
   * To enable the login page, add this to the rule model:
   *
   *     \.firstTask <= "login"
   *
   * And to configure the next page, as usual:
   *
   *     \.task == "login" => \.nextTask <= "query"
   *
   * Or whatever you like (defaults to "query").
   */
  struct Login: View {
    // TODO: Add keychain etc etc
    
    @Environment(\.database)  private var database
    @Environment(\.entity)    private var entity
    @Environment(\.attribute) private var attribute
    @Environment(\.nextTask)  private var nextTask

    @State var username  : String = ""
    @State var password  : String = ""
    @State var loginUser : OActiveRecord? = nil
    
    private var hasValidInput: Bool {
      return !username.isEmpty
    }
    
    private func loginAttributes() -> ( Attribute, Attribute )? {
      // We allow the user to specify the login property, but not the
      // password yet.
      let authProps = entity.lookupUserDatabaseProperties()
      if !attribute.d2s.isDefault {
        guard let pwd = authProps?.password
                     ?? entity[attribute: "password"] else {
          return nil
        }
        return ( attribute, pwd )
      }
      return authProps
    }
    
    private func login() {
      // FIXME: Make async, add spinner, all the good stuff ;-)
      defer { password = "" }
      
      loginUser = nil
      
      guard let ( la, pa ) = loginAttributes() else {
        globalD2SLogger.error("cannot login using entity:", entity)
        return
      }
      
      // TBD: This TextField on iOS always produces capitalized strings, which
      //      is often wrong, so lets also compare to the lowercase variant.
      let userNameQualifier = la.eq(username).or(la.eq(username.lowercased()))
      
      // For password we just go brute force. Managed to resist the urge to
      // also check for plain. More options might make sense.
      let pwdQualifier = pa.eq(password.md5()).or(pa.eq(password.sha1()))

      let ds = ActiveDataSource<OActiveRecord>(
                 database: database, entity: entity)
      ds.fetchSpecification = ModelFetchSpecification(entity: entity)
        .where(userNameQualifier.and(pwdQualifier))
      
      if let user = try? ds.find() {
        loginUser = user
      }
      else {
        globalD2SLogger.error("did not find user or pwd")
      }
    }

    public var body: some View {
      Group {
        if loginUser == nil {
          // Designers welcome.
          VStack {
            VStack {
              #if os(watchOS) // no RoundedBorderTextFieldStyle
                TextField  ("Username", text: $username)
                SecureField("Password", text: $password)
              #else
                TextField  ("Username", text: $username)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $password)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
              #endif
              Button(action: self.login) {
                Text("Login")
              }
              .disabled(!hasValidInput)
            }
            .padding()
            .padding()
            .background(RoundedRectangle(cornerRadius: 16)
                        .stroke()
                        .foregroundColor(.secondary))
            .padding()
            .frame(maxWidth: 320)
            Spacer()
          }
        }
        else {
          D2SPageView()
            .task(nextTask)
            .environment(\.user, loginUser!)
            // TODO: clear entity
        }
      }
    }
  }
}
