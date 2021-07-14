import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_gp/services/diagnose.dart';

class Diagnoses extends StatelessWidget {
  final db = Firestore.instance;
  void deleteData(DocumentSnapshot doc, String email) async {
    await db
        .collection('user')
        .document(email)
        .collection("Diagnoses")
        .document(doc.documentID)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context).settings.arguments as String;
    Stream<QuerySnapshot> shown = db
        .collection('user')
        .document(email)
        .collection("Diagnoses")
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnoses'),
        backgroundColor: Color(0xff21254A),
      ),
      body: StreamBuilder(
        stream: shown,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          return snapshot.data.documents.isEmpty
              ? LayoutBuilder(
                  builder: (ctx, constraint) {
                    return Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 387,left: 97),
                          child: Text('No previous diagnoses yet!',
                              style: Theme.of(context).textTheme.title),
                        ),
                      ],
                    );
                  },
                )
              : ListView.builder(
                  itemBuilder: (ctx, index) {
                    return Dismissible(
                        key: UniqueKey(),
                        background: Container(
                          color: Colors.red,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          deleteData(snapshot.data.documents[index], email);
                        },
                        child: Diagnose(snapshot.data.documents[index]));
                  },
                  itemCount: snapshot.data.documents.length,
                );
        },
      ),
    );
  }
}
