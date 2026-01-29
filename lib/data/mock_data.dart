import '../models/course.dart';

final List<Course> allCourses = [
  Course(
    id: '1',
    title: 'FACEBOOK SE KAMAYE',
    category: 'Part Time Income',
    description:
        'Learn how to monetize your Facebook page and profile with these revolutionary strategies for 2026.',
    seriesThumbnail: 'https://picsum.photos/seed/fb1/400/600',
    tag: 'WORK FROM HOME & EARN',
    rating: 4.8,
    reviewsCount: 1200,
    isFree: true,
    episodes: [
      Episode(
        id: 'e1',
        title: 'Facebook Page Setup',
        duration: '5:20',
        date: '21 Jan',
        videoUrl: 'tYeqWc_fDRY', // Testing URL provided by user
        thumbnailUrl: 'https://picsum.photos/seed/ep1/200/300',
        isNew: true,
      ),
      Episode(
        id: 'e2',
        title: 'Content Strategy 2026',
        duration: '12:45',
        date: '20 Jan',
        videoUrl: 'tYeqWc_fDRY',
        thumbnailUrl: 'https://picsum.photos/seed/ep2/200/300',
      ),
    ],
  ),
  Course(
    id: '2',
    title: 'Youtube Secret',
    category: 'Youtube',
    description:
        'Janiye Youtube ke aise practical tarike jo apko help carega apna Youtube channel ko grow karne me aur Youtube se Earning Shuru Karne Mein!',
    seriesThumbnail: 'https://picsum.photos/seed/yt1/400/600',
    tag: 'HOT',
    rating: 4.9,
    reviewsCount: 4500,
    isFree: false,
    episodes: [
      Episode(
        id: 'e3',
        title: 'Real Subscribers Badhao Har Roz',
        duration: '8:15',
        date: '21 Jan',
        videoUrl: 'dQw4w9WgXcQ',
        thumbnailUrl: 'https://picsum.photos/seed/ep3/200/300',
        isNew: true,
      ),
      Episode(
        id: 'e4',
        title: 'Monetization Sabse Bada Secret',
        duration: '15:20',
        date: '19 Jan',
        videoUrl: 'tYeqWc_fDRY',
        thumbnailUrl: 'https://picsum.photos/seed/ep4/200/300',
      ),
    ],
  ),
  Course(
    id: '3',
    title: 'I AM SE SEEKHO ENGLISH',
    category: 'English Speaking',
    description:
        'Master English grammar using the "I AM" method. Simple and effective for beginners.',
    seriesThumbnail: 'https://picsum.photos/seed/en1/400/600',
    tag: 'SPOKEN ENGLISH',
    rating: 4.7,
    reviewsCount: 3200,
    isFree: true,
    episodes: [
      Episode(
        id: 'e5',
        title: 'Introduction to I AM',
        duration: '10:00',
        date: '15 Jan',
        videoUrl: 'dQw4w9WgXcQ',
        thumbnailUrl: 'https://picsum.photos/seed/ep5/200/300',
      ),
    ],
  ),
  Course(
    id: '4',
    title: '3 WHATSAPP PRIVACY SETTINGS',
    category: 'Mobile Tricks',
    description:
        'Protect your data with these essential WhatsApp privacy settings everyone should know.',
    seriesThumbnail: 'https://picsum.photos/seed/ws1/400/600',
    tag: 'NEW',
    rating: 4.5,
    reviewsCount: 800,
    isFree: true,
    episodes: [
      Episode(
        id: 'e6',
        title: 'Hidden Privacy Menu',
        duration: '4:30',
        date: '21 Jan',
        videoUrl: 'dQw4w9WgXcQ',
        thumbnailUrl: 'https://picsum.photos/seed/ep6/200/300',
      ),
    ],
  ),
];
