# Continuation: Django Blog Platform

**Date:** 2026-02-18
**Working directory:** /dev/projects/blog-platform

---

## What This Project Is

A multi-tenant Django blog platform with real-time collaboration. Users create blogs, write posts, and collaborate with other writers in real-time. Built on Django 4.2, PostgreSQL, Redis, and WebSockets via Django Channels.

## Tech Stack

- Python 3.11
- Django 4.2 with Django REST Framework
- PostgreSQL 15 with pgvector for semantic search
- Redis for caching and message queues
- Django Channels for WebSocket real-time features
- React 18 (frontend)
- Docker + Docker Compose (development)
- Pytest for testing

## How to Build & Run

```bash
docker-compose up -d postgres redis
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python manage.py migrate
python manage.py runserver
```

## Key Files

| File | Purpose |
|------|---------|
| blog/models.py | Post, Blog, User models |
| blog/views.py | CRUD and real-time endpoints |
| chat/consumers.py | WebSocket consumers |

## What Was Just Done (Most Recent Session)

### Fixed WebSocket Keepalive Issue
Real-time collaboration was disconnecting after 10 minutes. Added heartbeat: client pings every 5 minutes, server responds with pong. Prevents NAT timeout.

### Fixed Search Ranking Inconsistency
Embeddings were from two model versions. Updated all embeddings and set `embedding_model_version` field. Migration took ~2 hours on prod (547k posts).

## Current State

**Working:**
- User authentication (OAuth2 + JWT)
- Blog creation and multi-author management
- Post CRUD with rich text editor
- Basic semantic search
- Real-time presence indicators
- Email notifications for mentions

**Broken / Known Issues:**
- WebSocket disconnects after 10 minutes idle (needs keepalive—fixed in code, deploying)
- File upload fails on files >10MB (S3 multipart not implemented)

**In Progress:**
- CRDT-based collaborative editing
- Async Django views migration
- Monitoring and alerting setup

## Pending Tasks

1. Implement CRDT-based collaborative editing (review Yjs vs Automerge)
2. Convert 10 high-traffic views to async Django
3. Set up alerting for WebSocket disconnects
4. Security audit of API endpoints

## Key Technical Decisions

- Chose CRDT over OT for editing—scales to many editors without central authority
- pgvector for semantic search instead of Elasticsearch—one fewer service
- Rate limiting at DRF view level instead of nginx—per-user customization

## Gotchas & Traps

**WebSocket NAT Timeout**
Idle connections drop after 10 minutes (NAT timeout, not Django).
**Solution:** Heartbeat pings every 5 minutes.
**Lesson:** Always add keepalive to long-lived connections.

**PostgreSQL ENUM Types Can't Be Altered**
Tried to add enum value, got "ERROR: cannot add enum value".
**Solution:** Create new type, update columns, drop old type.
**Lesson:** Avoid ENUM unless values are immutable; use string + constraints.

## How to Deploy

```bash
docker build -t blog-platform:staging .
docker-compose -f docker-compose.staging.yml up -d
```
