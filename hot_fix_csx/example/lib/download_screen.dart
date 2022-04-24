/*
 * @Author: Cao Shixin
 * @Date: 2022-04-22 18:10:43
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-24 11:13:23
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:hot_fix_csx/download_manager/downloader_model.dart';
import 'package:hot_fix_csx/hot_fix_csx.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('下载管理demo'),
      ),
      body: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              ResourceProvider.instance.batchDownResource([
                ResourceModel(
                    url:
                        'https://focus-resource.oss-cn-beijing.aliyuncs.com/focus-autism/assets/videos/story.mp4',
                    name: '游戏训练背景介绍'),
                ResourceModel(
                    url:
                        'https://focus-resource.oss-accelerate.aliyuncs.com/focus-autism/assets/videos/nian_intro_video.mp4',
                    name: '年兽背景介绍'),
                ResourceModel(
                    url:
                        'https://focus-resource.oss-cn-beijing.aliyuncs.com/focus-autism/assets/videos/evaluation_video_1.mp4',
                    name: '测评视频1'),
                ResourceModel(
                    url:
                        'https://focus-resource.oss-cn-beijing.aliyuncs.com/focus-autism/assets/videos/evaluation_video_2.mp4',
                    name: '测评视频2'),
                ResourceModel(
                    url:
                        'https://focus-resource.oss-cn-beijing.aliyuncs.com/focus-autism/assets/videos/evaluation_video_3.mp4',
                    name: '测评视频3'),
              ]).then((result) {
                if (result.isProgressArchive) {
                  print('所有资源已经全部下载完成');
                }
              });
            },
            icon: const Icon(Icons.skip_next),
            label: const Text('点击下载试试看'),
          ),
          const Expanded(
            child: DownloadManagerScreen(),
            flex: 200,
          ),
          const Spacer(
            flex: 20,
          )
        ],
      ),
    );
  }
}
