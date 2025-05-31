
# 🧠 Business Logic Vulnerability (BLV) Checklist

> This checklist helps identify logic flaws in web applications and APIs by breaking business assumptions or workflows. Designed for bug bounty hunters who want to find high-impact vulnerabilities beyond common CVEs.

---

## 🔐 Authentication & Authorization Logic

- [ ] Bypass login via unvalidated token, cookie, or session  
- [ ] Access authenticated endpoints without proper session/cookie  
- [ ] Use another user's token or session across accounts  
- [ ] Reuse password reset token after use  
- [ ] Skip or repeat 2FA/OTP steps to bypass  
- [ ] Register/login using `role=admin` or similar tampering  
- [ ] Change `user_id`, `email`, `username` to access other accounts  
- [ ] Attempt admin actions from a normal account via the API  
- [ ] Attempt impersonation via `X-User-ID`, `X-Forwarded-User`  
- [ ] Test across web, mobile, and API for role discrepancies  

---

## 💰 Payment, Pricing, Discounts

- [ ] Modify `price`, `amount`, `currency`, `total` during checkout  
- [ ] Apply expired or invalid coupons  
- [ ] Combine coupons in unintended ways  
- [ ] Remove items after applying discount, keep discount applied  
- [ ] Manipulate `item_id`, `order_id`, `subscription_id`  
- [ ] Tamper `plan=basic` → `plan=premium` in API requests  
- [ ] Access paid features without completing payment  
- [ ] Cancel or refund after digital delivery (e.g., PDF, video)  
- [ ] Check if invoice/receipts are issued before actual payment  
- [ ] Alter payment gateway status manually or replay it  
- [ ] Simulate successful transaction via webhook tampering  

---

## 🧭 Workflow Bypass & Step Skipping

- [ ] Skip steps in multi-step flows (checkout, onboarding, KYC)  
- [ ] Submit final step without completing earlier ones  
- [ ] Replay or loop earlier steps (e.g., multiple coupon applications)  
- [ ] Bypass form wizard or client-side disabled fields  
- [ ] Resend registration step to re-trigger a bonus/referral  
- [ ] Skip captcha/OTP via mobile APIs or direct POST  
- [ ] Complete actions before accepting ToS/agreements  
- [ ] Break out of expected workflow order (e.g., refund before pay)  

---

## 👥 User Roles, Access Tiers, Subscriptions

- [ ] Elevate role via tampering: `user` → `admin`, `moderator`, etc.  
- [ ] Access features behind paid plans by altering `plan`, `subscription`, or headers  
- [ ] Compare response differences between roles (diff HTTP status, fields)  
- [ ] Bypass "read-only" restrictions on trial accounts  
- [ ] Inject new roles into requests (`"role": "admin"`)  
- [ ] Access staff or internal endpoints via API fuzzing  
- [ ] Perform admin actions by modifying form parameters or API  

---

## 📈 Abuse of Referrals, Rewards, Points

- [ ] Create multiple accounts to abuse referral or bonus  
- [ ] Use your own referral code during signup  
- [ ] Apply same referral multiple times (e.g., resend code)  
- [ ] Refer yourself with variations in email/phone  
- [ ] Claim time-based rewards early via date tampering  
- [ ] Earn points without completing required action  
- [ ] Test for unlimited daily rewards (e.g., daily login, spin wheel)  

---

## 💳 Wallets, Balances, Credits

- [ ] Withdraw more than available balance  
- [ ] Transfer credits to another account without permission  
- [ ] Use negative amounts to manipulate wallet  
- [ ] Replay wallet transaction requests  
- [ ] Tamper `wallet_id`, `credit_id`, or `balance` fields  
- [ ] Test race conditions on withdraw/deposit endpoints  
- [ ] Check if `balance` is updated after failed transactions  

---

## 📤 File Upload & Import Logic

- [ ] Upload malicious filenames (`../../../etc/passwd`, `%00`, etc.)  
- [ ] Upload to another user's account  
- [ ] Change `owner_id` or `project_id` during upload  
- [ ] Import CSV/XML with external URLs (SSRF or open redirect)  
- [ ] Overwrite someone else’s file by guessing ID or path  
- [ ] Upload overly large files to break quotas  
- [ ] Upload via mobile API when web restricts types  

---

## 🔁 Rate-Limiting, Abuse, Replay

- [ ] Bruteforce login, reset, or verification without throttling  
- [ ] Send 100+ password reset requests to victim  
- [ ] Claim reward or bonus multiple times by spamming  
- [ ] Bypass email/SMS rate-limits using parallel requests  
- [ ] Submit same form/request repeatedly to gain advantage  
- [ ] Replay POST requests that trigger sensitive actions  

---

## 🕸️ API and Web/Mobile Discrepancies

- [ ] Compare API and Web behavior — do they enforce the same checks?  
- [ ] Mobile apps often miss server-side validation — test API directly  
- [ ] Tamper with mobile API headers (e.g., `platform`, `version`, `auth_type`)  
- [ ] Isolate API endpoints not linked in the UI but accessible  

---

## 🧪 Advanced Business Logic Scenarios

- [ ] Buy low, sell high abuse (e.g., swap currency at stale rates)  
- [ ] Send referral link after purchase to claim retroactive bonuses  
- [ ] Start paid subscription, cancel immediately, still keep access  
- [ ] Upgrade to premium, perform action, downgrade, check if action persists  
- [ ] Start action in one browser/tab, complete in another (session tampering)  
- [ ] Chain multiple flows across roles (e.g., buyer creates admin action)  
- [ ] Use JS-injected requests to invoke hidden features  
- [ ] Claim expired or one-time-only offer via URL tampering  

---

## 🧩 Misc & Creative Attacks

- [ ] Exploit logic in chat, messaging, or comment systems  
- [ ] Abuse voting, ranking, leaderboard logic  
- [ ] Publish unapproved or hidden content via preview endpoints  
- [ ] Delete or modify content not owned by user  
- [ ] Trigger actions through webhook replay  
- [ ] Test business logic through time-based manipulation (e.g., timezones, expired)  

---

## 🚨 Red Flags = Potential Business Logic Flaws

Look out for:
- Parameters like `role`, `plan`, `user_id`, `referrer`, `price`, `discount`, `amount`, `credits`  
- Multi-step flows with unique tokens or unverified steps  
- Mobile APIs that trust client-side info  
- Lack of integrity checks for critical values  
- Internal features "hidden" in frontend but exposed via API  
- Differences between POST, PUT, PATCH behavior  

---

## ✅ Suggested Tools & Techniques

- Burp Suite (with Turbo Intruder, Repeater, Comparer)  
- Postman or custom scripts for API testing  
- ffuf or Go-based concurrency scripts for race/replay  
- Proxy with custom header manipulation  
- Account automation (2–3 test users to simulate flows)  


---

# 📦 Example Requests (BLV Examples)

These examples show how you might test for or discover logic flaws in APIs or web apps.

---

## 🔐 Authentication Bypass

**Bypass Login with Reused Token**
```http
GET /dashboard HTTP/1.1
Host: target.com
Cookie: session=eyJ1c2VyX2lkIjoxLCJyb2xlIjoiYWRtaW4ifQ==   <-- hardcoded or reused token
```

---

## 💰 Price Tampering

**Tamper Checkout Price**
```http
POST /api/checkout HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "item_id": "12345",
  "price": "0.01",  // original was 999.99
  "quantity": 1
}
```

---

## 🧭 Skip Workflow Step

**Skip KYC Step**
```http
POST /api/verify/final-step HTTP/1.1
Host: target.com
Authorization: Bearer <token>

{
  "agree_terms": true,
  "signature": "signed_payload"
}
```
> Sent without completing step-1 and step-2 (e.g., identity upload).

---

## 👥 Role Escalation

**Change Role from User to Admin**
```http
PUT /api/user/update HTTP/1.1
Host: target.com
Authorization: Bearer <token>
Content-Type: application/json

{
  "user_id": 104,
  "role": "admin"
}
```

---

## 📈 Referral Abuse

**Reuse Referral Code**
```http
POST /api/signup HTTP/1.1
Host: target.com
Content-Type: application/json

{
  "email": "testuser2@example.com",
  "referral": "ref123456"
}
```
> Attempt this repeatedly across accounts with slight email variations.

---

## 💳 Wallet Race Condition

**Simultaneous Withdrawals**
```http
POST /api/wallet/withdraw HTTP/1.1
Host: target.com
Authorization: Bearer <token>

{
  "amount": 100
}
```
> Send 10+ requests concurrently using Turbo Intruder or a custom script.

---

## 📤 File Upload Ownership Bypass

**Upload to Another User’s Project**
```http
POST /api/upload HTTP/1.1
Host: target.com
Authorization: Bearer <token>
Content-Type: multipart/form-data

--boundary
Content-Disposition: form-data; name="file"; filename="malicious.pdf"
Content-Type: application/pdf

%PDF-1.4
... file data ...
--boundary
Content-Disposition: form-data; name="project_id"

987  <-- belongs to another user
--boundary--
```

---

## 🔁 Replay Attack

**Replay Purchase Confirmation**
```http
POST /api/purchase/confirm HTTP/1.1
Host: target.com
Authorization: Bearer <token>
Content-Type: application/json

{
  "transaction_id": "abc123"
}
```
> Replaying this may allow downloading paid content twice or more.

---

## 🧪 Premium Downgrade Logic

**Use Premium Feature Post Downgrade**
```http
POST /api/ai/generate HTTP/1.1
Host: target.com
Authorization: Bearer <token>

{
  "prompt": "Generate business report"
}
```
> Try after downgrading from Premium to Free — should be blocked.

---

## 🕸️ Mobile API Behavior

**Access Mobile-Only Endpoint**
```http
GET /api/mobile/features HTTP/1.1
Host: target.com
Authorization: Bearer <token>
User-Agent: Mobile-iOS/9.2.3

```
> May expose internal/test features not shown in the web version.

