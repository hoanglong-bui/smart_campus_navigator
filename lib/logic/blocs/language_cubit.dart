import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Cubit quản lý ngôn ngữ: State chính là một Locale (vi, en, hi)
class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('en')) {
    _loadSavedLanguage();
  }

  // Hàm chuyển đổi ngôn ngữ
  Future<void> changeLanguage(String code) async {
    final locale = Locale(code);
    emit(locale); // Phát ra trạng thái mới -> UI sẽ tự đổi

    // Lưu lại lựa chọn để lần sau mở app vẫn nhớ
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
  }

  // Hàm tải ngôn ngữ đã lưu khi mở app
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code') ?? 'en';
    emit(Locale(savedCode));
  }
}
