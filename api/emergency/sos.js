// In-memory storage (in production, use a database)
let emergencySettings = new Map();
let emergencyHistory = new Map();
let activeEmergencies = new Map();

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ error: 'User ID is required' });
  }

  try {
    switch (req.method) {
      case 'GET':
        return handleGet(req, res, userId);
      case 'POST':
        return handlePost(req, res, userId);
      case 'PUT':
        return handlePut(req, res, userId);
      default:
        return res.status(405).json({ error: 'Method not allowed' });
    }
  } catch (error) {
    console.error('Emergency SOS API Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}

async function handleGet(req, res, userId) {
  const { action } = req.query;

  switch (action) {
    case 'settings':
      const settings = emergencySettings.get(userId) || getDefaultSettings();
      res.status(200).json({ settings });
      break;

    case 'history':
      const history = emergencyHistory.get(userId) || [];
      res.status(200).json({ history });
      break;

    case 'active':
      const active = activeEmergencies.get(userId) || null;
      res.status(200).json({ active });
      break;

    case 'status':
      const status = {
        isEnabled: (emergencySettings.get(userId) || getDefaultSettings()).isEnabled,
        hasActiveEmergency: !!activeEmergencies.get(userId),
        lastTriggered: emergencyHistory.get(userId)?.[0]?.timestamp || null
      };
      res.status(200).json({ status });
      break;

    default:
      res.status(400).json({ error: 'Invalid action' });
  }
}

async function handlePost(req, res, userId) {
  const { action, data } = req.body;

  switch (action) {
    case 'trigger':
      return await handleEmergencyTrigger(req, res, userId, data);

    case 'update-settings':
      const currentSettings = emergencySettings.get(userId) || getDefaultSettings();
      const updatedSettings = { ...currentSettings, ...data };
      emergencySettings.set(userId, updatedSettings);
      res.status(200).json({ settings: updatedSettings });
      break;

    case 'add-contact':
      const settings = emergencySettings.get(userId) || getDefaultSettings();
      const newContact = {
        id: Date.now().toString(),
        name: data.name,
        phone: data.phone,
        relationship: data.relationship,
        isPrimary: data.isPrimary || false,
        createdAt: new Date().toISOString()
      };

      settings.contacts.push(newContact);
      emergencySettings.set(userId, settings);
      res.status(201).json({ contact: newContact });
      break;

    default:
      res.status(400).json({ error: 'Invalid action' });
  }
}

async function handlePut(req, res, userId) {
  const { action, data } = req.body;

  switch (action) {
    case 'update-contact':
      const settings = emergencySettings.get(userId) || getDefaultSettings();
      const contactIndex = settings.contacts.findIndex(c => c.id === data.id);
      
      if (contactIndex === -1) {
        return res.status(404).json({ error: 'Contact not found' });
      }

      settings.contacts[contactIndex] = { ...settings.contacts[contactIndex], ...data };
      emergencySettings.set(userId, settings);
      res.status(200).json({ contact: settings.contacts[contactIndex] });
      break;

    case 'resolve-emergency':
      const emergency = activeEmergencies.get(userId);
      if (!emergency) {
        return res.status(404).json({ error: 'No active emergency found' });
      }

      emergency.resolvedAt = new Date().toISOString();
      emergency.resolution = data.resolution || 'User resolved';

      const history = emergencyHistory.get(userId) || [];
      history.unshift(emergency);
      emergencyHistory.set(userId, history);
      activeEmergencies.delete(userId);

      res.status(200).json({ 
        message: 'Emergency resolved',
        emergency: emergency
      });
      break;

    default:
      res.status(400).json({ error: 'Invalid action' });
  }
}

async function handleEmergencyTrigger(req, res, userId, data) {
  const settings = emergencySettings.get(userId) || getDefaultSettings();
  
  if (!settings.isEnabled) {
    return res.status(400).json({ error: 'Emergency SOS is disabled' });
  }

  const emergency = {
    id: Date.now().toString(),
    userId: userId,
    triggerMethod: data.triggerMethod || 'manual',
    location: data.location || null,
    timestamp: new Date().toISOString(),
    status: 'active',
    contacts: settings.contacts,
    autoActions: settings.autoActions,
    resolvedAt: null,
    resolution: null
  };

  // Store active emergency
  activeEmergencies.set(userId, emergency);

  // Add to history
  const history = emergencyHistory.get(userId) || [];
  history.unshift(emergency);
  emergencyHistory.set(userId, history);

  // Execute auto actions
  const actions = await executeAutoActions(emergency, settings);

  // In a real app, you would:
  // 1. Send push notifications to emergency contacts
  // 2. Make emergency calls
  // 3. Send SMS messages
  // 4. Log to emergency services
  // 5. Send location data to family members

  res.status(200).json({
    emergency: emergency,
    actions: actions,
    message: 'Emergency SOS activated successfully'
  });
}

async function executeAutoActions(emergency, settings) {
  const actions = [];

  if (settings.autoActions.callEnabled) {
    actions.push({
      type: 'call',
      target: settings.contacts.find(c => c.isPrimary)?.phone || settings.contacts[0]?.phone,
      status: 'pending',
      timestamp: new Date().toISOString()
    });
  }

  if (settings.autoActions.messageEnabled) {
    actions.push({
      type: 'sms',
      target: settings.contacts.map(c => c.phone),
      message: settings.autoActions.customMessage || '緊急事態が発生しました。至急連絡してください。',
      status: 'pending',
      timestamp: new Date().toISOString()
    });
  }

  if (settings.autoActions.locationSharingEnabled && emergency.location) {
    actions.push({
      type: 'location_share',
      target: settings.contacts,
      location: emergency.location,
      status: 'pending',
      timestamp: new Date().toISOString()
    });
  }

  return actions;
}

function getDefaultSettings() {
  return {
    isEnabled: true,
    triggerMethod: 'button',
    contacts: [],
    autoActions: {
      callEnabled: true,
      messageEnabled: true,
      locationSharingEnabled: true,
      customMessage: '緊急事態が発生しました。至急連絡してください。'
    },
    quietHours: {
      enabled: false,
      startTime: '22:00',
      endTime: '07:00'
    }
  };
}
