import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const new({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  String? _name = "";
  String? _email = "";
  String? _phone = "";

  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedImage(); // جلب الصورة المحفوظة عند فتح التطبيق
  }

  // 1. قراءة المسار المحفوظ عند بداية التطبيق
  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString('saved_image');
      _name = prefs.getString("name");
      _phone = prefs.getString("phone");
      _email = prefs.getString("email");
    });
  }

  // 2. اختيار الصورة وحفظ مسارها
  Future<void> savephoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_image', image.path); // حفظ المسار فقط

      setState(() {
        _imagePath = image.path; // تحديث الواجهة فوراً
      });
    }
  }

  Future<void> saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name.text);
    await prefs.setString("email", email.text);
    await prefs.setString("phone", phone.text);
    setState(() {
      _email = email.text;
      _phone = phone.text;
      _name = name.text;
    });
  }

  bool isselected = false;
  void dispose() {
    super.dispose();
    email.dispose();
    name.dispose();
    phone.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: isselected
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    onPressed: () {
                      setState(() {
                        isselected = false;
                      });
                    },
                    icon: Icon(Icons.exit_to_app),
                  ),
                )
              : AppBar(backgroundColor: Colors.transparent),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/background.png"),
                fit: BoxFit.cover,
              ),
            ),

            child: isselected
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            savephoto();
                          },
                          child: Column(
                            children: [
                              Icon(Icons.photo, size: 40, color: Colors.black),
                              const SizedBox(height: 1),
                              Text(
                                "+",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 20, left: 20),
                          child: Card(
                            color: Colors.black,
                            child: ListTile(
                              title: TextField(
                                controller: name,
                                decoration: InputDecoration(
                                  hintText: "$_name",
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                              leading: Text(
                                "الإسم: ",
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    206,
                                    178,
                                    93,
                                  ),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.only(right: 20, left: 20),
                          child: Card(
                            color: Colors.black,
                            child: ListTile(
                              title: TextField(
                                controller: email,
                                decoration: InputDecoration(
                                  hintText: "$_email",
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                              leading: Text(
                                "الإيميل: ",
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    206,
                                    178,
                                    93,
                                  ),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.only(right: 20, left: 20),
                          child: Card(
                            color: Colors.black,
                            child: ListTile(
                              title: TextField(
                                controller: phone,
                                decoration: InputDecoration(
                                  hintText: "$_phone",
                                  hintStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                              leading: Text(
                                "التليفون: ",
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    206,
                                    178,
                                    93,
                                  ),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        IconButton(
                          onPressed: () async {
                            await saveUserData();
                            if (mounted) {
                              setState(() {
                                isselected = false;
                              });
                            }
                          },
                          icon: Icon(Icons.check, size: 40),
                        ),

                        Card(
                          color: const Color.fromARGB(255, 148, 10, 0),
                          child: ListTile(
                            leading: Icon(
                              Icons.warning,
                              size: 20,
                              color: const Color.fromARGB(255, 255, 194, 11),
                            ),
                            title: Text(
                              "تحذير : اذا ضغط صح والبيانات لم تكن ممكتمله سوف تمسح البيانات اذا كنت تريد الرجوع من الاعلى ^",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 185, 141, 7),
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                        Card(
                          color: const Color.fromARGB(255, 35, 122, 0),
                          child: ListTile(
                            leading: Icon(
                              Icons.warning,
                              size: 20,
                              color: const Color.fromARGB(255, 19, 18, 14),
                            ),
                            title: Text(
                        "البيانات التي في الخانات مجرد تذكير عند التغيير اكتب كل شي من الاول للضمان التجربه الصحيحيه ",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 31, 29, 23),
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child: Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.only(right: 15, left: 15),
                          child: Card(
                            color: Colors.black,
                            child: ListTile(
                              title: Text(
                                "$_name",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              leading: Text(
                                "الإسم: ",
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    206,
                                    178,
                                    93,
                                  ),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.only(right: 15, left: 15),
                          child: Card(
                            color: Colors.black,
                            child: ListTile(
                              title: Text(
                                "$_email",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              leading: Text(
                                "الإيميل: ",
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    206,
                                    178,
                                    93,
                                  ),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.only(right: 15, left: 15),
                          child: Card(
                            color: Colors.black,
                            child: ListTile(
                              title: Text(
                                "$_phone",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              leading: Text(
                                "التليفون: ",
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    206,
                                    178,
                                    93,
                                  ),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "في حالة الرغبة في إضافة أو تعديل اذهب الي",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isselected = true;
                                });
                              },

                              child: Text(
                                "\"Edit\"",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(width: 340,height: 160,margin: EdgeInsets.symmetric(horizontal: 50),child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(220),child: Image.asset("images/icon.png"),)),
                        const SizedBox(height: 30,),
                        Directionality(textDirection: TextDirection.ltr,child: Text("By </Omar ali/>",style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),))
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
