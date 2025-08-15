# Matte iOS App - Vercel Server

This is the backend server for the Matte iOS scam prevention app, built on Vercel with Gemini AI integration.

## 🚀 Features

- **Gemini AI Integration**: Real-time scam analysis using Google's Gemini 2.5 Flash Lite
- **Emergency SOS System**: Handle emergency situations and notifications
- **Family Connection**: Manage family members and location sharing
- **Statistics & Reports**: Generate security reports and analytics
- **RESTful API**: Clean, documented API endpoints

## 📁 Project Structure

```
/
├── api/
│   ├── ai/
│   │   └── gemini.js          # Gemini AI analysis endpoint
│   ├── emergency/
│   │   └── sos.js             # Emergency SOS management
│   ├── family/
│   │   └── connection.js      # Family connection features
│   └── statistics/
│       └── reports.js         # Statistics and reports
├── package.json               # Dependencies and scripts
├── vercel.json               # Vercel configuration
└── SERVER_README.md          # This file
```

## 🔧 Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Environment Variables

Create a `.env.local` file in the root directory:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### 3. Get Gemini API Key

1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Create a new project or select existing one
3. Generate an API key
4. Copy the API key to your `.env.local` file

### 4. Deploy to Vercel

#### Option A: Using Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Set environment variables
vercel env add GEMINI_API_KEY
```

#### Option B: Using Vercel Dashboard

1. Push your code to GitHub
2. Go to [Vercel Dashboard](https://vercel.com/dashboard)
3. Click "New Project"
4. Import your GitHub repository
5. Add environment variable `GEMINI_API_KEY` in the project settings

## 📡 API Endpoints

### AI Analysis (`/api/ai/gemini`)

**POST** - Analyze content for scam detection

```json
{
  "type": "call_analysis|email_analysis|website_analysis|general_advice|emergency_guidance",
  "content": "Content to analyze",
  "userId": "user_id",
  "context": {
    "sender": "sender_info",
    "subject": "email_subject",
    "description": "additional_context"
  }
}
```

**Response:**
```json
{
  "type": "call_analysis",
  "content": "Original content",
  "analysis": "AI analysis result",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "userId": "user_id",
  "riskLevel": "high|medium|low",
  "recommendations": ["recommendation1", "recommendation2"]
}
```

### Emergency SOS (`/api/emergency/sos`)

**GET** - Get emergency settings/status
```bash
GET /api/emergency/sos?userId=123&action=settings
```

**POST** - Trigger emergency or update settings
```json
{
  "action": "trigger|update-settings|add-contact",
  "data": {
    "triggerMethod": "button",
    "location": {
      "latitude": 35.6762,
      "longitude": 139.6503
    }
  }
}
```

### Family Connection (`/api/family/connection`)

**GET** - Get family members/location
```bash
GET /api/family/connection?userId=123&action=members
```

**POST** - Add family member or update location
```json
{
  "action": "add-member|update-location|share-location",
  "data": {
    "name": "Family Member Name",
    "phone": "+1234567890",
    "email": "member@example.com",
    "relationship": "son"
  }
}
```

### Statistics (`/api/statistics/reports`)

**GET** - Get statistics and reports
```bash
GET /api/statistics/reports?userId=123&action=overview&period=week
```

**POST** - Log security events
```json
{
  "action": "log-event|update-achievement",
  "data": {
    "type": "call_scam",
    "severity": "high",
    "description": "Suspicious call detected"
  }
}
```

## 🔒 Security Features

- **CORS Protection**: Configured for iOS app access
- **Input Validation**: All inputs are validated
- **Error Handling**: Comprehensive error handling
- **Rate Limiting**: Built-in rate limiting (Vercel default)
- **Environment Variables**: Secure API key storage

## 🧪 Testing

### Local Development

```bash
# Start local development server
npm run dev

# Test endpoints locally
curl -X POST http://localhost:3000/api/ai/gemini \
  -H "Content-Type: application/json" \
  -d '{
    "type": "call_analysis",
    "content": "Someone called claiming to be from the bank",
    "userId": "test_user"
  }'
```

### Production Testing

```bash
# Test deployed endpoint
curl -X POST https://your-vercel-app.vercel.app/api/ai/gemini \
  -H "Content-Type: application/json" \
  -d '{
    "type": "call_analysis",
    "content": "Test content",
    "userId": "test_user"
  }'
```

## 📱 iOS App Integration

Update your iOS app's `AIService.swift` to use the Vercel endpoints:

```swift
class NetworkService {
    private let baseURL = "https://your-vercel-app.vercel.app/api"
    
    func analyzeContent(type: String, content: String, userId: String) async throws -> AIAnalysis {
        let url = URL(string: "\(baseURL)/ai/gemini")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "type": type,
            "content": content,
            "userId": userId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AIAnalysis.self, from: data)
    }
}
```

## 🚨 Emergency Features

The server includes comprehensive emergency handling:

1. **Emergency Trigger**: Immediate response to SOS activation
2. **Contact Notification**: Automatic notification to emergency contacts
3. **Location Sharing**: Real-time location sharing with family
4. **Action Logging**: Complete audit trail of emergency events

## 📊 Analytics & Reporting

- **Real-time Statistics**: Live security event tracking
- **Trend Analysis**: Pattern recognition and trend identification
- **Protection Scoring**: Dynamic safety score calculation
- **Achievement System**: Gamified security milestones
- **Recommendations**: AI-powered security advice

## 🔧 Configuration

### Vercel Configuration (`vercel.json`)

```json
{
  "version": 2,
  "functions": {
    "api/ai/*.js": {
      "runtime": "nodejs18.x"
    }
  }
}
```

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GEMINI_API_KEY` | Google Gemini API key | Yes |

## 🐛 Troubleshooting

### Common Issues

1. **API Key Not Found**
   - Ensure `GEMINI_API_KEY` is set in Vercel environment variables
   - Check that the key is valid and has proper permissions

2. **CORS Errors**
   - Verify CORS headers are properly set
   - Check that the iOS app is making requests to the correct domain

3. **Function Timeout**
   - Vercel functions have a 10-second timeout limit
   - Optimize AI requests for faster response times

### Debug Mode

Enable debug logging by adding to your environment variables:

```env
DEBUG=true
```

## 📈 Performance

- **Response Time**: < 2 seconds for AI analysis
- **Uptime**: 99.9% (Vercel SLA)
- **Scalability**: Automatic scaling with Vercel
- **Caching**: Implemented for frequently requested data

## 🔄 Updates & Maintenance

### Regular Maintenance

1. **API Key Rotation**: Rotate Gemini API keys quarterly
2. **Dependency Updates**: Keep npm packages updated
3. **Security Audits**: Regular security reviews
4. **Performance Monitoring**: Monitor response times and errors

### Deployment Updates

```bash
# Deploy updates
vercel --prod

# Rollback if needed
vercel rollback
```

## 📞 Support

For technical support or questions:

1. Check the [Vercel Documentation](https://vercel.com/docs)
2. Review [Google AI Studio Documentation](https://ai.google.dev/docs)
3. Check server logs in Vercel Dashboard
4. Monitor function performance and errors

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note**: This server is designed specifically for the Matte iOS app. Ensure proper security measures are in place before deploying to production.
