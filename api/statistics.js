// In-memory storage (in production, use a database)
let securityEvents = new Map();
let userStatistics = new Map();
let achievements = new Map();

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  const { userId } = req.method === 'GET' ? req.query : req.body;

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    switch (req.method) {
      case 'GET':
        return handleGet(req, res, userId);
      case 'POST':
        return handlePost(req, res, userId);
      default:
        return res.status(405).json({ error: 'Method not allowed' });
    }
  } catch (error) {
    console.error('Statistics API Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}

async function handleGet(req, res, userId) {
  const { action, period = 'week' } = req.query;

  switch (action) {
    case 'overview':
      const overview = await generateOverview(userId, period);
      res.status(200).json(overview);
      break;

    case 'trends':
      const trends = await generateTrends(userId, period);
      res.status(200).json(trends);
      break;

    case 'detailed':
      const detailed = await generateDetailedStats(userId, period);
      res.status(200).json(detailed);
      break;

    case 'achievements':
      const userAchievements = achievements.get(userId) || [];
      res.status(200).json({ achievements: userAchievements });
      break;

    case 'recommendations':
      const recommendations = await generateRecommendations(userId);
      res.status(200).json({ recommendations });
      break;

    default:
      res.status(400).json({ error: 'Invalid action' });
  }
}

async function handlePost(req, res, userId) {
  const { action, data } = req.body;

  switch (action) {
    case 'log-event':
      const event = {
        id: Date.now().toString(),
        userId: userId,
        type: data.type,
        severity: data.severity,
        description: data.description,
        timestamp: new Date().toISOString(),
        resolved: data.resolved || false,
        aiAnalysis: data.aiAnalysis || null
      };

      const events = securityEvents.get(userId) || [];
      events.push(event);
      securityEvents.set(userId, events);

      // Update statistics
      await updateStatistics(userId, event);

      res.status(201).json({ event });
      break;

    case 'update-achievement':
      const userAchievements = achievements.get(userId) || [];
      const achievement = {
        id: data.id,
        name: data.name,
        description: data.description,
        category: data.category,
        unlockedAt: new Date().toISOString(),
        progress: data.progress || 100
      };

      const existingIndex = userAchievements.findIndex(a => a.id === data.id);
      if (existingIndex !== -1) {
        userAchievements[existingIndex] = achievement;
      } else {
        userAchievements.push(achievement);
      }

      achievements.set(userId, userAchievements);
      res.status(200).json({ achievement });
      break;

    default:
      res.status(400).json({ error: 'Invalid action' });
  }
}

async function generateOverview(userId, period) {
  const events = securityEvents.get(userId) || [];
  const periodStart = getPeriodStart(period);
  const periodEvents = events.filter(e => new Date(e.timestamp) >= periodStart);

  const totalEvents = periodEvents.length;
  const highRiskEvents = periodEvents.filter(e => e.severity === 'high').length;
  const resolvedEvents = periodEvents.filter(e => e.resolved).length;

  const protectionScore = calculateProtectionScore(periodEvents);
  const trend = calculateTrend(events, period);

  return {
    period: period,
    protectionScore: protectionScore,
    totalEvents: totalEvents,
    highRiskEvents: highRiskEvents,
    resolvedEvents: resolvedEvents,
    trend: trend,
    lastUpdated: new Date().toISOString()
  };
}

async function generateTrends(userId, period) {
  const events = securityEvents.get(userId) || [];
  const periodStart = getPeriodStart(period);
  const periodEvents = events.filter(e => new Date(e.timestamp) >= periodStart);

  // Group events by day
  const dailyStats = {};
  periodEvents.forEach(event => {
    const date = new Date(event.timestamp).toDateString();
    if (!dailyStats[date]) {
      dailyStats[date] = {
        total: 0,
        high: 0,
        medium: 0,
        low: 0
      };
    }
    dailyStats[date].total++;
    dailyStats[date][event.severity]++;
  });

  const trends = Object.entries(dailyStats).map(([date, stats]) => ({
    date: date,
    total: stats.total,
    high: stats.high,
    medium: stats.medium,
    low: stats.low
  }));

  return {
    period: period,
    trends: trends,
    summary: {
      totalDays: trends.length,
      averageEventsPerDay: trends.reduce((sum, day) => sum + day.total, 0) / trends.length || 0
    }
  };
}

async function generateDetailedStats(userId, period) {
  const events = securityEvents.get(userId) || [];
  const periodStart = getPeriodStart(period);
  const periodEvents = events.filter(e => new Date(e.timestamp) >= periodStart);

  const eventTypes = {};
  const severityBreakdown = { high: 0, medium: 0, low: 0 };
  const resolutionTime = [];

  periodEvents.forEach(event => {
    // Event types
    eventTypes[event.type] = (eventTypes[event.type] || 0) + 1;
    
    // Severity breakdown
    severityBreakdown[event.severity]++;
    
    // Resolution time for resolved events
    if (event.resolved) {
      const created = new Date(event.timestamp);
      const resolved = new Date(event.resolvedAt || event.timestamp);
      resolutionTime.push(resolved - created);
    }
  });

  const averageResolutionTime = resolutionTime.length > 0 
    ? resolutionTime.reduce((sum, time) => sum + time, 0) / resolutionTime.length 
    : 0;

  return {
    period: period,
    eventTypes: eventTypes,
    severityBreakdown: severityBreakdown,
    averageResolutionTime: averageResolutionTime,
    totalEvents: periodEvents.length,
    resolvedEvents: periodEvents.filter(e => e.resolved).length,
    unresolvedEvents: periodEvents.filter(e => !e.resolved).length
  };
}

async function generateRecommendations(userId) {
  const events = securityEvents.get(userId) || [];
  const recentEvents = events.filter(e => 
    new Date(e.timestamp) >= new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
  );

  const recommendations = [];

  // Analyze patterns and generate recommendations
  const highRiskCount = recentEvents.filter(e => e.severity === 'high').length;
  if (highRiskCount > 2) {
    recommendations.push({
      type: 'safety',
      priority: 'high',
      title: '高リスクイベントが増加しています',
      description: '最近の高リスクイベントが増加しています。家族に相談することをお勧めします。',
      action: '家族に相談する'
    });
  }

  const unresolvedCount = recentEvents.filter(e => !e.resolved).length;
  if (unresolvedCount > 0) {
    recommendations.push({
      type: 'action',
      priority: 'medium',
      title: '未解決のイベントがあります',
      description: `${unresolvedCount}件の未解決イベントがあります。確認をお勧めします。`,
      action: 'イベントを確認する'
    });
  }

  const callScamCount = recentEvents.filter(e => e.type === 'call_scam').length;
  if (callScamCount > 0) {
    recommendations.push({
      type: 'education',
      priority: 'medium',
      title: '電話詐欺の対策を強化',
      description: '電話詐欺のイベントが発生しています。不審な電話には注意してください。',
      action: '対策を確認する'
    });
  }

  return recommendations;
}

async function updateStatistics(userId, event) {
  const stats = userStatistics.get(userId) || {
    totalEvents: 0,
    highRiskEvents: 0,
    resolvedEvents: 0,
    lastEventDate: null
  };

  stats.totalEvents++;
  if (event.severity === 'high') {
    stats.highRiskEvents++;
  }
  if (event.resolved) {
    stats.resolvedEvents++;
  }
  stats.lastEventDate = event.timestamp;

  userStatistics.set(userId, stats);
}

function calculateProtectionScore(events) {
  if (events.length === 0) return 100;

  const highRiskEvents = events.filter(e => e.severity === 'high').length;
  const resolvedEvents = events.filter(e => e.resolved).length;
  const totalEvents = events.length;

  let score = 100;
  score -= highRiskEvents * 10; // High risk events reduce score
  score += resolvedEvents * 5; // Resolved events increase score
  score = Math.max(0, Math.min(100, score)); // Clamp between 0-100

  return Math.round(score);
}

function calculateTrend(events, period) {
  if (events.length < 2) return 'stable';

  const periodStart = getPeriodStart(period);
  const recentEvents = events.filter(e => new Date(e.timestamp) >= periodStart);
  const olderEvents = events.filter(e => new Date(e.timestamp) < periodStart);

  const recentCount = recentEvents.length;
  const olderCount = olderEvents.length;

  if (recentCount > olderCount * 1.5) return 'increasing';
  if (recentCount < olderCount * 0.7) return 'decreasing';
  return 'stable';
}

function getPeriodStart(period) {
  const now = new Date();
  switch (period) {
    case 'day':
      return new Date(now.getFullYear(), now.getMonth(), now.getDate());
    case 'week':
      return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    case 'month':
      return new Date(now.getFullYear(), now.getMonth(), 1);
    case 'year':
      return new Date(now.getFullYear(), 0, 1);
    default:
      return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  }
}
