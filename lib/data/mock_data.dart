import '../models/course.dart';

final List<Course> allCourses = [
  Course(
    id: '1',
    title: 'FACEBOOK SE KAMAYE',
    description:
        'Learn how to monetize your Facebook page and profile with these revolutionary strategies for 2026.',
    seriesThumbnail: 'https://picsum.photos/seed/fb1/400/600',
    reviewsCount: 1200,
    viewCount: 5000,
    isFree: true,
    episodes: [
      Episode(
        id: 'e1',
        title: 'Facebook Page Setup',
        date: '21 Jan',
        videoUrl: 'tYeqWc_fDRY',
        thumbnailUrl: 'https://picsum.photos/seed/ep1/200/300',
        isNew: true,
      ),
      Episode(
        id: 'e2',
        title: 'Content Strategy 2026',
        date: '20 Jan',
        videoUrl: 'tYeqWc_fDRY',
        thumbnailUrl: 'https://picsum.photos/seed/ep2/200/300',
      ),
    ],
  ),
  Course(
    id: '2',
    title: 'Youtube Secret',
    description:
        'Janiye Youtube ke aise practical tarike jo apko help carega apna Youtube channel ko grow karne me aur Youtube se Earning Shuru Karne Mein!',
    seriesThumbnail: 'https://picsum.photos/seed/yt1/400/600',
    reviewsCount: 4500,
    viewCount: 12000,
    isFree: false,
    episodes: [
      Episode(
        id: 'e3',
        title: 'Real Subscribers Badhao Har Roz',
        date: '21 Jan',
        videoUrl: 'dQw4w9WgXcQ',
        thumbnailUrl: 'https://picsum.photos/seed/ep3/200/300',
        isNew: true,
      ),
      Episode(
        id: 'e4',
        title: 'Monetization Sabse Bada Secret',
        date: '19 Jan',
        videoUrl: 'tYeqWc_fDRY',
        thumbnailUrl: 'https://picsum.photos/seed/ep4/200/300',
      ),
    ],
  ),
  Course(
    id: '3',
    title: 'I AM SE SEEKHO ENGLISH',
    description:
        'Master English grammar using the "I AM" method. Simple and effective for beginners.',
    seriesThumbnail: 'https://picsum.photos/seed/en1/400/600',
    reviewsCount: 3200,
    viewCount: 8000,
    isFree: true,
    episodes: [
      Episode(
        id: 'e5',
        title: 'Introduction to I AM',
        date: '15 Jan',
        videoUrl: 'dQw4w9WgXcQ',
        thumbnailUrl: 'https://picsum.photos/seed/ep5/200/300',
      ),
    ],
  ),
  Course(
    id: '4',
    title: '3 WHATSAPP PRIVACY SETTINGS',
    description:
        'Protect your data with these essential WhatsApp privacy settings everyone should know.',
    seriesThumbnail: 'https://picsum.photos/seed/ws1/400/600',
    reviewsCount: 800,
    viewCount: 3000,
    isFree: true,
    episodes: [
      Episode(
        id: 'e6',
        title: 'Hidden Privacy Menu',
        date: '21 Jan',
        videoUrl: 'dQw4w9WgXcQ',
        thumbnailUrl: 'https://picsum.photos/seed/ep6/200/300',
      ),
    ],
  ),
];
