class DangerNavigationController {
   final List<DateTime> _timestamps = [];
   int _currentIndex = -1;
 
   void setCurrent(DateTime timestamp) {
  if (!_timestamps.contains(timestamp)) {
    _timestamps.add(timestamp);
    _timestamps.sort();
  }
  _currentIndex = _timestamps.indexOf(timestamp);
}
 
   DateTime? get current =>
       (_currentIndex >= 0 && _currentIndex < _timestamps.length)
           ? _timestamps[_currentIndex]
           : null;
 
   DateTime? next() {
     if (_currentIndex + 1 < _timestamps.length) {
       _currentIndex++;
       return _timestamps[_currentIndex];
     }
     return null;
   }
 
   DateTime? previous() {
     if (_currentIndex - 1 >= 0) {
       _currentIndex--;
       return _timestamps[_currentIndex];
     }
     return null;
   }
 
   bool get hasNext => _currentIndex + 1 < _timestamps.length;
   bool get hasPrevious => _currentIndex - 1 >= 0;
 
   List<DateTime> get all => List.unmodifiable(_timestamps);
 }