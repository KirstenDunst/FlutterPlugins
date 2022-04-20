import android.app.Activity
import android.content.Context
import java.io.*
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream

// 工具类
class CommonTool {
    /**
     * 解压文件
     * 目前支持范围:无文件夹压缩包和带文件夹压缩包
     */
    fun unzip(applicationContext: Context, assetName: String, desDirectory: String) {
        var desDir = File(desDirectory)
        if (!desDir.exists()) {
            var mkdirSuccess = desDir.mkdir();
            if (!mkdirSuccess) {
                throw Exception("创建解压目标文件夹失败")
            }
        }
        // 读入流（第二个参数，处理压缩文件中文异常。如果没有中文，可以不写第二个参数）
        var inputStream: InputStream = applicationContext.assets.open(assetName)
        var zipInputStream = ZipInputStream(inputStream)
        // 遍历每一个文件
        var zipEntry = zipInputStream.nextEntry
        while (zipEntry != null) {

            var unzipFilePath = desDirectory + File.separator + zipEntry.name
            if (zipEntry.isDirectory) {
                // 直接创建（注意，不是使用系统的mkdir,自定义方法）
                mkdir(File(unzipFilePath))
            } else {
                var file = File(unzipFilePath)
                // 创建父目录（注意，不是使用系统的mkdir,自定义方法）
                mkdir(file.parentFile)
                // 写出文件
                var bufferedOutputStream = BufferedOutputStream(FileOutputStream(unzipFilePath))
                val bytes = ByteArray(1024)
                var readLen: Int
                // Java 与 Kotlin的不同之处，需要特别关注。
                // while ((readLen = zipInputStream.read(bytes))!=-1){
                while (zipInputStream.read(bytes).also { readLen = it } > 0) {
                    bufferedOutputStream.write(bytes, 0, readLen)
                }
                bufferedOutputStream.close()
            }
            zipInputStream.closeEntry()
            zipEntry = zipInputStream.nextEntry
        }
    }

    /**
     * 创建文件夹
     */
    private fun mkdir(file: File) {
        if (null == file || file.exists()) {
            return
        } else {
            file.parentFile.mkdir()
            file.mkdir()
        }
    }

    fun zipAll(directory: String, zipFile: String) {
        val sourceFile = File(directory)

        ZipOutputStream(BufferedOutputStream(FileOutputStream(zipFile))).use {
            it.use {
                zipFiles(it, sourceFile, "")
            }
        }
    }

    private fun zipFiles(zipOut: ZipOutputStream, sourceFile: File, parentDirPath: String) {
        val data = ByteArray(2048)
        for (f in sourceFile.listFiles()) {
            if (f.isDirectory) {
                val entry = ZipEntry(f.name + File.separator)
                entry.time = f.lastModified()
                entry.isDirectory
                entry.size = f.length()

                zipOut.putNextEntry(entry)
                //Call recursively to add files within this directory
                zipFiles(zipOut, f, f.name)
            } else {
                if (!f.name.contains(".zip")) { //If folder contains a file with extension ".zip", skip it
                    FileInputStream(f).use { fi ->
                        BufferedInputStream(fi).use { origin ->
                            val path = parentDirPath + File.separator + f.name

                            val entry = ZipEntry(path)
                            entry.time = f.lastModified()
                            entry.isDirectory
                            entry.size = f.length()
                            zipOut.putNextEntry(entry)
                            while (true) {
                                val readBytes = origin.read(data)
                                if (readBytes == -1) {
                                    break
                                }
                                zipOut.write(data, 0, readBytes)
                            }
                        }
                    }
                } else {
                    zipOut.closeEntry()
                    zipOut.close()
                }
            }
        }
    }

    /**
     * 文件拷贝，项目文件拷贝到设备本地
     */
    fun copyResourceToLocal(applicationContext: Context, assetName: String, targetPath: String) {
        //读取assets中的文件
        var inputStream: InputStream = applicationContext.assets.open(assetName)
        //保存到手机
        val file = File(targetPath)
        val fos = FileOutputStream(file)
        var bytes: ByteArray = ByteArray(1024)
        var byteCount: Int = inputStream.read(bytes)
        while (byteCount !== -1) {
            fos.write(bytes, 0, byteCount)
            byteCount = inputStream.read(bytes)
        }
        fos.flush()
        inputStream.close()
        fos.close()
    }
}