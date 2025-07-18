// 字符串扩展方法
extension OssZipString on String {
  ///是否是 视频
  bool isVideo() {
    if (isEmpty) return false;
    return contains('.mp4') ||
        contains('.MP4') ||
        contains('.flv') ||
        contains('.FLV') ||
        contains('.3gp') ||
        contains('.3GP') ||
        contains('.avi') ||
        contains('.AVI') ||
        contains('.rm') ||
        contains('.RM') ||
        contains('.rmvb') ||
        contains('.RMVB') ||
        contains('.wmv') ||
        contains('.WMV') ||
        contains('.mov') ||
        contains('.MOV');
  }

  ///oss压缩路径  视频除外
  String ossZip({int height = 600}) {
    if (isEmpty) return '';
    if (isVideo()) return this;
    return '$this?x-oss-process=image/resize,h_$height,p_70';
  }

  ///先按照控件宽高 大的缩放，然后根据控件大小裁切
  ///@param {string} orginUrl 图片原地址
  ///@param {number} width 控件一倍的宽度
  ///@param {number} height 控件一倍的高度
  ///@param {number} scale 缩放的倍数，需要效果的时候可以放大点，比如1.5， 2，
  ///
  String ossZipBy({int width = 0, int height = 0, double scale = 1.0}) {
    if (isEmpty) return '';
    if (isVideo()) {
      return ossVideoZipBy(width: width, height: height, scale: scale);
    }
    var scaleWidth = int.parse((width * scale).toStringAsFixed(0)); //必须为Int
    var scaleHeight = int.parse((height * scale).toStringAsFixed(0)); //必须为Int
    if (scaleWidth > scaleHeight) {
      return '$this?x-oss-process=image/resize,w_$scaleWidth/crop,w_$scaleWidth,h_$scaleHeight,g_center';
    }
    return '$this?x-oss-process=image/resize,h_$scaleHeight/crop,w_$scaleWidth,h_$scaleHeight,g_center';
  }

  ///视频截帧 https://help.aliyun.com/document_detail/64555.html?spm=a2c4g.11186623.6.1486.3699ced2jq9oFU
  String ossVideoZipBy({int width = 0, int height = 0, double scale = 1.0}) {
    var scaleWidth = int.parse((width * scale).toStringAsFixed(0)); //必须为Int
    var scaleHeight = int.parse((height * scale).toStringAsFixed(0)); //必须为Int
    return '$this?x-oss-process=video/snapshot,t_1,m_fast,w_$scaleWidth,h_$scaleHeight,ar_auto';
  }
}
