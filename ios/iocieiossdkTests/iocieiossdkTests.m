/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <React/RCTLog.h>
#import <React/RCTRootView.h>

#define TIMEOUT_SECONDS 600
#define TEXT_TO_LOOK_FOR @"Welcome to React"

#import "CieModule.h"

@interface iocieiossdkTests : XCTestCase

@end

@implementation iocieiossdkTests

- (BOOL)findSubviewInView:(UIView *)view matching:(BOOL(^)(UIView *view))test
{
  if (test(view)) {
    return YES;
  }
  for (UIView *subview in [view subviews]) {
    if ([self findSubviewInView:subview matching:test]) {
      return YES;
    }
  }
  return NO;
}

//- (void)testRendersWelcomeScreen
//{
//  UIViewController *vc = [[[RCTSharedApplication() delegate] window] rootViewController];
//  NSDate *date = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT_SECONDS];
//  BOOL foundElement = NO;
//
//  __block NSString *redboxError = nil;
//#ifdef DEBUG
//  RCTSetLogFunction(^(RCTLogLevel level, RCTLogSource source, NSString *fileName, NSNumber *lineNumber, NSString *message) {
//    if (level >= RCTLogLevelError) {
//      redboxError = message;
//    }
//  });
//#endif
//
//  while ([date timeIntervalSinceNow] > 0 && !foundElement && !redboxError) {
//    [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//    [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//
//    foundElement = [self findSubviewInView:vc.view matching:^BOOL(UIView *view) {
//      if ([view.accessibilityLabel isEqualToString:TEXT_TO_LOOK_FOR]) {
//        return YES;
//      }
//      return NO;
//    }];
//  }
//  
//#ifdef DEBUG
//  RCTSetLogFunction(RCTDefaultLogFunction);
//#endif
//
//  XCTAssertNil(redboxError, @"RedBox error: %@", redboxError);
//  XCTAssertTrue(foundElement, @"Couldn't find element with text '%@' in %d seconds", TEXT_TO_LOOK_FOR, TIMEOUT_SECONDS);
//}

- (void)testNFCAvailable
{
  CieModule* cieModule = [[CieModule alloc] init];
  
  [cieModule isNFCEnabled:^(NSArray *response) {
    
    XCTAssertNotNil(response, @"response error it is nil");
    XCTAssertNotNil(response.firstObject, @"response first object is nil");
    XCTAssertTrue(response.firstObject, @"NFC is not enabled");
    
    NSLog(@"isNFCEnabled response %@", response.firstObject);
  }];
}

- (void)testHasNFCFeature
{
  CieModule* cieModule = [[CieModule alloc] init];
  
  [cieModule hasNFCFeature:^(NSArray *response) {
    
    XCTAssertNotNil(response, @"response error it is nil");
    XCTAssertNotNil(response.firstObject, @"response first object is nil");
    XCTAssertTrue(response.firstObject, @"doesn't have NFC feature");
    
    NSLog(@"hasNFCFeature response %@", response.firstObject);
  }];
}

- (void)testSetPIN
{
  CieModule* cieModule = [[CieModule alloc] init];
  
  [cieModule setPin:@"11223344"];
    
  XCTAssertTrue([cieModule.getPin isEqualToString:@"11223344"], @"PIN don't match");
    
  NSLog(@"setPIN ok");
}

- (void)testSetAuthenticationUrl
{
  CieModule* cieModule = [[CieModule alloc] init];
  
  [cieModule setAuthenticationUrl:@"https://idppn-ipzs.fbk.eu/idp/erroreQr.jsp?opId=_bac67ee962bcae73318f5b634376c8bc&opType=login&SPName=FBK Test&IdPName=https://idppn-ipzs.fbk.eu/idp/&userId=CA00000AA&opText=FBK Test chiede di accedere ai servizi on-line &SPLogo=https://sp-ipzs-ssl.fbk.eu/img/sp.png"];
    
  XCTAssertTrue([cieModule.getAuthenticationUrl isEqualToString:@"https://idppn-ipzs.fbk.eu/idp/erroreQr.jsp?opId=_bac67ee962bcae73318f5b634376c8bc&opType=login&SPName=FBK Test&IdPName=https://idppn-ipzs.fbk.eu/idp/&userId=CA00000AA&opText=FBK Test chiede di accedere ai servizi on-line &SPLogo=https://sp-ipzs-ssl.fbk.eu/img/sp.png"], @"URLs don't match");
    
  NSLog(@"setAuthenticationUrl");
}

- (void)testStart
{
  CieModule* cieModule = [[CieModule alloc] init];
  
  [cieModule setPin:@"11223344"];
  [cieModule setAuthenticationUrl:@"https://idppn-ipzs.fbk.eu/idp/erroreQr.jsp?opId=_bac67ee962bcae73318f5b634376c8bc&opType=login&SPName=FBK Test&IdPName=https://idppn-ipzs.fbk.eu/idp/&userId=CA00000AA&opText=FBK Test chiede di accedere ai servizi on-line &SPLogo=https://sp-ipzs-ssl.fbk.eu/img/sp.png"];
  
  [cieModule post:^(NSString* error, NSString* response) {
    NSLog(@"post response %@", response);
    NSLog(@"post error %@", error);
    XCTAssertTrue([error isEqualToString:@"TAG_ERROR_NFC_NOT_SUPPORTED"], @"error is not valid");
    XCTAssertTrue([cieModule.getPin isEqualToString:@"11223344"], @"PIN don't match");
  }];
}

// non disponibile su iOS
-(void) testStartListeningNFC
{
  CieModule* cieModule = [[CieModule alloc] init];
  
  [cieModule startListeningNFC:^(NSArray *response) {
    NSLog(@"startListeningNFC %@", response);
    XCTAssertTrue(response.count == 0, @"response is not empty");
  }];
  
}

 // non disponibile su iOS
-(void) testStopListeningNFC
{
  CieModule* cieModule = [[CieModule alloc] init];
  
  [cieModule stopListeningNFC:^(NSArray *response) {
    NSLog(@"stopListeningNFC %@", response);
    XCTAssertTrue(response.count == 0, @"response is not empty");
  }];
}

 // non disponibile su iOS
-(void) testOpenNFCSettings
{
  CieModule* cieModule = [[CieModule alloc] init];
  
  [cieModule openNFCSettings:^(NSArray *response) {
    NSLog(@"openNFCSettings %@", response);
    XCTAssertTrue(response.count == 0, @"response is not empty");
  }];
}

 // non disponibile su iOS
-(void) testHasApiLevelSupport
{
  CieModule* cieModule = [[CieModule alloc] init];
  
  [cieModule hasApiLevelSupport:^(NSArray *response) {
    NSLog(@"hasApiLevelSupport %@", response);
    XCTAssertTrue(response.count == 0, @"response is not empty");
  }];
}

@end
