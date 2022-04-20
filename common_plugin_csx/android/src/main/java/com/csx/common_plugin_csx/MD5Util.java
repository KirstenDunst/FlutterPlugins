package com.csx.common_plugin_csx;/*
 * @Author: Cao Shixin
 * @Date: 2022-04-19 11:45:59
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-19 11:49:06
 * @Description:
 */

import java.io.File;
import java.io.FileInputStream;
import java.security.MessageDigest;


public class MD5Util {

    protected static char hexDigits[] = {'0', '1', '2', '3', '4', '5', '6',
            '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};

    public synchronized static String getAgentMD5(String path) {
        File file = new File(path);
        if (!file.exists() || !file.isFile()) {
            System.out.println("文件不存在");
            return null;
        }
        MessageDigest digest = null;
        FileInputStream fis = null;
        try {
            digest = MessageDigest.getInstance("MD5");
            fis = new FileInputStream(file);
            byte[] buffer = new byte[1024];
            int numRead = 0;
            while ((numRead = fis.read(buffer)) > 0) {
                digest.update(buffer, 0, numRead);
            }
            fis.close();
        } catch (Exception e) {
			System.out.println("处理异常:"+e);
			return null;
        }

        return bufferToHex(digest.digest());
    }

    private static String bufferToHex(byte bytes[]) {
        return bufferToHex(bytes, 0, bytes.length);
    }

    private static String bufferToHex(byte bytes[], int m, int n) {
        StringBuffer stringbuffer = new StringBuffer(2 * n);
        int k = m + n;
        for (int l = m; l < k; l++) {
            appendHexPair(bytes[l], stringbuffer);
        }
        return stringbuffer.toString();
    }

    private static void appendHexPair(byte bt, StringBuffer stringbuffer) {
        char c0 = hexDigits[(bt & 0xf0) >> 4];// 取字节中高 4 位的数字转换,

        char c1 = hexDigits[bt & 0xf];// 取字节中低 4 位的数字转换
        stringbuffer.append(c0);
        stringbuffer.append(c1);
    }
}