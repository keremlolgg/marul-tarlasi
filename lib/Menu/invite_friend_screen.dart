import 'package:Marul_Tarlasi/model/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class InviteFriend extends StatefulWidget {
  @override
  _InviteFriendState createState() => _InviteFriendState();
}

class _InviteFriendState extends State<InviteFriend> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
      color: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16,
                    right: 16),
                child: Image.asset('assets/images/inviteImage.png'),
              ),
              Container(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Arkadaşını Davet Et.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isLightMode ? Colors.black : Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Her şeyi son dakikada yapan insanlardan mısınız?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLightMode ? Colors.black : Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isLightMode ? Colors.blue : Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              offset: const Offset(4, 4),
                              blurRadius: 8.0),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Share.share('Marul Tarlası Uygulaması Davet Promt https://keremkk.can.re');
                          },
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.share,
                                  color:
                                      isLightMode ? Colors.white : Colors.black,
                                  size: 22,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    'Paylaş',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isLightMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
