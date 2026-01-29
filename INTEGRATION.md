# Backend Integration Guide

## Overview
Your Flutter app is now fully integrated with your Node.js/Express backend and MongoDB database.

## Backend Structure

### API Endpoints

#### Courses
- `GET /api/courses` - Fetch all courses
- `GET /api/courses/:id` - Fetch single course by ID
- `POST /api/courses` - Create a new course
- `PUT /api/courses/:id` - Update a course
- `DELETE /api/courses/:id` - Delete a course

#### Categories
- `GET /api/categories` - Fetch all categories
- `POST /api/categories` - Create a new category
- `PUT /api/categories/:id` - Update a category
- `DELETE /api/categories/:id` - Delete a category

### Data Models

#### Course Schema
```javascript
{
  title: String,
  category: String,
  description: String,
  seriesThumbnail: String,
  tag: String (default: 'New'),
  rating: Number (default: 4.5),
  reviewsCount: Number (default: 0),
  isFree: Boolean (default: true),
  episodes: [Episode],
  createdAt: Date
}
```

#### Episode Schema
```javascript
{
  title: String,
  duration: String,
  date: String (default: 'Today'),
  videoUrl: String,
  thumbnailUrl: String,
  isNew: Boolean (default: false),
  order: Number (default: 0)
}
```

#### Category Schema
```javascript
{
  label: String,
  icon: String,
  color: String (default: 'blue'),
  order: Number (default: 0)
}
```

## Flutter App Integration

### Models Created
- `lib/models/course.dart` - Course and Episode models
- `lib/models/category.dart` - Category model

### API Service
- `lib/services/api_service.dart` - Complete API service with all CRUD operations

### Configuration
- `lib/utils/config.dart` - Centralized configuration for API URL and app settings
- `.env` - Environment variables (not committed to git)

### Updated Screens
- `lib/screens/home_screen.dart` - Updated to use Category model instead of Map

## How to Run

### 1. Start the Backend Server
```bash
cd Backend
npm install
npm run dev
```

The server will run on `http://localhost:5000` by default.

### 2. Configure the Flutter App

Update the API base URL in `lib/utils/config.dart`:
- For **Android Emulator**: Use `http://10.0.2.2:5000/api`
- For **iOS Simulator**: Use `http://localhost:5000/api`
- For **Real Device**: Use your computer's IP address or deployed URL

Current configuration uses DevTunnel URL: `https://kaise-app-backend.vercel.app/api`

### 3. Run the Flutter App
```bash
cd "Mobile App"
flutter pub get
flutter run
```

## Admin Panel Integration

The Admin Panel is already integrated with the same backend:
- Base URL: `https://kaise-app-backend.vercel.app/api`
- Built with React + Vite
- Uses Axios for API calls

### Run Admin Panel
```bash
cd "Admin Pannel"
npm install
npm run dev
```

## Database Setup

Make sure MongoDB is running and create a `.env` file in the Backend folder:

```env
MONGODB_URI=mongodb://localhost:27017/app-runner
PORT=5000
```

## Seeding Data

To populate the database with sample data:
```bash
cd Backend
node seeder.js
```

## API Features Implemented in Flutter

✅ Fetch all courses
✅ Fetch single course by ID
✅ Fetch all categories
✅ Create course (for future admin features)
✅ Update course
✅ Delete course
✅ Create category
✅ Update category
✅ Delete category
✅ Error handling with proper messages
✅ Type-safe models
✅ Category filtering
✅ Search functionality

## Network Configuration

### For Development with Real Device

If testing on a real device, you have 3 options:

1. **Use DevTunnel** (Current setup)
   - Already configured
   - Works from anywhere

2. **Use ngrok**
   ```bash
   ngrok http 5000
   # Update config.dart with the ngrok URL
   ```

3. **Use Local Network**
   - Find your computer's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
   - Update config.dart: `http://YOUR_IP:5000/api`
   - Make sure both devices are on the same network

## Next Steps

1. ✅ Backend API is running
2. ✅ Admin Panel is connected
3. ✅ Flutter App is integrated
4. ⏭️ Add authentication (JWT)
5. ⏭️ Add user registration/login
6. ⏭️ Add favorites/bookmarks
7. ⏭️ Add progress tracking
8. ⏭️ Add video playback functionality
9. ⏭️ Add offline support

## Troubleshooting

### Cannot connect to backend
- Check if backend server is running
- Verify the API URL in `lib/utils/config.dart`
- Check network connectivity
- For Android Emulator, ensure you're using `10.0.2.2` instead of `localhost`

### CORS Errors
- CORS is already enabled in the backend
- If issues persist, check backend console for errors

### Data not loading
- Check backend console for errors
- Verify MongoDB is running
- Check if data exists in database
- Check Flutter console for error messages

## File Structure

```
Mobile App/
├── lib/
│   ├── models/
│   │   ├── course.dart          ✅ Course & Episode models
│   │   └── category.dart        ✅ Category model
│   ├── services/
│   │   └── api_service.dart     ✅ Complete API integration
│   ├── utils/
│   │   └── config.dart          ✅ App configuration
│   ├── screens/
│   │   └── home_screen.dart     ✅ Updated with Category model
│   └── main.dart
└── .env                         ✅ Environment variables

Backend/
├── models/
│   ├── Course.js
│   └── Category.js
├── controllers/
│   ├── courseController.js
│   └── categoryController.js
├── routes/
│   ├── courseRoutes.js
│   └── categoryRoutes.js
├── config/
│   └── db.js
└── server.js

Admin Pannel/
├── src/
│   ├── api/
│   │   └── axios.js
│   ├── pages/
│   │   ├── Courses.jsx
│   │   └── Categories.jsx
│   └── main.jsx
└── package.json
```

## Support

If you encounter any issues:
1. Check the console logs (both Flutter and Backend)
2. Verify all dependencies are installed
3. Ensure MongoDB is running
4. Check network connectivity
5. Review the error messages in the app
