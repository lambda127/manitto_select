import 'dart:io' show Directory, File, Platform;
import 'dart:math';
import 'dart:ui' as ui;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Member {
  final String name;
  final String email;
  final String grade;
  List<String> missions = ['간식 선물하기(직접 안 줘도 무방)', '간단한 편지쓰기', '셀카 찍기 '];

  Member({required this.name, required this.email, required this.grade});
}

class ManittoDispenser {
  List<Member> memberList = [];
  List<Member> oriMember = [];
  List<Member> newMember = [];
  List<String> missionList = [
    '옷차림새에 대한 칭찬하기',
    '발사이즈 알아오기',
    '최애 음식 알아오기',
    '본인의 TMI 한가지 말하기',
    '시력 알아오기',
    '이상형 알아오기',
    '본인의 깜짝 개인기 하나 보여주기 ',
    '상대방의 필기구(펜, 연필 등) 빌려보기',
    '상대방이 싫어하는 것을 하나 알아오기',
    '좋아하는 영화나 드라마 알아오기',
    '가장 좋아하는 계절 알아오기',
    '가장 최근에 본 유튜브 영상 물어보기',
    '가장 가보고 싶은 여행지 알아오기',
    '좋아하는 동물 알아오기',
    '싫어하는 음식 하나 알아오기',
    '어떤 초능력을 가지고 싶냐고 물어보기',
    '상대방과 가위바위보 해서 이기기 (이길 때까지 계속 도전 가능) ',
    '상대방과 셀카 찍기',
    '상대방과 하이파이브 하기 ✋',
    '상대방이 모르게 몰래 사진 찍고, 나중에 보여주기 👀',
    '상대방이 좋아하는 색 물어보고, 다음 교육날때 입고 오기(인증 필수)',
    '번호 교환하기',
    '인스타 맞팔하기 ',
    '아이스크림 사주기',
    '인스타 스토리 태그해서 올리기(사진이나 내용은 상관X)',
    '노트북 사양물어보기',
  ];
  var giverQueue = [];
  var receiverQueue = [];
  List<String> missionQueue = [];

  List<(Member, Member)> manittoList = [];

  int memberNum = 0;

  var excel = Excel.createExcel();

  ManittoDispenser() {
    parseSelectedColumn(0, 1, 2);

    giverQueue = [];
    receiverQueue = [];
    missionQueue = [];

    manittoList = [];

    _reset();
    memberNum = oriMember.length + newMember.length;
  }


  void parseSelectedColumn(
    int? nameColumnIndex,
    int? emailColumnIndex,
    int? gradeColumnIndex,
  ) {
    String fileName = "member_list.xlsx";
    String dir = Directory.current.path;
    String filePath = '$dir/$fileName';
    File? file = File(filePath);
    var bytes = file!.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    var table = excel.tables[excel.tables.keys.first]!;

    memberList =
        table.rows
            .skip(1)
            .map((row) {
              return Member(
                name: row[nameColumnIndex!]?.value.toString() ?? '',
                email: row[emailColumnIndex!]?.value.toString() ?? '',
                grade: row[gradeColumnIndex!]?.value.toString() ?? '',
              );
            })
            .where(
              (entry) =>
                  entry.name.isNotEmpty &&
                  entry.email.isNotEmpty &&
                  entry.grade.isNotEmpty,
            )
            .toList();
  }

  void _reset() {
    oriMember.clear();
    newMember.clear();
    oriMember.addAll(memberList.where((e) => e.grade != '1'));
    newMember.addAll(memberList.where((e) => e.grade == '1'));
  }

  /// 마니또 설정
  Future setManitto() async {
    //신입생들한테 마니또 배정
    _reset();

    if (oriMember.length < newMember.length) {
      int num1 = newMember.length;
      int num2 = oriMember.length;
      for (int i = 0; i < num1 - num2; i++) {
        oriMember.add(oriMember[Random().nextInt(num2)]);
      }
    }

    newMember.shuffle();

    for (int i = 0; i < newMember.length; i++) {
      missionList.shuffle();
      newMember[i].missions.addAll(missionList.sublist(0, 8));
    }

    giverQueue.addAll(newMember);

    oriMember.shuffle();
    receiverQueue.addAll(oriMember);

    /*
    for (int i = 0; i < oriMember.length; i++) {
      giverQueue.add(newMember[i]);
      receiverQueue.add(oriMember[Random().nextInt(oriMember.length)]);
      oriMember.remove(receiverQueue[i]);

      missionQueue.add(missionList[Random().nextInt(missionList.length)]);
      //missionList.remove(missionQueue[i]);
    }
*/
    _reset();

    if (oriMember.length > newMember.length) {
      int num1 = newMember.length;
      int num2 = oriMember.length;
      for (int i = 0; i < num2 - num1; i++)
        newMember.add(newMember[Random().nextInt(num1)]);
    }

    oriMember.shuffle();

    for (int i = 0; i < oriMember.length; i++) {
      missionList.shuffle();
      oriMember[i].missions.addAll(missionList.sublist(0, 8));
    }

    giverQueue.addAll(oriMember);

    newMember.shuffle();
    receiverQueue.addAll(newMember);

    /*
    for (int i = 0; i < newMember.length; i++) {
      giverQueue.add(oriMember[i]);
      receiverQueue.add(newMember[Random().nextInt(newMember.length)]);
      oriMember.remove(receiverQueue[i]);

      missionQueue.add(missionList[Random().nextInt(missionList.length)]);
      //missionList.remove(missionQueue[i]);
    }
    */

    for (int i = 0; i < memberNum; i++) {
      manittoList.add((giverQueue[i], receiverQueue[i]));
    }
    try {
      for (int i = 0; i < memberNum; i++) {
        await _sendEmail(
          recipientName: manittoList[i].$1.name,
          recipient: manittoList[i].$1.email,
          subject: '[PRIMITIVE] 당신의 마니또는...!',
          body: '파일을 확인주세요!',
          content: '''
${manittoList[i].$1.name}님의 마니또는 ${manittoList[i].$2.name}님입니다.\n\n
[미션]\n
1.  ${manittoList[i].$1.missions[0]}\n
2.  ${manittoList[i].$1.missions[1]}\n
3.  ${manittoList[i].$1.missions[2]}\n
4.  ${manittoList[i].$1.missions[3]}\n
5.  ${manittoList[i].$1.missions[4]}\n
6.  ${manittoList[i].$1.missions[5]}\n
7.  ${manittoList[i].$1.missions[6]}\n
8.  ${manittoList[i].$1.missions[7]}\n
9.  ${manittoList[i].$1.missions[8]}\n
10. ${manittoList[i].$1.missions[9]}\n
''',
        );
      }

      _createExcel(manittoList);

      if (_saveExcelFile(excel) != null) {}
    } catch (e) {
      print(e);
    }
    debugPrint("success");
    return true;
  }

  /// 엑셀 파일 생성
  int _createExcel(List<(Member, Member)> data) {
    Sheet sheetObject = excel['Get Manitto'];

    List<String> columnTitles = ['Name', 'Manitto', 'Mission'];

    for (int i = 0; i < columnTitles.length; i++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(columnTitles[i]);
    }

    for (int row = 0; row < data.length; row++) {
      // EventEnrollment 객체를 Excel '행'(row)으로 변환
      var rowData = [
        data[row].$1.name,
        data[row].$2.name,
        data[row].$1.missions,
      ];

      // '행'을 셀에 추가해준다.
      for (int col = 0; col < rowData.length; col++) {
        var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
        );
        cell.value = TextCellValue(rowData[col].toString());
      }
    }

    return 0;
  }

  /// 엑셀 파일 저장
  Future<String?> _saveExcelFile(Excel excel) async {
    String filename = 'Manitto_List.xlsx';

    if (kIsWeb) {
      var fileBytes = excel.save(fileName: filename);
    } else {
      String dir = Directory.current.path;
      String filePath = '$dir/$filename';

      // Excel 파일 저장
      File file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      //debugPrint(fileBytes.toString());

      return filePath;
    }

    return null;
  }

  /// 이메일 전송
  Future<void> _sendEmail({
    required String recipientName,
    required String recipient,
    required String subject,
    required String body,
    required String content,
  }) async {
    final String username = dotenv.get("GMAIL"); // Gmail 계정
    final String password = dotenv.get("GMAIL_PASSWORD"); // 앱 비밀번호

    String filePath = await _saveTextAsJpg(
      content,
      '$recipientName manitto.jpg',
    );

    // Gmail SMTP 설정
    final smtpServer = gmail(username, password);

    // 이메일 메시지 작성
    final message =
        Message()
          ..from = Address(username, 'PRIMITIVE')
          ..recipients.add(recipient) // 수신자 이메일
          ..subject = subject
          ..text = body
          ..attachments.add(FileAttachment(File(filePath)));

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
    } on MailerException catch (e) {
      print('Failed to send email: $e');
    }
  }

  /// 문자열을 JPG 이미지로 변환하여 저장하는 함수
  Future<String> _saveTextAsJpg(String text, String fileName) async {
    try {
      // 이미지 크기 설정
      const int width = 700;
      const int height = 900;

      // PictureRecorder를 이용하여 Canvas 생성
      final recorder = ui.PictureRecorder();
      final canvas = flutter.Canvas(
        recorder,
        flutter.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      );

      // 배경 그리기 (흰색)
      final paint = flutter.Paint()..color = flutter.Colors.white;
      canvas.drawRect(
        flutter.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        paint,
      );

      // 텍스트 스타일 설정
      final textPainter = flutter.TextPainter(
        text: flutter.TextSpan(
          text: text,
          style: flutter.TextStyle(color: flutter.Colors.black, fontSize: 20),
        ),
        textDirection: flutter.TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, flutter.Offset(50, 90));

      // 이미지로 변환
      final picture = recorder.endRecording();
      final img = await picture.toImage(width, height);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      // 저장할 경로 설정
      String dir = Directory.current.path;
      String filePath = '$dir/manitto_jpg/$fileName';

      // 파일 저장
      final file = File(filePath);
      await file.writeAsBytes(byteData!.buffer.asUint8List());

      print('JPG file saved: $filePath');
      return filePath;
    } catch (e) {
      print('Failed to save JPG file: $e');
      return '';
    }
  }
}
