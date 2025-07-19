const amplifyConfig = ''' {
    "UserAgent": "aws-amplify-dart/1.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-dart/1.0",
                "Version": "1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "us-east-1_XXXXXXXXX",
                        "AppClientId": "XXXXXXXXXXXXXXXXXXXXXXXXX",
                        "Region": "us-east-1"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": ["EMAIL"],
                        "signupAttributes": ["EMAIL", "NAME"],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": ["SMS"],
                        "verificationMechanisms": ["EMAIL"]
                    }
                }
            }
        }
    },
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "hyle": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://XXXXXXXXXXXXXXXXXXXXXXXXX.appsync-api.us-east-1.amazonaws.com/graphql",
                    "region": "us-east-1",
                    "authorizationType": "AMAZON_COGNITO_USER_POOLS",
                    "apiKey": "da2-XXXXXXXXXXXXXXXXXXXXXXXXX"
                },
                "aiTutorAPI": {
                    "endpointType": "REST",
                    "endpoint": "https://XXXXXXXXXX.execute-api.us-east-1.amazonaws.com/prod",
                    "region": "us-east-1",
                    "authorizationType": "AMAZON_COGNITO_USER_POOLS"
                }
            }
        }
    },
    "analytics": {
        "plugins": {
            "awsPinpointAnalyticsPlugin": {
                "pinpointAnalytics": {
                    "appId": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                    "region": "us-east-1"
                },
                "pinpointTargeting": {
                    "region": "us-east-1"
                }
            }
        }
    },
    "storage": {
        "plugins": {
            "awsS3StoragePlugin": {
                "bucket": "hyle-storage-XXXXXXXXX",
                "region": "us-east-1",
                "defaultAccessLevel": "guest"
            }
        }
    }
}''';