//
//  AWSConnector.m
//  CognitoYourUserPoolsSample
//
//  Created by Lippens, Stephen on 4/17/17.
//  Copyright © 2017 Lippens, Stephen. All rights reserved.
//

#import "AWSConnector.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface AWSConnector()
@end

@implementation AWSConnector

#pragma mark AWSSessionDelegate
-(void)fetchSession{
    NSLog(@"AWSConnector - FetchSession");
    __weak AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    AWSCognitoIdentityUserPool* pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
    //on initial load set the user and refresh to get attributes
    if(!appDelegate.user){
        NSLog(@"AWSConnector - FetchSession: User is nil");
        appDelegate.user = [pool currentUser];
        
        
        //Fetching User Data: If no session is found, login page will display - AppDelegate Handler triggered
        [[appDelegate.user getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    [self.sessionDelegate loadSessionFailedWithError:task.error];
                }else {
                    [self.sessionDelegate loadSessionSuccessful:task.result];
                }
                
            });
            
            return nil;
        }];
        
    }
}

@end
