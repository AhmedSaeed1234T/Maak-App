# Chat Backend Integration Checklist

## Your Backend Code Analysis ✅
Your C# ChatHub and ChatController implementation is **mostly correct**. Here's what we verified:

### ChatController Endpoints
- ✅ `GET /Chat/status/{userId}` - Returns online status
- ✅ `GET /Chat/online-users` - Returns list of online user IDs
- ✅ `GET /Chat/history/{targetUserId}` - Returns paginated message history with JWT user extraction

### ChatHub Methods
- ✅ `OnConnectedAsync()` - Broadcasts `UserStatusChanged` event with `[userId, "Online"]`
- ✅ `OnDisconnectedAsync()` - Broadcasts `UserStatusChanged` event with `[userId, "Offline"]`
- ✅ `SendMessage(receiverId, content)` - Sends `ReceiveMessage` event with `[senderId, content]`
- ✅ `DeleteMessage(messageId, receiverId)` - Sends `MessageDeleted` event
- ✅ `EditMessage(messageId, newContent, receiverId)` - Sends `MessageEdited` event

---

## ⚠️ CRITICAL ISSUES TO FIX

### 1. **IUserIdProvider Not Configured** 🔴 BLOCKING
Your backend uses `Clients.User(receiverId)` in SignalR, but SignalR needs a proper **IUserIdProvider** to map connection IDs to user IDs.

**In your `Startup.cs` or `Program.cs`, add:**

```csharp
// In ConfigureServices / builder.Services
services.AddSignalR();

// In Configure / app.MapHub
app.MapHub<ChatHub>("/chatHub", options =>
{
    options.CloseOnAuthenticationExpiration = true;
});

// CRITICAL: Add a custom UserIdProvider
// Create a file: Services/SignalRUserIdProvider.cs
public class SignalRUserIdProvider : IUserIdProvider
{
    public string? GetUserId(HubConnectionContext connection)
    {
        var userId = connection.User?.FindFirst("uid")?.Value;
        return userId;
    }
}

// Then register it:
services.AddSingleton<IUserIdProvider, SignalRUserIdProvider>();
```

**Why this matters:** Without this, `Clients.User(receiverId).SendAsync()` won't work because SignalR doesn't know which connection belongs to which user.

### 2. **Test Token Claim Name** 🟡 IMPORTANT
Your backend uses `User.FindFirst("uid")?.Value` and frontend looks for multiple claim names including `uid`.

**Verify your JWT token contains the `uid` claim:**
- Go to [jwt.io](https://jwt.io)
- Paste a sample token from your app
- Check the `payload` section contains `"uid": "user123"`

If it uses a different claim (like `sub`, `unique_name`), update the backend accordingly.

### 3. **User ID From Token Extraction** 🟡 IMPORTANT
Your code extracts `uid` from the token in **multiple places**:
- `ChatController.GetHistory()` - ✅ Correct
- `ChatHub.OnConnectedAsync()` - ✅ Correct
- Frontend also tries to extract it - ✅ Correct

Ensure **all three places use the same claim name**.

---

## Frontend Updates Applied ✅

Your Flutter frontend now handles:

1. **ReceiveMessage Event** - Format: `[senderId, content]`
   - ✅ Handler added to parse and display incoming messages

2. **MessageDeleted Event** - Format: `[messageId]`
   - ✅ Handler added to remove deleted messages from UI

3. **MessageEdited Event** - Format: `[messageId, newContent]`
   - ✅ Handler added to update edited messages in UI

4. **Delete & Edit UI** - Long-press on messages
   - ✅ Delete messages via `deleteMessage(messageId, receiverId)`
   - ✅ Edit messages via `editMessage(messageId, newContent, receiverId)`

5. **Online Status** - Fetched and tracked
   - ✅ PresenceController handles `UserStatusChanged` event

---

## How Message Flow Works Now

### Sending a Message:
1. User types message and taps "Send"
2. Frontend calls `SendMessage(receiverId, content)` via SignalR
3. **Sender's** message appears immediately in UI (optimistic)
4. Backend saves to MongoDB
5. Backend calls `Clients.User(receiverId).SendAsync("ReceiveMessage", senderId, content)`
6. **Receiver** gets the message via `ReceiveMessage` event listener

### Deleting a Message:
1. User long-presses message
2. Frontend calls `DeleteMessage(messageId, receiverId)` via SignalR
3. **Sender's** message removed immediately (optimistic)
4. Backend deletes from MongoDB (only if sender matches)
5. Backend calls both users' `MessageDeleted` event
6. **Receiver's** message disappears

### Editing a Message:
1. User long-presses message → "Edit"
2. Frontend calls `EditMessage(messageId, newContent, receiverId)` via SignalR
3. **Sender's** message updated immediately (optimistic)
4. Backend updates MongoDB (only if sender matches)
5. Backend calls both users' `MessageEdited` event
6. **Receiver's** message updates

---

## Testing Checklist

### Step 1: Fix Backend
- [ ] Add `IUserIdProvider` implementation
- [ ] Register `IUserIdProvider` in DI
- [ ] Verify JWT token has `uid` claim
- [ ] Test with Postman: GET `/api/v1/Chat/online-users` returns user IDs

### Step 2: Run Frontend
- [ ] Restart app with `flutter run`
- [ ] Check console for "SignalR Connected successfully"
- [ ] Look for "SignalR: Received raw arguments:" messages when receiving messages

### Step 3: Test Chat
- [ ] Open chat between two test users
- [ ] Send a message from User A
- [ ] Verify it appears in User B's chat immediately
- [ ] Verify it appears in User A's chat (if echoed back) or after refresh
- [ ] Test long-press delete/edit
- [ ] Check online status updates when users connect/disconnect

### Step 4: Check Logs
- [ ] Frontend: Look for "SignalR:" debug messages
- [ ] Backend: Check IIS/app logs for any SignalR connection errors
- [ ] Backend: Verify MongoDB saves messages correctly

---

## Common Issues & Solutions

### "Cannot send message, not connected"
- SignalR connection failed
- Check: Is `https://egyptonlinema3ak.com/chatHub` accessible?
- Check: Is JWT token valid? (expires)
- Check: Is backend running?

### Messages don't appear in receiver's chat
- Missing `IUserIdProvider` (most likely)
- Check: Does `Clients.User(receiverId)` have a mapping?
- Check: MongoDB write succeeded

### Online users list stays empty
- GET `/Chat/online-users` endpoint might be failing
- Check: API response in browser (with auth header)
- Check: PresenceService.GetOnlineUsers() implementation

### "uid claim not found" errors
- JWT token uses different claim name
- Update backend to look for correct claim: `sub`, `nameid`, `unique_name`, etc.
- Update frontend token parsing to match

---

## Next Steps

1. **Fix the IUserIdProvider first** - This is blocking everything
2. **Run the app and check console logs** - Send me the "SignalR:" debug messages
3. **Test message sending** - Verify it reaches the backend
4. **Test message receiving** - Verify receiver gets the event
5. **Share backend logs** - If anything fails, I need the backend error messages

**Send me:**
- ✅ Your updated `Startup.cs` or `Program.cs` with IUserIdProvider
- ✅ Console logs from Flutter when you send a message
- ✅ Backend logs if message doesn't reach receiver
- ✅ Sample JWT token payload (just the decoded part)
