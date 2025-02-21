import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:daftar_karyawan/models/karyawan.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Aplikasi(),
    );
  }
}

class Aplikasi extends StatelessWidget {
  const Aplikasi({super.key});

  Future<List<Karyawan>> _readJsonData() async {
    final String response = await rootBundle.loadString('assets/karyawan.json');
    final List<dynamic> data = json.decode(response);

    return data.map((json) => Karyawan.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Daftar Karyawan"),
      ),
      body: FutureBuilder(
        future: _readJsonData(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return ListView.builder(
            itemCount:snapshot.data!.length,
            itemBuilder:(context, index){
              return ListTile(
                title: Text(
                  snapshot.data![index].nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Umur : ${snapshot.data![index].umur} tahun"),
                    Text("Alamat : ${snapshot.data![index].alamat.jalan}")
                  ],
                ),
              )
            }),

          }else if(snapshot.hasError){
            return Center(child: Text('${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        })
    );
  }
}
