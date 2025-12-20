#!/bin/bash

# Debug script for cart persistence issue
echo "🔍 Cart Persistence Debug Script"
echo "=================================="
echo ""

# Check if app is running
echo "1. Checking flutter process..."
if pgrep -f "flutter run" > /dev/null; then
    echo "   ✅ Flutter app is running"
else
    echo "   ❌ Flutter app is NOT running"
    echo "   Run: flutter run"
    exit 1
fi

echo ""
echo "2. Recent console output (last 50 lines):"
echo "   (Look for cart-related logs)"
echo "   ----------------------------------------"

# This won't work if terminal output is not captured
# But let's provide instructions

echo ""
echo "📋 TESTING INSTRUCTIONS:"
echo "=================================="
echo ""
echo "Step 1: RESTART the app (HOT RELOAD WON'T WORK!)"
echo "   Press 'R' in the flutter run terminal"
echo "   Or stop and run: flutter run"
echo ""
echo "Step 2: Login with a test user"
echo "   Watch console for: '🛒 CartProvider created for user: ...'"
echo ""
echo "Step 3: Add an item to cart"
echo "   Watch console for:"
echo "   - '➕ Adding to cart: ...'"
echo "   - '✅ Saved to Firestore: ...'"
echo ""
echo "Step 4: Check Firebase Console"
echo "   Go to: Firestore Database → users → {userId} → cart"
echo "   Should see the item document"
echo ""
echo "Step 5: Logout"
echo "   Watch console for: '👋 User logged out - disposing CartProvider'"
echo ""
echo "Step 6: Login again with SAME user"
echo "   Watch console for:"
echo "   - '🛒 CartProvider created for user: ...'"
echo "   - '📥 Loading cart from Firestore...'"
echo "   - '✅ Cart loaded: X items'"
echo ""
echo "❓ If you DON'T see these logs:"
echo "   → App was not restarted properly"
echo "   → Changes not loaded"
echo "   → Need to stop and restart flutter run"
echo ""
echo "❓ If logs show but cart still empty:"
echo "   → Share the console output"
echo "   → Check Firestore security rules"
echo "   → Check if data exists in Firestore"
