//
//  HTTPSConnection.h
//  CIESDK
//
//  Created by ugo chirico on 29.02.2020.
//  Copyright © 2020 IPZS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTTPSConnection : NSObject

- (void) postTo: (NSString*) url withPIN: (NSString*) pin withCertificate: (NSData*) certificate withData: (NSData* _Nullable) data callback: (void(^) (int code, NSData* respData)) callback;

@end

NS_ASSUME_NONNULL_END
