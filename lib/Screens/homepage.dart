import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_search/models/speech.dart';
import 'package:voice_search/models/textmodel.dart';

import '../utils/utils.dart';
import '../widgets/dialogs.dart';
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //bool isListening = false;
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomePageBody(),
      // floatingActionButton: AvatarGlow(
      //   animate: isListening,
      //   endRadius: 75,
      //   glowColor: Theme.of(context).primaryColor,
      //   child: FloatingActionButton(
      //     onPressed: () {},
      //     child: const Icon(
      //       Icons.mic,
      //       size: 36,
      //     ),
      //   ),
      // ),
    );
  }
}

class HomePageBody extends StatefulWidget {
  const HomePageBody({Key? key}) : super(key: key);

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  final _speech = SpeechToText();
  final searchController = TextEditingController();

  bool isListening = false;
  bool isNotListening = false;
  String resultText = '';
  List<String> resultTextList = [];
  List<String> resultTextListFinal = [];
  late List<bool> isChecked;
  Future<bool> ttoggleRecording({
    required Function(String text) onResult,
    required ValueChanged<bool> onListening,
  }) async {
    if (_speech.isListening) {
      _speech.stop();
      return true;
    }
    final isAvailable = await _speech.initialize(
      onStatus: (status) {
        onListening(_speech.isListening);
      },
      // ignore: avoid_print
      onError: (e) => print('Error: $e'),
    );
    if (isAvailable) {
      _speech.listen(
          onResult: (result) => setState(
                () {
                  resultText = result.recognizedWords;
                  onResult(result.recognizedWords);
                },
              ));
    }
    return isAvailable;
  }

  Future openDialog(String resultText, List<String> resultTextListFinal,
      String selectedCommand) {
    if (!isListening) {
      Navigator.of(context).pop();
      if (resultText.isNotEmpty &&
          resultText != ' ' &&
          resultText != '' &&
          isListening == false) {
        if (selectedCommand == 'voice') {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: ((context, setState) {
                  return AlertDialog(
                    title: const Text('Write by Voice'),
                    content: SingleChildScrollView(
                      reverse: true,
                      child: Column(
                        children: [
                          Text(resultText),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Copy'),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                      (ClipboardData(text: resultText)));
                                  Fluttertoast.showToast(
                                      msg: 'Copied to clipboard');
                                },
                                icon: const Icon(Icons.copy),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }));
              });
        } else {
          isChecked = List<bool>.filled(resultTextListFinal.length, false);
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              print(resultTextListFinal);
              return StatefulBuilder(
                builder: (context, setSTate) {
                  return AlertDialog(
                    title: const Text('Variants'),
                    actions: [
                      ElevatedButton(
                          child: const Text('Ok'),
                          onPressed: () => Navigator.of(context).pop())
                    ],
                    content: SizedBox(
                      height: 200,
                      width: 200,
                      child: ListView.builder(
                        itemCount: resultTextListFinal.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: isChecked[index],
                            onChanged: (value) {
                              setSTate(() {
                                isChecked =
                                    isChecked.map((e) => false).toList();
                                isChecked[index] = value!;
                              });
                            },
                            title: Text(
                              resultTextListFinal[index],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ).then((value) => {
                Future.delayed(const Duration(seconds: 1), () {
                  if (selectedCommand == 'app') {
                    UrlHandler.open(
                            '$resultText${resultTextListFinal[isChecked.indexOf(true)]}.com')
                        .then((value) => {
                              context.read<TextModel>().setText(''),
                              resultTextListFinal = [],
                              resultTextList = [],
                            });
                  } else {
                    UrlHandler.open(resultText +
                            resultTextListFinal[isChecked.indexOf(true)])
                        .then((value) => {
                              context.read<TextModel>().setText(''),
                              resultTextListFinal = [],
                              resultTextList = []
                            });
                  }
                })
              });
        }
      } else {
        Fluttertoast.showToast(msg: 'Please speak something');
      }
    }
    return Future.value(true);
  }

  Future toggleRecording(String selectedCommand) {
    return ttoggleRecording(
      onResult: ((text) {
        resultText = context.read<TextModel>().setText(text);
        print('DADA $resultText');
        //resultText = text;
        resultTextList.add(text);
        resultTextListFinal = resultTextList.toSet().toList();
        resultTextListFinal.remove('');

        if (selectedCommand == 'google') {
          openDialog('https://www.google.com/search?q=', resultTextListFinal,
              'google');
        } else if (selectedCommand == 'youtube') {
          openDialog('https://www.youtube.com/results?search_query=',
              resultTextListFinal, 'youtube');
        } else if (selectedCommand == 'contactCall') {
          openDialog('tel:', resultTextListFinal, 'contactCall');
        } else if (selectedCommand == 'contactSms') {
          openDialog('sms:', resultTextListFinal, 'contactSms');
        } else if (selectedCommand == 'app') {
          openDialog('https://', resultTextListFinal, 'app');
        } else if (selectedCommand == 'voice') {
          openDialog(resultText, resultTextListFinal, 'voice');
        }
      }),
      onListening: (isListening) {
        print('isListening $isListening');
        return setState(() {
          this.isListening = isListening;
          context.read<TextModel>().setIsListening(isListening);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.white,
                child: Center(
                  child: TextFormField(
                    controller: searchController,
                    onFieldSubmitted: (val) async {
                      UrlHandler.open('https://www.google.com/search?q=$val');
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'COMMANDS',
                style: TextStyle(color: Colors.black54),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<TextModel>().setText('');
                        resultTextListFinal = [];
                        resultTextList = [];
                        toggleRecording('google');
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              text: 'Search in Google',
                              resultText: resultText,
                            );
                          },
                        );
                      },
                      child:
                          IconWidgets(widget: Image.asset('assets/google.png')),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<TextModel>().setText('');
                        resultTextListFinal = [];
                        resultTextList = [];
                        toggleRecording('youtube');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              resultText: resultText,
                              text: 'Search in Youtube',
                            );
                          },
                        );
                      },
                      child: IconWidgets(
                          widget: Image.asset('assets/youtube.png')),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<TextModel>().setText('');
                        resultTextListFinal = [];
                        resultTextList = [];
                        toggleRecording('voice');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              text: 'Write by Voice',
                              resultText: resultText,
                            );
                          },
                        );
                      },
                      child: IconWidgets(widget: Image.asset('assets/mic.png')),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<TextModel>().setText('');
                        resultTextListFinal = [];
                        resultTextList = [];
                        toggleRecording('contactCall');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                                resultText: resultText,
                                text: 'Say Phone number or Contact name');
                          },
                        );
                      },
                      child:
                          IconWidgets(widget: Image.asset('assets/phone.png')),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<TextModel>().setText('');
                        resultTextListFinal = [];
                        resultTextList = [];
                        toggleRecording('contactSms');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              resultText: resultText,
                              text: 'Say Phone number',
                            );
                          },
                        );
                      },
                      child: IconWidgets(widget: Image.asset('assets/msg.png')),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<TextModel>().setText('');
                        resultTextListFinal = [];
                        resultTextList = [];
                        toggleRecording('app');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              resultText: resultText,
                              text: 'Say app name',
                            );
                          },
                        );
                      },
                      child:
                          IconWidgets(widget: Image.asset('assets/share.png')),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'ACTIONS',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(
                height: 20,
              ),
              ButtonWidget(
                widget: Image.asset('assets/google.png'),
                onPressed: () =>
                    UrlHandler.open('https://www.google.com/search?q=news'),
                text: 'news',
              ),
              const SizedBox(
                height: 20,
              ),
              ButtonWidget(
                widget: Image.asset('assets/youtube.png'),
                onPressed: () => UrlHandler.open(
                    'https://www.youtube.com/results?search_query=new movies'),
                text: 'new movies',
              ),
              const SizedBox(
                height: 20,
              ),
              ButtonWidget(
                widget: Image.asset('assets/ebay.png'),
                onPressed: () => UrlHandler.open(
                    'https://www.ebay.com/sch/i.html?_from=R40&_trksid=p2380057.m570.l1313&_nkw=daily deals&_sacat=0'),
                text: 'daily deals',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
