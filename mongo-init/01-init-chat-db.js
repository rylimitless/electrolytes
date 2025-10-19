// MongoDB initialization script for n8n chat database
// This script runs when the MongoDB container starts for the first time

// Switch to the chat database
db = db.getSiblingDB('n8n_chat_db');

// Create collections
db.createCollection('n8n_chat_histories');

// Create indexes for n8n_chat_histories collection
db.n8n_chat_histories.createIndex(
  { "session_id": 1, "timestamp": 1 },
  { name: "session_timestamp_idx" }
);

db.n8n_chat_histories.createIndex(
  { "conversation_id": 1, "timestamp": 1 },
  { name: "conversation_timestamp_idx" }
);

db.n8n_chat_histories.createIndex(
  { "user_id": 1, "timestamp": 1 },
  { name: "user_timestamp_idx" }
);

db.n8n_chat_histories.createIndex(
  { "message_type": 1, "timestamp": 1 },
  { name: "type_timestamp_idx" }
);

db.n8n_chat_histories.createIndex(
  { "session_id": 1, "context_info.window_position": 1 },
  { name: "session_context_idx" }
);

// Create a unique index for message_id
db.n8n_chat_histories.createIndex(
  { "message_id": 1 },
  { unique: true, name: "message_id_unique_idx" }
);

// Create user for chat application
db.getSiblingDB('admin').createUser({
  user: 'n8n_chat_app',
  pwd: 'chatAppPass123',
  roles: [
    {
      role: 'readWrite',
      db: 'n8n_chat_db'
    }
  ]
});

print('Database initialization completed successfully!');
print('Created collections and indexes for n8n chat storage');
print('Created user: n8n_chat_app for chat application');