// Usado en web. fetch_client implementa http.Client usando
// el Fetch API del navegador con ReadableStream — da streaming real.
import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart' as http;

http.Client crearCliente() => FetchClient(mode: RequestMode.cors);