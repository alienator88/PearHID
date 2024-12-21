//
//  Sudo.swift
//  PearHID
//
//  Created by Alin Lupascu on 12/20/24.
//

import Foundation
import Security

public struct Sudo {

    private typealias AuthorizationExecuteWithPrivilegesImpl = @convention(c) (
        AuthorizationRef,
        UnsafePointer<CChar>, // cmd path
        AuthorizationFlags,
        UnsafePointer<UnsafeMutablePointer<CChar>?>, // cmd arguments
        UnsafeMutablePointer<UnsafeMutablePointer<FILE>>?
    ) -> OSStatus

    /// This wraps the deprecated AuthorizationExecuteWithPrivileges
    /// and makes it accessible by Swift
    ///
    /// - Parameters:
    ///   - cmd: The shell command
    /// - Returns: `errAuthorizationSuccess` or an error code
    public static func run(cmd: String) -> Bool {
        var authRef: AuthorizationRef!
        var status = AuthorizationCreate(nil, nil, [], &authRef)

        guard status == errAuthorizationSuccess else { return false }
        defer { AuthorizationFree(authRef, [.destroyRights]) }

        var item = kAuthorizationRightExecute.withCString { name in
            AuthorizationItem(name: name, valueLength: 0, value: nil, flags: 0)
        }
        var rights = withUnsafeMutablePointer(to: &item) { ptr in
            AuthorizationRights(count: 1, items: ptr)
        }

        status = AuthorizationCopyRights(authRef, &rights, nil, [.interactionAllowed, .preAuthorize, .extendRights], nil)

        guard status == errAuthorizationSuccess else { return false }

        status = executeWithPrivileges(authorization: authRef, cmd: "/bin/sh", arguments: ["-c", cmd])

        return status == errAuthorizationSuccess
    }

    private static func executeWithPrivileges(authorization: AuthorizationRef, cmd: String, arguments: [String]) -> OSStatus {
        let RTLD_DEFAULT = dlopen(nil, RTLD_NOW)
        guard let funcPtr = dlsym(RTLD_DEFAULT, "AuthorizationExecuteWithPrivileges") else {
            print("Failed to find AuthorizationExecuteWithPrivileges function")
            return -1
        }

        // Create a null-terminated array of argument pointers
        var argPtrs: [UnsafeMutablePointer<CChar>?] = arguments.map { strdup($0) }
        argPtrs.append(nil)  // Null terminator

        defer {
            // Free all dynamically allocated argument strings
            for ptr in argPtrs.dropLast() {
                if let ptr = ptr {
                    free(ptr)
                }
            }
        }

        let impl = unsafeBitCast(funcPtr, to: AuthorizationExecuteWithPrivilegesImpl.self)

        return impl(authorization, cmd, [], argPtrs, nil)
    }
    //    private static func executeWithPrivileges(authorization: AuthorizationRef, cmd: String, arguments: [String]) -> OSStatus {
    //        let RTLD_DEFAULT = dlopen(nil, RTLD_NOW)
    //        guard let funcPtr = dlsym(RTLD_DEFAULT, "AuthorizationExecuteWithPrivileges") else { return -1 }
    //        let args = arguments.map { strdup($0) }
    //        defer { args.forEach { free($0) }}
    //        let impl = unsafeBitCast(funcPtr, to: AuthorizationExecuteWithPrivilegesImpl.self)
    //        return impl(authorization, cmd, [], args, nil)
    //    }
}
