import { GoogleGenerativeAI } from '@google/generative-ai';

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Safety settings for elderly users
const safetySettings = [
  {
    category: "HARM_CATEGORY_HARASSMENT",
    threshold: "BLOCK_MEDIUM_AND_ABOVE"
  },
  {
    category: "HARM_CATEGORY_HATE_SPEECH",
    threshold: "BLOCK_MEDIUM_AND_ABOVE"
  },
  {
    category: "HARM_CATEGORY_SEXUALLY_EXPLICIT",
    threshold: "BLOCK_MEDIUM_AND_ABOVE"
  },
  {
    category: "HARM_CATEGORY_DANGEROUS_CONTENT",
    threshold: "BLOCK_MEDIUM_AND_ABOVE"
  }
];

// System prompt for scam prevention
const SYSTEM_PROMPT = `あなたは高齢者向け詐欺防止アシスタント「Matte」です。
以下の特徴を持っています：

1. **親切で分かりやすい説明**: 専門用語を避け、簡単な言葉で説明します
2. **具体的なアドバイス**: 抽象的な説明ではなく、具体的な行動指針を提供します
3. **安全性重視**: 疑わしい場合は「安全第一」を優先します
4. **家族への相談を推奨**: 重要な判断の前に家族に相談するよう促します
5. **緊急時の対応**: 危険を感じた場合は即座に警察や家族に連絡するよう指導します

詐欺の種類：
- 電話詐欺（オレオレ詐欺、還付金詐欺など）
- メール詐欺（フィッシング、偽装メールなど）
- ウェブサイト詐欺（偽サイト、個人情報窃取など）
- 投資詐欺（高利回り投資、仮想通貨詐欺など）
- 医療・健康詐欺（健康食品、治療法など）

常に以下の点を確認してください：
1. 相手の身元確認
2. 金銭の要求の有無
3. 緊急性の主張
4. 個人情報の要求
5. 不自然な要求や条件

回答は必ず日本語で、親切で分かりやすく、具体的なアドバイスを含めてください。`;

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { type, content, userId, context } = req.body;

    if (!process.env.GEMINI_API_KEY) {
      return res.status(500).json({ error: 'Gemini API key not configured' });
    }

    // Get the Gemini Pro model
    const model = genAI.getGenerativeModel({ 
      model: "gemini-1.5-flash",
      safetySettings: safetySettings
    });

    let prompt = SYSTEM_PROMPT + "\n\n";
    let response;

    switch (type) {
      case 'call_analysis':
        prompt += `電話の内容を分析してください：
        
電話内容: ${content}
追加情報: ${context || 'なし'}

以下の点について分析してください：
1. 詐欺の可能性（高/中/低）
2. 危険度（高/中/低）
3. 具体的な危険信号
4. 推奨される対応
5. 家族への相談の必要性

回答は簡潔で分かりやすく、具体的な行動指針を含めてください。`;
        break;

      case 'email_analysis':
        prompt += `メールの内容を分析してください：
        
メール内容: ${content}
送信者: ${context?.sender || '不明'}
件名: ${context?.subject || 'なし'}

以下の点について分析してください：
1. フィッシング詐欺の可能性（高/中/低）
2. 危険度（高/中/低）
3. 具体的な危険信号
4. 推奨される対応
5. 開封・返信の可否

回答は簡潔で分かりやすく、具体的な行動指針を含めてください。`;
        break;

      case 'website_analysis':
        prompt += `ウェブサイトの安全性を分析してください：
        
URL: ${content}
サイト内容: ${context?.description || 'なし'}

以下の点について分析してください：
1. 詐欺サイトの可能性（高/中/低）
2. 危険度（高/中/低）
3. 具体的な危険信号
4. 推奨される対応
5. 個人情報入力の可否

回答は簡潔で分かりやすく、具体的な行動指針を含めてください。`;
        break;

      case 'general_advice':
        prompt += `詐欺防止に関する一般的なアドバイスを提供してください：
        
質問内容: ${content}
状況: ${context || '一般的'}

以下の点について回答してください：
1. 具体的な防止策
2. 注意すべきポイント
3. 家族への相談のタイミング
4. 緊急時の連絡先

回答は親切で分かりやすく、具体的なアドバイスを含めてください。`;
        break;

      case 'emergency_guidance':
        prompt += `緊急時の対応について指導してください：
        
状況: ${content}
緊急度: ${context?.urgency || '高'}

以下の点について回答してください：
1. 即座に取るべき行動
2. 連絡すべき相手（家族、警察など）
3. 避けるべき行動
4. 今後の防止策

回答は簡潔で明確、具体的な行動指針を含めてください。`;
        break;

      default:
        return res.status(400).json({ error: 'Invalid analysis type' });
    }

    // Generate response
    const result = await model.generateContent(prompt);
    const response_text = result.response.text();

    // Parse response for structured data
    const analysis = {
      type: type,
      content: content,
      analysis: response_text,
      timestamp: new Date().toISOString(),
      userId: userId,
      riskLevel: extractRiskLevel(response_text),
      recommendations: extractRecommendations(response_text)
    };

    res.status(200).json(analysis);

  } catch (error) {
    console.error('Gemini API Error:', error);
    res.status(500).json({ 
      error: 'AI analysis failed', 
      details: error.message 
    });
  }
}

// Helper functions to extract structured data from AI response
function extractRiskLevel(text) {
  if (text.includes('危険度: 高') || text.includes('詐欺の可能性: 高')) {
    return 'high';
  } else if (text.includes('危険度: 中') || text.includes('詐欺の可能性: 中')) {
    return 'medium';
  } else {
    return 'low';
  }
}

function extractRecommendations(text) {
  const recommendations = [];
  const lines = text.split('\n');
  
  for (const line of lines) {
    if (line.includes('推奨') || line.includes('対応') || line.includes('行動')) {
      recommendations.push(line.trim());
    }
  }
  
  return recommendations.slice(0, 3); // Return top 3 recommendations
}
