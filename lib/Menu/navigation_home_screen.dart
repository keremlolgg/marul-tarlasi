import 'package:Marul_Tarlasi/model/app_theme.dart';
import 'package:Marul_Tarlasi/Menu/custom_drawer/drawer_user_controller.dart';
import 'package:Marul_Tarlasi/Menu/custom_drawer/home_drawer.dart';
import 'package:Marul_Tarlasi/Menu/feedback_screen.dart';
import 'package:Marul_Tarlasi/Menu/help_screen.dart';
import 'package:Marul_Tarlasi/Menu/invite_friend_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:Marul_Tarlasi/hasta menu/fitness_app_home_screen.dart';
import 'package:Marul_Tarlasi/doktor menu/doktor_home_screen.dart';
import 'package:Marul_Tarlasi/giris_animasyon/introduction_animation_screen.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:Marul_Tarlasi/functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget? screenView;
  DrawerIndex? drawerIndex;
  final _auth = firebase_auth.FirebaseAuth.instance;
  firebase_auth.User? _user;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message received: ${message.notification?.title}, ${message.notification?.body}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification?.title ?? 'Bildirim'),
              content: Text(message.notification?.body ?? 'Bildirim içeriği yok.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Tamam'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    });
    setState(() {
      drawerIndex = DrawerIndex.HOME;
      _user = _auth.currentUser;
    });
    if(_user==null) {
      setState(() {
        screenView =GirisAnimasyonScreen();
      });
    } else {
      setState(() {
        screenView = HastaHomeScreen();
      });
    }
    surumkiyasla();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }
  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      Permission.notification.request();
    }
  }
  Future<void> surumkiyasla() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String localVersion = packageInfo.version;
    String? remoteVersion;
    String? apkUrl;

    Future<void> _fetchData() async {
      try {
        final response = await http.get(Uri.parse(
            'https://raw.githubusercontent.com/keremlolgg/marul-tarlasi/main/latest_version.json'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Null kontrolü ve verinin geçerliliği
          if (data != null && data.containsKey('latest_version') && data.containsKey('apk_url') && data.containsKey('apiserver')) {
            setState(() {
              remoteVersion = data['latest_version'] ?? 'N/A';
              apkUrl = data['apk_url'] ?? 'N/A';
              apiserver = data['apiserver'] ?? 'N/A';
            });
          } else {
            throw Exception('Missing keys in the JSON data');
          }
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        debugPrint('Error: $e');
      }
    }

    await _fetchData();
    void showUpdateDialog(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Yeni Sürüm Var'),
            content: Text('Lütfen internet sitesinden uygulamayı tekrar indirerek güncelleyiniz.'),
            actions: <Widget>[
              TextButton(
                child: Text('Şimdi Değil'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Siteye Git'),
                onPressed: () {
                  Navigator.of(context).pop();
                  EasyLauncher.url(
                    url: apkUrl!,
                  );
                },
              ),
            ],
          );
        },
      );
    }

    if (remoteVersion != null &&
        apkUrl != null &&
        remoteVersion != localVersion) {
      showUpdateDialog(context);
    }
  }

  void changeIndex(DrawerIndex drawerIndexdata) async {
      drawerIndex = drawerIndexdata;
      switch (drawerIndex) {
        case DrawerIndex.HOME:
          if(_user==null) {
            setState(() {
              screenView =GirisAnimasyonScreen();
            });
          } else {
            setState(() {
              screenView = HastaHomeScreen();
            });
          }
          break;
        case DrawerIndex.Doctor:
          bool isDoctorUser = await isDoctor();
          if (isDoctorUser) {
            setState(() {
              screenView = DoktorHomeScreen();
            });
          } else {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Doktor menüsüne girmek için yetkiniz bulunmuyor.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          break;
        case DrawerIndex.Help:
          setState(() {
            screenView = HelpScreen();
          });
          break;
        case DrawerIndex.FeedBack:
          setState(() {
            screenView = FeedbackScreen();
          });
          break;
        case DrawerIndex.Invite:
          setState(() {
            screenView = InviteFriend();
          });
          break;
        case DrawerIndex.Share:
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Uygulamayı değerlendir sekmesi açılacak."),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.blue,
                action: SnackBarAction(
                  label: "Kapat",
                  onPressed: () {
                    // İşlem yapılabilir
                  },
                ),
              ),
            );
          });
          break;
        case DrawerIndex.About:
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Uygulamanın hakkında sekmesi açılacak internet sitesi lisanslar vb. şeyler gösterilecek."),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.blue,
                action: SnackBarAction(
                  label: "Kapat",
                  onPressed: () {
                    // İşlem yapılabilir
                  },
                ),
              ),
            );
          });
          break;
        default:
          break;
      }
    }

}
