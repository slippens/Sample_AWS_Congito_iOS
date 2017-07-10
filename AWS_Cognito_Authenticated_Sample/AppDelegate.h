//
//  AppDelegate.h
//  AWS_Cognito_Authenticated_Sample
//
//  Created by Lippens, Stephen on 7/10/17.
//  Copyright © 2017 Lippens, Stephen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWSCognitoIdentityProvider.h"
#import "MFAViewController.h"
#import "SignInViewController.h"
#import "NewPasswordRequiredViewController.h"
#import "AWSConnector.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, AWSCognitoIdentityInteractiveAuthenticationDelegate, AWSCognitoIdentityRememberDevice, AWSSessionDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *storyboard;
@property(nonatomic,strong) UINavigationController *navigationController;
@property(nonatomic,strong) SignInViewController* signInViewController;
@property(nonatomic,strong) MFAViewController* mfaViewController;
@property(nonatomic,strong) NewPasswordRequiredViewController* passwordRequiredViewController;
@property(nonatomic, retain) AWSCognitoIdentityUser* user;
@property (nonatomic,strong) AWSTaskCompletionSource<NSNumber *>* rememberDeviceCompletionSource;
@end

