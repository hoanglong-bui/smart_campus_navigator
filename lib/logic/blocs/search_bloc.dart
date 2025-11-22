import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart'; // Cần thêm cái này để debounce (chống spam)

import '../../data/models/service_model.dart';
import '../../data/repositories/service_repository.dart';

// --- EVENTS ---
abstract class SearchEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  final String languageCode;

  SearchQueryChanged({required this.query, required this.languageCode});

  @override
  List<Object> get props => [query, languageCode];
}

// --- STATES ---
abstract class SearchState extends Equatable {
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ServiceModel> results;
  SearchLoaded(this.results);
  @override
  List<Object> get props => [results];
}

class SearchEmpty extends SearchState {} // Tìm không thấy gì

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

// --- BLOC ---
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ServiceRepository _repository;

  SearchBloc(this._repository) : super(SearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      // Transformer: Đợi người dùng ngừng gõ 300ms mới bắt đầu tìm (Debounce)
      // Giúp tối ưu hiệu năng, không gọi DB liên tục từng ký tự
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await _repository.searchServices(
        query: event.query,
        languageCode: event.languageCode,
      );

      if (results.isEmpty) {
        emit(SearchEmpty());
      } else {
        emit(SearchLoaded(results));
      }
    } catch (e) {
      emit(SearchError("Search failed: $e"));
    }
  }
}
