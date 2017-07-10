//
//  AWSConnector.h
//  CognitoYourUserPoolsSample
//
//  Created by Lippens, Stephen on 4/17/17.
//  Copyright © 2017 Lippens, Stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import AWSCognitoIdentityProvider;

@protocol AWSSessionDelegate;

@interface AWSConnector : NSObject

-(void)fetchSession;

@property (nonatomic, weak) id <AWSSessionDelegate> sessionDelegate;
@end


@protocol AWSSessionDelegate <NSObject>
-(void)loadSessionSuccessful:(AWSCognitoIdentityUserGetDetailsResponse*)result;
-(void)loadSessionFailedWithError:(NSError*)error;
@end



