import 'package:socket_io_client/socket_io_client.dart';
import 'package:tume_ride_passenger/config/app_config.dart';
import 'package:tume_ride_passenger/services/auth_service.dart';
import 'package:tume_ride_passenger/utils/logger.dart';

class SocketService {
  static Socket? _socket;
  static bool _isConnected = false;
  static final Map<String, List<Function>> _listeners = {};

  static void initialize() {
    _socket = io(
      AppConfig.socketUrl,
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) {
      _isConnected = true;
      AppLogger.debug('Socket connected');
      _emit('authenticate', {'token': AuthService.getToken()});
      _trigger('connect', null);
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      AppLogger.debug('Socket disconnected');
      _trigger('disconnect', null);
    });

    _socket?.onError((data) {
      AppLogger.error('Socket error: $data');
    });
  }

  static void connect() {
    if (_socket != null && !_isConnected) {
      _socket?.connect();
    }
  }

  static void disconnect() {
    if (_socket != null && _isConnected) {
      _socket?.disconnect();
    }
  }

  static void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket?.emit(event, data);
    }
  }

  static void _emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket?.emit(event, data);
    }
  }

  static void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  static void addListener(String event, Function callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);

    _socket?.on(event, (data) {
      for (var cb in _listeners[event]!) {
        cb(data);
      }
    });
  }

  static void removeListener(String event, Function callback) {
    if (_listeners.containsKey(event)) {
      _listeners[event]!.remove(callback);
    }
  }

  static void _trigger(String event, dynamic data) {
    if (_listeners.containsKey(event)) {
      for (var cb in _listeners[event]!) {
        cb(data);
      }
    }
  }

  static void subscribeToRide(int rideId) {
    emit('subscribe_ride', {'ride_id': rideId});
  }

  static void unsubscribeFromRide(int rideId) {
    emit('unsubscribe_ride', {'ride_id': rideId});
  }

  static void updateLocation(double lat, double lng) {
    emit('update_location', {'lat': lat, 'lng': lng});
  }
}
