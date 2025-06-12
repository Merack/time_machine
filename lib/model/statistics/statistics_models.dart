export 'completes_statistics_model.dart';
export 'daily_statistics_model.dart';
export 'time_period_statistics_model.dart';
export 'statistics_data_model.dart';

/// 统计数据加载状态
// enum StatisticsLoadingState {
//   initial,
//   loading,
//   loaded,
//   error,
// }
//
// /// 统计数据状态包装器
// class StatisticsState {
//   final StatisticsLoadingState loadingState;
//   final CompleteStatistics? data;
//   final String? errorMessage;
//   final DateTime? lastUpdated;
//
//   const StatisticsState({
//     required this.loadingState,
//     this.data,
//     this.errorMessage,
//     this.lastUpdated,
//   });
//
//   const StatisticsState.initial()
//       : loadingState = StatisticsLoadingState.initial,
//         data = null,
//         errorMessage = null,
//         lastUpdated = null;
//
//   const StatisticsState.loading()
//       : loadingState = StatisticsLoadingState.loading,
//         data = null,
//         errorMessage = null,
//         lastUpdated = null;
//
//   StatisticsState.loaded(CompleteStatistics statistics)
//       : loadingState = StatisticsLoadingState.loaded,
//         data = statistics,
//         errorMessage = null,
//         lastUpdated = DateTime.now();
//
//   const StatisticsState.error(String message)
//       : loadingState = StatisticsLoadingState.error,
//         data = null,
//         errorMessage = message,
//         lastUpdated = null;
//
//   bool get isLoading => loadingState == StatisticsLoadingState.loading;
//   bool get hasData => loadingState == StatisticsLoadingState.loaded && data != null;
//   bool get hasError => loadingState == StatisticsLoadingState.error;
//
//   @override
//   String toString() {
//     return 'StatisticsState{state: $loadingState, hasData: $hasData, error: $errorMessage}';
//   }
// }
