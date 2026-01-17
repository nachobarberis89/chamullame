import crypto from 'node:crypto';
import express from 'express';
import { WebSocketServer } from 'ws';

const app = express();
app.use(express.json());

const sessions = new Map();
const participants = new Map();

function buildAlias(id) {
  return `Persona ${id}`;
}

app.post('/sessions', (req, res) => {
  const { eventCode } = req.body;
  if (!eventCode) {
    return res.status(400).json({ error: 'eventCode_required' });
  }

  const sessionId = crypto.randomUUID();
  sessions.set(sessionId, {
    id: sessionId,
    eventCode,
    createdAt: Date.now(),
  });

  return res.status(201).json({ sessionId });
});

app.post('/participants', (req, res) => {
  const { sessionId } = req.body;
  if (!sessionId || !sessions.has(sessionId)) {
    return res.status(404).json({ error: 'session_not_found' });
  }

  const participantId = crypto.randomUUID();
  const alias = buildAlias(participants.size + 1);
  const participant = {
    id: participantId,
    sessionId,
    alias,
    status: 'Disponible',
    joinedAt: Date.now(),
  };
  participants.set(participantId, participant);

  return res.status(201).json(participant);
});

app.get('/participants', (req, res) => {
  const { sessionId } = req.query;
  const list = Array.from(participants.values()).filter((participant) => {
    return !sessionId || participant.sessionId === sessionId;
  });

  return res.json({ participants: list });
});

app.delete('/participants/:id', (req, res) => {
  const { id } = req.params;
  participants.delete(id);
  return res.status(204).send();
});

const server = app.listen(8080, () => {
  console.log('Fono Chat server running on port 8080');
});

const wss = new WebSocketServer({ server });

wss.on('connection', (socket) => {
  socket.on('message', (raw) => {
    let payload;
    try {
      payload = JSON.parse(raw.toString());
    } catch (error) {
      socket.send(JSON.stringify({ type: 'error', message: 'invalid_json' }));
      return;
    }

    if (payload.type === 'status:update') {
      const participant = participants.get(payload.participantId);
      if (participant) {
        participant.status = payload.status;
        participants.set(participant.id, participant);
      }
    }

    if (payload.type === 'call:signal') {
      wss.clients.forEach((client) => {
        if (client.readyState === client.OPEN) {
          client.send(JSON.stringify(payload));
        }
      });
    }
  });

  socket.send(
    JSON.stringify({
      type: 'welcome',
      message: 'Conectado al servidor local de Fono Chat.',
    })
  );
});
