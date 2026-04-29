import 'package:doraemonkit_csx/utils/num_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vm_service/vm_service.dart';
import '../apm.dart';
import '../csx_dokit.dart';
import '../kit.dart';
import 'vm_helper.dart';

class MemoryInfo implements IInfo {
  int fps;
  String? pageName;
  MemoryInfo(this.fps);

  @override
  int getValue() {
    return fps;
  }
}

class MemoryKit extends ApmKit {
  int lastFrame = 0;

  @override
  String getKitName() {
    return ApmKitName.kitMemory;
  }

  @override
  String getIcon() {
    return 'assets/images/dk_ram.png';
  }

  @override
  void start() async {
    VmHelper vmHelper = VmHelper.instance;
    await vmHelper.startConnect();
    vmHelper.updateMemoryUsage();
  }

  void update() {
    VmHelper.instance.dumpAllocationProfile();
    VmHelper.instance.resolveFlutterVersion();
    VmHelper.instance.updateMemoryUsage();
  }

  AllocationProfile? getAllocationProfile() {
    return VmHelper.instance.allocationProfile;
  }

  @override
  void stop() {
    VmHelper.instance.disConnect();
  }

  @override
  IStorage createStorage() {
    return CommonStorage(maxCount: 120);
  }

  @override
  Widget createDisplayPage() {
    return MemoryPage();
  }
}

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MemoryPageState();
  }
}

class MemoryPageState extends State<MemoryPage> {
  MemoryKit? kit = ApmKitManager.instance.getKit<MemoryKit>(
    ApmKitName.kitMemory,
  );
  List<ClassHeapStats> heaps = [];
  TextEditingController editingController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    kit?.update();
    initHeaps();
  }

  void initHeaps() {
    if (kit?.getAllocationProfile() != null) {
      kit?.getAllocationProfile()?.members?.sort(
            (left, right) =>
                right.bytesCurrent != null && left.bytesCurrent != null
                    ? right.bytesCurrent!.compareTo(left.bytesCurrent!)
                    : 0,
          );
      kit?.getAllocationProfile()?.members?.forEach((element) {
        if (heaps.length < 32) {
          heaps.add(element);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Memory Info',
                  style: TextStyle(
                    color: Color(0xff333333),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                StreamBuilder(
                  stream: Stream.periodic(Duration(seconds: 2), (value) {
                    VmHelper.instance.dumpAllocationProfile();
                    VmHelper.instance.updateMemoryUsage();
                  }),
                  builder: (context, snapshot) {
                    return Container(
                      margin: EdgeInsets.only(top: 3),
                      alignment: Alignment.topLeft,
                      child: VmHelper.instance.memoryInfo.isNotEmpty
                          ? Column(
                              children: getMemoryInfo(
                                VmHelper.instance.memoryInfo,
                              ),
                            )
                          : Text(
                              '获取Memory数据失败(release模式下无法获取数据)',
                              style: TextStyle(
                                color: Color(0xff999999),
                                fontSize: 12,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 13),
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xff337cc4),
                  width: 0.5,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: TextField(
                      controller: editingController,
                      style: TextStyle(color: Color(0xff333333), fontSize: 16),
                      onSubmitted: (value) => {filterAllocations()},
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Color(0xffbebebe),
                          fontSize: 16,
                        ),
                        hintText: '输入类名，查看内存占用',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: ElevatedButton(
                      onPressed: filterAllocations,
                      child: Image.asset(
                        'assets/images/dk_memory_search.png',
                        height: 16,
                        width: 16,
                        package: dkPackageName,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              height: 34,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: Color(0xff337cc4),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Size',
                      style: TextStyle(color: Color(0xffffffff), fontSize: 14),
                    ),
                  ),
                  VerticalDivider(width: 0.5, color: Color(0xffffffff)),
                  Container(
                    width: 80,
                    decoration: BoxDecoration(color: Color(0xff337cc4)),
                    alignment: Alignment.center,
                    child: Text(
                      'Count',
                      style: TextStyle(color: Color(0xffffffff), fontSize: 14),
                    ),
                  ),
                  VerticalDivider(width: 0.5, color: Color(0xffffffff)),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff337cc4),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width - 193,
                    alignment: Alignment.center,
                    child: Text(
                      'ClassName',
                      style: TextStyle(color: Color(0xffffffff), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 200 - 210,
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: heaps.length,
                itemBuilder: (context, index) {
                  return HeapItemWidget(item: heaps[index], index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void filterAllocations() {
    var className = editingController.text;
    heaps.clear();
    if (className.length >= 3 && kit?.getAllocationProfile() != null) {
      kit?.getAllocationProfile()?.members?.forEach((element) {
        if ((element.classRef?.name?.toLowerCase() ?? '').contains(
          className.toLowerCase(),
        )) {
          heaps.add(element);
        }
      });
      heaps.sort(
        (left, right) => right.bytesCurrent != null && left.bytesCurrent != null
            ? right.bytesCurrent!.compareTo(left.bytesCurrent!)
            : 0,
      );
    }
    setState(() {});
  }

  List<Widget> getMemoryInfo(Map<IsolateRef, MemoryUsage> map) {
    List<Widget> widgets = <Widget>[];
    map.forEach((key, value) {
      widgets.add(
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'IsolateName: ',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xff333333),
                  height: 1.5,
                ),
              ),
              TextSpan(
                text: '${key.name}',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xff666666),
                ),
              ),
              TextSpan(
                text: '\nHeapUsage: ',
                style: TextStyle(
                  height: 1.5,
                  fontSize: 10,
                  color: Color(0xff333333),
                ),
              ),
              TextSpan(
                text: '${value.heapUsage?.byteFormat()}',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xff666666),
                ),
              ),
              TextSpan(
                text: '\nHeapCapacity: ',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xff333333),
                ),
              ),
              TextSpan(
                text: '${value.heapCapacity?.byteFormat()}',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xff666666),
                ),
              ),
              TextSpan(
                text: '\nExternalUsage: ',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xff333333),
                ),
              ),
              TextSpan(
                text: '${value.externalUsage?.byteFormat()}',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: Color(0xff666666),
                ),
              ),
            ],
          ),
        ),
      );
    });
    return widgets;
  }
}

class HeapItemWidget extends StatelessWidget {
  final ClassHeapStats item;
  final int index;

  const HeapItemWidget({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: index % 2 == 1 ? Color(0xfffafafa) : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 80,
            alignment: Alignment.center,
            child: Text(
              '${item.bytesCurrent?.byteFormat()}',
              style: TextStyle(color: Color(0xff333333), fontSize: 12),
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.center,
            child: Text(
              '${item.instancesCurrent}',
              style: TextStyle(color: Color(0xff333333), fontSize: 12),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 193,
            alignment: Alignment.center,
            child: Text(
              '${item.classRef?.name}',
              style: TextStyle(color: Color(0xff333333), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
