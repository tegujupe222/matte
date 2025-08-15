// In-memory storage (in production, use a database)
let familyMembers = new Map();
let locationData = new Map();
let emergencyContacts = new Map();

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
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
      case 'PUT':
        return handlePut(req, res, userId);
      case 'DELETE':
        return handleDelete(req, res, userId);
      default:
        return res.status(405).json({ error: 'Method not allowed' });
    }
  } catch (error) {
    console.error('Family Connection API Error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}

async function handleGet(req, res, userId) {
  const { action } = req.query;

  switch (action) {
    case 'members':
      const members = familyMembers.get(userId) || [];
      res.status(200).json({ members });
      break;

    case 'location':
      const location = locationData.get(userId) || null;
      res.status(200).json({ location });
      break;

    case 'emergency-contacts':
      const contacts = emergencyContacts.get(userId) || [];
      res.status(200).json({ contacts });
      break;

    case 'status':
      const memberStatus = Array.from(familyMembers.get(userId) || []).map(member => ({
        id: member.id,
        name: member.name,
        isOnline: Math.random() > 0.3, // Mock online status
        lastSeen: new Date(Date.now() - Math.random() * 86400000).toISOString() // Mock last seen
      }));
      res.status(200).json({ status: memberStatus });
      break;

    default:
      res.status(400).json({ error: 'Invalid action' });
  }
}

async function handlePost(req, res, userId) {
  const { action, data } = req.body;

  switch (action) {
    case 'add-member':
      const newMember = {
        id: Date.now().toString(),
        name: data.name,
        phone: data.phone,
        email: data.email,
        relationship: data.relationship,
        isEmergencyContact: data.isEmergencyContact || false,
        createdAt: new Date().toISOString()
      };

      const members = familyMembers.get(userId) || [];
      members.push(newMember);
      familyMembers.set(userId, members);

      if (newMember.isEmergencyContact) {
        const contacts = emergencyContacts.get(userId) || [];
        contacts.push(newMember);
        emergencyContacts.set(userId, contacts);
      }

      res.status(201).json({ member: newMember });
      break;

    case 'update-location':
      const location = {
        latitude: data.latitude,
        longitude: data.longitude,
        timestamp: new Date().toISOString(),
        accuracy: data.accuracy || 10
      };
      locationData.set(userId, location);
      res.status(200).json({ location });
      break;

    case 'share-location':
      const targetUserId = data.targetUserId;
      const userLocation = locationData.get(userId);
      
      if (!userLocation) {
        return res.status(404).json({ error: 'Location not found' });
      }

      // In a real app, you would send a push notification here
      res.status(200).json({ 
        message: 'Location shared successfully',
        location: userLocation
      });
      break;

    default:
      res.status(400).json({ error: 'Invalid action' });
  }
}

async function handlePut(req, res, userId) {
  const { action, data } = req.body;

  switch (action) {
    case 'update-member':
      const members = familyMembers.get(userId) || [];
      const memberIndex = members.findIndex(m => m.id === data.id);
      
      if (memberIndex === -1) {
        return res.status(404).json({ error: 'Member not found' });
      }

      members[memberIndex] = { ...members[memberIndex], ...data };
      familyMembers.set(userId, members);

      // Update emergency contacts if needed
      if (data.isEmergencyContact !== undefined) {
        const contacts = emergencyContacts.get(userId) || [];
        if (data.isEmergencyContact) {
          if (!contacts.find(c => c.id === data.id)) {
            contacts.push(members[memberIndex]);
          }
        } else {
          const contactIndex = contacts.findIndex(c => c.id === data.id);
          if (contactIndex !== -1) {
            contacts.splice(contactIndex, 1);
          }
        }
        emergencyContacts.set(userId, contacts);
      }

      res.status(200).json({ member: members[memberIndex] });
      break;

    default:
      res.status(400).json({ error: 'Invalid action' });
  }
}

async function handleDelete(req, res, userId) {
  const { action, memberId } = req.query;

  switch (action) {
    case 'remove-member':
      const members = familyMembers.get(userId) || [];
      const memberIndex = members.findIndex(m => m.id === memberId);
      
      if (memberIndex === -1) {
        return res.status(404).json({ error: 'Member not found' });
      }

      const removedMember = members.splice(memberIndex, 1)[0];
      familyMembers.set(userId, members);

      // Remove from emergency contacts if present
      const contacts = emergencyContacts.get(userId) || [];
      const contactIndex = contacts.findIndex(c => c.id === memberId);
      if (contactIndex !== -1) {
        contacts.splice(contactIndex, 1);
        emergencyContacts.set(userId, contacts);
      }

      res.status(200).json({ message: 'Member removed successfully', member: removedMember });
      break;

    default:
      res.status(400).json({ error: 'Invalid action' });
  }
}
