package com.salvad0r.cold_river_express_app

import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;

import java.util.Hashtable;
import android.graphics.Bitmap;

import android.util.Log
import androidx.lifecycle.lifecycleScope

import androidx.annotation.RequiresApi

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothDevice
import android.content.Context;
import android.os.Handler;
import android.os.Bundle
import android.content.pm.PackageManager
import android.os.Build
import android.os.Looper
import android.Manifest
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity() {
    // Channel name
    private val CHANNEL = "com.Salvad0r.netum_printer";
    // Debug tag
    private val TAG = "Main_Activity";
    // Bluetooth adapter
    private var mBluetoothAdapter: BluetoothAdapter? = null;
    // QR Code size
    private val QR_WIDTH = 350;
    private val QR_HEIGHT = 350;

    private val REQUEST_BLUETOOTH_PERMISSIONS = 1

    private var mService: BluetoothService? = null

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "printQRCode") {
                val qrcodeId = call.argument<String>("qrcodeId") ?: ""

                lifecycleScope.launch {
                    val printResult = withContext(Dispatchers.IO) {
                        printBadge(qrcodeId)
                    }
                    result.success(printResult)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private fun printBadge(
        qrcodeId: String,
    ): Map<String, Any> {
        Log.v(TAG, "[netum] Prepping to send file to printer")

        // inizialyze printer

        // define here my configuration of printer

        // verify is bluetooth is enabled
        if (mBluetoothAdapter == null || !mBluetoothAdapter!!.isEnabled) {
            Log.e(TAG, "[netum] Bluetooth is not enabled")
            return mapOf("success" to false, "error" to "Bluetooth non abilitato")
        }


        try {
            // start communication
            Log.i(TAG, "[netum] Start communication")

            val data = createImage(qrcodeId)

            if (data.isNotEmpty()) {
                sendDataByte(data)
                sendDataByte(PrinterCommand.POS_Set_PrtAndFeedPaper(30) ?: ByteArray(0))
                sendDataByte(PrinterCommand.POS_Set_Cut(1) ?: ByteArray(0))
                sendDataByte(PrinterCommand.POS_Set_PrtInit())

                Log.i(TAG, "[netum] Print operation was successful")
                return mapOf("success" to true)
            } else {
                Log.e(TAG, "[netum] Data for printing is empty")
                return mapOf("success" to false, "error" to "Data for printing is empty")
            }
        } catch (e: Exception) {
            e.printStackTrace()
            return mapOf(
                "success" to false,
                "error" to e.message.orEmpty().ifEmpty { "Errore sconosciuto" }
            )
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    
        if (requestCode == REQUEST_BLUETOOTH_PERMISSIONS) {
            if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                Log.d("Bluetooth", "Permessi Bluetooth concessi!")
            } else {
                Log.e("Bluetooth", "Permessi Bluetooth negati!")
            }
        }
    }

    fun checkAndRequestPermissions(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { // Android 12+
            val permissions = arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT
            )
    
            val missingPermissions = permissions.filter {
                ContextCompat.checkSelfPermission(context, it) != PackageManager.PERMISSION_GRANTED
            }
    
            if (missingPermissions.isNotEmpty()) {
                ActivityCompat.requestPermissions(
                    context as android.app.Activity,
                    missingPermissions.toTypedArray(),
                    REQUEST_BLUETOOTH_PERMISSIONS
                )
            } else {
                Log.d(TAG, "[Bluetooth] All required Bluetooth permissions are granted")
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.i(TAG, "[netum] onCreate")

        super.onCreate(savedInstanceState)
        checkAndRequestPermissions(this)
        // Initialize Bluetooth adapter
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        mBluetoothAdapter = bluetoothManager.adapter

        if (mBluetoothAdapter == null) {
            Log.e(TAG, "[netum] Bluetooth is not available")
            finish()
        } else {
            Log.i(TAG, "[netum] Bluetooth is available")
        }
    }

	override fun onStart() {
        Log.i(TAG, "[netum] onStart")

		super.onStart();

        if (mService == null) { 
            val mHandler = Handler(Looper.getMainLooper())
            mService = BluetoothService(this,  mHandler)
            mService?.start()

            val bluetoothAdapter = mBluetoothAdapter

            if (bluetoothAdapter != null && bluetoothAdapter.isEnabled) {
                val pairedDevices: Set<BluetoothDevice> = bluetoothAdapter.bondedDevices
    
                if (pairedDevices.isNotEmpty()) {
                    for (device in pairedDevices) {
                        Log.d("Bluetooth", "Dispositivo accoppiato: ${device.name} - ${device.address}")
                    }
                    
                    // Supponiamo che vogliamo connetterci al primo dispositivo accoppiato
                    val deviceToConnect: BluetoothDevice = pairedDevices.first()
                    val deviceAddress = deviceToConnect.address
    
                    // Passa il dispositivo al tuo BluetoothService
                    mService?.connect(deviceToConnect)
                    Log.i(TAG, "[netum] Connected to device: ${deviceToConnect.name} - $deviceAddress")
                } else {
                    Log.d("Bluetooth", "Nessun dispositivo Bluetooth accoppiato trovato.")
                }
            } else {
                Log.d("Bluetooth", "Bluetooth non attivo o non supportato.")
            }

        }
	}

    private fun sendDataByte(data: ByteArray) {
        if (mService?.getState() != BluetoothService.STATE_CONNECTED) {
            Log.e(TAG, "[netum] Not connected")
            return
        }
        mService?.write(data)
    }

    private fun createImage( 
        qrcodeId: String,
    ): ByteArray {
        Log.i(TAG, "[netum] Start create QR image")
    
        try {
            val writer = QRCodeWriter()

            val hints = Hashtable<EncodeHintType, String>().apply {
                put(EncodeHintType.CHARACTER_SET, "utf-8")
            }
            
            val bitMatrix: BitMatrix = writer.encode(qrcodeId, BarcodeFormat.QR_CODE, QR_WIDTH, QR_HEIGHT, hints)
    
            val pixels = IntArray(QR_WIDTH * QR_HEIGHT)

            for (y in 0 until QR_HEIGHT) {
                for (x in 0 until QR_WIDTH) {
                    pixels[y * QR_WIDTH + x] = if (bitMatrix[x, y]) 0xff000000.toInt() else 0xffffffff.toInt()
                }
            }
    
            val bitmap = Bitmap.createBitmap(QR_WIDTH, QR_HEIGHT, Bitmap.Config.ARGB_8888).apply {
                setPixels(pixels, 0, QR_WIDTH, 0, 0, QR_WIDTH, QR_HEIGHT)
            }
    
            return POS_PrintBMP(bitmap, 384, 0)    
        } catch (e: WriterException) {
            Log.e(TAG, "[netum] Error generating QR code image: ${e.message}")
            return ByteArray(0)
        }
    }

    fun POS_PrintBMP(mBitmap: Bitmap, nWidth: Int, nMode: Int): ByteArray {
        val width = ((nWidth + 7) / 8) * 8
        var height = mBitmap.height * width / mBitmap.width
        height = ((height + 7) / 8) * 8
    
        val rszBitmap = if (mBitmap.width != width) {
            Utils.resizeImage(mBitmap, width, height)
        } else {
            mBitmap
        }
    
        val grayBitmap = Utils.toGrayscale(rszBitmap)
        val dithered = Utils.thresholdToBWPic(grayBitmap)


        Log.i(TAG, "[netum] Converting bitmap to command format with width: $width, mode: $nMode")
    
        val commandData = Utils.eachLinePixToCmd(dithered, width, nMode)
        Log.i(TAG, "[netum] Command data length: ${commandData.size}")
        
        return commandData
    }
}