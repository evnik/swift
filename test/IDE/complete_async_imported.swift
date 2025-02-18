// REQUIRES: objc_interop
// REQUIRES: concurrency

// RUN: %empty-directory(%t)
// RUN: %empty-directory(%t/out)
// RUN: split-file %s %t
// RUN: %target-swift-ide-test(mock-sdk: %clang-importer-sdk) -swift-version 5.6 -batch-code-completion -source-filename %t/test.swift -filecheck %raw-FileCheck -completion-output-dir %t/out -import-objc-header %t/ObjC.h -enable-objc-interop 


//--- ObjC.h


@import Foundation;

_Pragma("clang assume_nonnull begin")

@interface MyObjCClass: NSObject

- (void)method1WithCompletionHandler:(void (^)(NSError * _Nullable err))completionHandler;
- (void)method2WithCompletionHandler:(void (^)(NSError * _Nullable err))completionHandler __attribute__((swift_private));
- (void)method3WithCompletionHandler:(void (^)(NSError * _Nullable err))completionHandler __attribute__((swift_private)) __attribute__((swift_async_name("named3()")));
- (void)method4WithCompletionHandler:(void (^)(NSError * _Nullable err))completionHandler __attribute__((swift_async(swift_private, 1)));
- (void)method5WithCompletionHandler:(void (^)(NSError * _Nullable err))completionHandler __attribute__((swift_async(swift_private, 1))) __attribute__((swift_async_name("named5()")));
- (void)method6WithCompletionHandler:(void (^)(NSError * _Nullable err))completionHandler __attribute__((swift_async(not_swift_private, 1)));
- (void)method7WithCompletionHandler:(void (^)(NSError * _Nullable err))completionHandler __attribute__((swift_async(not_swift_private, 1))) __attribute__((swift_async_name("named7()")));

@end

_Pragma("clang assume_nonnull end")

//--- test.swift

func test(obj: MyObjCClass) async throws {
    obj.#^COMPLETE^#
// COMPLETE: Begin completions
// COMPLETE-NOT: method2(
// COMPLETE-NOT: method4()
// COMPLETE-NOT: method5()
// COMPLETE-DAG: Keyword[self]/CurrNominal:          self[#MyObjCClass#]; name=self
// COMPLETE-DAG: Decl[InstanceMethod]/CurrNominal:   method1({#completionHandler: (Error?) -> Void##(Error?) -> Void#})[#Void#];
// COMPLETE-DAG: Decl[InstanceMethod]/CurrNominal:   method1()[' async'][' throws'][#Void#];
// COMPLETE-DAG: Decl[InstanceMethod]/CurrNominal:   named3()[' async'][' throws'][#Void#];
// COMPLETE-DAG: Decl[InstanceMethod]/CurrNominal:   method4({#completionHandler: (Error?) -> Void##(Error?) -> Void#})[#Void#];
// COMPLETE-DAG: Decl[InstanceMethod]/CurrNominal:   method5({#completionHandler: (Error?) -> Void##(Error?) -> Void#})[#Void#];
// COMPLETE-DAG: Decl[InstanceMethod]/CurrNominal:   method6({#completionHandler: (Error?) -> Void##(Error?) -> Void#})[#Void#];
// COMPLETE-DAG: Decl[InstanceMethod]/CurrNominal:   method6()[' async'][' throws'][#Void#];
// COMPLETE-DAG: Decl[InstanceMethod]/CurrNominal:   method7({#completionHandler: (Error?) -> Void##(Error?) -> Void#})[#Void#];
// COMPLETE-DAG: Decl[InstanceMethod]/CurrNominal:   named7()[' async'][' throws'][#Void#];
// COMPLETE: End completions
}
