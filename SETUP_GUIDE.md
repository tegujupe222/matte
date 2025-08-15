# Matte iOS App - Complete Setup Guide

This guide will help you set up the Vercel server with Gemini AI integration and connect it to your iOS app.

## 🎯 What We've Built

### ✅ Completed Features
1. **Vercel Server** - Complete backend with Gemini AI integration
2. **iOS App Integration** - Updated AIService to use Vercel endpoints
3. **Emergency SOS System** - Full emergency handling
4. **Family Connection** - Location sharing and member management
5. **Statistics & Reports** - Security analytics and reporting
6. **AI Analysis** - Real-time scam detection using Gemini 2.5 Flash Lite

## 🚀 Quick Start

### Step 1: Get Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Sign in with your Google account
3. Create a new project or select existing one
4. Click "Get API key" → "Create API key"
5. Copy the API key (you'll need this for Step 3)

### Step 2: Deploy to Vercel

#### Option A: Using the Deployment Script (Recommended)

```bash
# Make sure you're in the project directory
cd /path/to/your/matte/project

# Run the deployment script
./deploy.sh
```

The script will:
- Check for required dependencies
- Install Vercel CLI if needed
- Create `.env.local` template
- Deploy to Vercel
- Set up environment variables

#### Option B: Manual Deployment

```bash
# Install dependencies
npm install

# Install Vercel CLI
npm install -g vercel

# Create environment file
echo "GEMINI_API_KEY=your_actual_api_key_here" > .env.local

# Deploy
vercel --prod

# Set environment variable
vercel env add GEMINI_API_KEY
```

### Step 3: Update iOS App

1. **Get your Vercel URL** from the deployment output
2. **Update the baseURL** in `Matte/AIService.swift`:

```swift
// Find this line in NetworkService class
private let baseURL = "https://your-vercel-app.vercel.app/api"

// Replace with your actual Vercel URL
private let baseURL = "https://your-actual-app-name.vercel.app/api"
```

### Step 4: Test the Integration

1. **Build and run** your iOS app
2. **Test AI features**:
   - Go to Voice Assistant screen
   - Try voice commands
   - Test AI analysis features

## 📱 iOS App Features Now Working

### ✅ AI Integration
- **Real-time scam analysis** using Gemini 2.5 Flash Lite
- **Voice assistant** with speech recognition
- **Call analysis** for suspicious phone numbers
- **Email analysis** for phishing detection
- **Website analysis** for safe browsing

### ✅ Emergency SOS
- **One-tap emergency activation**
- **Automatic contact notification**
- **Location sharing** with family
- **Emergency history** tracking

### ✅ Family Connection
- **Family member management**
- **Real-time location sharing**
- **Emergency contact setup**
- **Activity status** monitoring

### ✅ Statistics & Reports
- **Security event tracking**
- **Protection score** calculation
- **Trend analysis**
- **Achievement system**

## 🔧 Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GEMINI_API_KEY` | Google Gemini API key | Yes |

### Vercel Configuration

The server is configured with:
- **Node.js 18.x** runtime
- **Serverless functions** for scalability
- **CORS enabled** for iOS app access
- **Automatic scaling** based on demand

## 🧪 Testing Your Setup

### Test AI Analysis

```bash
# Test the Gemini AI endpoint
curl -X POST https://your-app.vercel.app/api/ai/gemini \
  -H "Content-Type: application/json" \
  -d '{
    "type": "call_analysis",
    "content": "Someone called claiming to be from the bank asking for my account details",
    "userId": "test_user"
  }'
```

### Test Emergency SOS

```bash
# Test emergency trigger
curl -X POST https://your-app.vercel.app/api/emergency/sos \
  -H "Content-Type: application/json" \
  -d '{
    "action": "trigger",
    "data": {
      "triggerMethod": "button",
      "location": {
        "latitude": 35.6762,
        "longitude": 139.6503
      }
    }
  }'
```

### Test Family Connection

```bash
# Test family member retrieval
curl "https://your-app.vercel.app/api/family/connection?userId=test_user&action=members"
```

## 🔍 Troubleshooting

### Common Issues

1. **"API Key Not Found" Error**
   - Ensure `GEMINI_API_KEY` is set in Vercel environment variables
   - Check that the key is valid and has proper permissions

2. **CORS Errors**
   - Verify CORS headers are properly set in the API
   - Check that the iOS app is making requests to the correct domain

3. **Function Timeout**
   - Vercel functions have a 10-second timeout limit
   - AI requests are optimized for faster response times

4. **iOS App Can't Connect**
   - Verify the baseURL in `AIService.swift` is correct
   - Check network connectivity
   - Ensure the Vercel app is deployed and running

### Debug Mode

Enable debug logging by adding to your environment variables:

```env
DEBUG=true
```

## 📊 Monitoring

### Vercel Dashboard
- Monitor function performance
- Check error logs
- View deployment status
- Track API usage

### iOS App Logs
- Check Xcode console for network errors
- Monitor AI analysis responses
- Track user interactions

## 🔄 Updates & Maintenance

### Regular Maintenance
1. **API Key Rotation** - Rotate Gemini API keys quarterly
2. **Dependency Updates** - Keep npm packages updated
3. **Security Audits** - Regular security reviews
4. **Performance Monitoring** - Monitor response times and errors

### Deployment Updates
```bash
# Deploy updates
vercel --prod

# Rollback if needed
vercel rollback
```

## 📞 Support

### Documentation
- [Vercel Documentation](https://vercel.com/docs)
- [Google AI Studio Documentation](https://ai.google.dev/docs)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Getting Help
1. Check server logs in Vercel Dashboard
2. Monitor function performance and errors
3. Test endpoints individually
4. Verify environment variables are set correctly

## 🎉 Success Checklist

- [ ] Gemini API key obtained and configured
- [ ] Vercel server deployed successfully
- [ ] Environment variables set correctly
- [ ] iOS app baseURL updated
- [ ] AI analysis working in iOS app
- [ ] Emergency SOS functioning
- [ ] Family connection features working
- [ ] Statistics and reports generating
- [ ] Voice assistant responding
- [ ] All features tested and working

## 🚀 Next Steps

Once everything is working:

1. **Customize the AI prompts** in `api/ai/gemini.js` for better Japanese responses
2. **Add more security features** like real-time threat detection
3. **Implement push notifications** for emergency alerts
4. **Add offline capabilities** for when internet is unavailable
5. **Enhance the UI/UX** based on user feedback

---

**Congratulations!** 🎉 Your Matte iOS app now has a fully functional backend with Gemini AI integration, ready to protect elderly users from scams and provide emergency assistance.

For any questions or issues, refer to the troubleshooting section above or check the server logs in your Vercel dashboard.
