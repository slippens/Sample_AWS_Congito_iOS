# Sample_AWS_Congito_iOS
This is a sample that shows how to create and login to an iOS application using AWS Cognito Identity Pools

A full explanation of this sample can be found on my blog:
https://wordpress.com/post/stephenlippens.wordpress.com/374

Steps to configure:

1) Download the sample project and run the pod file to install the required frameworks
*navigate to the project folder where the Podfile is located in terminal and run:
'pod install'

2) Follow steps on how to configure the Cognito User Pool and Identity pool on my blog:
https://wordpress.com/post/stephenlippens.wordpress.com/374

3) Open the Constants.m file and provide:

AWSRegionType const CognitoIdentityUserPoolRegion = AWSRegionUSEast1; //Change this if your region is different

NSString *const CognitoIdentityPoolId = @"PROVIDE_IDENTITY_POOL_ID";

NSString *const CognitoIdentityUserPoolId = @"PROVIDE_USER_POOL_ID";

NSString *const CognitoIdentityUserPoolAppClientId = @"PROVIDE_USER_POOL_APP_CLIENT_ID";

NSString *const CognitoIdentityUserPoolAppClientSecret = @"PROVIDE_USER_POOL_APP_CLIENT_SECRET";
