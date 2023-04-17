import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//? Run de l'application
void main() {
  runApp(const MyApp());
}

//? Application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

//? Redéfinition du build du widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Get et Post (API)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

//? Page d'accueil
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Post> listArticles = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

//? Formatage de la réponse API
//* Pas d'async sans future / void évite de devoir retourner une réponse
  Future<void> _fetchPosts() async {
    //? Appel de l'API
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    //? Formatage des données Json et mapping du array
    final jsonData = jsonDecode(response.body) as List<dynamic>;
    final articles = jsonData.map((data) => Post.fromJson(data)).toList();
    //? Changement d'état à l'intérieur du framework
    setState(() {
      listArticles = articles;
    });
  }

//? Ecran principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Derniers articles'),
      ),
      body: ListView.builder(
        //? Nombre d'items selon le nombre d'articles
        itemCount: listArticles.length,
        //? Liste scrollable
        itemBuilder: (context, index) {
          final post = listArticles[index];
          return ListTile(
            title: Text(post.title),
            //? Pop up de l'article
            onTap: () {
              Navigator.push(
                context,
                //? Définition de la route
                MaterialPageRoute(
                    builder: (context) => PostDetailPage(post: post)),
              );
            },
          );
        },
      ),
      //? Icone ajout article
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            //? Définition de la route
            MaterialPageRoute(builder: (context) => const AddPostPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

//? Widget de la page d'affichage de l'article
class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({Key? key, required this.post}) : super(key: key);

//* Build de PostDetail
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(post.body),
      ),
    );
  }
}

//? Widget de la page d'ajout d'article (modifiable)
class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  AddPostPageState createState() => AddPostPageState();
}

//? Gestion de l'état de la page (State associé au StatefulWidget)
class AddPostPageState extends State<AddPostPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

//? Même principe que _fetchpost, mais cette fois on encode les input pour les poster
  Future<void> _addPost() async {
    final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      body: jsonEncode({
        //? Les contrôleurs sont définis juste en dessous
        'title': titleController.text,
        'body': bodyController.text,
        //* Par défaut, userId 1 (pas d'utilisateur' co)
        'userId': 1,
      }),
    );
    //? Retourne le statut en console / 201 pour le POST
    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(response.statusCode.toString());
    }
  }

//* Build de AddPost
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                //? Definition du controleur
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                ),
                //? Alerte sur l'absence de contenu
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Merci de remplir ce champs';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: "Contenu de l'article",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Merci de remplir ce champs';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  //? Envoi onPress
                  onPressed: () {
                    _addPost();
                  },
                  child: const Text('Soumettre'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//? Définition de la classe Post, il faut bien définir les variables et leur nature
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post(
      {required this.id,
      required this.userId,
      required this.title,
      required this.body});

//? Factory de mapping des objets (clé/valeur)
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }
}
