package com.salvad0r.cold_river_express_app

import android.graphics.*
import android.os.Environment
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.text.TextUtils
import java.io.*

class Utils(length: Int) {
    var buf: ByteArray = ByteArray(length)
    var index: Int = 0

    companion object {
        private const val WIDTH_80 = 576
        private const val WIDTH_58 = 384

        val p0 = intArrayOf(0, 128)
        val p1 = intArrayOf(0, 64)
        val p2 = intArrayOf(0, 32)
        val p3 = intArrayOf(0, 16)
        val p4 = intArrayOf(0, 8)
        val p5 = intArrayOf(0, 4)
        val p6 = intArrayOf(0, 2)

        private val chartobyte = byteArrayOf(
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 0, 0,
            0, 10, 11, 12, 13, 14, 15
        )

        public fun byteArraysToBytes(data: Array<ByteArray>): ByteArray {
            val length = data.sumOf { it.size }
            return ByteArray(length).apply {
                var k = 0
                for (arr in data) {
                    for (byte in arr) {
                        this[k++] = byte
                    }
                }
            }
        }

        fun resizeImage(bitmap: Bitmap, w: Int, h: Int): Bitmap {
            val width = bitmap.width
            val height = bitmap.height
            val scaleWidth = w.toFloat() / width
            val scaleHeight = h.toFloat() / height

            return Bitmap.createBitmap(bitmap, 0, 0, width, height, Matrix().apply {
                postScale(scaleWidth, scaleHeight)
            }, true)
        }

        fun toGrayscale(bmpOriginal: Bitmap): Bitmap {
            val width = bmpOriginal.width
            val height = bmpOriginal.height
            val bmpGrayscale = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        
            val canvas = Canvas(bmpGrayscale)
            val paint = Paint()
            val colorMatrix = ColorMatrix().apply {
                setSaturation(0.0F)
            }
            
            paint.colorFilter = ColorMatrixColorFilter(colorMatrix)
            canvas.drawBitmap(bmpOriginal, 0f, 0f, paint)
        
            return bmpGrayscale
        }

        fun thresholdToBWPic(mBitmap: Bitmap): ByteArray {
            val width = mBitmap.width
            val height = mBitmap.height
            val pixels = IntArray(width * height)
            val data = ByteArray(width * height)
        
            mBitmap.getPixels(pixels, 0, width, 0, 0, width, height)
            format_K_threshold(pixels, width, height, data)
        
            return data
        }

        private fun format_K_threshold(orgpixels: IntArray, xsize: Int, ysize: Int, despixels: ByteArray) {
            var grayTotal = 0
            var k = 0
        
            // Calcola la somma totale dei valori di grigio
            for (i in 0 until ysize) {
                for (j in 0 until xsize) {
                    val gray = orgpixels[k] and 255
                    grayTotal += gray
                    k++
                }
            }
        
            // Calcola la media dei valori di grigio
            val grayAve = grayTotal / (ysize * xsize)
            k = 0
        
            // Applica la soglia ai pixel
            for (i in 0 until ysize) {
                for (j in 0 until xsize) {
                    val gray = orgpixels[k] and 255
                    despixels[k] = if (gray > grayAve) 0 else 1
                    k++
                }
            }
        }

        fun eachLinePixToCmd(src: ByteArray, nWidth: Int, nMode: Int): ByteArray {
            val nHeight = src.size / nWidth
            val nBytesPerLine = nWidth / 8
            val data = ByteArray(nHeight * (8 + nBytesPerLine))
            var k = 0
        
            for (i in 0 until nHeight) {
                val offset = i * (8 + nBytesPerLine)
                data[offset + 0] = 29
                data[offset + 1] = 118
                data[offset + 2] = 48
                data[offset + 3] = (nMode and 1).toByte()
                data[offset + 4] = (nBytesPerLine % 256).toByte()
                data[offset + 5] = (nBytesPerLine / 256).toByte()
                data[offset + 6] = 1
                data[offset + 7] = 0
        
                for (j in 0 until nBytesPerLine) {
                    if (k + 7 < src.size) {
                        data[offset + 8 + j] = (Utils.p0[src[k].toInt() and 0xFF] + 
                                              Utils.p1[src[k + 1].toInt() and 0xFF] + 
                                              Utils.p2[src[k + 2].toInt() and 0xFF] +
                                              Utils.p3[src[k + 3].toInt() and 0xFF] + 
                                              Utils.p4[src[k + 4].toInt() and 0xFF] + 
                                              Utils.p5[src[k + 5].toInt() and 0xFF] +
                                              Utils.p6[src[k + 6].toInt() and 0xFF] + 
                                              (src[k + 7].toInt() and 0xFF)).toByte()
                        k += 8
                    }
                }
            }
        
            return data
        }
    }
}
