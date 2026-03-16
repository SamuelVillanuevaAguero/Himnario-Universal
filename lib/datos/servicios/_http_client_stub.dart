// Usado en Android / iOS / Desktop.
// En nativo, http.Client ya soporta streaming nativo.
import 'package:http/http.dart' as http;

http.Client crearCliente() => http.Client();