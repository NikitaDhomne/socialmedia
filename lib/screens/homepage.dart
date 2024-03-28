import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final url = "https://6604cb142ca9478ea17e83f1.mockapi.io/socialmedial/posts";

  var _postJson = [];
  Map<int, String> _comments = {};

  void fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body) as List;
      setState(() {
        _postJson = jsonData;
      });
    } catch (error) {}
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  void likePost(int index) {
    setState(() {
      bool isLiked = _postJson[index]['isLiked'] ?? false;
      _postJson[index]['isLiked'] = !isLiked;
      if (isLiked) {
        _postJson[index]['total_likes']--;
      } else {
        _postJson[index]['total_likes']++;
      }
    });
  }

  void openCommentModal(BuildContext context, int index) {
    TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Write your comment...',
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Save comment
                      _comments[index] = commentController.text;
                      // Update total comments
                      _postJson[index]['total_comments']++;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.amber,
                  ),
                  child: Text('Post Comment'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: 40,
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _postJson.length,
            itemBuilder: (context, i) {
              final user = _postJson[i];
              return Container(
                width: 100,
                alignment: Alignment.center,
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: ClipOval(
                        child: Image.network(
                          user['avatar'].toString(),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        user["name"],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 9,
          child: ListView.builder(
            itemCount: _postJson.length,
            itemBuilder: (context, i) {
              final post = _postJson[i];
              final bool isLiked = post['isLiked'] ?? false;
              var likes = post['total_likes'];
              final comment = post['total_comments'];
              final savedComment = _comments[i];

              return Container(
                alignment: Alignment.center,
                width: 100,
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(children: [
                      Image.network(post['post_url'].toString()),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  NetworkImage(post['avatar'].toString()),
                              radius: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              post['name'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: isLiked
                                    ? Icon(
                                        Icons.thumb_up_alt,
                                        color: Colors.orange,
                                      )
                                    : Icon(Icons.thumb_up_alt_outlined),
                                onPressed: () {
                                  likePost(i);
                                },
                              ),
                              Text(
                                '$likes Likes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.comment),
                                onPressed: () {
                                  openCommentModal(context, i);
                                },
                              ),
                              Text(
                                '$comment Comments',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (savedComment != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              savedComment,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ));
  }
}
