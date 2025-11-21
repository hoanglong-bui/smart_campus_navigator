import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';

// --- EVENTS (Các hành động người dùng làm) ---
abstract class ServiceListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadServices extends ServiceListEvent {
  final String languageCode;
  final String? clusterId; // Lọc theo khu vực
  final String? category; // Lọc theo danh mục ("On-Campus"...)

  LoadServices({required this.languageCode, this.clusterId, this.category});

  @override
  List<Object?> get props => [languageCode, clusterId, category];
}

// --- STATES (Trạng thái của màn hình) ---
abstract class ServiceListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServiceListInitial extends ServiceListState {}

class ServiceListLoading extends ServiceListState {}

class ServiceListLoaded extends ServiceListState {
  final List<ServiceModel> services;

  ServiceListLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

class ServiceListError extends ServiceListState {
  final String message;

  ServiceListError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLOC (Bộ xử lý Logic) ---
class ServiceListBloc extends Bloc<ServiceListEvent, ServiceListState> {
  final ServiceRepository _serviceRepository;

  ServiceListBloc(this._serviceRepository) : super(ServiceListInitial()) {
    // Đăng ký hàm xử lý khi có sự kiện LoadServices
    on<LoadServices>(_onLoadServices);
  }

  Future<void> _onLoadServices(
    LoadServices event,
    Emitter<ServiceListState> emit,
  ) async {
    emit(ServiceListLoading()); // Báo UI hiện vòng xoay loading

    try {
      // Gọi Repository để lấy dữ liệu từ SQLite
      final services = await _serviceRepository.getServices(
        languageCode: event.languageCode,
        clusterId: event.clusterId,
        category: event.category,
      );

      if (services.isEmpty) {
        // Nếu rỗng cũng báo Loaded nhưng list rỗng
        emit(ServiceListLoaded(const []));
      } else {
        emit(ServiceListLoaded(services));
      }
    } catch (e) {
      print("Bloc Error: $e");
      emit(ServiceListError("Failed to load services"));
    }
  }
}
