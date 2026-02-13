import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/course.dart';
import '../models/category.dart';
import '../utils/config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Fetch all courses (sorted by viewCount from API)
  static Future<List<Course>> fetchCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching courses: $e');
      rethrow;
    }
  }

  // Fetch single course by ID
  static Future<Course> fetchCourseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Course.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Course not found');
      } else {
        throw Exception('Failed to load course: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching course: $e');
      rethrow;
    }
  }

  // Increment view count for a course
  static Future<void> incrementViewCount(String courseId) async {
    try {
      await http.patch(
        Uri.parse('$baseUrl/courses/$courseId/view'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error incrementing view count: $e');
      // Don't rethrow - view count is non-critical
    }
  }

  // Create a new course (for admin features if needed)
  static Future<Course> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/courses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(courseData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Course.fromJson(data);
      } else {
        throw Exception('Failed to create course: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating course: $e');
      rethrow;
    }
  }

  // Update a course
  static Future<Course> updateCourse(
      String id, Map<String, dynamic> courseData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/courses/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(courseData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Course.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Course not found');
      } else {
        throw Exception('Failed to update course: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  // Delete a course
  static Future<void> deleteCourse(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/courses/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Course not found');
      } else {
        throw Exception('Failed to delete course: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting course: $e');
      rethrow;
    }
  }

  // Search courses by query
  static Future<List<Course>> searchCourses(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/courses/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching courses: $e');
      rethrow;
    }
  }

  // Fetch all categories
  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }
}
