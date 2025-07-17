# AWS Amplify Setup Guide for Hyle

## Prerequisites
1. Install AWS Amplify CLI globally:
```bash
npm install -g @aws-amplify/cli
```

2. Configure AWS credentials:
```bash
amplify configure
```

## Initialize Amplify in the Project

1. Navigate to the project directory:
```bash
cd "/Users/junhoochoi/dev/github desktop/hyle"
```

2. Initialize Amplify:
```bash
amplify init
```

Use these settings:
- **Name**: hyle
- **Environment**: dev
- **Default editor**: Visual Studio Code
- **App type**: flutter
- **Configuration**: 
  - Source Directory Path: lib
  - Distribution Directory Path: build
  - Build Command: flutter build
  - Start Command: flutter run

## Add Authentication

```bash
amplify add auth
```

Configuration:
- **Do you want to use the default authentication and security configuration?** Manual configuration
- **Select the authentication/authorization services**: Username (email)
- **Enable sign-in with**: Email
- **Do you want to configure advanced settings?** Yes
  - Password requirements: 8+ chars, uppercase, lowercase, number
  - Enable email verification
  - MFA: Optional
  - User attributes: nickname, preferred_username

## Add API (GraphQL)

```bash
amplify add api
```

Configuration:
- **Select from one of the below mentioned services**: GraphQL
- **Provide API name**: hyle
- **Choose the default authorization type**: Amazon Cognito User Pool
- **Do you want to configure advanced settings?** Yes
  - Enable conflict detection: Yes
  - Select conflict resolution strategy: Auto Merge
  - Enable DataStore: Yes

The GraphQL schema is already created at `amplify/backend/api/hyle/schema.graphql`

## Add Storage

```bash
amplify add storage
```

Configuration:
- **Select from one of the below mentioned services**: Content (Images, audio, video, etc.)
- **Provide a friendly name**: hyleStorage
- **Provide bucket name**: hyle-storage-{random}
- **Who should have access**: Auth users only
- **What kind of access**: Auth users: read/write, Guest users: read
- **Do you want to add a Lambda Trigger**: No

## Add Analytics

```bash
amplify add analytics
```

Configuration:
- **Select an Analytics provider**: Amazon Pinpoint
- **Provide your pinpoint resource name**: hyleAnalytics
- **Apps need authorization to send analytics events**: Yes
- **Allow guests to send analytics events**: No

## Deploy to AWS

```bash
amplify push
```

This will:
1. Create all AWS resources
2. Generate the configuration files
3. Create the Amplify models

## Update Flutter App

After deployment, run:
```bash
amplify codegen models
```

This generates Dart models in `lib/models/`

## Environment Variables

Create `.env` file:
```env
# AWS Configuration
AWS_REGION=us-east-1
AMPLIFY_ENV=dev

# AI Services
BEDROCK_MODEL_ID=anthropic.claude-3-opus-20240229
PINECONE_API_KEY=your-pinecone-api-key
PINECONE_ENVIRONMENT=us-east1-gcp

# Feature Flags
ENABLE_AI_FEATURES=true
ENABLE_SOCIAL_FEATURES=true
ENABLE_PREMIUM_FEATURES=true
```

## Next Steps

1. Update `amplifyconfiguration.dart` with the generated configuration
2. Initialize Amplify in your Flutter app
3. Update authentication screens to use Amplify Auth
4. Implement data repositories using Amplify DataStore
5. Set up real-time subscriptions

## Troubleshooting

If you encounter issues:
1. Check AWS credentials: `amplify configure`
2. Verify project status: `amplify status`
3. Pull latest backend: `amplify pull`
4. Check logs: `amplify console`

## Cost Considerations

- Use DynamoDB on-demand billing
- Set up billing alerts in AWS Console
- Monitor usage through CloudWatch
- Consider using AWS Free Tier for development

## Security Best Practices

1. Never commit AWS credentials
2. Use IAM roles with minimal permissions
3. Enable MFA for AWS accounts
4. Regularly rotate access keys
5. Use environment-specific configurations