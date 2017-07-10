//
//  AppDelegate.m
//  AWS_Cognito_Authenticated_Sample
//
//  Created by Lippens, Stephen on 7/10/17.
//  Copyright © 2017 Lippens, Stephen. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "AWSConnector.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark - Application Launch States
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    //setup logging
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
    //[AWSLogger defaultLogger].logLevel = AWSLogLevelError;
    
    //Register Pool Configuration
    AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:CognitoIdentityUserPoolAppClientId  clientSecret:CognitoIdentityUserPoolAppClientSecret poolId:CognitoIdentityUserPoolId];
    
    //setup service config
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoIdentityUserPoolRegion credentialsProvider:nil];
    
    //Register IdentityPool
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"UserPool"];
    
    //Create Identity Pool from registered value
    AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1 identityPoolId:CognitoIdentityPoolId identityProviderManager:pool];

    AWSServiceConfiguration *defaultServiceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = defaultServiceConfiguration;
    
    pool.delegate = self;
    
    
     self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    //load cognito session:
    AWSConnector* awsConnector = [[AWSConnector alloc] init];
    awsConnector.sessionDelegate = self;
    [awsConnector fetchSession];
    
    return YES;
}




#pragma mark - AWSCognitoAuthentication
//set up password authentication ui to retrieve username and password from the user
-(id<AWSCognitoIdentityPasswordAuthentication>) startPasswordAuthentication {
   
    
    if(!self.navigationController){
        self.navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"signinController"];
    }
    if(!self.signInViewController){
        self.signInViewController = self.navigationController.viewControllers[0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //rewind to login screen
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        //display login screen if it isn't already visibile
        if(!(self.navigationController.isViewLoaded && self.navigationController.view.window))
        {
            [self.window.rootViewController presentViewController:self.navigationController animated:YES completion:nil];
        }
    });
    return self.signInViewController;
}

//set up mfa ui to retrieve mfa code from end user
-(id<AWSCognitoIdentityMultiFactorAuthentication>) startMultiFactorAuthentication {
   
    if(!self.mfaViewController){
        self.mfaViewController = [MFAViewController new];
        self.mfaViewController.modalPresentationStyle = UIModalPresentationPopover;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //if mfa view isn't already visible, display it
        if (!(self.mfaViewController.isViewLoaded && self.mfaViewController.view.window)) {
            //display mfa as popover on current view controller
            UIViewController *vc = self.window.rootViewController;
            [vc presentViewController:self.mfaViewController animated: YES completion: nil];
            
            //configure popover vc
            UIPopoverPresentationController *presentationController =
            [self.mfaViewController popoverPresentationController];
            presentationController.permittedArrowDirections =
            UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
            presentationController.sourceView = vc.view;
            presentationController.sourceRect = vc.view.bounds;
        }
    });
    return self.mfaViewController;
}

//set up remember device ui
-(id<AWSCognitoIdentityRememberDevice>) startRememberDevice {
    return self;
}

-(void) getRememberDevice: (AWSTaskCompletionSource<NSNumber *> *) rememberDeviceCompletionSource {
    self.rememberDeviceCompletionSource = rememberDeviceCompletionSource;
    
    //Don't do anything fancy here, just display a popup.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Remember Device"
                                    message:@"Do you want to remember this device?"
                                   delegate:self
                          cancelButtonTitle:@"No"
                          otherButtonTitles:@"Yes", nil] show];
    });
}

-(void) didCompleteRememberDeviceStepWithError:(NSError* _Nullable) error {
    [self errorPopup:error];
}

-(void) errorPopup:(NSError *_Nullable) error {
    //Don't do anything fancy here, just display a popup.
    if(error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:error.userInfo[@"__type"]
                                        message:error.userInfo[@"message"]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Ok", nil] show];
        });
    }
}


-(id<AWSCognitoIdentityNewPasswordRequired>) startNewPasswordRequired {
    if(!self.passwordRequiredViewController){
        self.passwordRequiredViewController = [NewPasswordRequiredViewController new];
        self.passwordRequiredViewController.modalPresentationStyle = UIModalPresentationPopover;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //if new password required view isn't already visible, display it
        if (!(self.passwordRequiredViewController.isViewLoaded && self.passwordRequiredViewController.view.window)) {
            //display mfa as popover on current view controller
            UIViewController *vc = self.window.rootViewController;
            [vc presentViewController:self.passwordRequiredViewController animated: YES completion: nil];
            
            //configure popover vc
            UIPopoverPresentationController *presentationController =
            [self.passwordRequiredViewController popoverPresentationController];
            presentationController.permittedArrowDirections =
            UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
            presentationController.sourceView = vc.view;
            presentationController.sourceRect = vc.view.bounds;
        }
    });
    return self.passwordRequiredViewController;
    
}



#pragma mark- AWSSessionDelegate:

-(void)loadSessionSuccessful:(AWSCognitoIdentityUserGetDetailsResponse*)result{
    //Store UserPool Unique ID (AccountID)
    NSArray* attributes =  result.userAttributes;
    //NSLog(@"%@", attributes);
    for(int i = 0; i < attributes.count; i++){
        AWSCognitoIdentityProviderAttributeType *userAttribute = result.userAttributes[i];
        if([userAttribute.name isEqualToString:@"sub"]){
            NSString* userPoolAccountID = userAttribute.value;
            NSLog(@"Storing UserPoolUniqueID as %@", userAttribute.value);
        }
        else if([userAttribute.name isEqualToString:@"name"]){
            NSString* name = userAttribute.value;
            NSLog(@"Storing name as %@", userAttribute.value);
        }
        else if([userAttribute.name isEqualToString:@"family_name"]){
             NSString* familyName = userAttribute.value;
            NSLog(@"Storing familyName as %@", userAttribute.value);
        }
    }
    
    //Display content controller:
    [self.window setRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"MainNavController"]];
    
}

-(void)loadSessionFailedWithError:(NSError *)error{
    NSLog(@"ERROR:%@", error.description);
}


@end
